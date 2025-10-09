package algorithms


// 示例：LRU 缓存
fun demoLru() {
    val cache = LruCache<Int, String>(capacity = 3)
    cache.put(1, "A")
    cache.put(2, "B")
    cache.put(3, "C")
    println("LRU 初始: ${cache.keys()}") // 3,2,1

    cache.get(2)
    println("LRU 访问2后: ${cache.keys()}") // 2,3,1

    cache.put(4, "D")
    println("LRU 插入4后: ${cache.keys()}") // 4,2,3

    cache.put(2, "B2")
    println("LRU 更新2后: ${cache.keys()}") // 2,4,3
}

fun main() {
    demoLru()
}