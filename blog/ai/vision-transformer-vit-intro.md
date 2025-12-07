# Vision Transformer（ViT）入门：把图像“变成序列”

### 先把结论说在前面：

ViT = 把图片当“句子”、把小块当“单词”，然后扔进 Transformer 里做全局建模的视觉编码器。
它解决的是：CNN 看不远、建模不够全局、扩展性/迁移性差的问题。

⸻

## 一、为什么会有 ViT：图片也能像句子一样读吗？

ViT 全称 Vision Transformer，出自 2020 年 Google 的论文

> An Image is Worth 16x16 Words

这句话的意思很直白：一张图，可以拆成很多 16×16 像素的小块，每个小块就像文本里的一个“单词”。
既然文本能用 Transformer 干翻 RNN，那视觉为什么不能也试试呢？

在 ViT 之前，视觉领域主角一直是 CNN（ResNet、VGG、Inception…），但 CNN 有几个结构性短板：
1. 感受野有限：

  - 卷积核一般是 3×3、5×5 的小窗口；
  - 想看到更大区域，只能一层一层堆，
  - 堆多了训练难、信息中途丢失严重。

2. 全局建模能力弱：

  - CNN 天然强调“局部相关、平移不变”；
  - 相距很远的两个区域之间的关系，很难被直接建模；
  - 对于“整体布局”“跨区域逻辑关系”理解不够好。

3. 扩展性一般、架构设计很手工：

  - 想变大，就堆更多层、更多通道，参数和算力飞涨；
  - 各种 Block 设计很“手艺活”，迁移到新任务要重新调结构。

4. 跨任务迁移能力有限：

  - 在一个数据集上训练的 CNN，迁移到另一个任务时，经常需要大幅微调甚至重训；
  - 对下游任务的“通用性”不够强。

NLP 这边，Transformer 早就靠**自注意力机制（Self-Attention）**解决了“长距离依赖”和“大模型扩展”的问题。
ViT 的核心想法就是：把图片伪装成一串“token 序列”，让 Transformer 来做视觉。

⸻

## 二、ViT 总体结构：一张图进来，如何变成“序列”？

可以先把 ViT 想象成一个三段式流水线：

```
原始图像 → [图像切块] → [Patch Embedding + 位置编码 + CLS] → [Transformer Encoder] → 任务输出
```

**更具体点：**

### 1. Image Patching（切块）
- 把图片切成一块块小 patch，每块看成一个“视觉单词”。

### 2. Patch Embedding + CLS Token + 位置编码
- 每个 patch 变成一个固定维度的向量（embedding）；
- 前面加一个特殊的 [CLS] Token，负责聚合全局信息；
- 再加上位置编码，告诉模型“谁在左谁在右”。
- 注：`CLS` 是 “Classification” 的缩写，是一个可学习的序列首 token，用于聚合全局图像信息；分类任务通常读取它的输出向量。

### 3. Transformer Encoder
- 多层 Self-Attention + FFN；
- 每个 patch 都能和所有 patch 互相“看”；
- 最后拿 CLS 向量去做分类，或者拿所有 patch 表示去做检测、分割等任务。

下面逐步展开。

⸻

## 三、第一步：Image Patching —— 把图片“切成单词”

假设输入图片大小是 H × W × 3（RGB 三通道），ViT 会做：
1.	选择一个 patch 大小，比如论文中的 16×16；
2.	按网格方式切成不重叠的 patch：
    - 横向有 W / P 个 patch；
    - 纵向有 H / P 个 patch；
    - 总 patch 数量：N = (H / P) × (W / P)。

每个 patch 的大小是：P × P × 3。
在代码里一般会把 patch 展平成一个长向量，长度为 P × P × 3。

直观理解：
- 原图就像一整页文章；
- patch 就是这篇文章里的“词”；
- 后续 Transformer 看的就是这一串“词序列”。

⸻

## 四、第二步：Patch Embedding + CLS Token —— 让 patch 变成“向量词表”

仅仅是展平还是一堆像素值，维度大且不抽象。ViT 会再做一步 线性投影（Linear Projection）：
1. 对每个展平后的 patch（长度 P×P×3）接一个可学习的全连接层：

    ```
    patch_vector (P×P×3) → Linear → d 维向量
    ```

