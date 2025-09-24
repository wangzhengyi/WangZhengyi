//
//  PerformanceTracker.swift
//  StartupAnalyzer
//
//  性能追踪器 - 深度性能监控和分析
//  Created for iOS Startup Optimization Learning
//

import Foundation
import UIKit
import QuartzCore

/// 性能追踪器
/// 提供更详细的性能监控功能，包括 FPS、内存、CPU、磁盘 I/O 等
class PerformanceTracker {
    
    // MARK: - 单例模式
    static let shared = PerformanceTracker()
    private init() {}
    
    // MARK: - 性能指标结构体
    
    /// 综合性能指标
    struct PerformanceMetrics {
        let fps: Double
        let memoryUsage: Double
        let cpuUsage: Double
        let diskIORate: Double
        
        var overallScore: Int {
            var score = 100
            
            // FPS 评分
            if fps < 30 { score -= 30 }
            else if fps < 45 { score -= 15 }
            else if fps < 55 { score -= 5 }
            
            // 内存评分
            if memoryUsage > 300 { score -= 25 }
            else if memoryUsage > 200 { score -= 15 }
            else if memoryUsage > 100 { score -= 5 }
            
            // CPU 评分
            if cpuUsage > 80 { score -= 25 }
            else if cpuUsage > 60 { score -= 15 }
            else if cpuUsage > 30 { score -= 5 }
            
            // 磁盘I/O 评分
            if diskIORate > 100 { score -= 20 }
            else if diskIORate > 50 { score -= 10 }
            else if diskIORate > 10 { score -= 3 }
            
            return max(0, score)
        }
    }

    /// FPS 监控数据
    struct FPSMetrics {
        let timestamp: TimeInterval
        let fps: Double
        let frameTime: TimeInterval  // 单帧耗时
        
        var isSmooth: Bool {
            return fps >= 55.0  // 认为 55+ FPS 为流畅
        }
        
        var performanceLevel: PerformanceLevel {
            switch fps {
            case 55...60: return .excellent
            case 45..<55: return .good
            case 30..<45: return .fair
            default: return .poor
            }
        }
    }
    
    /// 内存监控数据
    struct MemoryMetrics {
        let timestamp: TimeInterval
        let usedMemory: UInt64      // 已使用内存 (bytes)
        let availableMemory: UInt64 // 可用内存 (bytes)
        let memoryPressure: MemoryPressure
        
        var usedMemoryMB: Double {
            return Double(usedMemory) / (1024 * 1024)
        }
        
        var availableMemoryMB: Double {
            return Double(availableMemory) / (1024 * 1024)
        }
        
        var memoryUsagePercentage: Double {
            let total = usedMemory + availableMemory
            return total > 0 ? Double(usedMemory) / Double(total) * 100 : 0
        }
    }
    
    /// CPU 监控数据
    struct CPUMetrics {
        let timestamp: TimeInterval
        let cpuUsage: Double        // CPU 使用率 (0.0-1.0)
        let userTime: Double        // 用户态时间
        let systemTime: Double     // 内核态时间
        
        var cpuUsagePercentage: Double {
            return cpuUsage * 100
        }
        
        var performanceLevel: PerformanceLevel {
            switch cpuUsage {
            case 0.0..<0.3: return .excellent
            case 0.3..<0.6: return .good
            case 0.6..<0.8: return .fair
            default: return .poor
            }
        }
    }
    
    /// 磁盘 I/O 监控数据
    struct DiskIOMetrics {
        let timestamp: TimeInterval
        let readBytes: UInt64       // 读取字节数
        let writeBytes: UInt64      // 写入字节数
        let readOperations: UInt64  // 读取操作次数
        let writeOperations: UInt64 // 写入操作次数
        
        var totalBytes: UInt64 {
            return readBytes + writeBytes
        }
        
        var totalOperations: UInt64 {
            return readOperations + writeOperations
        }
    }
    
    // MARK: - 枚举定义
    
    enum PerformanceLevel: String, CaseIterable {
        case excellent = "优秀"
        case good = "良好"
        case fair = "一般"
        case poor = "较差"
        
        var color: UIColor {
            switch self {
            case .excellent: return .systemGreen
            case .good: return .systemBlue
            case .fair: return .systemOrange
            case .poor: return .systemRed
            }
        }
        
