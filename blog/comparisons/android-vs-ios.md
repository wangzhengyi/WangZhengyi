# Android vs iOS 启动/内存/渲染 对照表

## 1. 应用启动机制对比

### 启动流程对比

| 维度 | Android | iOS |
|------|---------|-----|
| **启动入口** | `Application.onCreate()` | `application(_:didFinishLaunchingWithOptions:)` |
| **主线程** | UI Thread (Main Thread) | Main Thread |
| **启动类型** | 冷启动、温启动、热启动 | 冷启动、热启动 |
| **启动时间** | 通过 `adb shell am start -W` 测量 | 通过 Instruments Time Profiler 测量 |

### 代码示例对比

#### Android 启动代码
```java
// Application 类 - 启动时间测量起点
public class MyApplication extends Application {
    public static long sAppStartTime;
    
    static {
        // 在类加载时记录启动开始时间（最早时机）
        sAppStartTime = System.currentTimeMillis();
    }
    
    @Override
    public void onCreate() {
        super.onCreate();
        long appCreateTime = System.currentTimeMillis();
        Log.d("StartupTime", "Application onCreate: " + (appCreateTime - sAppStartTime) + "ms");
        
        // 应用启动初始化
        initSDK();
        setupCrashHandler();
    }
}

// MainActivity 启动 - 测量到首屏渲染完成
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initViews();
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // 首屏渲染完成时间点
        getWindow().getDecorView().post(() -> {
            long totalStartupTime = System.currentTimeMillis() - MyApplication.sAppStartTime;
            Log.d("StartupTime", "Total startup time: " + totalStartupTime + "ms");
        });
    }
}
```

#### iOS 启动代码
```swift
// AppDelegate.swift - 启动时间测量起点
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var appStartTime: CFAbsoluteTime = 0
    
    // 在 main 函数执行前记录启动时间（最早时机）
    override init() {
        super.init()
        if AppDelegate.appStartTime == 0 {
            AppDelegate.appStartTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appLaunchTime = CFAbsoluteTimeGetCurrent()
        print("Application didFinishLaunching: \((appLaunchTime - AppDelegate.appStartTime) * 1000)ms")
        
        // 应用启动初始化
        setupSDK()
        setupCrashHandler()
        return true
    }
}

// ViewController 启动 - 测量到首屏渲染完成
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 首屏渲染完成时间点
        DispatchQueue.main.async {
            let totalStartupTime = (CFAbsoluteTimeGetCurrent() - AppDelegate.appStartTime) * 1000
            print("Total startup time: \(totalStartupTime)ms")
        }
    }
}
```

### 启动优化对比

### 启动优化方法论

#### 1. 启动阶段划分与优化策略

| 启动阶段 | Android 优化方案 | iOS 优化方案 |
|----------|-----------------|-------------|
| **冷启动优化** | • Application 瘦身：延迟非必要初始化<br>• MultiDex 优化：主 dex 包含核心类<br>• 启动窗口优化：设置 windowBackground | • +load 方法优化：避免耗时操作<br>• 动态库合并：减少 dylib 加载时间<br>• Info.plist 精简：移除无用配置 |
| **首屏渲染** | • 布局优化：减少嵌套层级<br>• 异步加载：图片、数据分离<br>• ViewStub 懒加载：按需创建视图 | • Storyboard 拆分：避免大文件加载<br>• 异步渲染：后台准备 UI 数据<br>• Auto Layout 优化：减少约束计算 |
| **业务初始化** | • 分级初始化：核心业务优先<br>• 线程池管理：控制并发数量<br>• 预加载策略：智能预测用户行为 | • 模块化启动：按需加载业务模块<br>• GCD 优化：合理使用队列优先级<br>• 预热机制：提前准备关键资源 |

#### 2. 字节/美团级别的深度优化

