package algorithms

/**
 * LRU（最近最少使用）缓存实现：HashMap + 双向链表，get/put 均为 O(1)。
 * 适用于命令行轻量环境，无并发支持，如需并发请在外层加锁或改用并发容器。
 */
public class LruCache<K, V>(private val capacity: Int) {
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

    public fun get(key: K): V? {
        val node = map[key] ?: return null
        moveToHead(node)
        return node.value
    }

    public fun put(key: K, value: V) {
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

    public fun remove(key: K): V? {
        val node = map.remove(key) ?: return null
        removeNode(node)
        return node.value
    }

    public fun size(): Int = map.size

    internal fun keys(): List<K> {
        val list = mutableListOf<K>()
        var cur = head
        while (cur != null) {
            list.add(cur.key)
            cur = cur.next
        }
        return list
    }

    public fun clear() {
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