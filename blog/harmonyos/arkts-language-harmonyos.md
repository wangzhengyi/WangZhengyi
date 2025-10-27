# 鸿蒙开发语言 ArkTS：给 Android 工程师的快速上手指南

- 作者：王正一
- 领域：客户端开发 / 跨端架构 / 鸿蒙生态
- 平台：CSDN

---

## 摘要
- ArkTS 是 HarmonyOS NEXT 的主力语言，基于 TypeScript，强化静态类型以提升性能与稳定性。
- 对 Android 工程师而言：语法容易上手，但需理解与 Kotlin/Java 的差异（类型系统、并发模型、模块化等）。
- 文章以“从语法到工程实践”为线索：变量与类型、联合与可空、函数、类与继承、接口与泛型、模块、并发与异步、安全与锁、推荐方向。
- 全文各节均附 Kotlin 对照示例，便于迁移与类比。

## 关键词
- ArkTS、HarmonyOS NEXT、Android、TypeScript、Kotlin、ArkUI、并发模型、异步编程

---

## 目录
- 为什么 Android 程序员要了解 ArkTS
- 变量与类型：`let`、`const` 与类型系统
- 联合类型与可空类型
- 函数：声明、可选参数与箭头函数
- 类与继承
- 接口与泛型
- 模块与导入导出
- 并发模型与线程池
- 异步编程：Promise 与 async/await
- 异步安全：单线程也会有并发问题
- 总结：写给 Android 工程师的心里话
- 推荐方向与后续学习
- 作者与版权信息

---

## 为什么 Android 程序员要了解 ArkTS

如果你有 Android 或 Kotlin 开发经验，第一次接触鸿蒙开发时，一定会被 “ArkTS” 这个新语言吸引。

ArkTS 是 HarmonyOS NEXT 的主力开发语言，它基于 TypeScript，但为了运行性能和稳定性，去掉了很多 TS 的动态特性，让语言更接近 Java/Kotlin 的静态类型体系。

> 一句话总结：ArkTS 是一个“像 Java 一样严谨、像 Kotlin 一样优雅、像 TypeScript 一样灵活”的语言。”

对 Android 程序员来说，这意味着你可以在几天内快速上手基础语法，但要写出高质量的鸿蒙代码，仍然需要理解一些关键差异。

---

## 变量与类型：`let`、`const` 与类型系统

在 ArkTS 中，声明变量有两种关键字：

```ts
let name: string = "Harmony"
const version = 5.0
```

- `let`：可变变量，等价于 Kotlin 的 `var`
- `const`：常量，等价于 Kotlin 的 `val`

类型系统与 TS 保持一致，包括 `number`、`string`、`boolean`、`bigint` 等。
- 注意：`number` 是 64 位浮点数，整数超过 `9007199254740991` 会出现精度问题。
- 处理超大整数（如消息 ID、用户 ID）时，推荐：
  - 存储为 `string`；
  - 或使用 `bigint`（但与 JSON 序列化不兼容）。

### 与 Kotlin 的数据类型对照（速览）

| ArkTS 类型 | Kotlin 类型 | 说明 |
| --- | --- | --- |
| `number` | `Int`/`Long`/`Float`/`Double` | ArkTS 统一为 64 位浮点，整数存在精度上限；Kotlin 按数值类型细分 |
| `bigint` | `BigInteger` | 任意精度整数；ArkTS 与 JSON 不兼容，需转 `string` 持久化 |
| `string` | `String` | 字符串类型 |
| `boolean` | `Boolean` | 布尔类型 |
| `any` | `Any` | 顶层类型；ArkTS 的 `any` 会绕过类型检查，慎用 |
| `object` | `Any`/`Object` | ArkTS 表示非原始类型值；Kotlin `Any` 为所有类型基类 |
| `undefined` | 无对应 | Kotlin 无 `undefined` 概念，缺失值通常用 `null` 表达 |
| `null` | `null` | ArkTS 通过联合类型显式声明可空；Kotlin 用 `T?` 声明可空 |
| 联合类型 `A \| B` | `sealed class`/类型层级 | Kotlin 无原生联合类型，通常用密封类或层级模拟 |
| 数组 `T[]`/`Array<T>` | `Array<T>`/`IntArray` 等 | Kotlin 有原生数值型数组（`IntArray` 等） |
| `Map<K,V>` | `Map<K,V>`/`MutableMap<K,V>` | ArkTS 为 JS `Map`，API 与 Kotlin Map 不同 |
| `Set<T>` | `Set<T>`/`MutableSet<T>` | 集合类型概念一致 |
| `enum` | `enum class` | Kotlin 枚举可携带属性/方法；ArkTS 枚举编译为对象 |

- 空值处理对比：
  - ArkTS：`user?.name ?? 'N/A'`
  - Kotlin：`user?.name ?: "N/A"`


