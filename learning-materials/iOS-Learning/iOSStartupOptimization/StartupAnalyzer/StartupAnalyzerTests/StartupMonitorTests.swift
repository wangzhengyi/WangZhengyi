//
//  StartupMonitorTests.swift
//  StartupAnalyzerTests
//
//  Created by iOS Learning Project on 2024/01/15.
//  Copyright © 2024 iOS Learning Project. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import StartupAnalyzer

class StartupMonitorTests: QuickSpec {
    
    override func spec() {
        describe("StartupMonitor") {
            var monitor: StartupMonitor!
            
            beforeEach {
                monitor = StartupMonitor.shared
                monitor.reset() // 重置监控器状态
            }
            
            afterEach {
                monitor.stopMonitoring()
            }
            
            context("when monitoring startup") {
                it("should start monitoring successfully") {
                    monitor.startMonitoring()
                    expect(monitor.isMonitoring).to(beTrue())
                }
                
                it("should record startup phases") {
                    monitor.startMonitoring()
                    
                    // 模拟启动阶段
                    monitor.recordPhase(.premain, startTime: Date())
                    
                    let phases = monitor.getRecordedPhases()
                    expect(phases).toNot(beEmpty())
                    expect(phases.first?.phase).to(equal(StartupPhase.premain))
                }
                
                it("should calculate total startup time") {
                    let startTime = Date()
                    monitor.startMonitoring()
                    
                    // 等待一小段时间
                    Thread.sleep(forTimeInterval: 0.1)
                    
                    monitor.completeMonitoring()
                    
                    let totalTime = monitor.getTotalStartupTime()
                    expect(totalTime).to(beGreaterThan(0.05))
                    expect(totalTime).to(beLessThan(1.0))
                }
            }
            
            context("when collecting system metrics") {
                it("should get valid memory usage") {
                    let memoryUsage = monitor.getCurrentMemoryUsage()
                    expect(memoryUsage).to(beGreaterThan(0))
                }
                
                it("should get valid CPU usage") {
                    let cpuUsage = monitor.getCurrentCPUUsage()
                    expect(cpuUsage).to(beGreaterThanOrEqualTo(0))
                    expect(cpuUsage).to(beLessThanOrEqualTo(100))
                }
                
                it("should get battery level") {
                    let batteryLevel = monitor.getBatteryLevel()
                    expect(batteryLevel).to(beGreaterThanOrEqualTo(0))
                    expect(batteryLevel).to(beLessThanOrEqualTo(100))
                }
            }
            
            context("when analyzing performance") {
                beforeEach {
                    // 设置测试数据
                    monitor.startMonitoring()
                    monitor.recordPhase(.premain, startTime: Date())
                    Thread.sleep(forTimeInterval: 0.05)
                    monitor.recordPhase(.main, startTime: Date())
                    Thread.sleep(forTimeInterval: 0.03)
                    monitor.recordPhase(.postLaunch, startTime: Date())
                    Thread.sleep(forTimeInterval: 0.02)
                    monitor.completeMonitoring()
                }
                
                it("should generate performance analysis") {
                    let analysis = monitor.generatePerformanceAnalysis()
                    
                    expect(analysis["totalTime"]).toNot(beNil())
                    expect(analysis["phases"]).toNot(beNil())
                    expect(analysis["systemMetrics"]).toNot(beNil())
                }
                
                it("should identify slow phases") {
                    let slowPhases = monitor.getSlowPhases(threshold: 0.01)
                    expect(slowPhases).toNot(beEmpty())
                }
                
                it("should provide optimization suggestions") {
                    let suggestions = monitor.getOptimizationSuggestions()
                    expect(suggestions).toNot(beEmpty())
                }
            }
            
            context("when handling edge cases") {
                it("should handle multiple start calls gracefully") {
                    monitor.startMonitoring()
                    monitor.startMonitoring() // 重复调用
                    
                    expect(monitor.isMonitoring).to(beTrue())
                }
                
                it("should handle stop without start") {
                    monitor.stopMonitoring() // 没有先调用start
                    
                    expect(monitor.isMonitoring).to(beFalse())
                }
                
                it("should reset state properly") {
                    monitor.startMonitoring()
                    monitor.recordPhase(.premain, startTime: Date())
                    monitor.reset()
                    
                    expect(monitor.getRecordedPhases()).to(beEmpty())
                    expect(monitor.isMonitoring).to(beFalse())
                }
            }
        }
    }
}

// MARK: - 传统XCTest测试
class StartupMonitorXCTests: XCTestCase {
    
    var monitor: StartupMonitor!
    
    override func setUp() {
        super.setUp()
        monitor = StartupMonitor.shared
        monitor.reset()
    }
    
    override func tearDown() {
        monitor.stopMonitoring()
        super.tearDown()
    }
    
    func testSingletonInstance() {
        let instance1 = StartupMonitor.shared
        let instance2 = StartupMonitor.shared
        
        XCTAssertTrue(instance1 === instance2, "StartupMonitor should be singleton")
    }
    
    func testStartupTimeCalculation() {
        let expectation = XCTestExpectation(description: "Startup time calculation")
        
        monitor.startMonitoring()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.monitor.completeMonitoring()
            
            let totalTime = self.monitor.getTotalStartupTime()
            XCTAssertGreaterThan(totalTime, 0.05)
            XCTAssertLessThan(totalTime, 1.0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPhaseRecording() {
        monitor.startMonitoring()
        
        let testPhases: [StartupPhase] = [.premain, .main, .postLaunch]
        
        for phase in testPhases {
            monitor.recordPhase(phase, startTime: Date())
        }
        
        let recordedPhases = monitor.getRecordedPhases()
        XCTAssertEqual(recordedPhases.count, testPhases.count)
        
        for (index, recordedPhase) in recordedPhases.enumerated() {
            XCTAssertEqual(recordedPhase.phase, testPhases[index])
        }
    }
    
    func testPerformanceMetrics() {
        // 测试内存使用情况
        let memoryUsage = monitor.getCurrentMemoryUsage()
        XCTAssertGreaterThan(memoryUsage, 0)
        
        // 测试CPU使用情况
        let cpuUsage = monitor.getCurrentCPUUsage()
        XCTAssertGreaterThanOrEqual(cpuUsage, 0)
        XCTAssertLessThanOrEqual(cpuUsage, 100)
    }
}