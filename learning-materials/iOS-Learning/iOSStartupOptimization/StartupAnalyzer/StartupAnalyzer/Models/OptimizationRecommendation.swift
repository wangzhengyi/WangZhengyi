//
//  OptimizationRecommendation.swift
//  StartupAnalyzer
//
//  优化建议数据模型 - 定义启动优化建议
//  Created for iOS Startup Optimization Learning
//

import Foundation

/// 优化建议数据结构
/// 包含针对启动性能的具体优化建议
struct OptimizationRecommendation {
    
    // MARK: - 基础属性
    
    /// 建议ID
    let id: String
    
    /// 建议标题
    let title: String
    
    /// 建议描述
    let description: String
    
    /// 详细说明
    let details: String
    
    /// 优先级
    let priority: Priority
    
    /// 分类
    let category: Category
    
    /// 预期影响
    let expectedImpact: Impact
    
    /// 实施难度
    let difficulty: Difficulty
    
    /// 预估时间节省（毫秒）
    let estimatedTimeSaving: TimeInterval
    
    /// 创建时间
    let createdAt: Date
    
    /// 是否已实施
    var isImplemented: Bool
    
    /// 实施时间
    var implementedAt: Date?
    
    /// 相关代码文件
    let relatedFiles: [String]
    
    /// 相关方法或函数
    let relatedMethods: [String]
    
    // MARK: - 初始化方法
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        details: String = "",
        priority: Priority,
        category: Category,
        expectedImpact: Impact,
        difficulty: Difficulty,
        estimatedTimeSaving: TimeInterval = 0,
        createdAt: Date = Date(),
        isImplemented: Bool = false,
        implementedAt: Date? = nil,
        relatedFiles: [String] = [],
        relatedMethods: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.details = details
        self.priority = priority
        self.category = category
        self.expectedImpact = expectedImpact
        self.difficulty = difficulty
        self.estimatedTimeSaving = estimatedTimeSaving
        self.createdAt = createdAt
        self.isImplemented = isImplemented
        self.implementedAt = implementedAt
        self.relatedFiles = relatedFiles
        self.relatedMethods = relatedMethods
    }
    
    // MARK: - 计算属性
    
    /// 格式化的预估时间节省
    var formattedTimeSaving: String {
        if estimatedTimeSaving < 0.001 {
            return "< 1ms"
        } else {
            return String(format: "%.0fms", estimatedTimeSaving * 1000)
        }
    }
    
    /// 建议的重要性评分（0-100）
    var importanceScore: Int {
        let priorityWeight = priority.weight
        let impactWeight = expectedImpact.weight
        let difficultyWeight = (6 - difficulty.weight) // 难度越低，权重越高
        
        return min(100, (priorityWeight * 40 + impactWeight * 40 + difficultyWeight * 20) / 100)
    }
    
    /// 是否为高优先级建议
    var isHighPriority: Bool {
        return priority == .critical || priority == .high
    }
    
    /// 是否为快速修复
    var isQuickWin: Bool {
        return difficulty == .easy && expectedImpact != .low
    }
    
    // MARK: - 实例方法
    
    /// 标记为已实施
    mutating func markAsImplemented() {
        isImplemented = true
        implementedAt = Date()
    }
    
    /// 取消实施标记
    mutating func markAsNotImplemented() {
        isImplemented = false
        implementedAt = nil
    }
    
    // MARK: - 静态方法
    
    /// 创建预定义的优化建议集合
    static func getCommonRecommendations() -> [OptimizationRecommendation] {
        return [
            // 启动时间优化
            OptimizationRecommendation(
                title: "延迟非关键初始化",
                description: "将非关键的初始化操作延迟到应用启动完成后执行",
                details: "识别并延迟那些不影响首屏显示的初始化操作，如第三方SDK初始化、数据预加载等。可以使用DispatchQueue.main.async或延迟几秒后执行。",
                priority: .high,
                category: .initialization,
                expectedImpact: .high,
                difficulty: .medium,
                estimatedTimeSaving: 0.2,
                relatedFiles: ["AppDelegate.swift", "SceneDelegate.swift"],
                relatedMethods: ["application(_:didFinishLaunchingWithOptions:)", "scene(_:willConnectTo:options:)"]
            ),
            
            // 内存优化
            OptimizationRecommendation(
                title: "优化图片资源加载",
                description: "使用懒加载和适当的图片格式来减少内存占用",
                details: "将大图片资源改为懒加载，使用WebP格式减少文件大小，实现图片缓存机制。避免在启动时加载所有图片资源。",
                priority: .medium,
                category: .memory,
                expectedImpact: .medium,
                difficulty: .medium,
                estimatedTimeSaving: 0.15,
                relatedFiles: ["ImageCache.swift", "ResourceManager.swift"],
                relatedMethods: ["loadImage(_:)", "preloadImages()"]
            ),
            
            // 网络优化
            OptimizationRecommendation(
                title: "减少启动时网络请求",
                description: "将非必要的网络请求延迟到启动完成后执行",
                details: "分析启动时的网络请求，将非关键数据的获取延迟执行。使用缓存机制减少重复请求，实现离线模式支持。",
                priority: .high,
                category: .network,
                expectedImpact: .high,
                difficulty: .easy,
                estimatedTimeSaving: 0.3,
                relatedFiles: ["NetworkManager.swift", "APIClient.swift"],
                relatedMethods: ["fetchInitialData()", "loadUserProfile()"]
            ),
            
            // 代码优化
            OptimizationRecommendation(
                title: "移除未使用的代码",
                description: "清理未使用的类、方法和资源文件",
                details: "使用工具扫描并移除未使用的代码，减少应用包大小和启动时的加载时间。定期进行代码审查和清理。",
                priority: .low,
                category: .codeOptimization,
                expectedImpact: .low,
                difficulty: .easy,
                estimatedTimeSaving: 0.05,
                relatedFiles: [],
                relatedMethods: []
            ),
            
            // 数据库优化
            OptimizationRecommendation(
                title: "优化数据库查询",
                description: "优化启动时的数据库操作，使用索引和批量操作",
                details: "为常用查询添加索引，使用批量操作减少数据库访问次数，将复杂查询移到后台线程执行。",
                priority: .medium,
                category: .database,
                expectedImpact: .medium,
                difficulty: .hard,
                estimatedTimeSaving: 0.1,
                relatedFiles: ["DatabaseManager.swift", "CoreDataStack.swift"],
                relatedMethods: ["loadInitialData()", "setupDatabase()"]
            )
        ]
    }
    
    /// 根据性能指标生成建议
    static func generateRecommendations(for metrics: PerformanceMetrics) -> [OptimizationRecommendation] {
        var recommendations: [OptimizationRecommendation] = []
        
        // 基于启动时间的建议
        if metrics.totalLaunchTime > 2.0 {
            recommendations.append(
                OptimizationRecommendation(
                    title: "启动时间过长",
                    description: "当前启动时间为 \(metrics.formattedTotalLaunchTime)，建议优化启动流程",
                    details: "分析启动过程中的耗时操作，将非关键操作延迟执行，优化关键路径上的代码。",
                    priority: .critical,
                    category: .initialization,
                    expectedImpact: .high,
                    difficulty: .medium,
                    estimatedTimeSaving: metrics.totalLaunchTime * 0.3
                )
            )
        }
        
        // 基于内存使用的建议
        if metrics.memoryUsage > 150_000_000 { // 150MB
            recommendations.append(
                OptimizationRecommendation(
                    title: "内存使用过高",
                    description: "当前内存使用量为 \(metrics.formattedMemoryUsage)，建议优化内存管理",
                    details: "检查内存泄漏，优化图片和数据缓存策略，使用懒加载减少内存占用。",
                    priority: .high,
                    category: .memory,
                    expectedImpact: .medium,
                    difficulty: .medium,
                    estimatedTimeSaving: 0.1
                )
            )
        }
        
        // 基于CPU使用的建议
        if metrics.cpuUsage > 70 {
            recommendations.append(
                OptimizationRecommendation(
                    title: "CPU使用率过高",
                    description: "当前CPU使用率为 \(String(format: "%.1f", metrics.cpuUsage))%，建议优化计算密集型操作",
                    details: "将耗时计算移到后台线程，使用更高效的算法，避免在主线程执行重计算。",
                    priority: .medium,
                    category: .performance,
                    expectedImpact: .medium,
                    difficulty: .hard,
                    estimatedTimeSaving: 0.15
                )
            )
        }
        
        return recommendations
    }
}

