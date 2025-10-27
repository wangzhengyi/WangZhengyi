# Compose 登陆鸿蒙：字节 ByteKMP 的原生渲染方案全解析

- 作者：王正一（懂车帝客户端负责人）
- 面向读者：Android / Kotlin 开发者
- 平台：CSDN

---

## 摘要
- ByteKMP 将 Compose 渲染从 Skia 迁移到鸿蒙 ArkUI 的原生绘制体系，解决包体与内存问题。
- 通过 ArkTS + FFI + C++ 封装（OHRender）打通跨语言渲染链路，保持性能与可复用性。
- 文内拆解架构、渲染流程、脏区刷新、实测收益与工程启示，并给出发布建议与配图占位。

## 关键词
- Compose、ByteKMP、ArkUI、HarmonyOS、Skia、FFI、渲染链路、脏区刷新

---

## 目录
- 前言
- 问题起点：为什么要改掉 Skia
- 新架构：Compose → ArkUI 的三层结构
- 项目结构：SourceSet 与鸿蒙适配层
- 渲染流程：绑定与帧回调刷新
- 脏区管理：增量绘制与缓存机制
- 性能收益：包体、内存、FPS 与演进
- 总结与启示
- 后记：一图总结
- 结尾引导与配图建议

---

## 前言
Compose 是 Google 推出的声明式 UI 框架，已在 Android、iOS、桌面与 Web 多平台运行。鸿蒙（HarmonyOS）使用自研的 ArkUI 渲染体系，并不支持 Compose 默认的 Skia 引擎。ByteKMP 的目标是在鸿蒙上让 Compose“跑原生渲染”，既保持性能，又解决包体和内存的痛点。

---

## 问题起点：为什么要改掉 Skia
- 在 Android 上，Compose 底层绘制由 Skia 完成，Chrome/Flutter 也使用 Skia。
- 迁移到鸿蒙的现实问题：
  - 包体过大：引入 Skia 库体积增加数 MB；
  - 内存占用高：Skia Graph 内存叠加，页面复用易造成额外的几十 MB；
  - OOM 风险：复杂业务下（如 Feed/评测页）内存压力明显。
- 字节实测：每个全屏 Compose 页额外占用约 55MB。
- 结论：既然鸿蒙原生提供 Native Drawing 能力，就用原生绘制替代 Skia。

---

## 新架构：Compose → ArkUI 的三层结构
- 设计思路：在 Compose 渲染链路中插入 ArkUI 适配层。
- 三层结构：

| 层级 | 模块 | 作用 |
| --- | --- | --- |
| Kotlin 层 | Compose / Harko | 管理 UI 状态与组件 |
| C++ 层 | OHRender | 封装 ArkUI 的 Native Drawing 接口 |
| ArkTS 层 | Native Drawing | 实际执行绘制（GPU / Canvas） |

- 渲染链路：`Compose → Harko → OHRender → ArkTS Native Drawing`
- 要点：上层仍写 Kotlin；底层绘制不走 Skia，直接落到鸿蒙原生绘图系统。

---

## 项目结构：SourceSet 与鸿蒙适配层
- KMP 工程的 SourceSet：
```
commonMain/
androidMain/
iosMain/
jsMain/
```
- Compose 的典型平台层级：
  - `skikoMain`：Skia 绘制；
  - `jsNative`：Web 端。
- 鸿蒙适配新增：`ohosMain (harko)`。
- 结构示意：`Compose Common → jb → skiko / harko → ArkUI`
- 总结：鸿蒙端等价于新增一套 Compose 渲染实现，不依赖 Skia。

---

## 渲染流程：绑定与帧回调刷新
整个过程分两阶段。

### 阶段一：内容绑定（初次渲染）
1. ArkTS 层创建 Compose 容器 View（`ComposeView`）。
2. Kotlin 层通过 FFI（跨语言接口）创建 `RenderNode`。
3. `ComposeController` 根据 ID 找到对应的 `@Composable` 内容。
4. `RenderingUIView` 承载 Compose 内容并生成 `ComposeScene`。
5. 调用 `ComposeScene.setContent()` 启动绘制。

