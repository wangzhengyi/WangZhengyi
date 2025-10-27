//
//  StartupMonitor.swift
//  StartupAnalyzer
//
//  iOS 启动监控器 - 核心监控模块
//  Created for iOS Startup Optimization Learning
//

import Foundation
import UIKit
import QuartzCore

/// iOS 启动监控器
/// 负责监控应用启动过程中的各个关键节点和性能指标
class StartupMonitor {
    
    // MARK: - 单例模式
    static let shared = StartupMonitor()
    private init() {
        setupMonitoring()
    }
    
    // MARK: - 启动阶段枚举
    enum LaunchPhase: String, CaseIterable {
        case preMain = "Pre-main"           // Pre-main 阶段
        case applicationInit = "App Init"    // Application 初始化
        case sceneSetup = "Scene Setup"     // Scene 配置
        case firstViewLoad = "First View"   // 首个视图加载
        case firstRender = "First Render"   // 首次渲染完成
        case launchComplete = "Complete"    // 启动完成
        
        var description: String {
            switch self {
            case .preMain:
                return "系统加载 dylib、Runtime 初始化"
            case .applicationInit:
                return "Application 委托方法执行"
            case .sceneSetup:
                return "Scene 委托和窗口配置"
            case .firstViewLoad:
                return "首个 ViewController 加载"
            case .firstRender:
                return "首屏 UI 渲染完成"
            case .launchComplete:
                return "应用启动流程完全结束"
            }
        }
    }
    
    // MARK: - 性能指标结构体
    struct StartupMetrics {
        let phase: LaunchPhase
        let timestamp: CFAbsoluteTime      // 绝对时间戳
        let relativeTime: TimeInterval     // 相对启动开始的时间
        let memoryUsage: UInt64           // 内存使用量 (bytes)
        let cpuUsage: Double              // CPU 使用率 (0.0-1.0)
        
        var formattedTime: String {
            return String(format: "%.3f ms", relativeTime * 1000)
        }
        
        var formattedMemory: String {
            let mb = Double(memoryUsage) / (1024 * 1024)
            return String(format: "%.2f MB", mb)
        }
        
        var formattedCPU: String {
            return String(format: "%.1f%%", cpuUsage * 100)
        }
    }
    
    // MARK: - 私有属性
    private var startTime: CFAbsoluteTime = 0
    private var metrics: [StartupMetrics] = []
    private var isMonitoring = false
    private var displayLink: CADisplayLink?
    
    // MARK: - 公开属性
    var onMetricsUpdated: ((StartupMetrics) -> Void)?
    var onLaunchCompleted: (([StartupMetrics]) -> Void)?
    
    // MARK: - 监控控制
    
    /// 开始启动监控
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        startTime = CFAbsoluteTimeGetCurrent()
        isMonitoring = true
        metrics.removeAll()
        
        print("🚀 [StartupMonitor] 开始监控应用启动...")
        
        // 记录监控开始节点
        recordPhase(.applicationInit)
        
