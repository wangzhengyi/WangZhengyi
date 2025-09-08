//
//  AppDelegate.swift
//  HelloWorldApp
//
//  Created for iOS Learning
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 创建应用程序的主窗口
        // UIWindow是iOS应用的根容器，所有UI都显示在窗口中
        // UIScreen.main.bounds获取主屏幕的尺寸边界
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 设置窗口的根视图控制器
        // rootViewController是窗口显示的第一个视图控制器
        // ViewController()创建我们自定义的视图控制器实例
        window?.rootViewController = ViewController()
        
        // 使窗口可见并成为主窗口
        // makeKeyAndVisible()让窗口显示在屏幕上并接收用户交互
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle (iOS 13+)
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}