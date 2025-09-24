//
//  PerformanceMetrics.swift
//  StartupAnalyzer
//
//  性能指标数据模型 - 定义各种性能测量指标
//  Created for iOS Startup Optimization Learning
//

import Foundation

/// 性能指标数据结构
/// 包含启动过程中的各种性能测量数据
struct PerformanceMetrics {
    
    // MARK: - 基础指标
    
    /// 总启动时间（秒）
    let totalLaunchTime: TimeInterval
    
    /// 预启动时间（秒）
    let preLaunchTime: TimeInterval
    
    /// 主要启动时间（秒）
    let mainLaunchTime: TimeInterval
    
    /// 首次渲染时间（秒）
    let firstRenderTime: TimeInterval
    
    /// 记录时间戳
    let timestamp: Date
    
    // MARK: - CPU 指标
    
    /// CPU 使用率（百分比）
    let cpuUsage: Double
    
    /// CPU 核心数
    let cpuCoreCount: Int
    
    /// CPU 频率（MHz）
    let cpuFrequency: Double
    
    // MARK: - 内存指标
    
    /// 内存使用量（字节）
    let memoryUsage: UInt64
    
    /// 峰值内存使用量（字节）
    let peakMemoryUsage: UInt64
    
    /// 可用内存（字节）
    let availableMemory: UInt64
    
    /// 内存压力等级
    let memoryPressure: MemoryPressureLevel
    
    // MARK: - 磁盘 I/O 指标
    
    /// 磁盘读取字节数
    let diskReadBytes: UInt64
    
    /// 磁盘写入字节数
    let diskWriteBytes: UInt64
    
    /// 磁盘读取操作数
    let diskReadOps: UInt64
    
    /// 磁盘写入操作数
    let diskWriteOps: UInt64
    
    // MARK: - 网络指标
    
    /// 网络接收字节数
    let networkReceivedBytes: UInt64
    
    /// 网络发送字节数
    let networkSentBytes: UInt64
    
    /// 网络连接数
    let networkConnections: Int
    
    // MARK: - 应用指标
    
    /// 线程数量
    let threadCount: Int
    
    /// 文件描述符数量
    let fileDescriptorCount: Int
    
    /// 启动阶段数量
    let phaseCount: Int
    
    /// 性能评分（0-100）
    let performanceScore: Int
    
    // MARK: - 初始化方法
    
    init(
        totalLaunchTime: TimeInterval = 0,
        preLaunchTime: TimeInterval = 0,
        mainLaunchTime: TimeInterval = 0,
        firstRenderTime: TimeInterval = 0,
        timestamp: Date = Date(),
        cpuUsage: Double = 0,
        cpuCoreCount: Int = 0,
        cpuFrequency: Double = 0,
        memoryUsage: UInt64 = 0,
        peakMemoryUsage: UInt64 = 0,
        availableMemory: UInt64 = 0,
        memoryPressure: MemoryPressureLevel = .normal,
        diskReadBytes: UInt64 = 0,
        diskWriteBytes: UInt64 = 0,
        diskReadOps: UInt64 = 0,
        diskWriteOps: UInt64 = 0,
        networkReceivedBytes: UInt64 = 0,
        networkSentBytes: UInt64 = 0,
        networkConnections: Int = 0,
        threadCount: Int = 0,
        fileDescriptorCount: Int = 0,
        phaseCount: Int = 0,
        performanceScore: Int = 0
    ) {
        self.totalLaunchTime = totalLaunchTime
        self.preLaunchTime = preLaunchTime
        self.mainLaunchTime = mainLaunchTime
        self.firstRenderTime = firstRenderTime
        self.timestamp = timestamp
        self.cpuUsage = cpuUsage
        self.cpuCoreCount = cpuCoreCount
        self.cpuFrequency = cpuFrequency
        self.memoryUsage = memoryUsage
        self.peakMemoryUsage = peakMemoryUsage
        self.availableMemory = availableMemory
        self.memoryPressure = memoryPressure
        self.diskReadBytes = diskReadBytes
        self.diskWriteBytes = diskWriteBytes
        self.diskReadOps = diskReadOps
        self.diskWriteOps = diskWriteOps
        self.networkReceivedBytes = networkReceivedBytes
        self.networkSentBytes = networkSentBytes
        self.networkConnections = networkConnections
        self.threadCount = threadCount
        self.fileDescriptorCount = fileDescriptorCount
        self.phaseCount = phaseCount
        self.performanceScore = performanceScore
    }
    
    // MARK: - 计算属性
    
    /// 格式化的总启动时间
    var formattedTotalLaunchTime: String {
        return String(format: "%.3f ms", totalLaunchTime * 1000)
    }
    
    /// 格式化的内存使用量
    var formattedMemoryUsage: String {
        return ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
    }
    
    /// 格式化的峰值内存使用量
    var formattedPeakMemoryUsage: String {
        return ByteCountFormatter.string(fromByteCount: Int64(peakMemoryUsage), countStyle: .memory)
    }
    