// MARK: - 支持枚举

/// 优先级
enum Priority: String, CaseIterable {
    case critical = "严重"
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var weight: Int {
        switch self {
        case .critical: return 100
        case .high: return 75
        case .medium: return 50
        case .low: return 25
        }
    }
    
    var color: String {
        switch self {
        case .critical: return "systemRed"
        case .high: return "systemOrange"
        case .medium: return "systemYellow"
        case .low: return "systemGreen"
        }
    }
}

/// 分类
enum Category: String, CaseIterable {
    case initialization = "初始化"
    case memory = "内存"
    case network = "网络"
    case database = "数据库"
    case codeOptimization = "代码优化"
    case performance = "性能"
    case ui = "用户界面"
    case thirdParty = "第三方库"
    
    var icon: String {
        switch self {
        case .initialization: return "gear"
        case .memory: return "memorychip"
        case .network: return "network"
        case .database: return "cylinder"
        case .codeOptimization: return "hammer"
        case .performance: return "speedometer"
        case .ui: return "paintbrush"
        case .thirdParty: return "cube.box"
        }
    }
}

/// 预期影响
enum Impact: String, CaseIterable {
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var weight: Int {
        switch self {
        case .high: return 100
        case .medium: return 60
        case .low: return 30
        }
    }
    
    var description: String {
        switch self {
        case .high: return "显著改善启动性能"
        case .medium: return "适度改善启动性能"
        case .low: return "轻微改善启动性能"
        }
    }
}

/// 实施难度
enum Difficulty: String, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"
    
    var weight: Int {
        switch self {
        case .easy: return 1
        case .medium: return 3
        case .hard: return 5
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "1-2小时内完成"
        case .medium: return "半天到1天完成"
        case .hard: return "需要1天以上时间"
        }
    }
}

// MARK: - Codable 支持

extension OptimizationRecommendation: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, details
        case priority, category, expectedImpact, difficulty
        case estimatedTimeSaving, createdAt
        case isImplemented, implementedAt
        case relatedFiles, relatedMethods
    }
}

// MARK: - Identifiable 支持

extension OptimizationRecommendation: Identifiable {}

// MARK: - Equatable 支持

extension OptimizationRecommendation: Equatable {
    
    static func == (lhs: OptimizationRecommendation, rhs: OptimizationRecommendation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable 支持

extension OptimizationRecommendation: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}