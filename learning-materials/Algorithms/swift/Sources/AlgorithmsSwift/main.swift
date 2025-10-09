import Foundation

// 示例算法：Two Sum（两数之和）
func twoSum(_ nums: [Int], _ target: Int) -> (Int, Int)? {
    var dict: [Int: Int] = [:]
    for (i, num) in nums.enumerated() {
        if let j = dict[target - num] {
            return (j, i)
        }
        dict[num] = i
    }
    return nil
}

func demoTwoSum() {
    let nums = [2, 7, 11, 15]
    let target = 9
    if let (i, j) = twoSum(nums, target) {
        print("TwoSum => indices: \(i), \(j); values: \(nums[i]), \(nums[j])")
    } else {
        print("No solution found")
    }
}

// 程序入口
demoTwoSum()