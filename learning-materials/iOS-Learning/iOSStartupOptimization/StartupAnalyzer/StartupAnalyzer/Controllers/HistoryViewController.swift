//
//  HistoryViewController.swift
//  StartupAnalyzer
//
//  历史记录视图控制器 - 显示历史分析记录
//  Created for iOS Startup Optimization Learning
//

import UIKit

/// 历史记录视图控制器
/// 显示和管理历史启动分析记录
class HistoryViewController: UIViewController {
    
    // MARK: - UI 组件
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - 数据
    
    private var historyRecords: [HistoryRecord] = []
    
    struct HistoryRecord {
        let id: String
        let date: Date
        let totalLaunchTime: TimeInterval
        let performanceScore: Int
        let phaseCount: Int
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        var formattedLaunchTime: String {
            return String(format: "%.3f ms", totalLaunchTime * 1000)
        }
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHistoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoryData()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupEmptyStateView()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
    }
    
    private func setupEmptyStateView() {
        emptyStateLabel.text = "暂无历史记录\n开始分析以查看历史数据"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 16)
        
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
        
        emptyStateView.isHidden = true
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    // MARK: - 数据管理
    
    private func loadHistoryData() {
        // 模拟历史数据加载
        // 实际项目中应该从持久化存储中加载
        historyRecords = generateMockHistoryData()
        
        updateUI()
    }
    
    private func generateMockHistoryData() -> [HistoryRecord] {
        // 生成模拟历史数据
        var records: [HistoryRecord] = []
        
        for i in 0..<5 {
            let record = HistoryRecord(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(-TimeInterval(i * 3600)), // 每小时一条记录
                totalLaunchTime: Double.random(in: 0.5...2.0),
                performanceScore: Int.random(in: 60...95),
                phaseCount: Int.random(in: 8...12)
            )
            records.append(record)
        }
        
        return records.sorted { $0.date > $1.date }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.emptyStateView.isHidden = !self.historyRecords.isEmpty
            self.tableView.isHidden = self.historyRecords.isEmpty
        }
    }
    
    // MARK: - 公开方法
    
    func addHistoryRecord(_ record: HistoryRecord) {
        historyRecords.insert(record, at: 0)
        updateUI()
    }
    
    func addSession(_ sessionData: StartupAnalysisViewController.SessionData) {
        let record = HistoryRecord(
            id: sessionData.sessionId,
            date: sessionData.startTime,
            totalLaunchTime: sessionData.phaseRecords.reduce(0) { $0 + $1.duration },
            performanceScore: calculatePerformanceScore(from: sessionData),
            phaseCount: sessionData.phaseRecords.count
        )
        addHistoryRecord(record)
    }
    
    private func calculatePerformanceScore(from sessionData: StartupAnalysisViewController.SessionData) -> Int {
        let totalTime = sessionData.phaseRecords.reduce(0) { $0 + $1.duration }
        
        // 基于启动时间计算性能评分 (0-100分)
        if totalTime < 0.5 {
            return 95
        } else if totalTime < 1.0 {
            return 85
        } else if totalTime < 1.5 {
            return 75
        } else if totalTime < 2.0 {
            return 65
        } else {
            return 50
        }
    }
    
    func clearHistory() {
        historyRecords.removeAll()
        updateUI()
    }
    
    func clearAllSessions() {
        clearHistory()
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        let record = historyRecords[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let record = historyRecords[indexPath.row]
        showRecordDetail(record)
    }
    
    private func showRecordDetail(_ record: HistoryRecord) {
        let alert = UIAlertController(
            title: "历史记录详情",
            message: """
            记录时间: \(record.formattedDate)
            启动时间: \(record.formattedLaunchTime)
            性能评分: \(record.performanceScore)分
            分析阶段: \(record.phaseCount)个
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - HistoryTableViewCell

class HistoryTableViewCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    private let launchTimeLabel = UILabel()
    private let scoreLabel = UILabel()
    private let phaseCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 日期标签
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .label
        
        // 启动时间标签
        launchTimeLabel.font = .systemFont(ofSize: 14)
        launchTimeLabel.textColor = .secondaryLabel
        
        // 评分标签
        scoreLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        scoreLabel.textAlignment = .right
        
        // 阶段数量标签
        phaseCountLabel.font = .systemFont(ofSize: 12)
        phaseCountLabel.textColor = .tertiaryLabel
        phaseCountLabel.textAlignment = .right
        
        [dateLabel, launchTimeLabel, scoreLabel, phaseCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 日期标签
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8),
            
            // 启动时间标签
            launchTimeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            launchTimeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            launchTimeLabel.trailingAnchor.constraint(lessThanOrEqualTo: phaseCountLabel.leadingAnchor, constant: -8),
            launchTimeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            // 评分标签
            scoreLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // 阶段数量标签
            phaseCountLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            phaseCountLabel.trailingAnchor.constraint(equalTo: scoreLabel.trailingAnchor),
            phaseCountLabel.widthAnchor.constraint(equalTo: scoreLabel.widthAnchor)
        ])
    }
    
    func configure(with record: HistoryViewController.HistoryRecord) {
        dateLabel.text = record.formattedDate
        launchTimeLabel.text = "启动时间: \(record.formattedLaunchTime)"
        scoreLabel.text = "\(record.performanceScore)分"
        phaseCountLabel.text = "\(record.phaseCount)个阶段"
        
        // 根据评分设置颜色
        if record.performanceScore >= 90 {
            scoreLabel.textColor = .systemGreen
        } else if record.performanceScore >= 75 {
            scoreLabel.textColor = .systemBlue
        } else if record.performanceScore >= 60 {
            scoreLabel.textColor = .systemOrange
        } else {
            scoreLabel.textColor = .systemRed
        }
    }
}