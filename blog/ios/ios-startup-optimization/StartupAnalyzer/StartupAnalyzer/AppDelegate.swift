//
//  AppDelegate.swift
//  StartupAnalyzer
//
//  应用程序委托 - 管理应用生命周期和启动监控
//  Created for iOS Startup Optimization Learning
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - 启动监控
    
    /// 应用启动时间记录
    private var applicationLaunchTime: CFAbsoluteTime = 0
    
    // MARK: - 应用生命周期
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 记录应用启动完成时间
        applicationLaunchTime = CFAbsoluteTimeGetCurrent()
        
        // 开始启动监控
        startStartupMonitoring()
        
        // 创建窗口和根视图控制器
        setupWindow()
        
        // 完成启动阶段监控
        completeStartupMonitoring()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // 应用即将变为非活跃状态
        print("📱 应用即将变为非活跃状态")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 应用进入后台
        print("📱 应用进入后台")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 应用即将进入前台
        print("📱 应用即将进入前台")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 应用变为活跃状态
        print("📱 应用变为活跃状态")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 应用即将终止
        print("📱 应用即将终止")
        
        // 停止所有监控
        stopAllMonitoring()
    }
    
    // MARK: - 窗口设置
    
    private func setupWindow() {
        // 记录窗口创建开始时间
        let windowSetupStartTime = CFAbsoluteTimeGetCurrent()
        
        // 开始UIKit初始化阶段
        StartupPhaseAnalyzer.shared.startPhase(.uikitInitialization)
        
        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        
        // 完成UIKit初始化
        StartupPhaseAnalyzer.shared.completePhase(.uikitInitialization)
        
        // 创建主标签栏控制器
        let tabBarController = createMainTabBarController()
        
        // 设置根视图控制器
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // 记录窗口创建完成时间
        let windowSetupEndTime = CFAbsoluteTimeGetCurrent()
        let windowSetupDuration = windowSetupEndTime - windowSetupStartTime
        
        print("🪟 窗口设置完成，耗时: \(String(format: "%.2f", windowSetupDuration * 1000))ms")
    }
    
    private func createMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // 启动分析页面
        let startupAnalysisVC = StartupAnalysisViewController()
        startupAnalysisVC.tabBarItem = UITabBarItem(
            title: "启动分析",
            image: UIImage(systemName: "speedometer"),
            selectedImage: UIImage(systemName: "speedometer.fill")
        )
        let startupNavController = UINavigationController(rootViewController: startupAnalysisVC)
        startupNavController.navigationBar.prefersLargeTitles = true
        startupAnalysisVC.navigationItem.title = "启动性能分析"
        
        // 实时监控页面
        let realTimeMonitoringVC = RealTimeMonitoringViewController()
        realTimeMonitoringVC.tabBarItem = UITabBarItem(
            title: "实时监控",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.fill")
        )
        let monitoringNavController = UINavigationController(rootViewController: realTimeMonitoringVC)
        monitoringNavController.navigationBar.prefersLargeTitles = true
        realTimeMonitoringVC.navigationItem.title = "实时性能监控"
        
        // 分析报告页面
        let analysisReportVC = AnalysisReportViewController()
        analysisReportVC.tabBarItem = UITabBarItem(
            title: "分析报告",
            image: UIImage(systemName: "doc.text.magnifyingglass"),
            selectedImage: UIImage(systemName: "doc.text.magnifyingglass.fill")
        )
        let reportNavController = UINavigationController(rootViewController: analysisReportVC)
        reportNavController.navigationBar.prefersLargeTitles = true
        analysisReportVC.navigationItem.title = "性能分析报告"
        
        // 设置标签栏控制器
        tabBarController.viewControllers = [
            startupNavController,
            monitoringNavController,
            reportNavController
        ]
        
        // 设置标签栏外观
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.backgroundColor = .systemBackground
        
        return tabBarController
    }
    
    // MARK: - 启动监控管理
    
    private func startStartupMonitoring() {
        print("🚀 开始启动监控")
        
        // 开始启动监控
        StartupMonitor.shared.startMonitoring()
        
        // 开始阶段分析
        StartupPhaseAnalyzer.shared.startAnalysis()
        
        // 记录Pre-main阶段结束（应用委托开始执行）
        StartupPhaseAnalyzer.shared.endPhase(.preMain)
        
        // 开始Main阶段 - AppDelegate启动完成
        StartupPhaseAnalyzer.shared.startPhase(.appDelegateDidFinishLaunching)
        
        print("📊 启动阶段监控已开始")
    }
    
    // 已移除与PerformanceTracker相关的追踪逻辑
    
    private func completeStartupMonitoring() {
        // 延迟标记启动完成，确保UI完全加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.markStartupComplete()
        }
    }
    
    private func markStartupComplete() {
        // 结束AppDelegate启动完成阶段
        StartupPhaseAnalyzer.shared.completePhase(.appDelegateDidFinishLaunching)
        
        // 开始根视图控制器设置阶段
        StartupPhaseAnalyzer.shared.startPhase(.rootViewControllerSetup)
        
        // 完成根视图控制器设置
        StartupPhaseAnalyzer.shared.completePhase(.rootViewControllerSetup)
        
        // 开始首帧渲染阶段
        StartupPhaseAnalyzer.shared.startPhase(.firstFrameRender)
        
        // 记录启动完成
        StartupMonitor.shared.recordStartupComplete()
        
        // 延迟结束首帧渲染和开始Post-launch阶段
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 完成首帧渲染
            StartupPhaseAnalyzer.shared.completePhase(.firstFrameRender)
            
            // 开始Post-launch阶段 - ViewDidLoad
            StartupPhaseAnalyzer.shared.startPhase(.viewDidLoad)
            
            // 延迟完成ViewDidLoad并开始ViewWillAppear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                StartupPhaseAnalyzer.shared.completePhase(.viewDidLoad)
                StartupPhaseAnalyzer.shared.startPhase(.viewWillAppear)
                
                // 延迟完成ViewWillAppear并开始ViewDidAppear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    StartupPhaseAnalyzer.shared.completePhase(.viewWillAppear)
                    StartupPhaseAnalyzer.shared.startPhase(.viewDidAppear)
                    
                    // 延迟完成ViewDidAppear并开始首次有意义绘制
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        StartupPhaseAnalyzer.shared.completePhase(.viewDidAppear)
                        StartupPhaseAnalyzer.shared.startPhase(.firstMeaningfulPaint)
                        
                        // 延迟完成首次有意义绘制并开始完全可交互
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            StartupPhaseAnalyzer.shared.completePhase(.firstMeaningfulPaint)
                            StartupPhaseAnalyzer.shared.startPhase(.fullyInteractive)
                            
                            // 延迟完成所有启动阶段
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                StartupPhaseAnalyzer.shared.completePhase(.fullyInteractive)
                                StartupPhaseAnalyzer.shared.stopAnalysis()
                                
                                self.logStartupSummary()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func stopAllMonitoring() {
        print("🛑 停止所有监控")
        
        StartupMonitor.shared.stopMonitoring()
        StartupPhaseAnalyzer.shared.stopAnalysis()
    }
    
    // MARK: - 启动总结
    
    private func logStartupSummary() {
        print("\n" + "=" * 50)
        print("📊 启动性能总结")
        print("=" * 50)
        
        // 获取启动监控数据
        let startupMetrics = StartupMonitor.shared.getStartupMetrics()
        let totalLaunchTime = StartupMonitor.shared.getTotalLaunchTime()
        let peakMemoryUsage = StartupMonitor.shared.getPeakMemoryUsage()
        
        print("🚀 总启动时间: \(String(format: "%.2f", totalLaunchTime * 1000))ms")
        print("💾 启动时内存峰值: \(String(format: "%.1f", Double(peakMemoryUsage) / (1024 * 1024)))MB")
        
        // 获取最新的CPU使用率（如果有数据的话）
        if let latestMetric = startupMetrics.last {
            print("🖥️ 启动时CPU使用: \(String(format: "%.1f", latestMetric.cpuUsage * 100))%")
        }
        
        // 获取阶段分析数据
        let phaseRecords = StartupPhaseAnalyzer.shared.getPhaseRecords()
        print("\n📋 启动阶段分析:")
        for (index, record) in phaseRecords.enumerated() {
            print("  \(index + 1). \(record.phase.rawValue): \(String(format: "%.2f", record.duration * 1000))ms")
        }
        
        // 获取性能评分
        let performanceScore = StartupPhaseAnalyzer.shared.getPerformanceScore()
        print("\n⭐ 性能评分: \(performanceScore)/100")
        
        // 获取优化建议
        let recommendations = StartupPhaseAnalyzer.shared.getOptimizationRecommendations()
        if !recommendations.isEmpty {
            print("\n💡 优化建议:")
            for (index, recommendation) in recommendations.enumerated() {
                print("  \(index + 1). \(recommendation)")
            }
        }
        
        print("=" * 50 + "\n")
    }
    
    // MARK: - 内存警告处理
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("⚠️ 收到内存警告")
        
        // 记录内存警告事件
        PerformanceTracker.shared.recordMemoryWarning()
        
        // 可以在这里添加内存清理逻辑
        clearNonEssentialCaches()
    }
    
    private func clearNonEssentialCaches() {
        print("🧹 清理非必要缓存")
        
        // 清理图片缓存
        URLCache.shared.removeAllCachedResponses()
        
        // 清理其他缓存
        // 这里可以添加应用特定的缓存清理逻辑
    }
    
    // MARK: - 调试辅助
    
    #if DEBUG
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // 摇一摇显示调试信息
            showDebugInfo()
        }
    }
    
    private func showDebugInfo() {
        let alert = UIAlertController(
            title: "🔧 调试信息",
            message: getDebugInfoString(),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        alert.addAction(UIAlertAction(title: "重新分析", style: .default) { _ in
            self.restartAnalysis()
        })
        
        window?.rootViewController?.present(alert, animated: true)
    }
    
    private func getDebugInfoString() -> String {
        let startupMetrics = StartupMonitor.shared.getStartupMetrics()
        let performanceMetrics = PerformanceTracker.shared.getCurrentMetrics()
        let totalLaunchTime = StartupMonitor.shared.getTotalLaunchTime()
        
        var info = "启动时间: \(String(format: "%.2f", totalLaunchTime * 1000))ms\n"
        info += "当前内存: \(String(format: "%.1f", performanceMetrics.memoryUsage))MB\n"
        info += "当前CPU: \(String(format: "%.1f", performanceMetrics.cpuUsage))%\n"
        info += "当前FPS: \(String(format: "%.1f", performanceMetrics.fps))"
        
        return info
    }
    
    private func restartAnalysis() {
        print("🔄 重新开始分析")
        
        // 重置所有监控器
        StartupMonitor.shared.reset()
        PerformanceTracker.shared.reset()
        StartupPhaseAnalyzer.shared.reset()
        
        // 重新开始监控
        startStartupMonitoring()
        
        // 模拟启动完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.markStartupComplete()
        }
    }
    #endif
}

// MARK: - 扩展：字符串重复

fileprivate extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// MARK: - 扩展：启动时间测量

extension AppDelegate {
    
    /// 获取应用启动时间
    func getApplicationLaunchTime() -> CFAbsoluteTime {
        return applicationLaunchTime
    }
    
    /// 获取从启动到现在的时间
    func getTimeSinceLaunch() -> TimeInterval {
        return CFAbsoluteTimeGetCurrent() - applicationLaunchTime
    }
}