| 优化维度 | Android 实现 | iOS 实现 |
|----------|-------------|----------|
| **编译期优化** | • ProGuard/R8 深度混淆<br>• 字节码插桩：启动链路监控<br>• APK 瘦身：资源压缩、无用代码删除 | • Link Map 分析：二进制大小优化<br>• 符号表优化：减少启动时符号解析<br>• 静态库合并：减少动态链接开销 |
| **运行时优化** | • ART 预编译：dex2oat 优化<br>• 内存预分配：避免启动时 GC<br>• CPU 亲和性：绑定关键线程到大核 | • 预主线程：提前创建关键对象<br>• 内存映射：mmap 优化资源加载<br>• 启动时 CPU 锁频：保证性能 |
| **网络优化** | • DNS 预解析：提前解析域名<br>• 连接池预热：复用 HTTP 连接<br>• 数据预拉取：智能预加载接口 | • HTTP/2 多路复用：减少连接数<br>• CDN 就近接入：降低网络延迟<br>• 离线包机制：本地资源优先 |

#### 3. 监控与度量体系

| 监控指标 | Android 实现 | iOS 实现 |
|----------|-------------|----------|
| **启动时间** | • 自定义 Application.attachBaseContext()<br>• 首屏 Activity.onResume() 埋点<br>• Systrace 性能分析 | • main() 函数到 applicationDidBecomeActive<br>• 首屏 viewDidAppear 埋点<br>• Instruments Time Profiler 分析 |
| **内存监控** | • Debug.getNativeHeapSize()<br>• ActivityManager.getMemoryInfo()<br>• LeakCanary 内存泄漏检测 | • mach_task_basic_info 获取内存<br>• Xcode Memory Graph 分析<br>• MLeaksFinder 内存泄漏检测 |
| **卡顿监控** | • Choreographer 监听掉帧<br>• ANR 监控与上报<br>• 主线程耗时操作检测 | • CADisplayLink 监听掉帧<br>• Runloop 卡顿监控<br>• 主队列耗时操作检测 |

#### 4. 核心代码实现示例

**Android 启动优化核心代码：**

```java
// 1. Application 分阶段初始化
public class MyApplication extends Application {
    private static final String TAG = "StartupOptimization";
    
    @Override
    public void onCreate() {
        super.onCreate();
        
        // 核心初始化（同步）
        initCoreComponents();
        
        // 非核心初始化（异步）
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            2, 4, 60L, TimeUnit.SECONDS,
            new LinkedBlockingQueue<>(128)
        );
        
        executor.execute(this::initNonCoreComponents);
        executor.execute(this::preloadResources);
    }
    
    private void initCoreComponents() {
        // 只初始化启动必需的组件
        CrashHandler.init(this);
        NetworkManager.init(this);
    }
    
    private void initNonCoreComponents() {
        // 延迟初始化非核心组件
        ImageLoader.init(this);
        AnalyticsManager.init(this);
    }
}

// 2. 启动窗口优化
<!-- res/drawable/launch_screen.xml -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/colorPrimary"/>
    <item>
        <bitmap android:gravity="center" android:src="@drawable/logo"/>
    </item>
</layer-list>

// 3. MultiDex 优化
public class MyMultiDexApplication extends MultiDexApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // 只在主 dex 中包含启动必需的类
        MultiDex.install(this);
    }
}
```

**iOS 启动优化核心代码：**

```swift
// 1. AppDelegate 分阶段初始化
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 核心初始化（同步）
        initCoreComponents()
        
        // 非核心初始化（异步）
        DispatchQueue.global(qos: .utility).async {
            self.initNonCoreComponents()
        }
        
        DispatchQueue.global(qos: .background).async {
            self.preloadResources()
        }
        
        return true
    }
    
    private func initCoreComponents() {
        // 只初始化启动必需的组件
        CrashReporter.setup()
        NetworkManager.shared.configure()
    }
    
    private func initNonCoreComponents() {
        // 延迟初始化非核心组件
        ImageCache.shared.setup()
        AnalyticsManager.shared.configure()
    }
}

// 2. +load 方法优化
@objc class OptimizedClass: NSObject {
    override class func load() {
        // 避免在 +load 中执行耗时操作
        // 只做必要的 method swizzling
        DispatchQueue.once {
            // 延迟到合适时机执行
        }
    }
}

// 3. 预热机制
class PrewarmManager {
    static func prewarmCriticalPaths() {
        // 预热关键代码路径
        DispatchQueue.global(qos: .userInitiated).async {
            // 预创建关键对象
            _ = URLSession.shared
            _ = JSONDecoder()
            
            // 预加载关键资源
            Bundle.main.path(forResource: "config", ofType: "plist")
        }
    }
}
```