---

## 联合类型与可空类型

ArkTS 引入了联合类型与可空类型，灵感来自 Kotlin 的类型安全体系。

```ts
let data: number | string = 123
data = "hello"
```

对于可空值，ArkTS 明确区分 `null` 与 `undefined`。若变量可能为空，必须显式声明：

- 补充：`undefined` 表示“值不存在/未赋值”的状态，在 ArkTS 中常见于：
  - 变量已声明但未赋值：`let name: string | undefined; // 初始为 undefined`
  - 可选参数：`function foo(x?: number) { /* x: number | undefined */ }`
  - 可选属性：`type User = { name?: string } // user.name 可能为 undefined`
  - 函数未显式返回值（返回 `void`）：调用方得到 `undefined`

- 与 `null` 的区别：`null` 表示“有意设置为空”，需要显式赋值；`undefined` 多为“缺省/未提供”。业务语义建议用 `null` 表达主动空。

- 推荐判断与使用方式：
  - 使用可选链与空值合并：`user?.name ?? 'N/A'`
  - 判断未定义：`val === undefined` 或 `typeof val === 'undefined'`
  - 对可能未赋值的变量，类型写为 `T | undefined` 或用可选标记 `prop?: T`

- 注意：ArkTS 有“确定赋值”检查，`let x: string` 必须在使用前赋值；若允许未赋值，则声明为 `string | undefined`（或用非空断言 `!`，不推荐）。

```ts
let name: string | undefined
let user: User | null = null
```

访问时，推荐使用可选链与空值合并运算符：

```ts
let len = user?.name?.length ?? 0
```

这套机制让空指针问题显著降低。

### Kotlin 对照

```kotlin
// 可空类型与安全调用
var user: User? = null
val len = user?.name?.length ?: 0

// 模拟联合类型：使用密封类
sealed class Result {
    data class Ok(val data: String) : Result()
    data class Err(val error: Throwable) : Result()
}

fun handle(r: Result) = when (r) {
    is Result.Ok -> println(r.data)
    is Result.Err -> println(r.error.message)
}
```

---

## 函数：声明、可选参数与箭头函数

函数定义与 Kotlin/TS 类似：

```ts
function add(x: number, y: number): number {
  return x + y
}
```

可选参数用 `?` 标记，默认参数与 Kotlin 相同：

- 可选参数含义：参数可以不传；在函数体内该参数类型是 `T | undefined`。

```ts
function greet(name?: string): string {
  return `Hello ${name ?? 'World'}`
}

greet()         // "Hello World"
greet('ArkTS')  // "Hello ArkTS"
```

- Kotlin 类比：可选参数可用可空类型配合默认值实现。

```kotlin
fun greet(name: String? = null): String {
    return "Hello " + (name ?: "World")
}
```

```ts
function buildName(first: string, last: string = "default") {
  return first + " " + last
}
```

箭头函数简洁易读：

```ts
let sum = (x: number, y: number) => x + y
```

ArkTS 支持函数重载：有多组定义声明，最终实现需兼容所有重载。

---

## 类与继承

ArkTS 的类结构与 Java 极其相似：

```ts
class Car {
  private engine: string

  constructor(engine: string) {
    this.engine = engine
  }

  disp(): void {
    console.log(`发动机型号: ${this.engine}`)
  }
}
```

- 支持访问修饰符（`private`/`public`/`protected`）、静态成员、`getter/setter`。
- 继承使用 `extends`，通过 `super()` 调用父类构造函数：

```ts
class ElectricCar extends Car {
  constructor(engine: string, public battery: number) {
    super(engine)
  }

  override disp(): void {
    super.disp()
    console.log(`电池容量: ${this.battery}`)
  }
}
```

### Kotlin 对照

```kotlin
open class Car(private val engine: String) {
    open fun disp() { println("发动机型号: $engine") }
}

class ElectricCar(engine: String, val battery: Int) : Car(engine) {
    override fun disp() {
        super.disp()
        println("电池容量: $battery")
    }
}
```

---

## 接口与泛型

接口（`interface`）定义语法与 TS 一致，更强调“契约式约束”：

```ts
interface Area {
  calculate(): number
}

class Circle implements Area {
  constructor(private radius: number) {}
  calculate() { return Math.PI * this.radius ** 2 }
}
```

泛型支持函数、类与接口三种形式，书写方式与 Java 类似：

```ts
function identity<T>(arg: T): T {
  return arg
}
```

### Kotlin 对照

```kotlin
interface Area { fun calculate(): Double }

class Circle(private val radius: Double) : Area {
    override fun calculate(): Double = Math.PI * radius * radius
}

fun <T> identity(arg: T): T = arg
```

---

## 模块与导入导出

ArkTS 采用 ES Module 标准，文件即模块：