        var emoji: String {
            switch self {
            case .excellent: return "🟢"
            case .good: return "🔵"
            case .fair: return "🟡"
            case .poor: return "🔴"
            }
        }
    }
    
    enum MemoryPressure: String {
        case normal = "正常"
        case warning = "警告"
        case critical = "严重"
        
        var color: UIColor {
            switch self {
            case .normal: return .systemGreen
            case .warning: return .systemOrange
            case .critical: return .systemRed
            }
        }
    }
    
    // MARK: - 私有属性
    
    private var isTracking = false
    private var displayLink: CADisplayLink?
    private var trackingTimer: Timer?
    
    // 性能数据存储
    private var fpsHistory: [FPSMetrics] = []
    private var memoryHistory: [MemoryMetrics] = []
    private var cpuHistory: [CPUMetrics] = []
    private var diskIOHistory: [DiskIOMetrics] = []
    
    // FPS 监控相关
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    
    // CPU 监控相关
    private var lastCPUInfo: processor_info_array_t?
    private var lastCPUTime: TimeInterval = 0
    
    // MARK: - 公开属性
    
    var onFPSUpdated: ((FPSMetrics) -> Void)?
    var onMemoryUpdated: ((MemoryMetrics) -> Void)?
    var onCPUUpdated: ((CPUMetrics) -> Void)?
    var onDiskIOUpdated: ((DiskIOMetrics) -> Void)?
    
    // MARK: - 追踪控制
    

}

// MARK: - 便捷访问扩展

extension PerformanceTracker {
    
    /// 获取当前性能状态
    func getCurrentMetrics() -> PerformanceMetrics {
        let latestFPS = fpsHistory.last?.fps ?? 0.0
        let latestMemory = memoryHistory.last?.usedMemoryMB ?? 0.0
        let latestCPU = cpuHistory.last?.cpuUsagePercentage ?? 0.0
        let latestDiskIO = diskIOHistory.last?.totalBytes ?? 0
        
        return PerformanceMetrics(
            fps: latestFPS,
            memoryUsage: latestMemory,
            cpuUsage: latestCPU,
            diskIORate: Double(latestDiskIO) / (1024 * 1024) // 转换为MB
        )
    }