        // 开始渲染监控
        startRenderMonitoring()
    }
    
    /// 停止启动监控
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        stopRenderMonitoring()
        
        print("⏹️ [StartupMonitor] 停止监控")
        
        // 打印总结报告
        printSummary()
        
        // 通知监控完成
        onLaunchCompleted?(metrics)
    }
    
    /// 重置监控器状态
    func reset() {
        stopMonitoring()
        metrics.removeAll()
        startTime = 0
        onMetricsUpdated = nil
        onLaunchCompleted = nil
        print("🔄 [StartupMonitor] 监控器已重置")
    }
    
    /// 记录启动阶段
    func recordPhase(_ phase: LaunchPhase) {
        guard isMonitoring else { return }
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let relativeTime = currentTime - startTime
        let memoryUsage = getCurrentMemoryUsage()
        let cpuUsage = getCurrentCPUUsage()
        
        let metric = StartupMetrics(
            phase: phase,
            timestamp: currentTime,
            relativeTime: relativeTime,
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage
        )
        
        metrics.append(metric)
        
        print("📊 [\(phase.rawValue)] \(metric.formattedTime) | 内存: \(metric.formattedMemory) | CPU: \(metric.formattedCPU)")
        
        // 通知指标更新
        onMetricsUpdated?(metric)
    }
    
    // MARK: - 渲染监控
    
    private func startRenderMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopRenderMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkTick() {
        // 监控首次渲染完成
        // 这里可以根据具体需求判断首屏渲染是否完成
    }
    
    // MARK: - 系统指标获取
    
    /// 获取当前内存使用量
    private func getCurrentMemoryUsage() -> UInt64 {
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
            return info.resident_size
        } else {
            return 0
        }
    }
    
    /// 获取当前 CPU 使用率
    private func getCurrentCPUUsage() -> Double {
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
            return 0.1 // 占位值
        }
        
        return 0.0
    }
    
    // MARK: - 监控设置
    
    private func setupMonitoring() {
        // 监听应用生命周期通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidBecomeActive),
            name: UIScene.didActivateNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidFinishLaunching() {
        recordPhase(.applicationInit)
    }
    
    @objc private func sceneDidBecomeActive() {
        recordPhase(.sceneSetup)
    }
    
    // MARK: - 数据分析
    
    /// 获取启动总时间
    func getTotalLaunchTime() -> TimeInterval {
        guard let lastMetric = metrics.last else { return 0 }
        return lastMetric.relativeTime
    }
    
    /// 获取各阶段耗时
    func getPhaseTimings() -> [(LaunchPhase, TimeInterval)] {
        var timings: [(LaunchPhase, TimeInterval)] = []
        
        for i in 0..<metrics.count {
            let currentTime = metrics[i].relativeTime
            let previousTime = i > 0 ? metrics[i-1].relativeTime : 0
            let duration = currentTime - previousTime
            
            timings.append((metrics[i].phase, duration))
        }
        
        return timings
    }
    
    /// 获取内存峰值
    func getPeakMemoryUsage() -> UInt64 {
        return metrics.map { $0.memoryUsage }.max() ?? 0
    }
    
    /// 获取启动指标数据
    func getStartupMetrics() -> [StartupMetrics] {
        return metrics
    }
    
    /// 打印启动摘要
    private func printSummary() {
        print("\n📈 === 启动性能摘要 ===")
        print("总启动时间: \(String(format: "%.3f ms", getTotalLaunchTime() * 1000))")
        print("内存峰值: \(String(format: "%.2f MB", Double(getPeakMemoryUsage()) / (1024 * 1024)))")
        print("监控节点数: \(metrics.count)")
        
        print("\n⏱️ 各阶段耗时:")
        for (phase, duration) in getPhaseTimings() {
            print("  \(phase.rawValue): \(String(format: "%.3f ms", duration * 1000))")
        }
        print("========================\n")
    }
    
    // MARK: - 清理
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopRenderMonitoring()
    }
}

// MARK: - 便捷方法扩展

extension StartupMonitor {
    
    /// 便捷方法：记录视图加载完成
    func recordViewDidLoad(for viewController: String) {
        print("📱 [ViewDidLoad] \(viewController)")
        recordPhase(.firstViewLoad)
    }
    
    /// 便捷方法：记录首屏渲染完成
    func recordFirstRenderComplete() {
        print("🎨 [FirstRender] 首屏渲染完成")
        recordPhase(.firstRender)
    }
    
    /// 便捷方法：记录启动完成
    func recordStartupComplete() {
        print("✅ [StartupComplete] 应用启动完成")
        recordPhase(.launchComplete)
        stopMonitoring()
        printSummary()
        
        // 触发启动完成回调
        onLaunchCompleted?(metrics)
    }
    
    /// 便捷方法：获取格式化的启动报告
    func getFormattedReport() -> String {
        var report = "iOS 启动性能报告\n"
        report += "==================\n"
        report += "总启动时间: \(String(format: "%.3f ms", getTotalLaunchTime() * 1000))\n"
        report += "内存峰值: \(String(format: "%.2f MB", Double(getPeakMemoryUsage()) / (1024 * 1024)))\n\n"
        
        report += "详细时间线:\n"
        for metric in metrics {
            report += "[\(metric.phase.rawValue)] \(metric.formattedTime) - \(metric.phase.description)\n"
        }
        
        return report
    }
}