#### 5. 性能监控实现

**启动时间精确测量：**

```java
// Android 启动时间监控
public class StartupTimeMonitor {
    private static long sAppStartTime;
    private static long sAppAttachTime;
    
    static {
        sAppStartTime = System.currentTimeMillis();
    }
    
    public static void recordAttachTime() {
        sAppAttachTime = System.currentTimeMillis();
        Log.d("Startup", "App attach time: " + (sAppAttachTime - sAppStartTime) + "ms");
    }
    
    public static void recordFirstScreenTime() {
        long firstScreenTime = System.currentTimeMillis();
        Log.d("Startup", "First screen time: " + (firstScreenTime - sAppStartTime) + "ms");
        
        // 上报到监控系统
        Analytics.track("app_startup_time", firstScreenTime - sAppStartTime);
    }
}
```

```swift
// iOS 启动时间监控
class StartupTimeMonitor {
    private static var appStartTime: CFAbsoluteTime = 0
    
    static func recordAppStartTime() {
        appStartTime = CFAbsoluteTimeGetCurrent()
    }
    
    static func recordFirstScreenTime() {
        let firstScreenTime = CFAbsoluteTimeGetCurrent()
        let startupTime = (firstScreenTime - appStartTime) * 1000 // 转换为毫秒
        
        print("App startup time: \(startupTime)ms")
        
        // 上报到监控系统
        Analytics.track("app_startup_time", value: startupTime)
    }
}
```

---

## 2. 内存管理对比

### 内存管理机制

| 维度 | Android | iOS |
|------|---------|-----|
| **垃圾回收** | GC (Garbage Collection) | ARC (Automatic Reference Counting) |
| **内存分配** | 堆内存自动管理 | 引用计数自动管理 |
| **内存泄漏** | 强引用循环、静态引用 | 强引用循环、闭包捕获 |
| **内存监控** | `LeakCanary` | `Instruments Leaks` |

### 代码示例对比

#### Android 内存管理
```java
// 内存泄漏示例 - Handler 持有 Activity 引用
public class MainActivity extends AppCompatActivity {
    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            // 可能导致内存泄漏
        }
    };
    
    // 正确做法 - 使用静态内部类
    private static class MyHandler extends Handler {
        private WeakReference<MainActivity> mActivity;
        
        public MyHandler(MainActivity activity) {
            mActivity = new WeakReference<>(activity);
        }
        
        @Override
        public void handleMessage(Message msg) {
            MainActivity activity = mActivity.get();
            if (activity != null) {
                // 处理消息
            }
        }
    }
}

// 内存监控
public class MemoryMonitor {
    public static void logMemoryUsage() {
        Runtime runtime = Runtime.getRuntime();
        long usedMemory = runtime.totalMemory() - runtime.freeMemory();
        Log.d("Memory", "Used: " + (usedMemory / 1024 / 1024) + "MB");
    }
}
```

#### iOS 内存管理
```swift
// 内存泄漏示例 - 闭包强引用循环
class ViewController: UIViewController {
    var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 可能导致内存泄漏
        completionHandler = {
            self.updateUI() // 强引用 self
        }
        
        // 正确做法 - 使用 weak 引用
        completionHandler = { [weak self] in
            self?.updateUI()
        }
    }
}

// 内存监控
class MemoryMonitor {
    static func logMemoryUsage() {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = info.resident_size
            print("Used Memory: \(usedMemory / 1024 / 1024)MB")
        }
    }
}
```

### 内存优化策略对比

| 策略 | Android | iOS |
|------|---------|-----|
| **弱引用** | `WeakReference<T>` | `weak var` |
| **对象池** | 自定义 ObjectPool | `NSCache` |
| **图片缓存** | `LruCache` | `NSCache` / `SDWebImage` |

---

## 3. 渲染机制对比

### 渲染架构

| 维度 | Android | iOS |
|------|---------|-----|
| **底层渲染引擎** | Skia | Core Graphics / Metal |
| **动画合成框架** | SurfaceFlinger | Core Animation |
| **UI框架** | View System | UIKit |
| **硬件加速** | GPU 渲染 (Vulkan/OpenGL ES) | Metal / OpenGL ES |
| **刷新率** | 60fps / 90fps / 120fps | 60fps / 120fps (ProMotion) |

