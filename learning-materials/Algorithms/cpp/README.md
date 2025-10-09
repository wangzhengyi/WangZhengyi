## C++ LRU 缓存运行方式

目录结构：
- `src/LruCache.hpp`：模板类实现（`std::list + std::unordered_map`）。
- `src/main.cpp`：演示入口。

编译运行（不使用 CMake）：

```bash
cd learning-materials/Algorithms/cpp
g++ -std=c++17 -O2 -o run src/main.cpp
./run
```

如果使用 `clang++`：

```bash
clang++ -std=c++17 -O2 -o run src/main.cpp
./run
```

示例输出包含键的 LRU 顺序与 `get/put` 的效果，便于快速验证实现。