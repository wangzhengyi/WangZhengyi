//
//  StartupPhaseAnalyzer.swift
//  StartupAnalyzer
//
//  启动阶段分析器 - 详细分析iOS应用启动各阶段
//  Created for iOS Startup Optimization Learning
//

import Foundation
import UIKit

/// 启动阶段分析器
/// 负责分析和监控iOS应用启动的各个详细阶段
class StartupPhaseAnalyzer {
    
    // MARK: - 单例模式
    static let shared = StartupPhaseAnalyzer()
    private init() {}
    
    // MARK: - 启动阶段详细定义
    
    /// 启动阶段枚举
    enum StartupPhase: String, CaseIterable {
        // Pre-main 阶段
        case processCreation = "进程创建"
        case dylibLoading = "动态库加载"
        case rebase = "地址重定位"
        case binding = "符号绑定"
        case objcSetup = "ObjC运行时设置"
        case initializers = "初始化器执行"
        
        // Main 阶段
        case mainFunction = "main函数执行"
        case uikitInitialization = "UIKit初始化"
        case appDelegateDidFinishLaunching = "AppDelegate启动完成"
        case rootViewControllerSetup = "根视图控制器设置"
        case firstFrameRender = "首帧渲染"
        
        // Post-launch 阶段
        case viewDidLoad = "ViewDidLoad"
        case viewWillAppear = "ViewWillAppear"
        case viewDidAppear = "ViewDidAppear"
        case firstMeaningfulPaint = "首次有意义绘制"
        case fullyInteractive = "完全可交互"
        
        var category: PhaseCategory {
            switch self {
            case .processCreation, .dylibLoading, .rebase, .binding, .objcSetup, .initializers:
                return .preMain
            case .mainFunction, .uikitInitialization, .appDelegateDidFinishLaunching, .rootViewControllerSetup, .firstFrameRender:
                return .main
            case .viewDidLoad, .viewWillAppear, .viewDidAppear, .firstMeaningfulPaint, .fullyInteractive:
                return .postLaunch
            }
        }
        
        var description: String {
            switch self {
            case .processCreation:
                return "系统创建应用进程，分配内存空间"
            case .dylibLoading:
                return "加载应用依赖的动态库（dylib）"
            case .rebase:
                return "修正内部指针，适应ASLR随机地址"
            case .binding:
                return "绑定外部符号，解析函数地址"
            case .objcSetup:
                return "设置Objective-C运行时环境"
            case .initializers:
                return "执行C++静态构造函数和+load方法"
            case .mainFunction:
                return "执行main函数，启动应用主循环"
            case .uikitInitialization:
                return "初始化UIKit框架和UI系统"
            case .appDelegateDidFinishLaunching:
                return "执行AppDelegate的启动完成回调"
            case .rootViewControllerSetup:
                return "设置根视图控制器和窗口"
            case .firstFrameRender:
                return "渲染应用的第一帧画面"
            case .viewDidLoad:
                return "执行首个ViewController的viewDidLoad"
            case .viewWillAppear:
                return "执行viewWillAppear生命周期"
            case .viewDidAppear:
                return "执行viewDidAppear生命周期"
            case .firstMeaningfulPaint:
                return "完成首次有意义的内容绘制"
            case .fullyInteractive:
                return "应用完全可交互，启动完成"
            }
        }
        
        var optimizationTips: [String] {
            switch self {
            case .processCreation:
                return ["减少应用包大小", "优化Info.plist配置"]
            case .dylibLoading:
                return ["减少动态库依赖", "合并小的动态库", "延迟加载非必要库"]
            case .rebase:
                return ["减少DATA段大小", "避免大量全局变量"]
            case .binding:
                return ["减少外部符号引用", "使用静态链接替代动态链接"]
            case .objcSetup:
                return ["减少类和分类数量", "避免复杂的继承层次"]
            case .initializers:
                return ["避免+load方法", "延迟C++静态对象初始化", "使用+initialize替代+load"]
            case .mainFunction:
                return ["简化main函数逻辑", "避免同步网络请求"]
            case .uikitInitialization:
                return ["延迟UI组件创建", "使用懒加载"]
            case .appDelegateDidFinishLaunching:
                return ["异步执行非关键初始化", "延迟第三方SDK初始化"]
            case .rootViewControllerSetup:
                return ["简化根视图层次", "避免复杂布局计算"]
            case .firstFrameRender:
                return ["优化视图层次", "减少离屏渲染", "使用CALayer优化"]
            case .viewDidLoad:
                return ["延迟视图创建", "使用懒加载属性"]
            case .viewWillAppear:
                return ["避免同步数据加载", "预加载关键数据"]
            case .viewDidAppear:
                return ["异步执行动画", "延迟非关键UI更新"]
            case .firstMeaningfulPaint:
                return ["优先显示关键内容", "使用占位符"]
            case .fullyInteractive:
                return ["异步加载次要功能", "延迟初始化非核心模块"]
            }
        }
    }
    
