package algorithms

// 示例算法：Two Sum（两数之和）
fun twoSum(nums: IntArray, target: Int): IntArray {
    val map = HashMap<Int, Int>()
    for ((i, num) in nums.withIndex()) {
        val complement = target - num
        val j = map[complement]
        if (j != null) return intArrayOf(j, i)
        map[num] = i
    }
    return intArrayOf()
}

fun main() {
    val res = twoSum(intArrayOf(2, 7, 11, 15), 9)
    println("TwoSum => indices: ${res.joinToString()}")
}