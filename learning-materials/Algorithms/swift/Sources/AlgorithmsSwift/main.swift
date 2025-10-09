import Foundation

func demoLruSwift() {
    let cache = LruCache<Int, String>(capacity: 3)
    cache.put(key: 1, value: "A")
    cache.put(key: 2, value: "B")
    cache.put(key: 3, value: "C")
    print("LRU 初始: \(cache.keys())")

    _ = cache.get(2)
    print("LRU 访问2后: \(cache.keys())")

    cache.put(key: 4, value: "D")
    print("LRU 插入4后: \(cache.keys())")

    cache.put(key: 2, value: "B2")
    print("LRU 更新2后: \(cache.keys())")
}

// 程序入口
demoLruSwift()