    /// 阶段分类
    enum PhaseCategory: String, CaseIterable {
        case preMain = "Pre-main阶段"
        case main = "Main阶段"
        case postLaunch = "Post-launch阶段"
        
        var color: UIColor {
            switch self {
            case .preMain: return .systemRed
            case .main: return .systemBlue
            case .postLaunch: return .systemGreen
            }
        }
        
        var phases: [StartupPhase] {
            return StartupPhase.allCases.filter { $0.category == self }
        }
    }
    
    // MARK: - 阶段记录结构体
    
    /// 阶段执行记录
    struct PhaseRecord {
        let phase: StartupPhase
        let startTime: TimeInterval
        let endTime: TimeInterval
        let duration: TimeInterval
        let memoryUsage: UInt64
        let additionalInfo: [String: Any]
        
        var durationMs: Double {
            return duration * 1000
        }
        
        var memoryUsageMB: Double {
            return Double(memoryUsage) / (1024 * 1024)
        }
        
        var performanceLevel: PerformanceLevel {
            // 根据不同阶段设置不同的性能标准
            let thresholds = getPerformanceThresholds(for: phase)
            let durationMs = self.durationMs
            
            if durationMs <= thresholds.excellent {
                return .excellent
            } else if durationMs <= thresholds.good {
                return .good
            } else if durationMs <= thresholds.acceptable {
                return .acceptable
            } else {
                return .poor
            }
        }
        
        private func getPerformanceThresholds(for phase: StartupPhase) -> (excellent: Double, good: Double, acceptable: Double) {
            switch phase.category {
            case .preMain:
                return (50, 100, 200)  // Pre-main阶段阈值 (ms)
            case .main:
                return (100, 200, 400) // Main阶段阈值 (ms)
            case .postLaunch:
                return (50, 100, 200)  // Post-launch阶段阈值 (ms)
            }
        }
    }
    
    /// 性能等级
    enum PerformanceLevel: String, CaseIterable {
        case excellent = "优秀"
        case good = "良好"
        case acceptable = "可接受"
        case poor = "需优化"
        
        var color: UIColor {
            switch self {
            case .excellent: return .systemGreen
            case .good: return .systemBlue
            case .acceptable: return .systemOrange
            case .poor: return .systemRed
            }
        }
        
        var emoji: String {
            switch self {
            case .excellent: return "🟢"
            case .good: return "🔵"
            case .acceptable: return "🟡"
            case .poor: return "🔴"
            }
        }
    }
    
    // MARK: - 私有属性
    
    private var phaseRecords: [PhaseRecord] = []
    private var currentPhase: StartupPhase?
    private var phaseStartTime: TimeInterval = 0
    private var isAnalyzing = false
    
    // MARK: - 公开属性
    
    var onPhaseCompleted: ((PhaseRecord) -> Void)?
    var onAnalysisCompleted: (([PhaseRecord]) -> Void)?
    
    /// 获取分析状态
    func getIsAnalyzing() -> Bool {
        return isAnalyzing
    }
    
    /// 获取当前阶段
    func getCurrentPhase() -> StartupPhase? {
        return currentPhase
    }
    
    /// 获取阶段记录
    func getPhaseRecords() -> [PhaseRecord] {
        return phaseRecords
    }
    
    /// 获取优化建议
    func getOptimizationRecommendations() -> [(phase: StartupPhase, priority: Int, tips: [String])] {
        return getOptimizationPriorities()
    }
    
    /// 结束特定阶段类别
    func endPhase(_ category: PhaseCategory) {
        guard isAnalyzing else { return }
        
        // 根据类别结束对应的阶段
        let phasesToEnd = category.phases
        for phase in phasesToEnd {
            if currentPhase == phase {
                completePhase(phase)
                break
            }
        }
        
        print("⏱️ [Category] 结束: \(category.rawValue)")
    }
    
    // MARK: - 分析控制
    
