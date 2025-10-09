// LRU Cache demo in C++
#include <iostream>
#include <string>
#include "LruCache.hpp"

int main() {
    LruCache<int, std::string> cache(3);

    cache.put(1, "A");
    cache.put(2, "B");
    cache.put(3, "C");

    auto printKeys = [&](const std::string& title) {
        std::cout << title << ": [";
        auto ks = cache.keys();
        for (size_t i = 0; i < ks.size(); ++i) {
            std::cout << ks[i];
            if (i + 1 < ks.size()) std::cout << ", ";
        }
        std::cout << "]\n";
    };

    printKeys("LRU 初始"); // 3,2,1

    auto v2 = cache.get(2);
    std::cout << "get(2): " << (v2 ? *v2 : std::string("null")) << "\n";
    printKeys("LRU 访问2后"); // 2,3,1

    cache.put(4, "D");
    printKeys("LRU 插入4后"); // 4,2,3

    cache.put(2, "B2");
    printKeys("LRU 更新2后"); // 2,4,3

    return 0;
}