    /// 开始性能追踪
    func startTracking() {
        guard !isTracking else { return }
        
        isTracking = true
        clearHistory()
        
        print("📊 [PerformanceTracker] 开始性能追踪...")
        
        // 开始 FPS 监控
        startFPSMonitoring()
        
        // 开始系统指标监控 (每秒更新)
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSystemMetrics()
        }
    }
    
    /// 停止性能追踪
    func stopTracking() {
        guard isTracking else { return }
        
        isTracking = false
        stopFPSMonitoring()
        trackingTimer?.invalidate()
        trackingTimer = nil
        
        print("⏹️ [PerformanceTracker] 停止性能追踪")
        printPerformanceSummary()
    }
    
    /// 重置追踪器状态
    func reset() {
        stopTracking()
        clearHistory()
        lastTimestamp = 0
        frameCount = 0
        lastCPUTime = 0
        onFPSUpdated = nil
        onMemoryUpdated = nil
        onCPUUpdated = nil
        onDiskIOUpdated = nil
        print("🔄 [PerformanceTracker] 追踪器已重置")
    }
    
    // MARK: - FPS 监控
    
    private func startFPSMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
        lastTimestamp = CACurrentMediaTime()
        frameCount = 0
    }
    
    private func stopFPSMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkTick() {
        let currentTime = CACurrentMediaTime()
        frameCount += 1
        
        // 每秒计算一次 FPS
        let deltaTime = currentTime - lastTimestamp
        if deltaTime >= 1.0 {
            let fps = Double(frameCount) / deltaTime
            let frameTime = deltaTime / Double(frameCount)
            
            let fpsMetric = FPSMetrics(
                timestamp: currentTime,
                fps: fps,
                frameTime: frameTime
            )
            
            fpsHistory.append(fpsMetric)
            onFPSUpdated?(fpsMetric)
            
            // 重置计数器
            lastTimestamp = currentTime
            frameCount = 0
        }
    }
    
    // MARK: - 系统指标监控
    
    private func updateSystemMetrics() {
        let currentTime = CACurrentMediaTime()
        
        // 更新内存指标
        updateMemoryMetrics(timestamp: currentTime)
        
        // 更新 CPU 指标
        updateCPUMetrics(timestamp: currentTime)
        
        // 更新磁盘 I/O 指标
        updateDiskIOMetrics(timestamp: currentTime)
    }
    
    private func updateMemoryMetrics(timestamp: TimeInterval) {
        let memoryInfo = getMemoryInfo()
        let memoryPressure = getMemoryPressure()
        
        let memoryMetric = MemoryMetrics(
            timestamp: timestamp,
            usedMemory: memoryInfo.used,
            availableMemory: memoryInfo.available,
            memoryPressure: memoryPressure
        )
        
        memoryHistory.append(memoryMetric)
        onMemoryUpdated?(memoryMetric)
    }
    
    private func updateCPUMetrics(timestamp: TimeInterval) {
        let cpuInfo = getCPUInfo()
        
        let cpuMetric = CPUMetrics(
            timestamp: timestamp,
            cpuUsage: cpuInfo.usage,
            userTime: cpuInfo.userTime,
            systemTime: cpuInfo.systemTime
        )
        
        cpuHistory.append(cpuMetric)
        onCPUUpdated?(cpuMetric)
    }
    
    private func updateDiskIOMetrics(timestamp: TimeInterval) {
        let diskInfo = getDiskIOInfo()
        
        let diskMetric = DiskIOMetrics(
            timestamp: timestamp,
            readBytes: diskInfo.readBytes,
            writeBytes: diskInfo.writeBytes,
            readOperations: diskInfo.readOps,
            writeOperations: diskInfo.writeOps
        )
        
        diskIOHistory.append(diskMetric)
        onDiskIOUpdated?(diskMetric)
    }
    
    // MARK: - 系统信息获取
    
    private func getMemoryInfo() -> (used: UInt64, available: UInt64) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // 获取系统总内存
            let totalMemory = ProcessInfo.processInfo.physicalMemory
            let usedMemory = info.resident_size
            let availableMemory = totalMemory - usedMemory
            
            return (usedMemory, availableMemory)
        }
        
        return (0, 0)
    }
    
    private func getMemoryPressure() -> MemoryPressure {
        // 简化的内存压力检测
        let memoryInfo = getMemoryInfo()
        let usagePercentage = Double(memoryInfo.used) / Double(memoryInfo.used + memoryInfo.available) * 100
        
        switch usagePercentage {
        case 0..<70: return .normal
        case 70..<85: return .warning
        default: return .critical
        }
    }
    
    private func getCPUInfo() -> (usage: Double, userTime: Double, systemTime: Double) {
        var info: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &info,
                                       &numCpuInfo)
        
        if result == KERN_SUCCESS {
            // 简化的 CPU 使用率计算
            // 实际项目中需要更复杂的计算逻辑
            if let cpuInfo = info {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo))
            }
            let usage = Double.random(in: 0.1...0.3) // 模拟数据
            return (usage, usage * 0.7, usage * 0.3)
        }
        
        return (0.0, 0.0, 0.0)
    }
    
    private func getDiskIOInfo() -> (readBytes: UInt64, writeBytes: UInt64, readOps: UInt64, writeOps: UInt64) {
        // 简化的磁盘 I/O 监控
        // 实际项目中需要使用 IOKit 或其他系统 API
        return (
            readBytes: UInt64.random(in: 1024...8192),
            writeBytes: UInt64.random(in: 512...4096),
            readOps: UInt64.random(in: 1...10),
            writeOps: UInt64.random(in: 1...5)
        )
    }
    
    // MARK: - 数据分析
    
    /// 获取平均 FPS
    func getAverageFPS() -> Double {
        guard !fpsHistory.isEmpty else { return 0 }
        let totalFPS = fpsHistory.reduce(0) { $0 + $1.fps }
        return totalFPS / Double(fpsHistory.count)
    }
    
    /// 获取最低 FPS
    func getMinFPS() -> Double {
        return fpsHistory.map { $0.fps }.min() ?? 0
    }
    
    /// 获取平均内存使用量
    func getAverageMemoryUsage() -> Double {
        guard !memoryHistory.isEmpty else { return 0 }
        let totalMemory = memoryHistory.reduce(0) { $0 + $1.usedMemoryMB }
        return totalMemory / Double(memoryHistory.count)
    }
    
    /// 获取内存峰值
    func getPeakMemoryUsage() -> Double {
        return memoryHistory.map { $0.usedMemoryMB }.max() ?? 0
    }
    
    /// 获取平均 CPU 使用率
    func getAverageCPUUsage() -> Double {
        guard !cpuHistory.isEmpty else { return 0 }
        let totalCPU = cpuHistory.reduce(0) { $0 + $1.cpuUsagePercentage }
        return totalCPU / Double(cpuHistory.count)
    }
    
    /// 清空历史数据
    private func clearHistory() {
        fpsHistory.removeAll()
        memoryHistory.removeAll()
        cpuHistory.removeAll()
        diskIOHistory.removeAll()
    }
    
    /// 打印性能摘要
    private func printPerformanceSummary() {
        print("\n📈 === 性能追踪摘要 ===")
        print("平均 FPS: \(String(format: "%.1f", getAverageFPS()))")
        print("最低 FPS: \(String(format: "%.1f", getMinFPS()))")
        print("平均内存: \(String(format: "%.2f MB", getAverageMemoryUsage()))")
        print("内存峰值: \(String(format: "%.2f MB", getPeakMemoryUsage()))")
        print("平均 CPU: \(String(format: "%.1f%%", getAverageCPUUsage()))")
        print("数据点数: FPS(\(fpsHistory.count)), 内存(\(memoryHistory.count)), CPU(\(cpuHistory.count))")
        print("========================\n")
    }
}