    /// 开始启动分析
    func startAnalysis() {
        guard !isAnalyzing else { return }
        
        isAnalyzing = true
        phaseRecords.removeAll()
        
        print("🔍 [StartupPhaseAnalyzer] 开始启动阶段分析...")
        
        // 开始第一个阶段（通常从main函数开始，因为Pre-main阶段难以直接监控）
        startPhase(.mainFunction)
    }
    
    /// 停止分析
    func stopAnalysis() {
        guard isAnalyzing else { return }
        
        isAnalyzing = false
        
        // 如果有未完成的阶段，完成它
        if let currentPhase = currentPhase {
            completePhase(currentPhase)
        }
        
        print("⏹️ [StartupPhaseAnalyzer] 分析完成")
        printAnalysisSummary()
        
        onAnalysisCompleted?(phaseRecords)
    }
    
    /// 重置分析器状态
    func reset() {
        stopAnalysis()
        phaseRecords.removeAll()
        currentPhase = nil
        phaseStartTime = 0
        onPhaseCompleted = nil
        onAnalysisCompleted = nil
        print("🔄 [StartupPhaseAnalyzer] 分析器已重置")
    }
    
    /// 开始特定阶段
    func startPhase(_ phase: StartupPhase, additionalInfo: [String: Any] = [:]) {
        guard isAnalyzing else { return }
        
        // 如果有当前阶段，先完成它
        if let currentPhase = currentPhase {
            completePhase(currentPhase)
        }
        
        currentPhase = phase
        phaseStartTime = CACurrentMediaTime()
        
        print("⏱️ [Phase] 开始: \(phase.rawValue)")
    }
    
    /// 完成特定阶段
    func completePhase(_ phase: StartupPhase, additionalInfo: [String: Any] = [:]) {
        guard isAnalyzing, currentPhase == phase else { return }
        
        let endTime = CACurrentMediaTime()
        let duration = endTime - phaseStartTime
        let memoryUsage = getCurrentMemoryUsage()
        
        let record = PhaseRecord(
            phase: phase,
            startTime: phaseStartTime,
            endTime: endTime,
            duration: duration,
            memoryUsage: memoryUsage,
            additionalInfo: additionalInfo
        )
        
        phaseRecords.append(record)
        currentPhase = nil
        
        print("✅ [Phase] 完成: \(phase.rawValue) - \(String(format: "%.2f ms", record.durationMs)) \(record.performanceLevel.emoji)")
        
        onPhaseCompleted?(record)
    }
    
    /// 标记阶段检查点
    func markCheckpoint(_ phase: StartupPhase, info: [String: Any] = [:]) {
        startPhase(phase, additionalInfo: info)
        
        // 对于某些瞬时阶段，立即完成
        DispatchQueue.main.async {
            self.completePhase(phase, additionalInfo: info)
        }
    }
    
    // MARK: - 数据访问
    
    /// 获取所有阶段记录
    func getAllPhaseRecords() -> [PhaseRecord] {
        return phaseRecords
    }
    
    /// 获取总启动时间
    func getTotalStartupTime() -> TimeInterval {
        guard !phaseRecords.isEmpty else { return 0 }
        
        let firstRecord = phaseRecords.first!
        let lastRecord = phaseRecords.last!
        
        return lastRecord.endTime - firstRecord.startTime
    }
    
    /// 获取各阶段分类的总时间
    func getCategoryDurations() -> [PhaseCategory: TimeInterval] {
        var categoryDurations: [PhaseCategory: TimeInterval] = [:]
        
        for category in PhaseCategory.allCases {
            let categoryRecords = phaseRecords.filter { $0.phase.category == category }
            let totalDuration = categoryRecords.reduce(0) { $0 + $1.duration }
            categoryDurations[category] = totalDuration
        }
        
        return categoryDurations
    }
    
    /// 获取最耗时的阶段
    func getSlowestPhases(count: Int = 5) -> [PhaseRecord] {
        return phaseRecords
            .sorted { $0.duration > $1.duration }
            .prefix(count)
            .map { $0 }
    }
    
    /// 获取需要优化的阶段
    func getPhasesNeedingOptimization() -> [PhaseRecord] {
        return phaseRecords.filter { $0.performanceLevel == .poor || $0.performanceLevel == .acceptable }
    }
    
    /// 获取性能分布
    func getPerformanceDistribution() -> [PerformanceLevel: Int] {
        var distribution: [PerformanceLevel: Int] = [:]
        
        for level in PerformanceLevel.allCases {
            distribution[level] = phaseRecords.filter { $0.performanceLevel == level }.count
        }
        
        return distribution
    }
    
