//
//  PerformanceVisualizationView.swift
//  StartupAnalyzer
//
//  性能数据可视化视图 - 展示启动性能分析结果
//  Created for iOS Startup Optimization Learning
//

import UIKit
import QuartzCore

/// 性能数据可视化视图
/// 提供多种图表展示启动性能数据
class PerformanceVisualizationView: UIView {
    
    // MARK: - UI 组件
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let summaryView = PerformanceSummaryView()
    private let phaseChartView = PhaseTimelineChartView()
    private let categoryPieChartView = CategoryPieChartView()
    private let performanceScoreView = PerformanceScoreView()
    private let optimizationSuggestionsView = OptimizationSuggestionsView()
    
    // MARK: - 数据属性
    
    private var phaseRecords: [StartupPhaseAnalyzer.PhaseRecord] = []
    private var performanceMetrics: PerformanceMetrics?
    
    struct PerformanceMetrics {
        let totalStartupTime: TimeInterval
        let averageFPS: Double
        let peakMemoryUsage: Double
        let averageCPUUsage: Double
        let performanceScore: Int
    }
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 标题设置
        titleLabel.text = "启动性能分析报告"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        // 滚动视图设置
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // 添加子视图
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(summaryView)
        contentView.addSubview(phaseChartView)
        contentView.addSubview(categoryPieChartView)
        contentView.addSubview(performanceScoreView)
        contentView.addSubview(optimizationSuggestionsView)
        
        // 设置子视图样式
        setupSubviewStyles()
    }
    
    private func setupSubviewStyles() {
        let cornerRadius: CGFloat = 12
        let shadowOpacity: Float = 0.1
        let shadowOffset = CGSize(width: 0, height: 2)
        let shadowRadius: CGFloat = 4
        
        let views = [summaryView, phaseChartView, categoryPieChartView, performanceScoreView, optimizationSuggestionsView]
        
        for view in views {
            view.backgroundColor = .secondarySystemBackground
            view.layer.cornerRadius = cornerRadius
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = shadowOpacity
            view.layer.shadowOffset = shadowOffset
            view.layer.shadowRadius = shadowRadius
        }
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        phaseChartView.translatesAutoresizingMaskIntoConstraints = false
        categoryPieChartView.translatesAutoresizingMaskIntoConstraints = false
        performanceScoreView.translatesAutoresizingMaskIntoConstraints = false
        optimizationSuggestionsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 标题约束
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 摘要视图约束
            summaryView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            summaryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryView.heightAnchor.constraint(equalToConstant: 120),
            
            // 阶段图表约束
            phaseChartView.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: 16),
            phaseChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            phaseChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            phaseChartView.heightAnchor.constraint(equalToConstant: 300),
            
            // 分类饼图约束
            categoryPieChartView.topAnchor.constraint(equalTo: phaseChartView.bottomAnchor, constant: 16),
            categoryPieChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryPieChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryPieChartView.heightAnchor.constraint(equalToConstant: 250),
            
            // 性能评分约束
            performanceScoreView.topAnchor.constraint(equalTo: categoryPieChartView.bottomAnchor, constant: 16),
            performanceScoreView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            performanceScoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            performanceScoreView.heightAnchor.constraint(equalToConstant: 150),
            
            // 优化建议约束
            optimizationSuggestionsView.topAnchor.constraint(equalTo: performanceScoreView.bottomAnchor, constant: 16),
            optimizationSuggestionsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optimizationSuggestionsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optimizationSuggestionsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 数据更新
    
    /// 更新性能数据
    func updatePerformanceData(
        phaseRecords: [StartupPhaseAnalyzer.PhaseRecord],
        metrics: PerformanceMetrics
    ) {
        self.phaseRecords = phaseRecords
        self.performanceMetrics = metrics
        
        DispatchQueue.main.async {
            self.refreshAllViews()
        }
    }
    
    private func refreshAllViews() {
        guard let metrics = performanceMetrics else { return }
        
        summaryView.updateSummary(
            totalTime: metrics.totalStartupTime,
            averageFPS: metrics.averageFPS,
            peakMemory: metrics.peakMemoryUsage,
            averageCPU: metrics.averageCPUUsage
        )
        
        phaseChartView.updatePhaseData(phaseRecords)
        categoryPieChartView.updateCategoryData(phaseRecords)
        performanceScoreView.updateScore(metrics.performanceScore)
        optimizationSuggestionsView.updateSuggestions(phaseRecords)
    }
}

// MARK: - 性能摘要视图