    /// 格式化的磁盘读取量
    var formattedDiskReadBytes: String {
        return ByteCountFormatter.string(fromByteCount: Int64(diskReadBytes), countStyle: .file)
    }
    
    /// 格式化的磁盘写入量
    var formattedDiskWriteBytes: String {
        return ByteCountFormatter.string(fromByteCount: Int64(diskWriteBytes), countStyle: .file)
    }
    
    /// 性能等级
    var performanceLevel: PerformanceLevel {
        switch performanceScore {
        case 90...100:
            return .excellent
        case 75..<90:
            return .good
        case 60..<75:
            return .fair
        case 40..<60:
            return .poor
        default:
            return .critical
        }
    }
    
    /// 是否为高性能
    var isHighPerformance: Bool {
        return performanceScore >= 80 && totalLaunchTime <= 1.0
    }
    
    // MARK: - 静态方法
    
    /// 创建空的性能指标
    static func empty() -> PerformanceMetrics {
        return PerformanceMetrics()
    }
    
    /// 创建模拟性能指标
    static func mock() -> PerformanceMetrics {
        return PerformanceMetrics(
            totalLaunchTime: Double.random(in: 0.5...2.0),
            preLaunchTime: Double.random(in: 0.1...0.5),
            mainLaunchTime: Double.random(in: 0.3...1.2),
            firstRenderTime: Double.random(in: 0.1...0.3),
            timestamp: Date(),
            cpuUsage: Double.random(in: 10...80),
            cpuCoreCount: Int.random(in: 4...8),
            cpuFrequency: Double.random(in: 2000...3500),
            memoryUsage: UInt64.random(in: 50_000_000...200_000_000),
            peakMemoryUsage: UInt64.random(in: 80_000_000...300_000_000),
            availableMemory: UInt64.random(in: 1_000_000_000...4_000_000_000),
            memoryPressure: MemoryPressureLevel.allCases.randomElement() ?? .normal,
            diskReadBytes: UInt64.random(in: 1_000_000...50_000_000),
            diskWriteBytes: UInt64.random(in: 500_000...20_000_000),
            diskReadOps: UInt64.random(in: 100...1000),
            diskWriteOps: UInt64.random(in: 50...500),
            networkReceivedBytes: UInt64.random(in: 0...10_000_000),
            networkSentBytes: UInt64.random(in: 0...5_000_000),
            networkConnections: Int.random(in: 0...10),
            threadCount: Int.random(in: 5...20),
            fileDescriptorCount: Int.random(in: 10...100),
            phaseCount: Int.random(in: 8...15),
            performanceScore: Int.random(in: 60...95)
        )
    }
}

// MARK: - 支持枚举

/// 内存压力等级
enum MemoryPressureLevel: String, CaseIterable {
    case normal = "正常"
    case warning = "警告"
    case urgent = "紧急"
    case critical = "严重"
    
    var color: String {
        switch self {
        case .normal:
            return "systemGreen"
        case .warning:
            return "systemYellow"
        case .urgent:
            return "systemOrange"
        case .critical:
            return "systemRed"
        }
    }
}

/// 性能等级
enum PerformanceLevel: String, CaseIterable {
    case excellent = "优秀"
    case good = "良好"
    case fair = "一般"
    case poor = "较差"
    case critical = "严重"
    
    var color: String {
        switch self {
        case .excellent:
            return "systemGreen"
        case .good:
            return "systemBlue"
        case .fair:
            return "systemYellow"
        case .poor:
            return "systemOrange"
        case .critical:
            return "systemRed"
        }
    }
    
    var description: String {
        switch self {
        case .excellent:
            return "应用启动性能优秀，用户体验极佳"
        case .good:
            return "应用启动性能良好，用户体验较好"
        case .fair:
            return "应用启动性能一般，有优化空间"
        case .poor:
            return "应用启动性能较差，需要优化"
        case .critical:
            return "应用启动性能严重，急需优化"
        }
    }
}

// MARK: - Codable 支持

extension PerformanceMetrics: Codable {
    
    enum CodingKeys: String, CodingKey {
        case totalLaunchTime
        case preLaunchTime
        case mainLaunchTime
        case firstRenderTime
        case timestamp
        case cpuUsage
        case cpuCoreCount
        case cpuFrequency
        case memoryUsage
        case peakMemoryUsage
        case availableMemory
        case memoryPressure
        case diskReadBytes
        case diskWriteBytes
        case diskReadOps
        case diskWriteOps
        case networkReceivedBytes
        case networkSentBytes
        case networkConnections
        case threadCount
        case fileDescriptorCount
        case phaseCount
        case performanceScore
    }
}

// MARK: - Equatable 支持

extension PerformanceMetrics: Equatable {
    
    static func == (lhs: PerformanceMetrics, rhs: PerformanceMetrics) -> Bool {
        return lhs.timestamp == rhs.timestamp &&
               lhs.totalLaunchTime == rhs.totalLaunchTime &&
               lhs.performanceScore == rhs.performanceScore
    }
}

// MARK: - Hashable 支持

extension PerformanceMetrics: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
        hasher.combine(totalLaunchTime)
        hasher.combine(performanceScore)
    }
}