import Foundation

public final class LruCache<Key: Hashable, Value> {
    private let capacity: Int

    private final class Node {
        var key: Key
        var value: Value
        var prev: Node?
        var next: Node?
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
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
            if map.count > capacity {
                if let toRemove = tail {
                    removeNode(toRemove)
                    map.removeValue(forKey: toRemove.key)
                }
            }
        }
    }

    @discardableResult
    public func remove(_ key: Key) -> Value? {
        guard let node = map.removeValue(forKey: key) else { return nil }
        removeNode(node)
        return node.value
    }

    public var size: Int { map.count }

    public func clear() {
        map.removeAll()
        head = nil
        tail = nil
    }

    internal func keys() -> [Key] {
        var result: [Key] = []
        var cur = head
        while let node = cur {
            result.append(node.key)
            cur = node.next
        }
        return result
    }

    private func addToHead(_ node: Node) {
        node.prev = nil
        node.next = head
        head?.prev = node
        head = node
        if tail == nil { tail = node }
    }

    private func removeNode(_ node: Node) {
        let p = node.prev
        let n = node.next
        if let p = p { p.next = n } else { head = n }
        if let n = n { n.prev = p } else { tail = p }
        node.prev = nil
        node.next = nil
    }

    private func moveToHead(_ node: Node) {
        removeNode(node)
        addToHead(node)
    }
}