2. 这一步的输出叫做 Patch Embedding，得到一个形状为：

    ```
    [N, d]  // N 个 patch，每个是 d 维
    ```


接下来，两件重要的事：

1）加一个 CLS Token
- 类似 BERT 里的 [CLS]；
- 是一个同为 d 维的可学习向量；
- 会和所有 patch 一起被送进 Transformer 做交互；
- 最后分类任务就直接用 CLS 的输出向量去接线性分类器。

此时序列长度从 N 变为 N + 1：

```
[CLS], patch1, patch2, ..., patchN
→ 形状：[N+1, d]
```

2）加入位置编码（Positional Encoding）

Transformer 本身不懂“顺序”，它只看一堆向量。
但图片里的空间关系（左/右/上/下）显然很重要，所以要给每个位置一个“标签”：
- 为每个序列位置（包括 CLS）分配一个可学习的位置向量 pos[i]；
- 直接和对应的 patch embedding 相加：

```
z0[i] = patch_embed[i] + pos_embed[i]
```

这一步完成后，Transformer 就知道“这是第几个 patch”，从而间接知道大概的空间位置。

---

## 五、第三步：Transformer Encoder —— 让每个 patch“互相看见”

有了带位置的序列，剩下就是 NLP 那套 Transformer Encoder：
- 堆 L 层 Encoder Block；
- 每层包括：
	1.	Multi-Head Self-Attention（多头自注意力）
	2.	FFN 前馈网络
	3.	LayerNorm + 残差连接

Self-Attention 在图像里的意义：
- 对于某个 patch，它的注意力可以直接连到任何一个 patch（不管距离多远）；

- 这意味着：
- 物体的头和尾之间的关系可以更直接地建模；
- 背景和前景、不同物体之间的相互作用也能表达出来；
- 模型能更自然地理解“全局布局”和“整体语义”。

经过 L 层 Encoder 后：
- 对于分类任务：
- 拿 CLS Token 的输出向量 z_L[CLS]，接一个线性层，输出类别 logits；
- 对于检测/分割/其他密集任务：
- 一般会用 所有 patch 的输出，作为特征图的“补丁级表示”，再接 detection head / segmentation head 等。

⸻

## 六、ViT 在 VLM（视觉语言模型）里的角色：一个高质量的“视觉前端”

现代的 VLM（如各种多模态大模型）普遍有三段结构：

```
[视觉编码器] —— [多模态连接器] —— [大语言模型（LLM）]
```

在这个流水线里，ViT 扮演的就是“视觉编码器”：
1.	视觉编码器（ViT）
  - 输入：一张或多张图片；
  - 输出：图片的特征矩阵（每个 patch 一个向量，或者 CLS 特征）；
  - 这些特征包含了全局语义 + 局部细节。
2.	多模态连接器（Projector / Connector）
  - 把 ViT 的视觉特征映射到 LLM 的语义空间；
  - 做维度对齐、空间对齐（比如从 d_vit 映射到 d_llm）；
  - 有时会做对比学习（contrastive learning），让图像和文本的 embedding 更接近。
3.	大语言模型（LLM）
  - 把“视觉特征 + 文本问题”拼到一起当输入；
  - 结合上下文生成回答、描述、代码等。

在这个过程中：
- ViT 的质量决定了模型“看得清不清楚、看得懂不懂”；
- 对比学习 + ViT 常用于增强图文对齐效果，如 CLIP 系列；
- 为了适配不同尺寸图片，研究者还会玩 可变 patch 大小、自适应分辨率、多尺度输出 等花样，以兼顾全局语义和本地细节。

⸻

## 七、ViT 的输入与输出：从单张图到多任务

1. 输入：主要是 RGB 图像（也可以是多张）

最基础的输入就是标准的 RGB 图像，形状 H × W × 3。
常见预处理步骤：
- 调整分辨率到模型支持的大小（如 224×224）；
- 标准化（减 ImageNet 均值、除以标准差）；
- 可能做数据增强（随机裁剪、翻转、颜色抖动等）。

在多模态场景下：
- ViT 也可以同时编码多张图，比如对一组图的关系做推理，
- 通常的做法是把多张图片各自通过 ViT，再在连接器或 LLM 里融合。

2. 输出：完全看任务类型

图像分类（最经典）
- 输出：一个长度为 num_classes 的向量；
- 通常使用 CLS 作为图像整体表示：