    // MARK: - 辅助方法
    
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
        
        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
    
    private func printAnalysisSummary() {
        print("\n📊 === 启动阶段分析摘要 ===")
        print("总启动时间: \(String(format: "%.2f ms", getTotalStartupTime() * 1000))")
        print("阶段数量: \(phaseRecords.count)")
        
        let categoryDurations = getCategoryDurations()
        for category in PhaseCategory.allCases {
            let duration = categoryDurations[category] ?? 0
            print("\(category.rawValue): \(String(format: "%.2f ms", duration * 1000))")
        }
        
        let slowestPhases = getSlowestPhases(count: 3)
        print("\n最耗时阶段:")
        for (index, record) in slowestPhases.enumerated() {
            print("  \(index + 1). \(record.phase.rawValue): \(String(format: "%.2f ms", record.durationMs))")
        }
        
        let needOptimization = getPhasesNeedingOptimization()
        if !needOptimization.isEmpty {
            print("\n需要优化的阶段 (\(needOptimization.count)个):")
            for record in needOptimization {
                print("  \(record.performanceLevel.emoji) \(record.phase.rawValue): \(String(format: "%.2f ms", record.durationMs))")
            }
        }
        
        print("============================\n")
    }
}

// MARK: - 便捷访问扩展

extension StartupPhaseAnalyzer {
    
    /// 获取格式化的分析报告
    func getFormattedAnalysisReport() -> String {
        var report = "启动阶段分析报告\n"
        report += "==================\n\n"
        
        // 总体概况
        report += "📱 总体概况\n"
        report += "总启动时间: \(String(format: "%.2f ms", getTotalStartupTime() * 1000))\n"
        report += "分析阶段数: \(phaseRecords.count)\n\n"
        
        // 各分类耗时
        report += "⏱️ 各阶段分类耗时\n"
        let categoryDurations = getCategoryDurations()
        for category in PhaseCategory.allCases {
            let duration = categoryDurations[category] ?? 0
            let percentage = getTotalStartupTime() > 0 ? (duration / getTotalStartupTime()) * 100 : 0
            report += "  \(category.rawValue): \(String(format: "%.2f ms (%.1f%%)", duration * 1000, percentage))\n"
        }
        report += "\n"
        
        // 最耗时阶段
        let slowestPhases = getSlowestPhases(count: 5)
        report += "🐌 最耗时阶段 (Top 5)\n"
        for (index, record) in slowestPhases.enumerated() {
            report += "  \(index + 1). \(record.phase.rawValue)\n"
            report += "     耗时: \(String(format: "%.2f ms", record.durationMs))\n"
            report += "     性能: \(record.performanceLevel.emoji) \(record.performanceLevel.rawValue)\n"
        }
        report += "\n"
        
        // 优化建议
        let needOptimization = getPhasesNeedingOptimization()
        if !needOptimization.isEmpty {
            report += "💡 优化建议\n"
            for record in needOptimization {
                report += "  \(record.performanceLevel.emoji) \(record.phase.rawValue) (\(String(format: "%.2f ms", record.durationMs)))\n"
                for tip in record.phase.optimizationTips.prefix(2) {
                    report += "    • \(tip)\n"
                }
            }
        }
        
        return report
    }
    
    /// 获取性能评分 (0-100)
    func getPerformanceScore() -> Int {
        guard !phaseRecords.isEmpty else { return 0 }
        
        let distribution = getPerformanceDistribution()
        let totalPhases = phaseRecords.count
        
        let excellentCount = distribution[.excellent] ?? 0
        let goodCount = distribution[.good] ?? 0
        let acceptableCount = distribution[.acceptable] ?? 0
        let poorCount = distribution[.poor] ?? 0
        
        // 加权计算分数
        let score = (excellentCount * 100 + goodCount * 80 + acceptableCount * 60 + poorCount * 30) / totalPhases
        
        return max(0, min(100, score))
    }
    
    /// 获取优化优先级列表
    func getOptimizationPriorities() -> [(phase: StartupPhase, priority: Int, tips: [String])] {
        let needOptimization = getPhasesNeedingOptimization()
        
        return needOptimization.map { record in
            let priority = record.performanceLevel == .poor ? 1 : 2
            return (record.phase, priority, record.phase.optimizationTips)
        }.sorted { $0.priority < $1.priority }
    }
}