//
//  RealTimeMonitoringViewController.swift
//  StartupAnalyzer
//
//  实时监控视图控制器 - 显示实时性能数据
//  Created for iOS Startup Optimization Learning
//

import UIKit

/// 实时监控视图控制器
/// 负责显示实时的启动和性能监控数据
class RealTimeMonitoringViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 启动阶段监控
    private let startupSectionView = UIView()
    private let startupTitleLabel = UILabel()
    private let currentPhaseLabel = UILabel()
    private let phaseProgressView = UIProgressView(progressViewStyle: .default)
    private let phaseTimeLabel = UILabel()
    
    
    // 实时图表
    private let chartSectionView = UIView()
    private let chartTitleLabel = UILabel()
    private let performanceVisualizationView = PerformanceVisualizationView()
    
    // 日志区域
    private let logSectionView = UIView()
    private let logTitleLabel = UILabel()
    private let logTextView = UITextView()
    private let clearLogButton = UIButton(type: .system)
    
    // MARK: - 数据管理
    
    private var updateTimer: Timer?
    private var logEntries: [String] = []
    private let maxLogEntries = 100
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        startRealTimeUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRealTimeUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRealTimeUpdates()
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 滚动视图设置
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = true
        
        // 内容视图设置
        contentView.backgroundColor = .systemBackground
        
        // 启动阶段监控区域
        setupStartupSection()
        
        // 图表区域
        setupChartSection()
        
        // 日志区域
        setupLogSection()
        
        // 添加子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(startupSectionView)
        contentView.addSubview(chartSectionView)
        contentView.addSubview(logSectionView)
    }
    
    private func setupStartupSection() {
        startupSectionView.backgroundColor = .secondarySystemBackground
        startupSectionView.layer.cornerRadius = 12
        startupSectionView.layer.shadowColor = UIColor.black.cgColor
        startupSectionView.layer.shadowOpacity = 0.1
        startupSectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        startupSectionView.layer.shadowRadius = 4
        
        startupTitleLabel.text = "🚀 启动阶段监控"
        startupTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        startupTitleLabel.textColor = .label
        
        currentPhaseLabel.text = "当前阶段: 未开始"
        currentPhaseLabel.font = .systemFont(ofSize: 16, weight: .medium)
        currentPhaseLabel.textColor = .secondaryLabel
        
        phaseProgressView.progressTintColor = .systemBlue
        phaseProgressView.trackTintColor = .systemGray4
        phaseProgressView.progress = 0.0
        
        phaseTimeLabel.text = "耗时: 0.00ms"
        phaseTimeLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        phaseTimeLabel.textColor = .secondaryLabel
        
        startupSectionView.addSubview(startupTitleLabel)
        startupSectionView.addSubview(currentPhaseLabel)
        startupSectionView.addSubview(phaseProgressView)
        startupSectionView.addSubview(phaseTimeLabel)
    }
    
    
    
    private func setupChartSection() {
        chartSectionView.backgroundColor = .secondarySystemBackground
        chartSectionView.layer.cornerRadius = 12
        chartSectionView.layer.shadowColor = UIColor.black.cgColor
        chartSectionView.layer.shadowOpacity = 0.1
        chartSectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chartSectionView.layer.shadowRadius = 4
        
        chartTitleLabel.text = "📈 实时性能图表"
        chartTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        chartTitleLabel.textColor = .label
        
        performanceVisualizationView.backgroundColor = .systemBackground
        performanceVisualizationView.layer.cornerRadius = 8
        
        chartSectionView.addSubview(chartTitleLabel)
        chartSectionView.addSubview(performanceVisualizationView)
    }
    
    private func setupLogSection() {
        logSectionView.backgroundColor = .secondarySystemBackground
        logSectionView.layer.cornerRadius = 12
        logSectionView.layer.shadowColor = UIColor.black.cgColor
        logSectionView.layer.shadowOpacity = 0.1
        logSectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logSectionView.layer.shadowRadius = 4
        
        logTitleLabel.text = "📝 实时日志"
        logTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        logTitleLabel.textColor = .label
        
        logTextView.backgroundColor = .systemBackground
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.textColor = .label
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 8
        logTextView.layer.borderColor = UIColor.separator.cgColor
        logTextView.layer.borderWidth = 1
        logTextView.text = "等待监控开始...\n"
        
        clearLogButton.setTitle("清除日志", for: .normal)
        clearLogButton.setTitleColor(.systemRed, for: .normal)
        clearLogButton.backgroundColor = .clear
        clearLogButton.layer.borderColor = UIColor.systemRed.cgColor
        clearLogButton.layer.borderWidth = 1
        clearLogButton.layer.cornerRadius = 6
        clearLogButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        logSectionView.addSubview(logTitleLabel)
        logSectionView.addSubview(logTextView)
        logSectionView.addSubview(clearLogButton)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let sectionViews = [startupSectionView, chartSectionView, logSectionView]
        sectionViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let labels = [startupTitleLabel, currentPhaseLabel, phaseTimeLabel,
                     chartTitleLabel, logTitleLabel]
        labels.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        phaseProgressView.translatesAutoresizingMaskIntoConstraints = false
        performanceVisualizationView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        clearLogButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 启动阶段监控区域约束
            startupSectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            startupSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            startupSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startupSectionView.heightAnchor.constraint(equalToConstant: 120),
            
            startupTitleLabel.topAnchor.constraint(equalTo: startupSectionView.topAnchor, constant: 12),
            startupTitleLabel.leadingAnchor.constraint(equalTo: startupSectionView.leadingAnchor, constant: 16),
            startupTitleLabel.trailingAnchor.constraint(equalTo: startupSectionView.trailingAnchor, constant: -16),
            
            currentPhaseLabel.topAnchor.constraint(equalTo: startupTitleLabel.bottomAnchor, constant: 8),
            currentPhaseLabel.leadingAnchor.constraint(equalTo: startupSectionView.leadingAnchor, constant: 16),
            currentPhaseLabel.trailingAnchor.constraint(equalTo: startupSectionView.trailingAnchor, constant: -16),
            
            phaseProgressView.topAnchor.constraint(equalTo: currentPhaseLabel.bottomAnchor, constant: 8),
            phaseProgressView.leadingAnchor.constraint(equalTo: startupSectionView.leadingAnchor, constant: 16),
            phaseProgressView.trailingAnchor.constraint(equalTo: startupSectionView.trailingAnchor, constant: -16),
            phaseProgressView.heightAnchor.constraint(equalToConstant: 4),
            
            phaseTimeLabel.topAnchor.constraint(equalTo: phaseProgressView.bottomAnchor, constant: 8),
            phaseTimeLabel.leadingAnchor.constraint(equalTo: startupSectionView.leadingAnchor, constant: 16),
            phaseTimeLabel.trailingAnchor.constraint(equalTo: startupSectionView.trailingAnchor, constant: -16),
            
            // 图表区域约束
            chartSectionView.topAnchor.constraint(equalTo: startupSectionView.bottomAnchor, constant: 16),
            chartSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartSectionView.heightAnchor.constraint(equalToConstant: 280),
            
            chartTitleLabel.topAnchor.constraint(equalTo: chartSectionView.topAnchor, constant: 12),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartSectionView.leadingAnchor, constant: 16),
            chartTitleLabel.trailingAnchor.constraint(equalTo: chartSectionView.trailingAnchor, constant: -16),
            
            performanceVisualizationView.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 12),
            performanceVisualizationView.leadingAnchor.constraint(equalTo: chartSectionView.leadingAnchor, constant: 16),
            performanceVisualizationView.trailingAnchor.constraint(equalTo: chartSectionView.trailingAnchor, constant: -16),
            performanceVisualizationView.bottomAnchor.constraint(equalTo: chartSectionView.bottomAnchor, constant: -12),
            
            // 日志区域约束
            logSectionView.topAnchor.constraint(equalTo: chartSectionView.bottomAnchor, constant: 16),
            logSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logSectionView.heightAnchor.constraint(equalToConstant: 200),
            logSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            logTitleLabel.topAnchor.constraint(equalTo: logSectionView.topAnchor, constant: 12),
            logTitleLabel.leadingAnchor.constraint(equalTo: logSectionView.leadingAnchor, constant: 16),
            
            clearLogButton.topAnchor.constraint(equalTo: logSectionView.topAnchor, constant: 8),
            clearLogButton.trailingAnchor.constraint(equalTo: logSectionView.trailingAnchor, constant: -16),
            clearLogButton.widthAnchor.constraint(equalToConstant: 80),
            clearLogButton.heightAnchor.constraint(equalToConstant: 32),
            
            logTextView.topAnchor.constraint(equalTo: logTitleLabel.bottomAnchor, constant: 8),
            logTextView.leadingAnchor.constraint(equalTo: logSectionView.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: logSectionView.trailingAnchor, constant: -16),
            logTextView.bottomAnchor.constraint(equalTo: logSectionView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupActions() {
        clearLogButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
    }
    
    // MARK: - 实时更新
    
    private func startRealTimeUpdates() {
        stopRealTimeUpdates() // 确保没有重复的定时器
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateRealTimeData()
        }
    }
    
    private func stopRealTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateRealTimeData() {
        DispatchQueue.main.async {
            self.updateStartupPhaseInfo()
            self.updateVisualization()
        }
    }
    
    private func updateStartupPhaseInfo() {
        let analyzer = StartupPhaseAnalyzer.shared
        
        if analyzer.getIsAnalyzing() {
            let currentPhase = analyzer.getCurrentPhaseForUI()
            currentPhaseLabel.text = "当前阶段: \(currentPhase.rawValue)"
            
            let progress = analyzer.getCurrentPhaseProgress()
            phaseProgressView.progress = Float(progress)
            
            let elapsedTime = analyzer.getCurrentPhaseElapsedTime()
            phaseTimeLabel.text = String(format: "耗时: %.2fms", elapsedTime * 1000)
            
            addLogEntry("[\(currentPhase.rawValue)] 进行中... (\(String(format: "%.2fms", elapsedTime * 1000)))")
        } else {
            currentPhaseLabel.text = "当前阶段: 未开始"
            phaseProgressView.progress = 0.0
            phaseTimeLabel.text = "耗时: 0.00ms"
        }
    }
    
    
    
    private func updateVisualization() {
        let analyzer = StartupPhaseAnalyzer.shared
        if analyzer.getIsAnalyzing() {
            let visualMetrics = PerformanceVisualizationView.PerformanceMetrics(
                totalStartupTime: analyzer.getTotalStartupTime()
            )
            let phaseRecords = analyzer.getAllPhaseRecords()
            performanceVisualizationView.updatePerformanceData(
                phaseRecords: phaseRecords,
                metrics: visualMetrics
            )
        } else {
            performanceVisualizationView.clearData()
        }
    }
    
    // MARK: - 颜色辅助方法
    
    
    
    // MARK: - 日志管理
    
    private func addLogEntry(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)"
        
        logEntries.append(logEntry)
        
        // 限制日志条目数量
        if logEntries.count > maxLogEntries {
            logEntries.removeFirst(logEntries.count - maxLogEntries)
        }
        
        // 更新日志显示
        DispatchQueue.main.async {
            self.logTextView.text = self.logEntries.joined(separator: "\n")
            
            // 滚动到底部
            let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }
    
    @objc private func clearLog() {
        logEntries.removeAll()
        logTextView.text = "日志已清除\n"
        addLogEntry("日志已清除")
    }
    
    // MARK: - 公开方法
    
    func clearData() {
        stopRealTimeUpdates()
        
        // 重置UI状态
        currentPhaseLabel.text = "当前阶段: 未开始"
        phaseProgressView.progress = 0.0
        phaseTimeLabel.text = "耗时: 0.00ms"
        
        // 清除日志
        clearLog()
        
        // 重置图表
        performanceVisualizationView.clearData()
        
        // 重新开始更新（如果视图可见）
        if view.window != nil {
            startRealTimeUpdates()
        }
    }
}

// MARK: - 扩展：StartupPhaseAnalyzer 实时数据访问

extension StartupPhaseAnalyzer {
    func getCurrentPhaseForUI() -> StartupPhase {
        // 返回当前正在执行的启动阶段
        return getCurrentPhase() ?? .processCreation // 返回当前阶段或默认阶段
    }
    
    func getCurrentPhaseProgress() -> Double {
        // 返回当前阶段的进度 (0.0 - 1.0)
        return 0.5 // 临时返回
    }
    
    func getCurrentPhaseElapsedTime() -> TimeInterval {
        // 返回当前阶段已经耗费的时间
        return 0.1 // 临时返回
    }
}