```
logits = Linear(z_L[CLS])  // z_L[CLS] 是最后一层 CLS 特征
```

- 通过 softmax 得到类别概率。

VLM / 多模态任务
- 输出：每个 patch 的特征矩阵，形状大概类似 [N_patches, d]（再加一个 CLS）；
- 连接器会从这些特征中选择：
- 只取 CLS，或者
- 取所有 patch，甚至
- 取多层（中间层 + 最后一层）做多尺度特征。

检测 / 分割等密集预测任务
- ViT 输出每个 patch 的特征（可以看作低分辨率的 feature map）；
- 再加上：
- 检测头（Detection Head），预测每个 patch 上/附近的边界框和类别；
- 分割头（Segmentation Head），上采样回像素级、预测每个点的类别。

在很多现代架构里：
- 会从 ViT 的中间层 + 最后一层同时取特征：
- 最后一层：语义最强，适合分类、全局判断；
- 中间层：保留更多细节，适合分割、关键点检测等。

⸻

## 八、ViT 相对 CNN 的优缺点：该怎么选？

### 优点：
1.	天然全局建模：
  - Self-Attention 让每个 patch 都能和所有 patch 交互，适合捕捉远距离依赖。
2.	扩展性好：
  - 模型结构非常统一，主要调参：层数、头数、维度；
  - 很适合直接“堆大”，做大规模预训练，再迁移到下游任务。
3.	迁移性强：
  - 在超大数据（比如私有数据或 JFT 等）上预训练后，
  - 微调到各种视觉任务（分类、检测、分割、多模态）效果都很好。
4.	和 Transformer 生态协同：
  - 方便与文本 Transformer（LLM）对接；
- 多模态模型设计简单很多。

### 缺点/挑战：
1.	对数据量要求高：
  - 纯 ViT 在小数据集上训练，容易过拟合；
  - 很多工作用数据增强、蒸馏或 CNN 先验来缓解。
2.	对高分辨率图像算力敏感：
  - 自注意力是 O(N²)（N 是 patch 数），分辨率上去 patch 数量暴增；
  - 需要一些工程/结构优化（比如分层 ViT、局部注意力等）。
3.	局部归纳偏置较弱：
  - CNN 天然擅长局部模式识别（比如平移不变特性），
  - ViT 需要通过数据和训练来“学会”这些先验，效率稍差。

⸻

## 九、给工程师的 mental model：怎么快速记住 ViT？

可以用一句话 + 一张“脑补流程”来记：

一句话：
把图片拆成 patch 序列 → 每个 patch 像 token 一样 embedding → 加 CLS + 位置编码 → 扔进 Transformer Encoder → 根据任务读取 CLS 或所有 patch。

脑补流程：

```
[H×W×3 图像]
  └─ 切块 (P×P) → N 个 patch
      └─ 展平 + 线性投影 → [N, d] patch embeddings
          └─ 拼 CLS → [N+1, d]
              └─ 加位置编码 → [N+1, d]
                  └─ L 层 Transformer Encoder
                      ├─ 分类：取 CLS 向量 → Linear → 类别
                      ├─ 检测/分割：取所有 patch 向量 → Head
                      └─ VLM：取 CLS/所有 patch → 多模态连接器 → LLM
```

把这张脑图刻在脑子里，看到任何 ViT 的变体，大部分都可以归结为：
- 怎么切 patch（大小/自适应/多尺度）；
- 怎么设计位置编码；
- Transformer 本身有没有改造（层数、注意力形式等）；
- 输出怎么被下游任务消费。

⸻

## 十、小结与延伸

这一篇我们从 “为什么要 ViT” → “ViT 怎么把图变成序列” → “Transformer 如何做全局建模” → “VLM 中的角色与输入输出” 走了一遍：
- ViT 把 CNN 的局部卷积变成全局自注意力；
- 把“图像”拆成“patch 序列”，复用了 NLP 的 Transformer 框架；
- 在多模态时代，ViT 通常作为 VLM 的视觉编码器，把“看图”这件事做好；
- 下游任务只需要换一个“头”，就能复用同一套视觉 backbone。

如果你已经搞清楚 ViT 的这三步：切块 → Embedding + 位置编码 → Transformer Encoder，
基本就拿到了理解各种 Vision Transformer 变种（Swin、DeiT、MAE、各种多模态 ViT）的“钥匙”。