### 代码示例对比

#### Android 渲染代码
```java
// 自定义 View 渲染
public class CustomView extends View {
    private Paint mPaint;
    
    public CustomView(Context context) {
        super(context);
        mPaint = new Paint();
        mPaint.setColor(Color.BLUE);
        mPaint.setAntiAlias(true);
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        
        // 绘制圆形
        canvas.drawCircle(getWidth() / 2, getHeight() / 2, 100, mPaint);
        
        // 性能监控
        long startTime = System.nanoTime();
        // 绘制操作
        long endTime = System.nanoTime();
        Log.d("Render", "Draw took: " + (endTime - startTime) / 1000000 + "ms");
    }
}

// 动画实现
ObjectAnimator animator = ObjectAnimator.ofFloat(view, "translationX", 0f, 300f);
animator.setDuration(1000);
animator.start();
```

#### iOS 渲染代码
```swift
// 自定义 View 渲染
class CustomView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 绘制圆形
        context.setFillColor(UIColor.blue.cgColor)
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        context.addArc(center: center, radius: 100, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
        
        // 性能监控
        let startTime = CFAbsoluteTimeGetCurrent()
        // 绘制操作
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Draw took: \((endTime - startTime) * 1000)ms")
    }
}

// 动画实现
UIView.animate(withDuration: 1.0) {
    view.transform = CGAffineTransform(translationX: 300, y: 0)
}
```

### 渲染优化对比

| 优化策略 | Android | iOS |
|----------|---------|-----|
| **布局优化** | `ConstraintLayout` | `Auto Layout` |
| **过度绘制** | GPU 过度绘制检测 | Core Animation Instruments |
| **异步渲染** | `TextureView` | `CALayer` 异步绘制 |
| **缓存机制** | `View.setLayerType()` | `CALayer.shouldRasterize` |

---

## 4. 性能监控工具对比

### 开发工具

| 功能 | Android | iOS |
|------|---------|-----|
| **启动分析** | `adb shell am start -W` | Instruments Time Profiler |
| **内存分析** | Android Studio Memory Profiler | Instruments Allocations |
| **渲染分析** | GPU 渲染模式分析 | Core Animation Instruments |
| **网络分析** | Network Profiler | Network Instruments |

### 代码监控示例

#### Android 性能监控
```java
public class PerformanceMonitor {
    // 启动时间监控
    public static void trackStartupTime(String tag) {
        long startTime = System.currentTimeMillis();
        // 执行操作
        long duration = System.currentTimeMillis() - startTime;
        Log.d("Performance", tag + " took: " + duration + "ms");
    }
    
    // FPS 监控
    public static void startFPSMonitor() {
        Choreographer.getInstance().postFrameCallback(new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                // FPS 计算逻辑
                Choreographer.getInstance().postFrameCallback(this);
            }
        });
    }
}
```

#### iOS 性能监控
```swift
class PerformanceMonitor {
    // 启动时间监控
    static func trackStartupTime<T>(tag: String, operation: () -> T) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("\(tag) took: \(duration)ms")
        return result
    }
    
    // FPS 监控
    static func startFPSMonitor() {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc static func displayLinkTick(displayLink: CADisplayLink) {
        // FPS 计算逻辑
    }
}
```

---

## 5. 总结

### 关键差异点

1. **启动机制**：Android 基于 Activity 生命周期，iOS 基于 AppDelegate 回调
2. **内存管理**：Android 使用 GC，iOS 使用 ARC
3. **渲染技术栈**：Android 使用 Skia(底层渲染) + SurfaceFlinger(合成)，iOS 使用 Core Graphics/Metal(底层渲染) + Core Animation(合成)
4. **开发语言**：Android 主要使用 Java/Kotlin，iOS 使用 Swift/Objective-C

### 学习建议

- 通过对比学习，快速理解两个平台的设计理念差异
- 重点关注性能优化的不同策略和工具
- 实践中验证理论知识，建立深度理解
- 利用已有的 Android 经验，类比学习 iOS 开发模式