class PerformanceSummaryView: UIView {
    
    private let stackView = UIStackView()
    private let totalTimeLabel = MetricLabel()
    private let fpsLabel = MetricLabel()
    private let memoryLabel = MetricLabel()
    private let cpuLabel = MetricLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(totalTimeLabel)
        stackView.addArrangedSubview(fpsLabel)
        stackView.addArrangedSubview(memoryLabel)
        stackView.addArrangedSubview(cpuLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateSummary(totalTime: TimeInterval, averageFPS: Double, peakMemory: Double, averageCPU: Double) {
        totalTimeLabel.update(title: "启动时间", value: "\(String(format: "%.0f", totalTime * 1000))ms", color: .systemBlue)
        fpsLabel.update(title: "平均FPS", value: String(format: "%.1f", averageFPS), color: .systemGreen)
        memoryLabel.update(title: "内存峰值", value: "\(String(format: "%.1f", peakMemory))MB", color: .systemOrange)
        cpuLabel.update(title: "平均CPU", value: "\(String(format: "%.1f", averageCPU))%", color: .systemPurple)
    }
}

// MARK: - 指标标签

class MetricLabel: UIView {
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textAlignment = .center
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func update(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

// MARK: - 阶段时间线图表视图

class PhaseTimelineChartView: UIView {
    
    private let titleLabel = UILabel()
    private let chartView = UIView()
    // 移除重复的phaseRecords存储，直接使用传入的数据
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "启动阶段时间线"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        addSubview(titleLabel)
        addSubview(chartView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updatePhaseData(_ records: [StartupPhaseAnalyzer.PhaseRecord]) {
        setNeedsDisplay()
        
        // 清除旧的子视图
        chartView.subviews.forEach { $0.removeFromSuperview() }
        
        // 绘制新的图表
        drawPhaseChart(with: records)
    }
    
    private func drawPhaseChart(with phaseRecords: [StartupPhaseAnalyzer.PhaseRecord]) {
        guard !phaseRecords.isEmpty else { return }
        
        let maxDuration = phaseRecords.map { $0.duration }.max() ?? 0
        let chartHeight: CGFloat = 200
        let barHeight: CGFloat = 20
        let spacing: CGFloat = 4
        
        for (index, record) in phaseRecords.enumerated() {
            let barWidth = CGFloat(record.duration / maxDuration) * (chartView.bounds.width - 100)
            let yPosition = CGFloat(index) * (barHeight + spacing)
            
            // 创建进度条
            let barView = UIView()
            barView.backgroundColor = record.performanceLevel.color
            barView.layer.cornerRadius = 4
            
            // 创建标签
            let label = UILabel()
            label.text = "\(record.phase.rawValue) (\(String(format: "%.1f ms", record.durationMs)))"
            label.font = .systemFont(ofSize: 12)
            label.textColor = .label
            
            chartView.addSubview(barView)
            chartView.addSubview(label)
            
            barView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
                barView.topAnchor.constraint(equalTo: chartView.topAnchor, constant: yPosition),
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: barHeight),
                
                label.leadingAnchor.constraint(equalTo: barView.trailingAnchor, constant: 8),
                label.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
            ])
        }
    }
}

// MARK: - 分类饼图视图

class CategoryPieChartView: UIView {
    
    private let titleLabel = UILabel()
    private let chartView = UIView()
    private let legendView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "阶段分类耗时分布"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        legendView.axis = .vertical
        legendView.spacing = 8
        
        addSubview(titleLabel)
        addSubview(chartView)
        addSubview(legendView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        legendView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartView.widthAnchor.constraint(equalToConstant: 150),
            chartView.heightAnchor.constraint(equalToConstant: 150),
            
            legendView.topAnchor.constraint(equalTo: chartView.topAnchor),
            legendView.leadingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: 20),
            legendView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func updateCategoryData(_ records: [StartupPhaseAnalyzer.PhaseRecord]) {
        // 简化的饼图实现
        // 实际项目中可以使用Charts库或自定义绘制
        
        var categoryDurations: [StartupPhaseAnalyzer.PhaseCategory: TimeInterval] = [:]
        
        for category in StartupPhaseAnalyzer.PhaseCategory.allCases {
            let categoryRecords = records.filter { $0.phase.category == category }
            let totalDuration = categoryRecords.reduce(0) { $0 + $1.duration }
            categoryDurations[category] = totalDuration
        }
        
        updateLegend(categoryDurations)
    }
    