// MARK: - 便捷访问扩展

extension PerformanceTracker {
    
    /// 获取当前性能状态
    func getCurrentPerformanceStatus() -> (fps: PerformanceLevel, cpu: PerformanceLevel, memory: MemoryPressure) {
        let latestFPS = fpsHistory.last?.performanceLevel ?? .poor
        let latestCPU = cpuHistory.last?.performanceLevel ?? .poor
        let latestMemory = memoryHistory.last?.memoryPressure ?? .critical
        
        return (latestFPS, latestCPU, latestMemory)
    }
    
    /// 获取跟踪状态
    func getIsTracking() -> Bool {
        return isTracking
    }
    
    /// 记录内存警告
    func recordMemoryWarning() {
        let timestamp = CACurrentMediaTime()
        let memoryInfo = getMemoryInfo()
        let memoryMetrics = MemoryMetrics(
            timestamp: timestamp,
            usedMemory: memoryInfo.used,
            availableMemory: memoryInfo.available,
            memoryPressure: .critical
        )
        
        memoryHistory.append(memoryMetrics)
        onMemoryUpdated?(memoryMetrics)
        
        print("⚠️ 内存警告记录: 使用 \(memoryMetrics.usedMemoryMB) MB")
    }
    
    /// 获取格式化的性能报告
    func getFormattedPerformanceReport() -> String {
        var report = "性能追踪报告\n"
        report += "================\n"
        report += "📱 FPS 性能\n"
        report += "  平均: \(String(format: "%.1f", getAverageFPS())) FPS\n"
        report += "  最低: \(String(format: "%.1f", getMinFPS())) FPS\n\n"
        
        report += "🧠 内存使用\n"
        report += "  平均: \(String(format: "%.2f MB", getAverageMemoryUsage()))\n"
        report += "  峰值: \(String(format: "%.2f MB", getPeakMemoryUsage()))\n\n"
        
        report += "⚡ CPU 使用\n"
        report += "  平均: \(String(format: "%.1f%%", getAverageCPUUsage()))\n\n"
        
        let status = getCurrentPerformanceStatus()
        report += "📊 当前状态\n"
        report += "  FPS: \(status.fps.emoji) \(status.fps.rawValue)\n"
        report += "  CPU: \(status.cpu.emoji) \(status.cpu.rawValue)\n"
        report += "  内存: \(status.memory.rawValue)\n"
        
        return report
    }
}