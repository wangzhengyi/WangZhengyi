# Algorithms Workspace（极简版）

该目录提供使用 Swift、Kotlin、Java 编写与运行算法题的最小化结构，不依赖 Gradle 等构建工具（Swift 保留 SwiftPM，亦可直接用 `swiftc`）。

## 目录结构
- `swift/`：Swift 示例（SwiftPM 包，亦可用 `swift run`）
- `kotlin/`：Kotlin 源码（纯命令行编译运行）
  - `src/main/kotlin/algorithms/Main.kt`
- `java/`：Java 源码（纯命令行编译运行）
  - `src/main/java/algorithms/Main.java`

## 运行方式（命令行）

### Kotlin（不使用 Gradle）
- 进入目录：`cd learning-materials/Algorithms/kotlin`
- 方式 A：打可执行 JAR（推荐）
  - `kotlinc src/main/kotlin -include-runtime -d app.jar`
  - `java -jar app.jar`
- 方式 B：类文件 + 解释器
  - `kotlinc src/main/kotlin -d out`
  - `kotlin -cp out algorithms.MainKt`

### Java（不使用 Gradle）
- 进入目录：`cd learning-materials/Algorithms/java`
- 编译：`find src/main/java -name "*.java" | xargs javac -d out`
- 运行：`java -cp out algorithms.Main`

### Swift
- 进入目录：`cd learning-materials/Algorithms/swift`
- 使用 SwiftPM：`swift build && swift run`
- 或直接编译：`swiftc Sources/AlgorithmsSwift/main.swift -o run && ./run`

## 新增算法建议
- Kotlin/Java：在各自 `algorithms/` 包下新增文件与方法，并在入口 `Main.kt` / `Main.java` 调用示例。
- Swift：在 `Sources/AlgorithmsSwift` 下新增文件，并在 `main.swift` 中调用示例。