    private func updateLegend(_ categoryDurations: [StartupPhaseAnalyzer.PhaseCategory: TimeInterval]) {
        legendView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalDuration = categoryDurations.values.reduce(0, +)
        
        for category in StartupPhaseAnalyzer.PhaseCategory.allCases {
            let duration = categoryDurations[category] ?? 0
            let percentage = totalDuration > 0 ? (duration / totalDuration) * 100 : 0
            
            let legendItem = createLegendItem(
                color: category.color,
                title: category.rawValue,
                value: "\(String(format: "%.1f ms (%.1f%%)", duration * 1000, percentage))"
            )
            
            legendView.addArrangedSubview(legendItem)
        }
    }
    
    private func createLegendItem(color: UIColor, title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 6
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = .secondaryLabel
        
        containerView.addSubview(colorView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 12),
            colorView.heightAnchor.constraint(equalToConstant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
}

// MARK: - 性能评分视图

class PerformanceScoreView: UIView {
    
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let progressView = UIProgressView()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "性能评分"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        scoreLabel.font = .systemFont(ofSize: 48, weight: .bold)
        scoreLabel.textAlignment = .center
        
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        addSubview(scoreLabel)
        addSubview(progressView)
        addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            progressView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
        progressView.progress = Float(score) / 100.0
        
        let (color, description) = getScoreInfo(score)
        scoreLabel.textColor = color
        progressView.progressTintColor = color
        descriptionLabel.text = description
    }
    
    private func getScoreInfo(_ score: Int) -> (UIColor, String) {
        switch score {
        case 90...100:
            return (.systemGreen, "优秀！启动性能表现卓越")
        case 80..<90:
            return (.systemBlue, "良好，启动性能表现不错")
        case 70..<80:
            return (.systemOrange, "一般，有一定优化空间")
        case 60..<70:
            return (.systemRed, "较差，需要重点优化")
        default:
            return (.systemRed, "很差，急需优化改进")
        }
    }
}

// MARK: - 优化建议视图

class OptimizationSuggestionsView: UIView {
    
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "优化建议"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        stackView.axis = .vertical
        stackView.spacing = 12
        
        addSubview(titleLabel)
        addSubview(stackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateSuggestions(_ records: [StartupPhaseAnalyzer.PhaseRecord]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let needOptimization = records.filter { 
            $0.performanceLevel == .poor || $0.performanceLevel == .acceptable 
        }.sorted { $0.duration > $1.duration }
        
        if needOptimization.isEmpty {
            let noSuggestionsLabel = UILabel()
            noSuggestionsLabel.text = "🎉 所有阶段性能表现良好，无需特别优化"
            noSuggestionsLabel.font = .systemFont(ofSize: 14)
            noSuggestionsLabel.textColor = .systemGreen
            noSuggestionsLabel.textAlignment = .center
            stackView.addArrangedSubview(noSuggestionsLabel)
            return
        }
        
        for (index, record) in needOptimization.prefix(5).enumerated() {
            let suggestionView = createSuggestionView(
                priority: index + 1,
                phase: record.phase.rawValue,
                duration: record.durationMs,
                level: record.performanceLevel,
                tips: Array(record.phase.optimizationTips.prefix(2))
            )
            stackView.addArrangedSubview(suggestionView)
        }
    }
    
    private func createSuggestionView(
        priority: Int,
        phase: String,
        duration: Double,
        level: StartupPhaseAnalyzer.PerformanceLevel,
        tips: [String]
    ) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8
        
        let headerLabel = UILabel()
        headerLabel.text = "\(level.emoji) 优先级 \(priority): \(phase) (\(String(format: "%.1f ms", duration)))"
        headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        headerLabel.textColor = level.color
        
        let tipsStackView = UIStackView()
        tipsStackView.axis = .vertical
        tipsStackView.spacing = 4
        
        for tip in tips {
            let tipLabel = UILabel()
            tipLabel.text = "• \(tip)"
            tipLabel.font = .systemFont(ofSize: 13)
            tipLabel.textColor = .secondaryLabel
            tipLabel.numberOfLines = 0
            tipsStackView.addArrangedSubview(tipLabel)
        }
        
        containerView.addSubview(headerLabel)
        containerView.addSubview(tipsStackView)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            tipsStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            tipsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tipsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            tipsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
}

// MARK: - 公共方法

extension PerformanceVisualizationView {
    
    /// 清除所有图表数据
    func clearData() {
        // 清除所有数据
        self.phaseRecords.removeAll()
        self.performanceMetrics = nil
        
        // 刷新所有视图
        self.refreshAllViews()
    }
}