一句话理解：鸿蒙的 View 容器通过 FFI，把 Compose 的渲染内容“绑定”上去。

### 阶段二：帧回调与刷新（状态变化）
1. 当 `mutableState` 变化时，触发 `invalidate()` 请求重绘。
2. ArkTS 注册 `FrameCallback`（鸿蒙 vsync 帧机制）。
3. 下一帧触发 `onFrame()`，回调到 Kotlin 层。
4. Kotlin 调用 `onDraw()`，执行 Compose 渲染逻辑并刷新画面。

---

## 脏区管理：增量绘制与缓存机制
Compose 使用 `PictureRecorder` 缓存上次绘制结果，仅在内容变化时增量刷新。

```kotlin
if (picture == null) {
    pictureCanvas = pictureRecorder.beginRecording()
    drawContent(pictureCanvas)
    picture = pictureRecorder.finishRecordingAsPicture()
}
canvas.drawPicture(picture)

// 某区域变化
override fun invalidate() {
    picture = null
}
```

- 这就是脏区刷新（Dirty Region）：让 Compose 性能更接近 Android View 的增量绘制。

---

## 性能收益：包体、内存、FPS 与演进
迁移测试的对比结论如下：

| 项 | Skia 方案 | ArkUI 方案 | 优化效果 |
| --- | --- | --- | --- |
| 包体 | +3MB | ✅ -3MB | 体积更小 |
| 内存 | +57.5MB | ✅ 大幅下降 | Graph 内存释放 |
| OOM 风险 | 高 | ✅ 基本解决 | 稳定性提升 |
| FPS (120Hz) | 100% | 85~90% | 目前有 10~15% 差距 |
| FPS (60Hz) | ≈ 持平 | ✅ | 基本一致 |

- FPS 差距的主要原因：鸿蒙当前缺少部分 CAPI（底层接口）。
- 进展：已与鸿蒙官方协作确认，后续系统会补齐接口，FPS 预计回到 Skia 水平。

---

## 总结与启示
- 适配的主要价值：

| 方向 | 价值 |
| --- | --- |
| 架构 | 完成 Kotlin Compose → ArkUI 的全链路打通 |
| 性能 | 解决包体、内存与 OOM 三大痛点 |
| 稳定性 | Compose 页面可大规模复用 |
| 生态 | 为鸿蒙 Compose 打开跨平台生态一环 |

- 对 Android 开发者的启示：
  - 渲染不是黑盒，理解 UI 的“绘制链路”很重要；
  - Kotlin/Compose 并不绑定 Skia，可以接入任意原生绘制系统；
  - 鸿蒙 ArkUI 正在完善跨语言 CAPI，这对未来 Compose KMP 一致性至关重要。

---

## 后记：一图总结
```
Compose (Kotlin)
   ↓
Harko (Kotlin wrapper)
   ↓
OHRender (C++)
   ↓
ArkUI Native Drawing (ArkTS)
   ↓
GPU / Canvas 渲染
```

一句话概括：从 Skia 到 ArkUI，Byte 把 Compose 带入鸿蒙原生世界——这不仅是平台适配，更是跨语言渲染链路的重构。

---

## 结尾引导与配图建议
- 如果这篇文章对你有帮助，请点赞、收藏、关注我；后续将持续更新 ByteKMP 与鸿蒙适配的工程实践。
- 欢迎评论交流你的渲染问题与优化思路，我会选典型案例做专文解析。
- 配图建议（可在 CSDN 上传）：
  - 渲染链路图：Compose → Harko → OHRender → ArkTS。
  - 帧回调时序图：`invalidate()` → `FrameCallback` → `onFrame()` → `onDraw()`。
  - 脏区刷新示意图：首次录制与增量复绘对比。