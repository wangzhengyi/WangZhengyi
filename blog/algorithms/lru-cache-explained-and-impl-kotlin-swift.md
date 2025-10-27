# LRU缓存科普与实现（Kotlin 与 Swift）

## 什么是 LRU？
- LRU 的中文是“最近最少使用”。
- 核心思想：当缓存容量有限时，优先保留最近使用过的数据，最久未被使用的数据优先淘汰。
- 典型规则：
  - 命中（`get`）或写入（`put`）的数据，被视为“最近刚使用”，提升其优先级。
  - 当容量已满时，淘汰“最久未使用”的数据。

## 为什么需要 LRU？
- 内存受限场景：移动端、嵌入式设备、服务端实例都有严格的内存预算。
- 性能优化：减少重复的磁盘/网络请求，提高响应速度与吞吐。
- 常见应用：
  - 图片/资源缓存（如列表滚动时的图片）
  - 数据库查询结果缓存、HTTP 请求结果缓存
  - 浏览器缓存、编译器/解释器内部缓存等

## 原理与数据结构
- 经典实现：哈希表（`HashMap`）+双向链表（`Doubly Linked List`）。
  - `HashMap` 提供 O(1) 的查找，定位链表中的节点。
  - 双向链表维护使用顺序：
    - 链表头（Head）：最近使用（MRU）
    - 链表尾（Tail）：最久未使用（LRU）
- 操作语义：
  - `get(key)`: 如果命中，将该节点移动到链表头；未命中返回 `null`。
  - `put(key, value)`: 
    - 若键已存在，更新值并把节点移动到链表头；
    - 若键不存在，创建新节点加到链表头；
    - 如容量超限，淘汰尾节点（LRU）。
- 复杂度：`get`/`put` 均为 O(1)。

## 两种常见实现方式
- 自行实现（哈希表 + 双向链表）：可控性高，适合教学与扩展。
- 依赖 `LinkedHashMap`：设置访问顺序 `accessOrder=true` 并重写 `removeEldestEntry` 即可快速实现，适合简单场景。

## API 设计与可见性（Kotlin）
- 对外暴露（public）：
  - `get(key: K): V?` 获取并提升到最近使用。
  - `put(key: K, value: V)` 写入/更新并维护容量与淘汰。
  - `remove(key: K): V?` 移除并返回旧值。
  - `size(): Int` 当前缓存项数量。
  - `clear()` 清空缓存。
- 内部/调试（internal）：
  - `keys(): List<K>` 返回从最近到最久的键序，用于观测顺序，不作为稳定外部 API。
- 私有（private）：
  - 节点结构与链表维护函数：`Node`、`addToHead`、`removeNode`、`moveToHead`。

以上可见性在 `LruCache.kt` 中已明确设置，满足“对外 API 简洁、内部细节封装”的工程化要求。

## Kotlin 代码实现（哈希表 + 双向链表）
```kotlin
package algorithms

class LruCache<K, V>(private val capacity: Int) {
    init { require(capacity > 0) { "capacity must be > 0" } }

    private data class Node<K, V>(
        var key: K,
        var value: V,
        var prev: Node<K, V>? = null,
        var next: Node<K, V>? = null
    )

    private val map = HashMap<K, Node<K, V>>()
    private var head: Node<K, V>? = null // MRU
    private var tail: Node<K, V>? = null // LRU

    fun get(key: K): V? {
        val node = map[key] ?: return null
        moveToHead(node)
        return node.value
    }

    fun put(key: K, value: V) {
        val node = map[key]
        if (node != null) {
            node.value = value
            moveToHead(node)
        } else {
            val newNode = Node(key, value)
            map[key] = newNode
            addToHead(newNode)
            if (map.size > capacity) {
                tail?.let { toRemove ->
                    removeNode(toRemove)
                    map.remove(toRemove.key)
                }
            }
        }
    }

    fun remove(key: K): V? {
        val node = map.remove(key) ?: return null
        removeNode(node)
        return node.value
    }

    fun size(): Int = map.size

    fun keys(): List<K> {
        val list = mutableListOf<K>()
        var cur = head
        while (cur != null) {
            list.add(cur.key)
            cur = cur.next
        }
        return list
    }

    fun clear() {
        map.clear()
        head = null
        tail = null
    }

    private fun addToHead(node: Node<K, V>) {
        node.prev = null
        node.next = head
        head?.prev = node
        head = node
        if (tail == null) tail = node
    }

    private fun removeNode(node: Node<K, V>) {
        val p = node.prev
        val n = node.next
        if (p != null) p.next = n else head = n
        if (n != null) n.prev = p else tail = p
        node.prev = null
        node.next = null
    }

    private fun moveToHead(node: Node<K, V>) {
        removeNode(node)
        addToHead(node)
    }
}
```

