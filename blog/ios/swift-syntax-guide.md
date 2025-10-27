# Swift 语法学习指南 - 与 Kotlin 对比

> 本指南专为有 Android/Kotlin 开发经验的开发者设计，通过对比学习快速掌握 Swift 语法

## 目录

1. [语言基础对比](#语言基础对比)
2. [变量与常量](#变量与常量)
3. [数据类型](#数据类型)
4. [函数定义](#函数定义)
5. [类与结构体](#类与结构体)
6. [继承与协议](#继承与协议)
7. [可选类型](#可选类型)
8. [集合类型](#集合类型)
9. [控制流](#控制流)
10. [闭包与Lambda](#闭包与lambda)
11. [扩展与Extension](#扩展与extension)
12. [错误处理](#错误处理)
13. [内存管理](#内存管理)
14. [实战练习](#实战练习)

---

## 语言基础对比

### 基本特性对比

| 特性 | Swift | Kotlin |
|------|-------|--------|
| 类型推断 | ✅ 强类型推断 | ✅ 强类型推断 |
| 空安全 | ✅ Optional 类型 | ✅ Nullable 类型 |
| 函数式编程 | ✅ 支持 | ✅ 支持 |
| 面向对象 | ✅ 支持 | ✅ 支持 |
| 协议/接口 | Protocol | Interface |
| 扩展 | Extension | Extension Function |

---

## 变量与常量

### Swift
```swift
// 常量 - 不可变
let name = "张三"           // 类型推断
let age: Int = 25          // 显式类型

// 变量 - 可变
var score = 90
var height: Double = 175.5

// 延迟初始化
lazy var expensiveResource = createResource()
```

### Kotlin
```kotlin
// 常量 - 不可变
val name = "张三"           // 类型推断
val age: Int = 25          // 显式类型

// 变量 - 可变
var score = 90
var height: Double = 175.5

// 延迟初始化
val expensiveResource by lazy { createResource() }
```

### 对比总结
- Swift 使用 `let`/`var`，Kotlin 使用 `val`/`var`
- 两者都支持类型推断
- Swift 的 `lazy` 是关键字，Kotlin 使用 `by lazy` 委托

---

## 数据类型

### 基本数据类型对比

| 类型 | Swift | Kotlin |
|------|-------|--------|
| 整数 | `Int`, `Int8`, `Int16`, `Int32`, `Int64` | `Int`, `Byte`, `Short`, `Int`, `Long` |
| 浮点 | `Float`, `Double` | `Float`, `Double` |
| 布尔 | `Bool` | `Boolean` |
| 字符 | `Character` | `Char` |
| 字符串 | `String` | `String` |

### 字符串操作

#### Swift
```swift
// 字符串插值
let name = "Swift"
let message = "Hello, \(name)!"

// 多行字符串
let multiline = """
这是一个
多行字符串
"""

// 字符串方法
let text = "Hello World"
print(text.count)                    // 长度
print(text.uppercased())            // 大写
print(text.contains("World"))       // 包含
```

#### Kotlin
```kotlin
// 字符串插值
val name = "Kotlin"
val message = "Hello, $name!"
val complexMessage = "Hello, ${name.uppercase()}!"

// 多行字符串
val multiline = """
    这是一个
    多行字符串
""".trimIndent()

// 字符串方法
val text = "Hello World"
println(text.length)                 // 长度
println(text.uppercase())           // 大写
println(text.contains("World"))     // 包含
```

### 协议属性声明详解

**为什么协议中必须使用 `var` 而不是 `let`？**

Swift 协议中的属性声明有特殊的语法规则：

#### 1. 协议属性声明规则

```swift
protocol MyProtocol {
    // ✅ 正确：只读属性
    var readOnlyProperty: String { get }
    
    // ✅ 正确：可读写属性
    var readWriteProperty: Int { get set }
    
    // ❌ 错误：协议中不能使用 let
    // let constantProperty: String { get }  // 编译错误
}
```

#### 2. 实现协议时的灵活性

```swift
class MyClass: MyProtocol {
    // 只读属性可以用 let 实现
    let readOnlyProperty: String = "Hello"
    
    // 也可以用 var 实现
    var anotherReadOnly: String {
        return "World"
    }
    
    // 可读写属性必须用 var 实现
    var readWriteProperty: Int = 42
}
```

#### 3. 与 Kotlin 的对比

| 特性 | Swift 协议 | Kotlin 接口 |
|------|------------|-------------|
| 只读属性声明 | `var property: Type { get }` | `val property: Type` |
| 可读写属性声明 | `var property: Type { get set }` | `var property: Type` |
| 实现只读属性 | 可用 `let` 或 `var` | 可用 `val` 或 `var` |
| 实现可读写属性 | 必须用 `var` | 必须用 `var` |

#### 4. 核心要点

- **协议声明**：Swift 协议中所有属性都必须用 `var` 声明
- **访问控制**：通过 `{ get }` 和 `{ get set }` 指定属性的访问权限
- **实现灵活性**：只读属性（`{ get }`）在实现时可以是 `let` 常量
- **类型安全**：编译器确保实现类满足协议的访问权限要求

这种设计让 Swift 协议既保持了灵活性，又确保了类型安全。

---

## 函数定义

### Swift
```swift
// 基本函数
func greet(name: String) -> String {
    return "Hello, \(name)!"
}

// 带默认参数
func greet(name: String, age: Int = 18) -> String {
    return "Hello, \(name), you are \(age) years old"
}

// 可变参数
func sum(_ numbers: Int...) -> Int {
    return numbers.reduce(0, +)
}

// 高阶函数
func processData(_ data: [Int], processor: (Int) -> Int) -> [Int] {
    return data.map(processor)
}

// 调用
let result1 = greet(name: "张三")
let result2 = greet(name: "李四", age: 25)
let total = sum(1, 2, 3, 4, 5)
```

### Kotlin
```kotlin
// 基本函数
fun greet(name: String): String {
    return "Hello, $name!"
}

// 带默认参数
fun greet(name: String, age: Int = 18): String {
    return "Hello, $name, you are $age years old"
}

// 可变参数
fun sum(vararg numbers: Int): Int {
    return numbers.sum()
}

// 高阶函数
fun processData(data: List<Int>, processor: (Int) -> Int): List<Int> {
    return data.map(processor)
}

// 调用
val result1 = greet("张三")
val result2 = greet("李四", 25)
val total = sum(1, 2, 3, 4, 5)
```

### 对比总结
- Swift 使用 `func` 关键字，Kotlin 使用 `fun`
- Swift 参数标签更灵活，Kotlin 相对简单
- Swift 可变参数用 `...`，Kotlin 用 `vararg`

---

## 类与结构体

### Swift
```swift
// 结构体（值类型）
struct Point {
    var x: Double
    var y: Double
    
    // 计算属性
    var distance: Double {
        return sqrt(x * x + y * y)
    }
    
    // 方法
    // mutating 关键字说明：
    // 在 Swift 中，结构体（struct）是值类型，默认情况下其方法不能修改实例的属性
    // 如果需要在方法中修改结构体的属性，必须使用 mutating 关键字标记该方法
    // 这是 Swift 的安全机制，确保值类型的不可变性，除非明确声明为可变
    mutating func moveBy(x deltaX: Double, y deltaY: Double) {
        x += deltaX  // 修改实例属性 x
        y += deltaY  // 修改实例属性 y
    }
}

// 类（引用类型）
class Person {
    var name: String
    var age: Int
    
    // 构造器
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // 方法
    func introduce() -> String {
        return "我是\(name)，今年\(age)岁"
    }
}

// 使用
var point = Point(x: 3.0, y: 4.0)
print(point.distance)  // 5.0
point.moveBy(x: 1.0, y: 1.0)

let person = Person(name: "张三", age: 25)
print(person.introduce())
```

### Kotlin
```kotlin
// 数据类（类似结构体）
data class Point(
    var x: Double,
    var y: Double
) {
    // 计算属性
    val distance: Double
        get() = sqrt(x * x + y * y)
    
    // 方法
    fun moveBy(deltaX: Double, deltaY: Double) {
        x += deltaX
        y += deltaY
    }
}

// 类
class Person(
    var name: String,
    var age: Int
) {
    // 方法
    fun introduce(): String {
        return "我是$name，今年${age}岁"
    }
}

// 使用
val point = Point(3.0, 4.0)
println(point.distance)  // 5.0
point.moveBy(1.0, 1.0)

val person = Person("张三", 25)
println(person.introduce())
```

### mutating 关键字详解

#### Swift 中的 mutating

`mutating` 是 Swift 中一个重要的关键字，专门用于值类型（struct 和 enum）：

```swift
struct Counter {
    var count = 0
    
    // ❌ 错误：不能在非 mutating 方法中修改属性
    // func increment() {
    //     count += 1  // 编译错误
    // }
    
    // ✅ 正确：使用 mutating 关键字
    mutating func increment() {
        count += 1  // 可以修改属性
    }
    
    mutating func reset() {
        count = 0
    }
    
    // 不修改属性的方法不需要 mutating
    func getCurrentCount() -> Int {
        return count
    }
}

// 使用示例
var counter = Counter()  // 注意：必须是 var，不能是 let
counter.increment()      // count = 1
counter.increment()      // count = 2
print(counter.getCurrentCount())  // 2

// let counter2 = Counter()
// counter2.increment()  // ❌ 编译错误：let 常量不能调用 mutating 方法
```

#### 与 Kotlin 的对比

| 特性 | Swift | Kotlin |
|------|-------|--------|
| 值类型可变性 | 需要 `mutating` 关键字明确标记 | 直接修改，无需特殊标记 |
| 编译时检查 | 严格检查，防止意外修改 | 相对宽松 |
| 常量实例 | `let` 实例不能调用 `mutating` 方法 | `val` 实例仍可修改内部可变属性 |
| 安全性 | 更高的类型安全性 | 依赖开发者自觉 |

#### 为什么需要 mutating？

1. **值类型的不可变性**：Swift 的 struct 是值类型，默认不可变
2. **明确的意图表达**：`mutating` 明确表示该方法会修改实例
3. **编译时安全**：防止意外修改，提高代码安全性
4. **函数式编程支持**：鼓励不可变编程风格

#### 实际应用场景

```swift
struct BankAccount {
    private var balance: Double
    
    init(initialBalance: Double) {
        self.balance = initialBalance
    }
    
    // 查询余额 - 不需要 mutating
    func getBalance() -> Double {
        return balance
    }
    
    // 存款 - 需要 mutating
    mutating func deposit(amount: Double) {
        guard amount > 0 else { return }
        balance += amount
    }
    
    // 取款 - 需要 mutating
    mutating func withdraw(amount: Double) -> Bool {
        guard amount > 0 && amount <= balance else {
            return false
        }
        balance -= amount
        return true
    }
}

var account = BankAccount(initialBalance: 1000.0)
print(account.getBalance())  // 1000.0
account.deposit(amount: 500.0)
print(account.getBalance())  // 1500.0
let success = account.withdraw(amount: 200.0)
print(account.getBalance())  // 1300.0
```

---

## 继承与协议

### Swift
```swift
// 协议定义
protocol Drawable {
    func draw()
    // 注意：协议中的属性声明必须使用 var，不能使用 let
    // { get } 表示这是一个只读属性，实现时可以是 let 常量或 var 变量
    // 但在协议声明中必须用 var，因为协议不知道具体实现方式
    var area: Double { get }
}

protocol Colorable {
    // { get set } 表示这是一个可读写属性，实现时必须是 var 变量
    var color: String { get set }
}

// 基类
class Shape: Drawable {
    var area: Double {
        return 0.0
    }
    
    func draw() {
        print("绘制形状")
    }
}

// 继承和协议实现
class Circle: Shape, Colorable {
    var radius: Double
    var color: String
    
    init(radius: Double, color: String) {
        self.radius = radius
        self.color = color
        super.init()
    }
    
    override var area: Double {
        return Double.pi * radius * radius
    }
    
    override func draw() {
        print("绘制\(color)的圆形")
    }
}
```

### Kotlin
```kotlin
// 接口定义
interface Drawable {
    fun draw()
    val area: Double
}

interface Colorable {
    var color: String
}

// 基类
open class Shape : Drawable {
    override val area: Double
        get() = 0.0
    
    override fun draw() {
        println("绘制形状")
    }
}

// 继承和接口实现
class Circle(
    val radius: Double,
    override var color: String
) : Shape(), Colorable {
    
    override val area: Double
        get() = Math.PI * radius * radius
    
    override fun draw() {
        println("绘制${color}的圆形")
    }
}
```

---

## 可选类型

### Swift Optional
```swift
// 可选类型声明
var optionalName: String? = "张三"
var optionalAge: Int? = nil

// 可选绑定
if let name = optionalName {
    // \(name) 是字符串插值，name 是变量调用
    // 在字符串插值中可以调用属性、方法和扩展函数
    print("姓名是: \(name)")
    print("姓名长度: \(name.count)")  // 调用属性
    print("大写姓名: \(name.uppercased())")  // 调用方法
} else {
    print("姓名为空")
}

// guard 语句
func processUser(name: String?) {
    guard let userName = name else {
        print("用户名不能为空")
        return
    }
    print("处理用户: \(userName)")
}

// 空合并运算符
let displayName = optionalName ?? "未知用户"

// 强制解包（危险操作）
let forcedName = optionalName!  // 如果为nil会崩溃

// 可选链
class Person {
    var address: Address?
}

class Address {
    var street: String?
}

let person: Person? = Person()
let street = person?.address?.street  // 可选链调用
```

### Kotlin Nullable
```kotlin
// 可空类型声明
var optionalName: String? = "张三"
var optionalAge: Int? = null

// 安全调用
optionalName?.let { name ->
    println("姓名是: $name")
} ?: run {
    println("姓名为空")
}

// Elvis 运算符
val displayName = optionalName ?: "未知用户"

// 非空断言（危险操作）
val forcedName = optionalName!!  // 如果为null会抛异常

// 安全调用链
class Person {
    var address: Address? = null
}

class Address {
    var street: String? = null
}

val person: Person? = Person()
val street = person?.address?.street  // 安全调用链
```

### 对比总结
- Swift 使用 `?` 和 `!`，Kotlin 也使用 `?` 和 `!!`
- Swift 的 `if let` 对应 Kotlin 的 `?.let`
- Swift 的 `??` 对应 Kotlin 的 `?:`

### 字符串插值与扩展函数调用

**回答你的问题**：是的，`\(name)` 是对变量的调用，而且在字符串插值中可以调用属性、方法和扩展函数。

#### Swift 字符串插值

```swift
let name = "张三"
let age = 25

// 基本变量调用
print("姓名: \(name)")

// 调用属性和方法
print("姓名长度: \(name.count)")
print("大写姓名: \(name.uppercased())")
print("年龄加10: \(age + 10)")

// 调用扩展函数
extension String {
    func addPrefix(_ prefix: String) -> String {
        return prefix + self
    }
}

print("带前缀的姓名: \(name.addPrefix("Mr. "))")

// 复杂表达式
print("信息: \(name.isEmpty ? "无名" : name.uppercased())")
```

#### Kotlin 字符串模板

```kotlin
val name = "张三"
val age = 25

// 基本变量调用
println("姓名: $name")

// 调用属性和方法
println("姓名长度: ${name.length}")
println("大写姓名: ${name.uppercase()}")
println("年龄加10: ${age + 10}")

// 调用扩展函数
fun String.addPrefix(prefix: String): String {
    return prefix + this
}

println("带前缀的姓名: ${name.addPrefix("Mr. ")}")

// 复杂表达式
println("信息: ${if (name.isEmpty()) "无名" else name.uppercase()}")
```

#### 对比总结

| 特性 | Swift | Kotlin |
|------|-------|--------|
| 基本语法 | `\(variable)` | `$variable` |
| 复杂表达式 | `\(expression)` | `${expression}` |
| 方法调用 | `\(obj.method())` | `${obj.method()}` |
| 扩展函数 | `\(obj.extensionFunc())` | `${obj.extensionFunc()}` |
| 条件表达式 | `\(condition ? a : b)` | `${if (condition) a else b}` |

#### 核心要点

- **变量调用**：字符串插值中的变量是正常的变量访问
- **方法链式调用**：可以在插值中进行链式方法调用
- **扩展函数支持**：完全支持调用扩展函数
- **表达式计算**：插值内可以进行复杂的表达式计算
- **类型安全**：编译时检查确保类型正确

---

## 集合类型

### Swift
```swift
// 数组
var numbers = [1, 2, 3, 4, 5]
var strings: [String] = ["a", "b", "c"]

// 数组操作
numbers.append(6)
numbers.insert(0, at: 0)
let first = numbers.first  // Optional<Int>
let count = numbers.count

// 字典
var scores = ["张三": 95, "李四": 87]
var ages: [String: Int] = [:]

// 字典操作
scores["王五"] = 92
let zhangScore = scores["张三"]  // Optional<Int>

// 集合
var uniqueNumbers: Set<Int> = [1, 2, 3, 3, 4]  // {1, 2, 3, 4}

// 高阶函数
let doubled = numbers.map { $0 * 2 }
let evens = numbers.filter { $0 % 2 == 0 }
let sum = numbers.reduce(0, +)
```

### Kotlin
```kotlin
// 列表
val numbers = mutableListOf(1, 2, 3, 4, 5)
val strings: List<String> = listOf("a", "b", "c")

// 列表操作
numbers.add(6)
numbers.add(0, 0)
val first = numbers.firstOrNull()  // Int?
val count = numbers.size

// 映射
val scores = mutableMapOf("张三" to 95, "李四" to 87)
val ages: MutableMap<String, Int> = mutableMapOf()

// 映射操作
scores["王五"] = 92
val zhangScore = scores["张三"]  // Int?

// 集合
val uniqueNumbers: Set<Int> = setOf(1, 2, 3, 3, 4)  // {1, 2, 3, 4}

// 高阶函数
val doubled = numbers.map { it * 2 }
val evens = numbers.filter { it % 2 == 0 }
val sum = numbers.reduce { acc, n -> acc + n }
```

---

## 控制流

### Swift
```swift
// if-else
let score = 85
if score >= 90 {
    print("优秀")
} else if score >= 80 {
    print("良好")
} else {
    print("需要努力")
}

// switch
let grade = "A"
switch grade {
    case "A":
        print("优秀")
    case "B", "C":
        print("良好")
    case "D":
        print("及格")
    default:
        print("不及格")
}

// for 循环
for i in 1...5 {
    print(i)
}

for i in 1..<5 {
    print(i)  // 1, 2, 3, 4
}

for (index, value) in ["a", "b", "c"].enumerated() {
    print("\(index): \(value)")
}

// while 循环
var count = 0
while count < 5 {
    print(count)
    count += 1
}
```

### Kotlin
```kotlin
// if-else
val score = 85
if (score >= 90) {
    println("优秀")
} else if (score >= 80) {
    println("良好")
} else {
    println("需要努力")
}

// when (类似 switch)
val grade = "A"
when (grade) {
    "A" -> println("优秀")
    "B", "C" -> println("良好")
    "D" -> println("及格")
    else -> println("不及格")
}

// for 循环
for (i in 1..5) {
    println(i)
}

for (i in 1 until 5) {
    println(i)  // 1, 2, 3, 4
}

for ((index, value) in listOf("a", "b", "c").withIndex()) {
    println("$index: $value")
}

// while 循环
var count = 0
while (count < 5) {
    println(count)
    count++
}
```

---

## 闭包与Lambda

### Swift 闭包
```swift
// 基本闭包语法
let numbers = [1, 2, 3, 4, 5]

// 完整语法
let doubled1 = numbers.map({ (number: Int) -> Int in
    return number * 2
})

// 简化语法
let doubled2 = numbers.map { number in
    return number * 2
}

// 最简语法
let doubled3 = numbers.map { $0 * 2 }

// 尾随闭包
let filtered = numbers.filter { $0 % 2 == 0 }

// 捕获值
func makeIncrementer(incrementAmount: Int) -> () -> Int {
    var total = 0
    let incrementer: () -> Int = {
        total += incrementAmount
        return total
    }
    return incrementer
}

let incrementByTwo = makeIncrementer(incrementAmount: 2)
print(incrementByTwo())  // 2
print(incrementByTwo())  // 4
```

### Kotlin Lambda
```kotlin
// 基本 Lambda 语法
val numbers = listOf(1, 2, 3, 4, 5)

// 完整语法
val doubled1 = numbers.map({ number: Int -> number * 2 })

// 简化语法
val doubled2 = numbers.map { number -> number * 2 }

// 最简语法（使用 it）
val doubled3 = numbers.map { it * 2 }

// 过滤
val filtered = numbers.filter { it % 2 == 0 }

// 捕获值
fun makeIncrementer(incrementAmount: Int): () -> Int {
    var total = 0
    return {
        total += incrementAmount
        total
    }
}

val incrementByTwo = makeIncrementer(2)
println(incrementByTwo())  // 2
println(incrementByTwo())  // 4
```

---

## 扩展与Extension

### Swift Extension
```swift
// 扩展基本类型
extension String {
    var isEmail: Bool {
        return self.contains("@") && self.contains(".")
    }
    
    func reversed() -> String {
        return String(self.reversed())
    }
}

// 扩展自定义类型
extension Person {
    func greet() -> String {
        return "Hello, I'm \(name)"
    }
    
    var isAdult: Bool {
        return age >= 18
    }
}

// 使用扩展
let email = "test@example.com"
print(email.isEmail)  // true
print("Swift".reversed())  // tfiwS

let person = Person(name: "张三", age: 20)
print(person.greet())
print(person.isAdult)
```

### Kotlin Extension
```kotlin
// 扩展基本类型
val String.isEmail: Boolean
    get() = this.contains("@") && this.contains(".")

fun String.reversed(): String {
    return this.reversed()
}

// 扩展自定义类型
fun Person.greet(): String {
    return "Hello, I'm $name"
}

val Person.isAdult: Boolean
    get() = age >= 18

// 使用扩展
val email = "test@example.com"
println(email.isEmail)  // true
println("Kotlin".reversed())  // niltoK

val person = Person("张三", 20)
println(person.greet())
println(person.isAdult)
```

---

## 错误处理

### Swift 错误处理
```swift
// 定义错误类型
enum ValidationError: Error {
    case emptyName
    case invalidAge
    case invalidEmail
}

// 可能抛出错误的函数
func validateUser(name: String, age: Int, email: String) throws -> Bool {
    if name.isEmpty {
        throw ValidationError.emptyName
    }
    
    if age < 0 || age > 150 {
        throw ValidationError.invalidAge
    }
    
    if !email.contains("@") {
        throw ValidationError.invalidEmail
    }
    
    return true
}

// 错误处理
do {
    try validateUser(name: "张三", age: 25, email: "zhang@example.com")
    print("用户验证成功")
} catch ValidationError.emptyName {
    print("姓名不能为空")
} catch ValidationError.invalidAge {
    print("年龄无效")
} catch ValidationError.invalidEmail {
    print("邮箱格式无效")
} catch {
    print("未知错误: \(error)")
}

// try? 和 try!
let result1 = try? validateUser(name: "李四", age: 30, email: "li@example.com")
let result2 = try! validateUser(name: "王五", age: 28, email: "wang@example.com")
```

### Kotlin 异常处理
```kotlin
// 自定义异常
class ValidationException(message: String) : Exception(message)

// 可能抛出异常的函数
fun validateUser(name: String, age: Int, email: String): Boolean {
    if (name.isEmpty()) {
        throw ValidationException("姓名不能为空")
    }
    
    if (age < 0 || age > 150) {
        throw ValidationException("年龄无效")
    }
    
    if (!email.contains("@")) {
        throw ValidationException("邮箱格式无效")
    }
    
    return true
}

// 异常处理
try {
    validateUser("张三", 25, "zhang@example.com")
    println("用户验证成功")
} catch (e: ValidationException) {
    println("验证错误: ${e.message}")
} catch (e: Exception) {
    println("未知错误: ${e.message}")
}

// runCatching (类似 try?)
val result = runCatching {
    validateUser("李四", 30, "li@example.com")
}.getOrNull()
```

---

## 内存管理

### Swift ARC (自动引用计数)
```swift
class Person {
    let name: String
    var apartment: Apartment?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("\(name) 被释放")
    }
}

class Apartment {
    let unit: String
    weak var tenant: Person?  // 弱引用避免循环引用
    
    init(unit: String) {
        self.unit = unit
    }
    
    deinit {
        print("公寓 \(unit) 被释放")
    }
}

// 使用
var john: Person? = Person(name: "John")
var unit4A: Apartment? = Apartment(unit: "4A")

john?.apartment = unit4A
unit4A?.tenant = john

// 释放引用 - Swift ARC 需要手动打破循环引用
// 如果不手动置 nil，即使使用了 weak 引用，外部强引用仍然存在
john = nil    // 释放 Person 实例的强引用
unit4A = nil  // 释放 Apartment 实例的强引用
```

### Kotlin GC (垃圾回收)
```kotlin
class Person(val name: String) {
    var apartment: Apartment? = null
    
    protected fun finalize() {
        println("$name 被回收")
    }
}

class Apartment(val unit: String) {
    var tenant: Person? = null  // Kotlin 的 GC 会处理循环引用
    
    protected fun finalize() {
        println("公寓 $unit 被回收")
    }
}

// 使用
var john: Person? = Person("John")
var unit4A: Apartment? = Apartment("4A")

john?.apartment = unit4A
unit4A?.tenant = john

// 释放引用 - Kotlin GC 可以自动处理循环引用
// 即使不手动置 null，GC 也能检测并回收循环引用的对象
john = null  // 可选操作，GC 会自动处理
unit4A = null  // 可选操作，GC 会自动处理
```

### Swift ARC vs Kotlin GC 对比

**回答你的问题**：你说得对！Kotlin 确实不需要手动置 null，而 Swift 在某些情况下需要。

#### 内存管理机制对比

| 特性 | Swift ARC | Kotlin GC |
|------|-----------|----------|
| **管理方式** | 自动引用计数 | 垃圾回收器 |
| **循环引用处理** | 需要 weak/unowned 引用 | 自动检测和处理 |
| **手动置 nil** | 有时需要 | 通常不需要 |
| **性能特点** | 确定性释放，低延迟 | 可能有 GC 暂停 |
| **内存泄漏风险** | 循环引用导致泄漏 | 很少发生 |

#### 具体差异说明

**Swift ARC 的限制**：
```swift
// 即使使用了 weak 引用，外部强引用仍需手动释放
var john: Person? = Person(name: "John")
var unit4A: Apartment? = Apartment(unit: "4A")

john?.apartment = unit4A
unit4A?.tenant = john  // weak 引用

// 必须手动置 nil，否则 john 和 unit4A 不会被释放
john = nil    // 必需！
unit4A = nil  // 必需！
```

**Kotlin GC 的优势**：
```kotlin
// GC 可以自动检测循环引用
var john: Person? = Person("John")
var unit4A: Apartment? = Apartment("4A")

john?.apartment = unit4A
unit4A?.tenant = john  // 普通引用

// 不需要手动置 null，GC 会自动处理
// john = null  // 可选
// unit4A = null  // 可选

// 当这些变量超出作用域时，GC 会自动回收
```

#### 核心要点

- **Swift**：ARC 基于引用计数，无法自动处理循环引用，需要开发者使用 `weak`/`unowned` 和手动置 `nil`
- **Kotlin**：GC 可以检测并自动回收循环引用的对象，开发者无需特殊处理
- **最佳实践**：Swift 中养成手动置 `nil` 的习惯，Kotlin 中可以依赖 GC 自动管理

这就是为什么 Swift 开发者需要更加注意内存管理，而 Kotlin/Java 开发者相对轻松一些。
```

---

## 实战练习

### 练习1：创建一个简单的学生管理系统

#### Swift 版本
```swift
struct Student {
    let id: String
    var name: String
    var age: Int
    var scores: [String: Double]  // 科目: 分数
    
    var averageScore: Double {
        guard !scores.isEmpty else { return 0.0 }
        return scores.values.reduce(0, +) / Double(scores.count)
    }
    
    mutating func addScore(subject: String, score: Double) {
        scores[subject] = score
    }
}

class StudentManager {
    private var students: [String: Student] = [:]
    
    func addStudent(_ student: Student) {
        students[student.id] = student
    }
    
    func getStudent(id: String) -> Student? {
        return students[id]
    }
    
    func getAllStudents() -> [Student] {
        return Array(students.values)
    }
    
    func getTopStudents(count: Int) -> [Student] {
        return getAllStudents()
            .sorted { $0.averageScore > $1.averageScore }
            .prefix(count)
            .map { $0 }
    }
}

// 使用示例
let manager = StudentManager()

var student1 = Student(id: "001", name: "张三", age: 20, scores: [:])
student1.addScore(subject: "数学", score: 95.0)
student1.addScore(subject: "英语", score: 87.0)

manager.addStudent(student1)

if let student = manager.getStudent(id: "001") {
    print("学生: \(student.name), 平均分: \(student.averageScore)")
}
```

#### Kotlin 版本
```kotlin
data class Student(
    val id: String,
    var name: String,
    var age: Int,
    private val scores: MutableMap<String, Double> = mutableMapOf()
) {
    val averageScore: Double
        get() = if (scores.isEmpty()) 0.0 else scores.values.average()
    
    fun addScore(subject: String, score: Double) {
        scores[subject] = score
    }
    
    fun getScores(): Map<String, Double> = scores.toMap()
}

class StudentManager {
    private val students = mutableMapOf<String, Student>()
    
    fun addStudent(student: Student) {
        students[student.id] = student
    }
    
    fun getStudent(id: String): Student? {
        return students[id]
    }
    
    fun getAllStudents(): List<Student> {
        return students.values.toList()
    }
    
    fun getTopStudents(count: Int): List<Student> {
        return getAllStudents()
            .sortedByDescending { it.averageScore }
            .take(count)
    }
}

// 使用示例
val manager = StudentManager()

val student1 = Student("001", "张三", 20)
student1.addScore("数学", 95.0)
student1.addScore("英语", 87.0)

manager.addStudent(student1)

manager.getStudent("001")?.let { student ->
    println("学生: ${student.name}, 平均分: ${student.averageScore}")
}
```

### 练习2：网络请求封装

#### Swift 版本
```swift
import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Codable>(
        url: String,
        type: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // guard 语句：提前退出模式，确保条件满足才继续执行
        // 类似 Kotlin 的 require() 或 early return 模式
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return  // 条件不满足时提前退出
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

// 使用示例
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

NetworkManager.shared.request(
    url: "https://api.example.com/users/1",
    type: User.self
) { result in
    switch result {
    case .success(let user):
        print("用户: \(user.name)")
    case .failure(let error):
        print("错误: \(error)")
    }
}
```

#### Kotlin 版本
```kotlin
import kotlinx.coroutines.*
import kotlinx.serialization.*
import kotlinx.serialization.json.*

sealed class NetworkResult<T> {
    data class Success<T>(val data: T) : NetworkResult<T>()
    data class Error<T>(val message: String) : NetworkResult<T>()
}

class NetworkManager {
    companion object {
        val instance = NetworkManager()
    }
    
    private val json = Json { ignoreUnknownKeys = true }
    
    suspend inline fun <reified T> request(url: String): NetworkResult<T> {
        return withContext(Dispatchers.IO) {
            try {
                // 这里应该使用实际的 HTTP 客户端，如 OkHttp
                val response = ""  // 模拟响应
                val result = json.decodeFromString<T>(response)
                NetworkResult.Success(result)
            } catch (e: Exception) {
                NetworkResult.Error(e.message ?: "Unknown error")
            }
        }
    }
}

// 使用示例
@Serializable
data class User(
    val id: Int,
    val name: String,
    val email: String
)

// 在协程中使用
GlobalScope.launch {
    when (val result = NetworkManager.instance.request<User>("https://api.example.com/users/1")) {
        is NetworkResult.Success -> {
            println("用户: ${result.data.name}")
        }
        is NetworkResult.Error -> {
            println("错误: ${result.message}")
        }
    }
}
```

---

## Guard 语句详解

### 什么是 Guard 语句

`guard` 是 Swift 中的一个关键字，用于**提前退出模式**（Early Exit Pattern）。它确保某个条件必须为真，否则就提前退出当前作用域。

### 基本语法

```swift
guard 条件 else {
    // 条件不满足时执行的代码
    return  // 必须有退出语句
}
// 条件满足时继续执行的代码
```

### Guard vs If Let 对比

```swift
// 使用 if let（嵌套结构）
func processUser(name: String?) {
    if let userName = name {
        if userName.count > 0 {
            if userName != "admin" {
                print("处理用户: \(userName)")
                // 更多逻辑...
            } else {
                print("管理员用户")
                return
            }
        } else {
            print("用户名为空")
            return
        }
    } else {
        print("用户名为 nil")
        return
    }
}

// 使用 guard（扁平结构）
func processUserWithGuard(name: String?) {
    guard let userName = name else {
        print("用户名为 nil")
        return
    }
    
    guard userName.count > 0 else {
        print("用户名为空")
        return
    }
    
    guard userName != "admin" else {
        print("管理员用户")
        return
    }
    
    print("处理用户: \(userName)")
    // 更多逻辑...
}
```

### Guard 的优势

1. **减少嵌套**：避免金字塔式的 if-else 嵌套
2. **提高可读性**：主要逻辑更清晰
3. **强制处理**：必须在 else 块中处理异常情况
4. **作用域扩展**：guard let 绑定的变量在后续代码中可用

### 与 Kotlin 的对比

| 特性 | Swift Guard | Kotlin 等价写法 |
|------|-------------|----------------|
| **提前退出** | `guard condition else { return }` | `if (!condition) return` |
| **空值检查** | `guard let value = optional else { return }` | `val value = optional ?: return` |
| **条件验证** | `guard user.isValid else { return }` | `require(user.isValid) { "Invalid user" }` |
| **多条件检查** | 多个 guard 语句 | `takeIf { }` 或多个 require |

#### Kotlin 对应写法示例

```kotlin
// Swift guard 对应的 Kotlin 写法
fun processUser(name: String?) {
    // Swift: guard let userName = name else { return }
    val userName = name ?: return
    
    // Swift: guard userName.isNotEmpty() else { return }
    if (userName.isEmpty()) return
    
    // Swift: guard userName != "admin" else { return }
    require(userName != "admin") { "Admin user not allowed" }
    
    println("处理用户: $userName")
}

// 或者使用 takeIf
fun processUserWithTakeIf(name: String?) {
    name?.takeIf { it.isNotEmpty() }
        ?.takeIf { it != "admin" }
        ?.let { userName ->
            println("处理用户: $userName")
        }
}
```

### 核心要点

1. **必须退出**：guard 的 else 块必须包含 `return`、`break`、`continue`、`throw` 等退出语句
2. **扁平化代码**：避免深层嵌套，让主要逻辑更突出
3. **变量作用域**：guard let 绑定的变量在整个函数剩余部分可用
4. **错误处理**：适合用于参数验证和前置条件检查
5. **Kotlin 替代**：主要使用 `?:` 操作符、`require()`、`takeIf()` 等实现类似效果

---

## 总结

### 学习建议

1. **从相似点开始**：Swift 和 Kotlin 有很多相似的概念，可以快速上手
2. **重点关注差异**：特别注意可选类型、内存管理、语法细节的不同
3. **多写代码**：理论学习后要多实践，加深理解
4. **利用工具**：使用 Xcode 的代码补全和错误提示
5. **阅读官方文档**：Apple 的 Swift 文档非常详细

### 下一步学习方向

1. **iOS 框架学习**：UIKit、SwiftUI、Core Data 等
2. **架构模式**：MVC、MVVM、VIPER 等
3. **网络编程**：URLSession、Alamofire 等
4. **数据持久化**：Core Data、SQLite、UserDefaults
5. **测试**：XCTest、UI Testing
6. **性能优化**：Instruments、内存管理

### 常用资源

- [Swift 官方文档](https://docs.swift.org/swift-book/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Swift Playgrounds](https://www.apple.com/swift/playgrounds/)
- [Hacking with Swift](https://www.hackingwithswift.com/)
- [Ray Wenderlich](https://www.raywenderlich.com/)

---

*本指南持续更新中，欢迎反馈和建议！*