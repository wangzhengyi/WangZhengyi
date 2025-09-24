//
//  StartupAnalysisViewController.swift
//  StartupAnalyzer
//
//  启动分析主视图控制器 - 整合所有监控和分析功能
//  Created for iOS Startup Optimization Learning
//

import UIKit

/// 启动分析主视图控制器
/// 负责协调启动监控、性能追踪和数据可视化
class StartupAnalysisViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let navigationBar = UINavigationBar()
    private let segmentedControl = UISegmentedControl(items: ["实时监控", "分析报告", "历史记录"])
    private let containerView = UIView()
    
    // 子视图控制器
    private let realTimeMonitoringVC = RealTimeMonitoringViewController()
    private let analysisReportVC = AnalysisReportViewController()
    private let historyVC = HistoryViewController()
    
    private var currentViewController: UIViewController?
    
    // MARK: - 控制按钮
    
    private let controlPanel = UIView()
    private let startButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let exportButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    
    // MARK: - 状态指示器
    
    private let statusView = UIView()
    private let statusLabel = UILabel()
    private let statusIndicator = UIView()
    
    // MARK: - 数据管理
    
    private var isMonitoring = false
    private var analysisStartTime: TimeInterval = 0
    private var currentSessionData: SessionData?
    
    struct SessionData {
        let startTime: Date
        let phaseRecords: [StartupPhaseAnalyzer.PhaseRecord]
        let performanceMetrics: PerformanceTracker.PerformanceMetrics
        let sessionId: String
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupNotifications()
        
        // 默认显示实时监控
        showViewController(realTimeMonitoringVC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 导航栏设置
        let navItem = UINavigationItem(title: "iOS 启动性能分析器")
        navigationBar.setItems([navItem], animated: false)
        navigationBar.prefersLargeTitles = false
        
        // 分段控制器设置
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .secondarySystemBackground
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        // 容器视图设置
        containerView.backgroundColor = .systemBackground
        
        // 控制面板设置
        setupControlPanel()
        
        // 状态视图设置
        setupStatusView()
        
        // 添加子视图
        view.addSubview(navigationBar)
        view.addSubview(segmentedControl)
        view.addSubview(statusView)
        view.addSubview(controlPanel)
        view.addSubview(containerView)
    }
    
    private func setupControlPanel() {
        controlPanel.backgroundColor = .secondarySystemBackground
        controlPanel.layer.cornerRadius = 12
        controlPanel.layer.shadowColor = UIColor.black.cgColor
        controlPanel.layer.shadowOpacity = 0.1
        controlPanel.layer.shadowOffset = CGSize(width: 0, height: 2)
        controlPanel.layer.shadowRadius = 4
        
        // 开始按钮
        startButton.setTitle("开始分析", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemGreen
        startButton.layer.cornerRadius = 8
        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        // 停止按钮
        stopButton.setTitle("停止分析", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.layer.cornerRadius = 8
        stopButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        stopButton.isEnabled = false
        stopButton.alpha = 0.6
        
        // 导出按钮
        exportButton.setTitle("导出报告", for: .normal)
        exportButton.setTitleColor(.systemBlue, for: .normal)
        exportButton.backgroundColor = .clear
        exportButton.layer.borderColor = UIColor.systemBlue.cgColor
        exportButton.layer.borderWidth = 1
        exportButton.layer.cornerRadius = 8
        exportButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        // 清除按钮
        clearButton.setTitle("清除数据", for: .normal)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.backgroundColor = .clear
        clearButton.layer.borderColor = UIColor.systemRed.cgColor
        clearButton.layer.borderWidth = 1
        clearButton.layer.cornerRadius = 8
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        controlPanel.addSubview(startButton)
        controlPanel.addSubview(stopButton)
        controlPanel.addSubview(exportButton)
        controlPanel.addSubview(clearButton)
    }
    
    private func setupStatusView() {
        statusView.backgroundColor = .tertiarySystemBackground
        statusView.layer.cornerRadius = 8
        
        statusLabel.text = "就绪"
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .label
        
        statusIndicator.backgroundColor = .systemGray
        statusIndicator.layer.cornerRadius = 6
        
        statusView.addSubview(statusLabel)
        statusView.addSubview(statusIndicator)
    }
    
    private func setupConstraints() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        statusView.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 导航栏约束
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 分段控制器约束
            segmentedControl.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // 状态视图约束
            statusView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusView.widthAnchor.constraint(equalToConstant: 100),
            statusView.heightAnchor.constraint(equalToConstant: 32),
            
            // 状态标签和指示器约束
            statusIndicator.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
            statusIndicator.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),
            
            // 控制面板约束
            controlPanel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            controlPanel.leadingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: 12),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            controlPanel.heightAnchor.constraint(equalToConstant: 80),
            
            // 控制按钮约束
            startButton.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 8),
            startButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 8),
            startButton.heightAnchor.constraint(equalToConstant: 32),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            
            stopButton.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 8),
            stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 8),
            stopButton.heightAnchor.constraint(equalToConstant: 32),
            stopButton.widthAnchor.constraint(equalToConstant: 80),
            
            exportButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 8),
            exportButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 8),
            exportButton.heightAnchor.constraint(equalToConstant: 32),
            exportButton.widthAnchor.constraint(equalToConstant: 80),
            
            clearButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 8),
            clearButton.leadingAnchor.constraint(equalTo: exportButton.trailingAnchor, constant: 8),
            clearButton.heightAnchor.constraint(equalToConstant: 32),
            clearButton.widthAnchor.constraint(equalToConstant: 80),
            
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        startButton.addTarget(self, action: #selector(startAnalysis), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopAnalysis), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportReport), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearData), for: .touchUpInside)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    // MARK: - 视图控制器管理
    
    private func showViewController(_ viewController: UIViewController) {
        // 移除当前视图控制器
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // 添加新的视图控制器
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        // 设置约束
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        currentViewController = viewController
    }
    
    // MARK: - 事件处理
    
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showViewController(realTimeMonitoringVC)
        case 1:
            showViewController(analysisReportVC)
        case 2:
            showViewController(historyVC)
        default:
            break
        }
    }
    
    @objc private func startAnalysis() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        analysisStartTime = CACurrentMediaTime()
        
        // 开始监控
        StartupMonitor.shared.startMonitoring()
        PerformanceTracker.shared.startTracking()
        StartupPhaseAnalyzer.shared.startAnalysis()
        
        // 更新UI状态
        updateMonitoringState()
        
        // 显示开始提示
        showAlert(title: "分析已开始", message: "正在监控应用启动性能，请进行正常的应用操作。")
        
        print("🚀 [StartupAnalysis] 开始启动性能分析")
    }
    
    @objc private func stopAnalysis() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        
        // 停止监控
        StartupMonitor.shared.stopMonitoring()
        PerformanceTracker.shared.stopTracking()
        StartupPhaseAnalyzer.shared.stopAnalysis()
        
        // 收集分析数据
        collectAnalysisData()
        
        // 更新UI状态
        updateMonitoringState()
        
        // 自动切换到分析报告页面
        segmentedControl.selectedSegmentIndex = 1
        showViewController(analysisReportVC)
        
        // 显示完成提示
        showAlert(title: "分析完成", message: "启动性能分析已完成，请查看分析报告。")
        
        print("✅ [StartupAnalysis] 启动性能分析完成")
    }
    
    @objc private func exportReport() {
        guard let sessionData = currentSessionData else {
            showAlert(title: "无数据", message: "没有可导出的分析数据，请先进行一次完整的分析。")
            return
        }
        
        let report = generateAnalysisReport(sessionData)
        shareReport(report)
    }
    
    @objc private func clearData() {
        let alert = UIAlertController(
            title: "清除数据",
            message: "确定要清除所有分析数据吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清除", style: .destructive) { _ in
            self.performClearData()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func applicationDidBecomeActive() {
        updateUI()
    }
    
    @objc private func applicationWillResignActive() {
        // 如果正在监控，暂停监控
        if isMonitoring {
            // 可以选择暂停或继续监控
        }
    }
    
    // MARK: - 数据处理
    
    private func collectAnalysisData() {
        let phaseRecords = StartupPhaseAnalyzer.shared.getAllPhaseRecords()
        
        let performanceMetrics = PerformanceTracker.shared.getCurrentMetrics()
        
        currentSessionData = SessionData(
            startTime: Date(timeIntervalSinceReferenceDate: analysisStartTime),
            phaseRecords: phaseRecords,
            performanceMetrics: performanceMetrics,
            sessionId: UUID().uuidString
        )
        
        // 更新分析报告视图
        analysisReportVC.updateAnalysisData(
            phaseRecords: phaseRecords,
            metrics: performanceMetrics
        )
        
        // 保存到历史记录
        if let sessionData = currentSessionData {
            historyVC.addSession(sessionData)
        }
    }
    
    private func generateAnalysisReport(_ sessionData: SessionData) -> String {
        var report = "iOS 启动性能分析报告\n"
        report += "===================\n\n"
        report += "分析时间: \(DateFormatter.localizedString(from: sessionData.startTime, dateStyle: .medium, timeStyle: .medium))\n"
        report += "会话ID: \(sessionData.sessionId)\n\n"
        
        let metrics = sessionData.performanceMetrics
        report += "📊 性能概览\n"
        report += "总启动时间: 计算中...\n"
        report += "平均FPS: \(String(format: "%.1f", metrics.fps))\n"
        report += "内存峰值: \(String(format: "%.2f MB", metrics.memoryUsage))\n"
        report += "平均CPU: \(String(format: "%.1f%%", metrics.cpuUsage))\n"
        report += "性能评分: \(Int(metrics.overallScore))/100\n\n"
        
        report += StartupPhaseAnalyzer.shared.getFormattedAnalysisReport()
        
        return report
    }
    
    private func shareReport(_ report: String) {
        let activityVC = UIActivityViewController(
            activityItems: [report],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    private func performClearData() {
        currentSessionData = nil
        
        // 清除各个组件的数据
        realTimeMonitoringVC.clearData()
        analysisReportVC.clearData()
        historyVC.clearAllSessions()
        
        showAlert(title: "数据已清除", message: "所有分析数据已成功清除。")
    }
    
    // MARK: - UI 更新
    
    private func updateUI() {
        updateMonitoringState()
        updateButtonStates()
    }
    
    private func updateMonitoringState() {
        if isMonitoring {
            statusLabel.text = "监控中"
            statusIndicator.backgroundColor = .systemGreen
            
            // 添加闪烁动画
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.3
            animation.duration = 0.8
            animation.repeatCount = .infinity
            animation.autoreverses = true
            statusIndicator.layer.add(animation, forKey: "blinking")
        } else {
            statusLabel.text = "就绪"
            statusIndicator.backgroundColor = .systemGray
            statusIndicator.layer.removeAnimation(forKey: "blinking")
        }
    }
    
    private func updateButtonStates() {
        startButton.isEnabled = !isMonitoring
        startButton.alpha = isMonitoring ? 0.6 : 1.0
        
        stopButton.isEnabled = isMonitoring
        stopButton.alpha = isMonitoring ? 1.0 : 0.6
        
        exportButton.isEnabled = currentSessionData != nil
        exportButton.alpha = currentSessionData != nil ? 1.0 : 0.6
    }
    
    // MARK: - 辅助方法
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 扩展：StartupPhaseAnalyzer 访问

// 移除不必要的扩展，直接使用StartupPhaseAnalyzer的getAllPhaseRecords()方法