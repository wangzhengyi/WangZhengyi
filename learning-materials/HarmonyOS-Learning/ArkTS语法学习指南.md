# ArkTS 语法学习指南

## 基础语法

### 变量声明
```typescript
let message: string = "Hello World";
const PI: number = 3.14159;
var isVisible: boolean = true;
```

### 函数定义
```typescript
function greet(name: string): string {
  return `Hello, ${name}!`;
}

// 箭头函数
const add = (a: number, b: number): number => a + b;
```

### 类和接口
```typescript
interface Person {
  name: string;
  age: number;
}

class Student implements Person {
  name: string;
  age: number;
  
  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }
}
```

## HarmonyOS 特有语法

### 组件装饰器
```typescript
// @Entry 标记应用入口组件
@Entry
// @Component 标记自定义组件
@Component
struct Index {
  // 组件内容
}
```

### 状态管理装饰器
```typescript
@Component
struct MyComponent {
  // @State 管理组件内部状态
  @State message: string = 'Hello World';
  
  // @Prop 接收父组件传递的属性
  @Prop title: string;
  
  // @Link 双向数据绑定
  @Link count: number;
  
  // @Provide/@Consume 跨组件层级传递数据
  @Provide('theme') theme: string = 'light';
}
```

## 实际项目语法分析

### 1. 页面组件结构（基于HelloWorld项目）
```typescript
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}
```

**语法要点：**
- `@Entry` + `@Component`：标记入口页面组件
- `@State`：响应式状态变量，变化时自动更新UI
- `build()`：组件构建方法，返回UI描述
- `RelativeContainer()`：相对布局容器
- `$r()`：资源引用语法
- 链式调用：组件属性设置采用链式语法
- 事件处理：`.onClick(() => {})`

### 2. Ability类结构
```typescript
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }
}
```

**语法要点：**
- Kit导入：`@kit.AbilityKit`、`@kit.PerformanceAnalysisKit`等
- 类继承：`extends UIAbility`
- 生命周期方法：`onCreate`、`onWindowStageCreate`等
- 日志输出：`hilog.info()`、`hilog.error()`
- 页面加载：`windowStage.loadContent()`

## 布局组件语法

### 容器组件
```typescript
// 相对布局
RelativeContainer() {
  // 子组件
}

// 线性布局
Column() {
  // 垂直排列
}

Row() {
  // 水平排列
}

// 弹性布局
Flex({ direction: FlexDirection.Column }) {
  // 子组件
}
```

### 基础组件
```typescript
// 文本组件
Text('Hello')
  .fontSize(16)
  .fontColor(Color.Black)
  .fontWeight(FontWeight.Bold)

// 按钮组件
Button('Click Me')
  .onClick(() => {
    // 点击事件
  })

// 图片组件
Image($r('app.media.icon'))
  .width(100)
  .height(100)
```

## 资源引用语法

### 资源类型
```typescript
// 字符串资源
$r('app.string.hello_world')

// 颜色资源
$r('app.color.primary')

// 尺寸资源
$r('app.float.text_size')

// 图片资源
$r('app.media.icon')
```

## 事件处理语法

### 常用事件
```typescript
.onClick(() => {
  // 点击事件
})

.onTouch((event: TouchEvent) => {
  // 触摸事件
})

.onAppear(() => {
  // 组件出现事件
})

.onDisAppear(() => {
  // 组件消失事件
})
```

## 动画语法

### 属性动画
```typescript
@State rotateAngle: number = 0;

Text('Rotate')
  .rotate({ angle: this.rotateAngle })
  .animation({
    duration: 1000,
    curve: Curve.EaseInOut
  })
  .onClick(() => {
    this.rotateAngle += 90;
  })
```

### 转场动画
```typescript
.transition({
  type: TransitionType.Insert,
  opacity: 0,
  translate: { x: 100 }
})
```

## 最佳实践

1. **组件命名**：使用PascalCase命名组件
2. **状态管理**：合理使用@State、@Prop、@Link等装饰器
3. **资源引用**：统一使用$r()语法引用资源
4. **代码组织**：将复杂组件拆分为多个小组件
5. **性能优化**：避免在build()方法中进行复杂计算
6. **类型安全**：充分利用TypeScript的类型检查

## 调试技巧

### 日志输出
```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'MyComponent';
const DOMAIN = 0x0000;

hilog.info(DOMAIN, TAG, 'Debug message: %{public}s', 'value');
```

### 组件标识
```typescript
Text('Debug Text')
  .id('debugText')  // 用于UI测试和调试
```