## 使用示例（命令行环境）
- 假设你的源码在 `learning-materials/Algorithms/kotlin/src/main/kotlin/algorithms`：
```kotlin
package algorithms

fun demoLru() {
    val cache = LruCache<Int, String>(capacity = 3)
    cache.put(1, "A")
    cache.put(2, "B")
    cache.put(3, "C")
    println("初始: ${cache.keys()}") // 3,2,1 (头到尾)

    cache.get(2) // 访问2，提升优先级
    println("访问2后: ${cache.keys()}") // 2,3,1

    cache.put(4, "D") // 容量满，淘汰最久未使用：1
    println("插入4后: ${cache.keys()}") // 4,2,3

    cache.put(2, "B2") // 更新2并提升
    println("更新2后: ${cache.keys()}") // 2,4,3
}
```
- 你可以在 `Main.kt` 调用 `demoLru()`，或单独新建入口。

### Kotlin（不使用 Gradle）运行命令
- 进入目录：`cd learning-materials/Algorithms/kotlin`
- 打包运行：
  - `kotlinc src/main/kotlin -include-runtime -d app.jar`
  - `java -jar app.jar`
- 或类路径运行：
  - `kotlinc src/main/kotlin -d out`
  - `kotlin -cp out algorithms.MainKt`

## 复杂度与性能
- 时间复杂度：`get`/`put` 均为 O(1)。
- 空间复杂度：O(N)，N 为缓存容量。
- 性能建议：
  - 依据实际数据分布与命中率评估容量大小。
  - 热点数据访问频繁时，LRU 能显著提升性能；如存在“扫描型访问”（一次性访问大量不重复数据），可考虑 LFU/ARC 等策略。

## 边界与常见坑
- 容量必须 > 0（已在实现中校验）。
- 更新已存在键时要提升优先级，否则顺序不正确。
- 注意线程安全：当前实现非线程安全，必要时用外部锁或使用并发容器封装。
- 对象释放：清理时确保不再被链表引用，避免内存泄漏（实现中已断开指针）。

## 与其他策略对比
- FIFO：按进入顺序淘汰，简单但不考虑最近访问性。
- LFU：淘汰访问频率最低的数据，更关注长周期的“热度”。
- LRU：在多数通用场景下表现稳健、实现简单，是工程中最常用的缓存淘汰策略之一。

## Swift 语法要点（与示例相关）
- 泛型约束与字典键：`LruCache<Key: Hashable, Value>` 中 `Key: Hashable` 要求键可哈希，才能作为 `Dictionary` 的键（`[Key: Node]`）。
- 参数标签与 `_`：`get(_ key: Key)` 通过 `_` 省略外部标签，调用更自然；`put(key:value:)` 保留标签以提升可读性。
- 实例引用：Swift 使用 `self` 指代当前实例（类似 Kotlin/Java 的 `this`）。在初始化器与闭包中常显式写 `self` 以消除歧义。
- 访问控制与 `final`：`public`/`internal`/`private` 控制可见性；`final class` 禁止继承，利于内联优化与语义稳定。
- 可选类型与早退：返回 `Value?` 表示可能为 `nil`；`guard let`/`if let` 常用于安全解包并早退。
- 结果可丢弃：`@discardableResult` 允许忽略返回值（本文用于 `remove`）。
- 链表维护私有化：`addToHead`、`removeNode`、`moveToHead` 作为私有方法，确保双向链表在任何更新后保持一致性。

## Swift 代码实现（HashMap + 双向链表）
```swift
import Foundation

public final class LruCache<Key: Hashable, Value> {
    private let capacity: Int
    private final class Node {
        var key: Key
        var value: Value
        var prev: Node?
        var next: Node?
        init(key: Key, value: Value) { self.key = key; self.value = value }
    }
    private var map: [Key: Node] = [:]
    private var head: Node? // MRU
    private var tail: Node? // LRU

    public init(capacity: Int) {
        precondition(capacity > 0, "capacity must be > 0")
        self.capacity = capacity
    }
    public func get(_ key: Key) -> Value? {
        guard let node = map[key] else { return nil }
        moveToHead(node)
        return node.value
    }
    public func put(key: Key, value: Value) {
        if let node = map[key] {
            node.value = value
            moveToHead(node)
        } else {
            let newNode = Node(key: key, value: value)
            map[key] = newNode
            addToHead(newNode)
            if map.count > capacity, let toRemove = tail {
                removeNode(toRemove)
                map.removeValue(forKey: toRemove.key)
            }
        }
    }
    @discardableResult
    public func remove(_ key: Key) -> Value? {
        guard let node = map.removeValue(forKey: key) else { return nil }
        removeNode(node); return node.value
    }
    public var size: Int { map.count }
    internal func keys() -> [Key] {
        var result: [Key] = []; var cur = head
        while let n = cur { result.append(n.key); cur = n.next }
        return result
    }
    public func clear() { map.removeAll(); head = nil; tail = nil }
    private func addToHead(_ node: Node) {
        node.prev = nil; node.next = head
        head?.prev = node; head = node
        if tail == nil { tail = node }
    }
    private func removeNode(_ node: Node) {
        let p = node.prev, n = node.next
        if let p = p { p.next = n } else { head = n }
        if let n = n { n.prev = p } else { tail = p }
        node.prev = nil; node.next = nil
    }
    private func moveToHead(_ node: Node) { removeNode(node); addToHead(node) }
}
```