```ts
// moduleA.ets
export class User {}

// main.ets
import { User } from './moduleA'
```

为避免层级过深，建议每个模块下设立 `index.ets` 聚合导出：

```ts
export * from './ui'
export * from './network'
```

### Kotlin 对照

```kotlin
// Kotlin 使用包与文件组织模块
package com.example.moduleA

class User

// 使用 import 引入
import com.example.moduleA.User

// 建议用顶层函数与对象聚合导出
object Export {
    fun fromUi() {}
    fun fromNetwork() {}
}
```

---

## 并发模型与线程池

ArkTS 是单线程模型，但提供多线程机制（TaskPool、Worker、FFRT）处理耗时任务；这与 Android 的“主线程 + Handler”思路相似。

主线程负责 UI 与逻辑，耗时操作放入任务池中异步执行：

```ts
@Concurrent
function heavyTask(data: number): number {
  console.log("running:", data)
  return data * 2
}

taskpool.execute(heavyTask, 10).then(result => {
  console.log("result:", result)
})
```

ArkTS 线程间数据不共享，通信通过消息传递完成；“内存隔离”设计避免了传统多线程的死锁与竞争风险。

### Kotlin 对照

```kotlin
// 使用协程与调度器执行耗时任务
suspend fun heavyTask(data: Int): Int = withContext(Dispatchers.Default) {
    println("running: $data")
    data * 2
}

// 或者使用线程池
val executor = Executors.newFixedThreadPool(4)
executor.submit { println("running in pool") }
```

---

## 异步编程：Promise 与 async/await

ArkTS 完全支持 `Promise` 与 `async/await`：

```ts
async function fetchData(): Promise<string> {
  const res = await getRemoteData()
  return res
}

fetchData()
  .then(res => console.log(res))
  .catch(err => console.error(err))
  .finally(() => console.log("done"))
```

建议在异步函数中配合 `try/catch` 捕获异常，防止任务中断：

```ts
async function safeFetch() {
  try {
    const res = await fetchData()
  } catch (err) {
    console.error("fetch error:", err)
  }
}
```

### Kotlin 对照

```kotlin
// 使用挂起函数与 try/catch 处理异常
suspend fun fetchData(): String = remote()

suspend fun safeFetch() {
    try {
        val res = fetchData()
    } catch (e: Exception) {
        println("fetch error: $e")
    }
}
```

---

## 异步安全：单线程也会有并发问题

虽然 ArkTS 是单线程模型，但异步执行仍可能出现并发安全风险。例如创建单例：

```ts
let instance: Object | null = null

async function getInstance() {
  if (!instance) {
    instance = await createInstance() // 可能被多次并发触发
  }
  return instance
}
```

解决方案：引入简单的 `AsyncLock`，保证同一时间只有一个任务进入关键区：

```ts
export class AsyncLock {
  private locked = false
  private queue: (() => void)[] = []

  async lock(): Promise<void> {
    if (this.locked) {
      await new Promise<void>(resolve => this.queue.push(resolve))
      return
    }
    this.locked = true
  }

  unlock() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift()
      resolve?.()
    } else {
      this.locked = false
    }
  }
}

let lock = new AsyncLock()

async function getInstanceSafe() {
  await lock.lock()
  if (!instance) instance = await createInstance()
  lock.unlock()
  return instance
}
```

### Kotlin 对照

```kotlin
// 使用互斥锁或 synchronized 保证并发安全
val mutex = Mutex()
var instance: Any? = null

suspend fun getInstanceSafe(): Any {
    mutex.lock()
    try {
        if (instance == null) instance = createInstance()
        return instance!!
    } finally {
        mutex.unlock()
    }
}

// 或者：
@Synchronized fun getInstanceSync(): Any {
    if (instance == null) instance = createInstance()
    return instance!!
}
```

---

## 总结：写给 Android 工程师的心里话

从 Java → Kotlin → ArkTS，语言在不断靠近一个目标：

> 既能保证安全，又不失开发效率。

ArkTS 更像是 Android 工程师熟悉的老朋友：
- 有 Kotlin 的语法糖；
- 有 TypeScript 的灵活类型系统；
- 有 Java 的严格边界与稳定性。

如果你已经熟悉 Android 架构（Activity 生命周期、异步任务、数据通信等），学习鸿蒙开发并不难——你只是换了一个新的生态，但仍在同一个逻辑体系中工作。

---


## 作者与版权信息
- 作者：王正一｜懂车帝客户端负责人。
- 版权声明：原创不易，转载请注明出处。

---

## 结尾引导（Call to Action）
- 如果这篇文章对你有帮助，请点赞、收藏、关注我，后续将持续更新鸿蒙开发与跨端架构实践。
- 欢迎在评论区交流你的 ArkTS 上手体验与工程问题，我会选取典型问题做专文解答。