### 使用示例（SwiftPM）
```swift
func demoLruSwift() {
    let cache = LruCache<Int, String>(capacity: 3)
    cache.put(key: 1, value: "A")
    cache.put(key: 2, value: "B")
    cache.put(key: 3, value: "C")
    print("LRU 初始: \(cache.keys())") // 3,2,1

    _ = cache.get(2)
    print("LRU 访问2后: \(cache.keys())") // 2,3,1

    cache.put(key: 4, value: "D")
    print("LRU 插入4后: \(cache.keys())") // 4,2,3

    cache.put(key: 2, value: "B2")
    print("LRU 更新2后: \(cache.keys())") // 2,4,3
}
```
- 运行：`cd learning-materials/Algorithms/swift && swift run`
- 或在 Xcode 打开 `learning-materials/Algorithms/swift`（Swift Package）后直接运行。

## 结语
本文科普了 LRU 的原理与典型实现，给出 Kotlin 与 Swift 代码，并补充了与示例相关的 Swift 语法要点。对于命令行轻量开发，这种实现方式易读、易扩展、易运行。你可以在此基础上继续增加统计、TTL、权重、字节级容量等特性，服务更复杂的业务需求。

## 科普扩展：工程实践与常见变体

- 进阶策略与变体：
  - 2Q：将缓存分为 A1（新进入、一次访问）与 Am（多次访问），减少“扫描型访问”污染。
  - ARC（Adaptive Replacement Cache）：自适应融合最近访问与频繁访问两类集合，动态权衡。
  - LIRS：用“复用间隔”度量热度，较 LRU 更抗顺序扫描，适用于磁盘/数据库缓存。
  - LFU/TinyLFU：基于访问频率的淘汰；TinyLFU 常用于“准入”阶段，结合 LRU 提升整体命中率。
  - SLRU（分段 LRU）：热区与冷区分段，命中升级、淘汰从冷区发生，降低热点被误淘汰。

- 容量度量与权重：
  - 条目计数：以 Key 数量为容量（本文示例）。实现简单，适用于轻量场景。
  - 字节级容量/权重：根据对象大小或自定义成本（如图片像素、序列化字节数）来计量；
    - Java：常见库支持 `weigher`/`maximumWeight`；
    - Swift：`NSCache` 支持 `totalCostLimit`，可通过 `setObject(_:forKey:cost:)` 记录成本。
  - 权衡：权重越精细，淘汰更符合真实资源消耗，但度量成本与准确性需平衡。

- 过期策略与淘汰时机：
  - TTL（绝对过期）与 Idle（滑动过期）：分别按创建时间或最近访问时间失效。
  - 主动淘汰 vs 惰性淘汰：主动用定时器/后台任务清理；惰性在访问时检测并淘汰，降低维护开销。
  - 异步刷新/回源：值临近过期时异步刷新，避免请求抖动；失败时优雅降级回源。

- 并发模式与性能：
  - 单锁（推荐起步）：实现最简单，保持结构一致性与内存可见性。
  - 分片（Sharding，推荐首选）：按 Key 取模拆分多个独立 LRU，提升并发吞吐，降低锁竞争。
  - 乐观读 + 短写锁：如 Java 的 `StampedLock` 思路，读多写少场景下可降低写锁持有时间。
  - 近似策略：异步重排、`tryLock` 跳过重排等，以牺牲少量准确性换取更高吞吐。

- 工程落地与监控：
  - 关键指标：命中率、淘汰次数、平均驻留时间、回源次数/耗时、内存/字节使用量。
  - 扫描型访问防御：检测一次性大批不重复访问，触发降级策略或限流，避免缓存被污染。
  - 预热与分层：启动/部署后预热热点；前台内存缓存 + 后台持久层/分布式缓存分层。
  - 限制与降级：设置上限与保护阈值，OOM 前主动降级；观察 GC/ARC 行为与峰值内存。

- 常用库与平台特性：
  - Java：`Caffeine`（W-TinyLFU + 高性能并发结构，支持权重、统计、异步刷新）、`Guava Cache`。
  - Swift：`NSCache` 线程安全、在内存压力下自动回收，但策略并非严格 LRU，适合 UI 资源缓存。
  - Kotlin/多平台：可移植的简化实现用于教学/轻量工具，生产可接入 JVM 端成熟库或自研分片缓存。