# Android传统开发 vs Android Compose vs HarmonyOS ArkUI 对照表

## 1. 组件架构对比

| 维度 | Android传统开发 | Android Compose | HarmonyOS ArkUI |
|------|----------------|----------------|----------------|
| **UI组件模型** | View/ViewGroup 树形结构 | @Composable 函数式组件树 | ArkUI 声明式组件树 |
| **组件定义方式** | XML布局 + Java/Kotlin代码 | Kotlin @Composable 函数 | ArkTS 声明式语法 |
| **组件渲染引擎** | Skia + SurfaceFlinger | Skia + Compose Runtime | ArkUI 渲染引擎 |
| **组件状态管理** | 手动状态管理 + ViewModel | remember/mutableStateOf | @State/@Prop 响应式状态 |
| **组件通信** | Intent/Callback/EventBus | 参数传递/回调函数 | @Link/@Provide/@Consume |
| **自定义组件** | 继承View/ViewGroup | @Composable 函数 | @Component 装饰器 |

#### 组件通信代码示例：

**Android传统开发 - EventBus通信：**
```kotlin
// 发送事件
EventBus.getDefault().post(MessageEvent("Hello World"))

// 接收事件
@Subscribe(threadMode = ThreadMode.MAIN)
fun onMessageEvent(event: MessageEvent) {
    textView.text = event.message
}
```

**Android Compose - 参数传递：**
```kotlin
@Composable
fun ParentComponent() {
    var message by remember { mutableStateOf("Hello") }
    
    ChildComponent(
        message = message,
        onMessageChange = { message = it }
    )
}

@Composable
fun ChildComponent(
    message: String,
    onMessageChange: (String) -> Unit
) {
    Button(onClick = { onMessageChange("Updated!") }) {
        Text(message)
    }
}
```

**HarmonyOS ArkUI - @Link装饰器：**
```typescript
@Component
struct ParentComponent {
  @State message: string = 'Hello'
  
  build() {
    Column() {
      ChildComponent({ message: $message })
    }
  }
}

@Component
struct ChildComponent {
  @Link message: string
  
  build() {
    Button('Click Me')
      .onClick(() => {
        this.message = 'Updated!'
      })
  }
}
```

#### 自定义组件代码示例：

**Android传统开发 - 继承View：**
```kotlin
class CustomButton : View {
    private var text = "Custom Button"
    private val paint = Paint()
    
    constructor(context: Context) : super(context) {
        init()
    }
    
    private fun init() {
        paint.textSize = 48f
        paint.color = Color.BLUE
        setOnClickListener {
            text = "Clicked!"
            invalidate() // 手动触发重绘
        }
    }
    
    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        canvas?.drawText(text, 50f, 100f, paint)
    }
}
```

**Android Compose - @Composable函数：**
```kotlin
@Composable
fun CustomButton(
    text: String = "Custom Button",
    onClick: () -> Unit = {}
) {
    Button(
        onClick = onClick,
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.Blue
        )
    ) {
        Text(
            text = text,
            fontSize = 18.sp,
            color = Color.White
        )
    }
}

// 使用
@Composable
fun MyScreen() {
    var buttonText by remember { mutableStateOf("Custom Button") }
    
    CustomButton(
        text = buttonText,
        onClick = { buttonText = "Clicked!" }
    )
}
```

**HarmonyOS ArkUI - @Component装饰器：**
```typescript
@Component
struct CustomButton {
  @Prop text: string = 'Custom Button'
  @Prop onClickCallback: () => void = () => {}
  
  build() {
    Button(this.text)
      .backgroundColor(Color.Blue)
      .fontColor(Color.White)
      .fontSize(18)
      .onClick(() => {
        this.onClickCallback()
      })
  }
}

// 使用
@Component
struct MyPage {
  @State buttonText: string = 'Custom Button'
  
  build() {
    Column() {
      CustomButton({
        text: this.buttonText,
        onClickCallback: () => {
          this.buttonText = 'Clicked!'
        }
      })
    }
  }
}
```

## 2. 应用组件对比

| 组件类型 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 说明 |
|----------|----------------|----------------|-----------------|------|
| **页面组件** | Activity | @Composable + NavHost | @Entry + @Component | 承载UI界面的基本单元 |
| **片段组件** | Fragment | - | - | Android独有，现代开发中被替代 |
| **可组合组件** | Custom View/ViewGroup | @Composable 函数 | @Component 装饰器 | 可复用的UI组件 |
| **状态组件** | ViewModel + LiveData | remember/rememberSaveable | @State/@Prop | 状态管理组件 |
| **导航组件** | Intent + startActivity | Navigation Compose | Router | 页面导航管理 |

**导航组件代码示例：**

*Android传统开发：*
```java
// 页面跳转
Intent intent = new Intent(this, SecondActivity.class);
intent.putExtra("data", "Hello");
startActivity(intent);

// 带返回结果的跳转
startActivityForResult(intent, REQUEST_CODE);
```

*Android Compose：*
```kotlin
// 导航设置
val navController = rememberNavController()
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen(navController) }
    composable("detail/{id}") { backStackEntry ->
        DetailScreen(backStackEntry.arguments?.getString("id"))
    }
}

// 页面跳转
navController.navigate("detail/123")
```

*HarmonyOS ArkUI：*
```typescript
// 页面跳转
import router from '@ohos.router'

// 跳转到指定页面
router.pushUrl({
  url: 'pages/Detail',
  params: { data: 'Hello' }
})

// 带回调的跳转
router.pushUrl({
  url: 'pages/Detail'
}, router.RouterMode.Standard, (err) => {
  if (err) console.error('跳转失败')
})
```

| **布局组件** | LinearLayout/RelativeLayout | Column/Row/Box/LazyColumn | Column/Row/Stack/List | 布局容器组件 |

**布局组件代码示例：**

*Android传统开发：*
```xml
<!-- LinearLayout 线性布局 -->
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical">
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="标题" />
    
    <Button
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="按钮" />
</LinearLayout>
```

*Android Compose：*
```kotlin
// Column 垂直布局
Column(
    modifier = Modifier.fillMaxWidth(),
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    Text("标题")
    Button(
        onClick = { /* 点击事件 */ },
        modifier = Modifier.fillMaxWidth()
    ) {
        Text("按钮")
    }
}

// LazyColumn 列表布局
LazyColumn {
    items(dataList) { item ->
        ListItem(item)
    }
}
```

*HarmonyOS ArkUI：*
```typescript
// Column 垂直布局
Column({ space: 8 }) {
  Text('标题')
    .fontSize(16)
    .fontWeight(FontWeight.Bold)
  
  Button('按钮')
    .width('100%')
    .onClick(() => {
      // 点击事件
    })
}
.width('100%')
.padding(16)

// List 列表布局
List({ space: 8 }) {
  ForEach(this.dataList, (item) => {
    ListItem() {
      Text(item.title)
    }
  })
}
```

## 3. 生命周期对比

### 3.1 页面级生命周期对比

| 阶段 | Android传统开发 | Android Compose | HarmonyOS ArkUI |
|------|----------------|----------------|----------------|
| **创建** | onCreate() | Composition | aboutToAppear() |
| **启动** | onStart() | - | - |
| **恢复** | onResume() | LaunchedEffect | onPageShow() |
| **暂停** | onPause() | - | onPageHide() |
| **停止** | onStop() | - | - |
| **销毁** | onDestroy() | onDispose | aboutToDisappear() |
| **重建** | 配置变化重建 | Recomposition | build()重建 |

#### 页面生命周期代码示例

*Android传统开发：*
```java
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Log.d("Lifecycle", "onCreate - 页面创建");
    }
    
    @Override
    protected void onStart() {
        super.onStart();
        Log.d("Lifecycle", "onStart - 页面启动");
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        Log.d("Lifecycle", "onResume - 页面恢复");
    }
    
    @Override
    protected void onPause() {
        super.onPause();
        Log.d("Lifecycle", "onPause - 页面暂停");
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d("Lifecycle", "onDestroy - 页面销毁");
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun MainScreen() {
    // Composition阶段 - 组合函数被调用
    LaunchedEffect(Unit) {
        Log.d("Lifecycle", "LaunchedEffect - 页面恢复时执行")
    }
    
    DisposableEffect(Unit) {
        Log.d("Lifecycle", "DisposableEffect - 进入组合")
        
        onDispose {
            Log.d("Lifecycle", "onDispose - 离开组合")
        }
    }
    
    Column {
        Text("主页面内容")
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct MainPage {
  aboutToAppear() {
    console.log('Lifecycle', 'aboutToAppear - 页面即将出现')
  }
  
  onPageShow() {
    console.log('Lifecycle', 'onPageShow - 页面显示')
  }
  
  onPageHide() {
    console.log('Lifecycle', 'onPageHide - 页面隐藏')
  }
  
  aboutToDisappear() {
    console.log('Lifecycle', 'aboutToDisappear - 页面即将销毁')
  }
  
  build() {
    Column({ space: 16 }) {
      Text('主页面内容')
        .fontSize(18)
    }
    .padding(16)
  }
}
```

### 3.2 组件级生命周期对比

| 阶段 | Android传统开发 | Android Compose | HarmonyOS ArkUI |
|------|----------------|----------------|----------------|
| **创建** | View构造函数 | @Composable调用 | @Component创建 |
| **测量** | onMeasure() | - | - |
| **布局** | onLayout() | Layout阶段 | build()方法 |
| **绘制** | onDraw() | Draw阶段 | 自动渲染 |
| **更新** | invalidate() | Recomposition | 状态变化自动更新 |
| **销毁** | - | 离开组合树 | aboutToDisappear() |

#### 组件生命周期代码示例

*Android传统开发：*
```java
public class CustomView extends View {
    public CustomView(Context context) {
        super(context);
        Log.d("Component", "构造函数 - 组件创建");
    }
    
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        Log.d("Component", "onMeasure - 组件测量");
    }
    
    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        Log.d("Component", "onLayout - 组件布局");
    }
    
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        Log.d("Component", "onDraw - 组件绘制");
    }
    
    public void updateContent() {
        invalidate(); // 触发重绘
        Log.d("Component", "invalidate - 组件更新");
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun CustomComponent(text: String) {
    // @Composable调用 - 组件创建
    Log.d("Component", "Composable调用 - 组件创建")
    
    // 状态变化时会触发Recomposition
    var count by remember { mutableStateOf(0) }
    
    LaunchedEffect(count) {
        Log.d("Component", "Recomposition - 组件重组")
    }
    
    DisposableEffect(Unit) {
        onDispose {
            Log.d("Component", "离开组合树 - 组件销毁")
        }
    }
    
    Column {
        Text(text = text)
        Button(
            onClick = { count++ }
        ) {
            Text("点击次数: $count")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Component
struct CustomComponent {
  @State count: number = 0
  private text: string = ''
  
  aboutToAppear() {
    console.log('Component', 'aboutToAppear - 组件即将出现')
  }
  
  aboutToDisappear() {
    console.log('Component', 'aboutToDisappear - 组件即将销毁')
  }
  
  build() {
    // build()方法 - 组件布局和渲染
    console.log('Component', 'build - 组件构建')
    
    Column({ space: 12 }) {
      Text(this.text)
        .fontSize(16)
      
      Button(`点击次数: ${this.count}`)
        .onClick(() => {
          this.count++
          // 状态变化自动触发UI更新
          console.log('Component', '状态变化自动更新')
        })
    }
  }
}
```

## 4. 状态管理对比

| 状态类型 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 使用场景 |
|----------|----------------|----------------|-----------------|----------|
| **局部状态** | 成员变量 + setter/getter | remember + mutableStateOf | @State | 组件内部状态 |
| **共享状态** | ViewModel + LiveData | ViewModel + collectAsState | @Provide/@Consume | 跨组件状态共享 |
| **持久化状态** | SharedPreferences | rememberSaveable | PersistentStorage | 数据持久化 |
| **全局状态** | Application + 单例 | Hilt + ViewModel | AppStorage | 应用级状态管理 |
| **双向绑定** | DataBinding(已废弃) | 回调函数 + State | @Link | 父子组件状态同步 |
| **状态观察** | Observer模式 | collectAsState | @Watch | 状态变化监听 |
| **副作用管理** | 手动管理 | LaunchedEffect/SideEffect | - | 处理副作用操作 |
| **UI更新** | 手动调用更新方法 | 自动重组 | 响应式更新 | UI状态同步 |

#### 状态管理代码示例

**1. 局部状态管理**

*Android传统开发：*
```java
public class CounterActivity extends AppCompatActivity {
    private TextView counterText;
    private Button incrementButton;
    private int counter = 0; // 成员变量存储状态
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_counter);
        
        counterText = findViewById(R.id.counterText);
        incrementButton = findViewById(R.id.incrementButton);
        
        updateUI(); // 手动更新UI
        
        incrementButton.setOnClickListener(v -> {
            counter++; // 修改状态
            updateUI(); // 手动更新UI
        });
    }
    
    private void updateUI() {
        counterText.setText("计数: " + counter);
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun CounterScreen() {
    // remember + mutableStateOf 管理局部状态
    var counter by remember { mutableStateOf(0) }
    
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "计数: $counter",
            fontSize = 24.sp
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Button(
            onClick = { counter++ } // 状态变化自动触发重组
        ) {
            Text("增加")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct CounterPage {
  @State counter: number = 0 // @State装饰器管理局部状态
  
  build() {
    Column({ space: 16 }) {
      Text(`计数: ${this.counter}`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Button('增加')
        .onClick(() => {
          this.counter++ // 状态变化自动更新UI
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

**2. 共享状态管理**

*Android传统开发：*
```java
// ViewModel
public class SharedViewModel extends ViewModel {
    private MutableLiveData<String> message = new MutableLiveData<>("Hello");
    
    public LiveData<String> getMessage() {
        return message;
    }
    
    public void updateMessage(String newMessage) {
        message.setValue(newMessage);
    }
}

// Activity
public class MainActivity extends AppCompatActivity {
    private SharedViewModel viewModel;
    private TextView messageText;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        viewModel = new ViewModelProvider(this).get(SharedViewModel.class);
        messageText = findViewById(R.id.messageText);
        
        // 观察状态变化
        viewModel.getMessage().observe(this, message -> {
            messageText.setText(message);
        });
    }
}
```

*Android Compose：*
```kotlin
// ViewModel
class SharedViewModel : ViewModel() {
    private val _message = mutableStateOf("Hello")
    val message: State<String> = _message
    
    fun updateMessage(newMessage: String) {
        _message.value = newMessage
    }
}

// Composable
@Composable
fun SharedStateScreen(viewModel: SharedViewModel = hiltViewModel()) {
    val message by viewModel.message // collectAsState自动观察
    
    Column {
        Text(text = message)
        
        Button(
            onClick = { viewModel.updateMessage("Updated!") }
        ) {
            Text("更新消息")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
// 共享状态类
class SharedState {
  @Provide message: string = 'Hello'
  
  updateMessage(newMessage: string) {
    this.message = newMessage
  }
}

// 父组件
@Entry
@Component
struct ParentPage {
  @Provide sharedState: SharedState = new SharedState()
  
  build() {
    Column() {
      ChildComponent()
      AnotherChildComponent()
    }
  }
}

// 子组件
@Component
struct ChildComponent {
  @Consume sharedState: SharedState
  
  build() {
    Column() {
      Text(this.sharedState.message)
      
      Button('更新消息')
        .onClick(() => {
          this.sharedState.updateMessage('Updated!')
        })
    }
  }
}
```

## 5. 导航与路由对比

| 功能 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 说明 |
|------|----------------|----------------|-----------------|------|
| **导航容器** | Activity Task Stack | NavHost | Router | 导航管理容器 |
| **页面跳转** | Intent + startActivity() | navController.navigate() | router.pushUrl() | 基本页面导航 |
| **参数传递** | Intent.putExtra() | NavArguments | router.pushUrl(params) | 页面间数据传递 |
| **返回处理** | finish() + onBackPressed() | popBackStack() | router.back() | 页面返回管理 |
| **路由定义** | AndroidManifest.xml | NavGraph | 路由表配置 | 路由结构定义 |
| **深度链接** | Intent Filter | DeepLink | 路由表配置 | 外部链接处理 |
| **导航动画** | Activity Transition | AnimatedNavHost | 页面转场动画 | 页面切换效果 |
| **嵌套导航** | Fragment嵌套 | Nested NavGraph | - | 复杂导航结构 |
| **结果返回** | startActivityForResult() | - | router.back()携带数据 | 页面间结果传递 |

#### 导航与路由代码示例

**1. 基本页面跳转**

*Android传统开发：*
```java
// 主页面Activity
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        Button navigateButton = findViewById(R.id.navigateButton);
        navigateButton.setOnClickListener(v -> {
            // Intent页面跳转
            Intent intent = new Intent(this, DetailActivity.class);
            intent.putExtra("userId", 123); // 参数传递
            intent.putExtra("userName", "张三");
            startActivity(intent);
        });
    }
}

// 详情页面Activity
public class DetailActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail);
        
        // 获取传递的参数
        Intent intent = getIntent();
        int userId = intent.getIntExtra("userId", 0);
        String userName = intent.getStringExtra("userName");
        
        TextView userInfo = findViewById(R.id.userInfo);
        userInfo.setText("用户ID: " + userId + ", 姓名: " + userName);
        
        Button backButton = findViewById(R.id.backButton);
        backButton.setOnClickListener(v -> finish()); // 返回上一页
    }
}
```

*Android Compose：*
```kotlin
// 导航设置
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(
        navController = navController,
        startDestination = "main"
    ) {
        composable("main") {
            MainScreen(navController)
        }
        composable(
            "detail/{userId}/{userName}",
            arguments = listOf(
                navArgument("userId") { type = NavType.IntType },
                navArgument("userName") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getInt("userId") ?: 0
            val userName = backStackEntry.arguments?.getString("userName") ?: ""
            DetailScreen(navController, userId, userName)
        }
    }
}

@Composable
fun MainScreen(navController: NavController) {
    Column {
        Button(
            onClick = {
                // 导航到详情页面并传递参数
                navController.navigate("detail/123/张三")
            }
        ) {
            Text("跳转到详情页")
        }
    }
}

@Composable
fun DetailScreen(navController: NavController, userId: Int, userName: String) {
    Column {
        Text("用户ID: $userId, 姓名: $userName")
        
        Button(
            onClick = { navController.popBackStack() } // 返回上一页
        ) {
            Text("返回")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
// 主页面
@Entry
@Component
struct MainPage {
  build() {
    Column({ space: 16 }) {
      Text('主页面')
        .fontSize(24)
      
      Button('跳转到详情页')
        .onClick(() => {
          // 页面跳转并传递参数
          router.pushUrl({
            url: 'pages/DetailPage',
            params: {
              userId: 123,
              userName: '张三'
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// 详情页面
@Entry
@Component
struct DetailPage {
  @State userId: number = 0
  @State userName: string = ''
  
  aboutToAppear() {
    // 获取传递的参数
    const params = router.getParams() as Record<string, Object>
    this.userId = params['userId'] as number
    this.userName = params['userName'] as string
  }
  
  build() {
    Column({ space: 16 }) {
      Text(`用户ID: ${this.userId}, 姓名: ${this.userName}`)
        .fontSize(18)
      
      Button('返回')
        .onClick(() => {
          router.back() // 返回上一页
        })
      
      Button('返回并传递数据')
        .onClick(() => {
          router.back({
            url: 'pages/MainPage',
            params: {
              result: '处理完成'
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
```

**2. 路由配置**

*Android传统开发 (AndroidManifest.xml)：*
```xml
<application>
    <activity
        android:name=".MainActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
        <!-- 深度链接配置 -->
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="myapp" android:host="main" />
        </intent-filter>
    </activity>
    
    <activity
        android:name=".DetailActivity"
        android:parentActivityName=".MainActivity" />
</application>
```

*Android Compose (NavGraph)：*
```kotlin
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(
        navController = navController,
        startDestination = "main"
    ) {
        composable("main") { MainScreen(navController) }
        
        composable(
            "detail/{id}",
            deepLinks = listOf(
                navDeepLink { uriPattern = "myapp://detail/{id}" }
            )
        ) { DetailScreen(navController) }
        
        // 嵌套导航
        navigation(
            startDestination = "profile_main",
            route = "profile"
        ) {
            composable("profile_main") { ProfileMainScreen() }
            composable("profile_edit") { ProfileEditScreen() }
        }
    }
}
```

*HarmonyOS ArkUI (路由表配置)：*
```json
{
  "src": [
    "pages/MainPage",
    "pages/DetailPage",
    "pages/ProfilePage"
  ],
  "launchType": "standard"
}
```

## 6. 事件处理对比

| 事件类型 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 实现方式 |
|----------|----------------|----------------|-----------------|----------|
| **点击事件** | OnClickListener | Modifier.clickable | onClick | 基础交互事件 |
| **触摸事件** | OnTouchListener | Modifier.pointerInput | onTouch | 触摸手势处理 |
| **长按事件** | OnLongClickListener | Modifier.combinedClickable | onLongPress | 长按交互 |
| **滑动事件** | OnScrollListener | Modifier.draggable | PanGesture | 手势识别 |
| **键盘事件** | OnKeyListener | onKeyEvent | onKeyEvent | 键盘输入处理 |
| **焦点事件** | OnFocusChangeListener | Modifier.focusable | onFocus/onBlur | 焦点状态管理 |
| **手势组合** | GestureDetector | detectGestures | 手势识别器 | 复杂手势处理 |
| **生命周期事件** | Activity回调方法 | LaunchedEffect | 页面生命周期回调 | 生命周期处理 |

#### 事件处理代码示例

**1. 点击事件**

*Android传统开发：*
```java
public class EventActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event);
        
        Button clickButton = findViewById(R.id.clickButton);
        TextView resultText = findViewById(R.id.resultText);
        
        // 设置点击监听器
        clickButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resultText.setText("按钮被点击了！");
            }
        });
        
        // Lambda表达式简化写法
        clickButton.setOnClickListener(v -> {
            resultText.setText("使用Lambda表达式处理点击");
        });
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun EventHandlingScreen() {
    var clickCount by remember { mutableStateOf(0) }
    var message by remember { mutableStateOf("等待点击") }
    
    Column(
        modifier = Modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(text = message)
        
        Button(
            onClick = {
                clickCount++
                message = "点击次数: $clickCount"
            },
            modifier = Modifier.clickable {
                // 可以添加额外的点击处理逻辑
            }
        ) {
            Text("点击我")
        }
        
        // 自定义可点击组件
        Box(
            modifier = Modifier
                .size(100.dp)
                .background(Color.Blue)
                .clickable {
                    message = "蓝色方块被点击"
                },
            contentAlignment = Alignment.Center
        ) {
            Text("点击区域", color = Color.White)
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct EventHandlingPage {
  @State clickCount: number = 0
  @State message: string = '等待点击'
  
  build() {
    Column({ space: 16 }) {
      Text(this.message)
        .fontSize(18)
      
      Button('点击我')
        .onClick(() => {
          this.clickCount++
          this.message = `点击次数: ${this.clickCount}`
        })
      
      // 自定义可点击组件
      Row()
        .width(100)
        .height(100)
        .backgroundColor(Color.Blue)
        .onClick(() => {
          this.message = '蓝色方块被点击'
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(16)
  }
}
```

**2. 触摸和手势事件**

*Android传统开发：*
```java
public class TouchEventActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_touch);
        
        View touchView = findViewById(R.id.touchView);
        TextView statusText = findViewById(R.id.statusText);
        
        // 触摸事件监听
        touchView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        statusText.setText("触摸开始: (" + event.getX() + ", " + event.getY() + ")");
                        break;
                    case MotionEvent.ACTION_MOVE:
                        statusText.setText("触摸移动: (" + event.getX() + ", " + event.getY() + ")");
                        break;
                    case MotionEvent.ACTION_UP:
                        statusText.setText("触摸结束");
                        break;
                }
                return true;
            }
        });
        
        // 长按事件
        touchView.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                statusText.setText("长按事件触发");
                return true;
            }
        });
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun TouchEventScreen() {
    var touchInfo by remember { mutableStateOf("等待触摸") }
    
    Column(
        modifier = Modifier.padding(16.dp)
    ) {
        Text(text = touchInfo)
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Box(
            modifier = Modifier
                .size(200.dp)
                .background(Color.LightGray)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onTap = { offset ->
                            touchInfo = "点击位置: (${offset.x.toInt()}, ${offset.y.toInt()})"
                        },
                        onLongPress = { offset ->
                            touchInfo = "长按位置: (${offset.x.toInt()}, ${offset.y.toInt()})"
                        }
                    )
                }
                .pointerInput(Unit) {
                    detectDragGestures(
                        onDragStart = { offset ->
                            touchInfo = "拖拽开始: (${offset.x.toInt()}, ${offset.y.toInt()})"
                        },
                        onDrag = { change, _ ->
                            touchInfo = "拖拽中: (${change.position.x.toInt()}, ${change.position.y.toInt()})"
                        },
                        onDragEnd = {
                            touchInfo = "拖拽结束"
                        }
                    )
                },
            contentAlignment = Alignment.Center
        ) {
            Text("触摸区域")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct TouchEventPage {
  @State touchInfo: string = '等待触摸'
  
  build() {
    Column({ space: 16 }) {
      Text(this.touchInfo)
        .fontSize(16)
      
      Row()
        .width(200)
        .height(200)
        .backgroundColor(Color.Gray)
        .onClick(() => {
          this.touchInfo = '点击事件触发'
        })
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            case TouchType.Down:
              this.touchInfo = `触摸开始: (${event.touches[0].x.toFixed(0)}, ${event.touches[0].y.toFixed(0)})`
              break
            case TouchType.Move:
              this.touchInfo = `触摸移动: (${event.touches[0].x.toFixed(0)}, ${event.touches[0].y.toFixed(0)})`
              break
            case TouchType.Up:
              this.touchInfo = '触摸结束'
              break
          }
          return true
        })
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction(() => {
              this.touchInfo = '长按事件触发'
            })
        )
        .gesture(
          PanGesture()
            .onActionStart(() => {
              this.touchInfo = '拖拽开始'
            })
            .onActionUpdate((event: GestureEvent) => {
              this.touchInfo = `拖拽中: (${event.offsetX.toFixed(0)}, ${event.offsetY.toFixed(0)})`
            })
            .onActionEnd(() => {
              this.touchInfo = '拖拽结束'
            })
        )
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(16)
  }
}
```

## 7. 布局系统对比

| 布局类型 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 特点 |
|----------|----------------|----------------|-----------------|------|
| **线性布局** | LinearLayout | Column/Row | Column/Row | 垂直/水平排列 |
| **层叠布局** | FrameLayout | Box | Stack | 层叠布局 |
| **网格布局** | GridLayout | LazyVerticalGrid | Grid | 网格排列 |
| **相对布局** | RelativeLayout | - | RelativeContainer | 相对位置布局 |
| **约束布局** | ConstraintLayout | ConstraintLayout | - | 复杂约束关系 |
| **滚动布局** | ScrollView/RecyclerView | LazyColumn/LazyRow | List/Scroll | 可滚动内容 |
| **分页布局** | ViewPager | HorizontalPager | Swiper | 分页滑动 |
| **流式布局** | FlexboxLayout | FlowLayout | Flex | 自动换行布局 |
| **表格布局** | TableLayout | - | - | 表格形式布局 |

#### 布局系统代码示例

**1. 线性布局 (垂直/水平排列)**

*Android传统开发：*
```xml
<!-- 垂直线性布局 -->
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="标题"
        android:textSize="24sp" />
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="副标题"
        android:textSize="16sp"
        android:layout_marginTop="8dp" />
    
    <!-- 水平线性布局 -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="16dp">
        
        <Button
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="取消"
            android:layout_marginEnd="8dp" />
        
        <Button
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="确定" />
    </LinearLayout>
</LinearLayout>
```

*Android Compose：*
```kotlin
@Composable
fun LinearLayoutScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "标题",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        
        Text(
            text = "副标题",
            fontSize = 16.sp,
            color = Color.Gray
        )
        
        Spacer(modifier = Modifier.height(8.dp))
        
        // 水平排列
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = { },
                modifier = Modifier.weight(1f)
            ) {
                Text("取消")
            }
            
            Button(
                onClick = { },
                modifier = Modifier.weight(1f)
            ) {
                Text("确定")
            }
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct LinearLayoutPage {
  build() {
    Column({ space: 8 }) {
      Text('标题')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Text('副标题')
        .fontSize(16)
        .fontColor(Color.Gray)
      
      // 水平排列
      Row({ space: 8 }) {
        Button('取消')
          .layoutWeight(1)
        
        Button('确定')
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }
}
```

**2. 层叠布局**

*Android传统开发：*
```xml
<FrameLayout
    android:layout_width="match_parent"
    android:layout_height="200dp">
    
    <ImageView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/background"
        android:scaleType="centerCrop" />
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:text="覆盖文字"
        android:textColor="@android:color/white"
        android:textSize="18sp"
        android:background="#80000000"
        android:padding="8dp" />
    
    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|end"
        android:layout_margin="16dp"
        android:text="操作" />
</FrameLayout>
```

*Android Compose：*
```kotlin
@Composable
fun StackLayoutScreen() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
    ) {
        // 背景图片
        Image(
            painter = painterResource(id = R.drawable.background),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        
        // 中心文字
        Text(
            text = "覆盖文字",
            color = Color.White,
            fontSize = 18.sp,
            modifier = Modifier
                .align(Alignment.Center)
                .background(
                    Color.Black.copy(alpha = 0.5f),
                    RoundedCornerShape(4.dp)
                )
                .padding(8.dp)
        )
        
        // 右下角按钮
        Button(
            onClick = { },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp)
        ) {
            Text("操作")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct StackLayoutPage {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图片
      Image($r('app.media.background'))
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
      
      // 中心文字
      Text('覆盖文字')
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor(Color.Black)
        .opacity(0.8)
        .padding(8)
        .borderRadius(4)
      
      // 右下角按钮
      Button('操作')
        .margin({ bottom: 16, right: 16 })
    }
    .alignContent(Alignment.BottomEnd)
    .width('100%')
    .height(200)
  }
}
```

**3. 网格布局**

*Android传统开发：*
```xml
<GridLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:columnCount="2"
    android:rowCount="2"
    android:padding="16dp">
    
    <TextView
        android:layout_width="0dp"
        android:layout_height="100dp"
        android:layout_columnWeight="1"
        android:layout_margin="4dp"
        android:background="#FF5722"
        android:gravity="center"
        android:text="项目 1"
        android:textColor="@android:color/white" />
    
    <TextView
        android:layout_width="0dp"
        android:layout_height="100dp"
        android:layout_columnWeight="1"
        android:layout_margin="4dp"
        android:background="#2196F3"
        android:gravity="center"
        android:text="项目 2"
        android:textColor="@android:color/white" />
    
    <TextView
        android:layout_width="0dp"
        android:layout_height="100dp"
        android:layout_columnWeight="1"
        android:layout_margin="4dp"
        android:background="#4CAF50"
        android:gravity="center"
        android:text="项目 3"
        android:textColor="@android:color/white" />
    
    <TextView
        android:layout_width="0dp"
        android:layout_height="100dp"
        android:layout_columnWeight="1"
        android:layout_margin="4dp"
        android:background="#FF9800"
        android:gravity="center"
        android:text="项目 4"
        android:textColor="@android:color/white" />
</GridLayout>
```

*Android Compose：*
```kotlin
@Composable
fun GridLayoutScreen() {
    val items = listOf(
        "项目 1" to Color(0xFFFF5722),
        "项目 2" to Color(0xFF2196F3),
        "项目 3" to Color(0xFF4CAF50),
        "项目 4" to Color(0xFFFF9800)
    )
    
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(items) { (text, color) ->
            Box(
                modifier = Modifier
                    .height(100.dp)
                    .background(color, RoundedCornerShape(8.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = text,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct GridLayoutPage {
  private items: Array<{text: string, color: Color}> = [
    { text: '项目 1', color: Color.Red },
    { text: '项目 2', color: Color.Blue },
    { text: '项目 3', color: Color.Green },
    { text: '项目 4', color: Color.Orange }
  ]
  
  build() {
    Grid() {
      ForEach(this.items, (item: {text: string, color: Color}) => {
        GridItem() {
          Text(item.text)
            .width('100%')
            .height(100)
            .backgroundColor(item.color)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .borderRadius(8)
        }
        .margin(4)
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('100vp 100vp')
    .columnsGap(8)
    .rowsGap(8)
    .padding(16)
    .width('100%')
    .height('100%')
  }
}
```

## 8. 数据绑定对比

| 绑定方式 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 说明 |
|----------|----------------|----------------|-----------------|------|
| **单向绑定** | 手动设置UI | State读取 | @State/@Prop | 数据到视图 |
| **双向绑定** | DataBinding(已废弃) | 回调函数 + State | @Link | 视图与数据同步 |
| **列表绑定** | Adapter模式 | LazyColumn + items() | LazyForEach | 动态列表数据 |
| **条件渲染** | View.setVisibility() | if/when 表达式 | if/else 语句 | 条件显示组件 |
| **循环渲染** | 手动创建View | forEach/items | ForEach | 批量创建组件 |
| **数据观察** | Observer模式 | collectAsState | @Watch | 数据变化监听 |
| **计算属性** | 手动计算 | derivedStateOf | @Computed | 派生状态计算 |
| **动态更新** | 手动调用更新方法 | 状态变化自动重组 | 状态变化自动更新 | 响应式更新机制 |
| **事件绑定** | setOnClickListener() | onClick参数 | onClick属性 | 事件处理绑定 |

### 数据绑定代码示例

#### 1. 单向绑定

*Android传统开发：*
```java
public class MainActivity extends AppCompatActivity {
    private TextView textView;
    private String userName = "张三";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        textView = findViewById(R.id.textView);
        // 手动设置UI
        textView.setText(userName);
    }
    
    private void updateUserName(String newName) {
        userName = newName;
        // 手动更新UI
        textView.setText(userName);
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun UserProfile() {
    var userName by remember { mutableStateOf("张三") }
    
    Column {
        // State读取，自动绑定
        Text(text = userName)
        
        Button(
            onClick = { userName = "李四" }
        ) {
            Text("更新姓名")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct UserProfile {
  @State userName: string = '张三'
  
  build() {
    Column({ space: 16 }) {
      // @State自动绑定
      Text(this.userName)
        .fontSize(18)
      
      Button('更新姓名')
        .onClick(() => {
          this.userName = '李四'
        })
    }
    .padding(16)
  }
}
```

#### 2. 双向绑定

*Android传统开发：*
```java
// 使用TextWatcher实现双向绑定
public class EditActivity extends AppCompatActivity {
    private EditText editText;
    private String inputText = "";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit);
        
        editText = findViewById(R.id.editText);
        editText.setText(inputText);
        
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void afterTextChanged(Editable s) {
                inputText = s.toString();
            }
            // ... 其他方法
        });
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun EditForm() {
    var inputText by remember { mutableStateOf("") }
    
    Column {
        // 双向绑定：回调函数 + State
        TextField(
            value = inputText,
            onValueChange = { inputText = it },
            label = { Text("输入内容") }
        )
        
        Text("当前输入：$inputText")
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct EditForm {
  @State inputText: string = ''
  
  build() {
    Column({ space: 16 }) {
      // @Link实现双向绑定
      TextInput({ placeholder: '输入内容' })
        .onChange((value: string) => {
          this.inputText = value
        })
      
      Text(`当前输入：${this.inputText}`)
    }
    .padding(16)
  }
}
```

#### 3. 列表绑定

*Android传统开发：*
```java
public class ListActivity extends AppCompatActivity {
    private RecyclerView recyclerView;
    private UserAdapter adapter;
    private List<User> userList;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        
        recyclerView = findViewById(R.id.recyclerView);
        userList = getUserList();
        
        // Adapter模式
        adapter = new UserAdapter(userList);
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
    }
    
    private void updateList(List<User> newList) {
        userList.clear();
        userList.addAll(newList);
        adapter.notifyDataSetChanged();
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun UserList() {
    var userList by remember { mutableStateOf(getUserList()) }
    
    // LazyColumn + items()
    LazyColumn {
        items(userList) { user ->
            UserItem(
                user = user,
                onDelete = { 
                    userList = userList.filter { it.id != user.id }
                }
            )
        }
    }
}

@Composable
fun UserItem(user: User, onDelete: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(8.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(user.name)
        Button(onClick = onDelete) {
            Text("删除")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct UserList {
  @State userList: User[] = this.getUserList()
  
  build() {
    Column() {
      // LazyForEach动态列表
      List({ space: 8 }) {
        LazyForEach(this.userList, (user: User) => {
          ListItem() {
            this.UserItem(user)
          }
        }, user => user.id.toString())
      }
    }
  }
  
  @Builder UserItem(user: User) {
    Row() {
      Text(user.name)
        .layoutWeight(1)
      
      Button('删除')
        .onClick(() => {
          this.userList = this.userList.filter(u => u.id !== user.id)
        })
    }
    .width('100%')
    .padding(8)
  }
  
  private getUserList(): User[] {
    return [
      { id: 1, name: '张三' },
      { id: 2, name: '李四' }
    ]
  }
}
```

#### 4. 条件渲染

*Android传统开发：*
```java
public class ConditionalActivity extends AppCompatActivity {
    private TextView messageView;
    private Button toggleButton;
    private boolean isVisible = true;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_conditional);
        
        messageView = findViewById(R.id.messageView);
        toggleButton = findViewById(R.id.toggleButton);
        
        toggleButton.setOnClickListener(v -> {
            isVisible = !isVisible;
            // View.setVisibility()控制显示隐藏
            messageView.setVisibility(isVisible ? View.VISIBLE : View.GONE);
            toggleButton.setText(isVisible ? "隐藏" : "显示");
        });
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun ConditionalView() {
    var isVisible by remember { mutableStateOf(true) }
    
    Column {
        // if表达式条件渲染
        if (isVisible) {
            Text(
                text = "这是条件显示的内容",
                modifier = Modifier.padding(16.dp)
            )
        }
        
        Button(
            onClick = { isVisible = !isVisible }
        ) {
            Text(if (isVisible) "隐藏" else "显示")
        }
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct ConditionalView {
  @State isVisible: boolean = true
  
  build() {
    Column({ space: 16 }) {
      // if/else语句条件渲染
      if (this.isVisible) {
        Text('这是条件显示的内容')
          .padding(16)
          .backgroundColor(Color.Gray)
      }
      
      Button(this.isVisible ? '隐藏' : '显示')
        .onClick(() => {
          this.isVisible = !this.isVisible
        })
    }
    .padding(16)
  }
}
```

#### 5. 数据观察

*Android传统开发：*
```java
public class ObserverActivity extends AppCompatActivity {
    private TextView statusView;
    private UserViewModel viewModel;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_observer);
        
        statusView = findViewById(R.id.statusView);
        viewModel = new ViewModelProvider(this).get(UserViewModel.class);
        
        // Observer模式监听数据变化
        viewModel.getUserStatus().observe(this, status -> {
            statusView.setText(status);
        });
    }
}

public class UserViewModel extends ViewModel {
    private MutableLiveData<String> userStatus = new MutableLiveData<>();
    
    public LiveData<String> getUserStatus() {
        return userStatus;
    }
    
    public void updateStatus(String status) {
        userStatus.setValue(status);
    }
}
```

*Android Compose：*
```kotlin
@Composable
fun ObserverView(viewModel: UserViewModel = viewModel()) {
    // collectAsState监听数据变化
    val userStatus by viewModel.userStatus.collectAsState()
    
    Column {
        Text("状态：$userStatus")
        
        Button(
            onClick = { viewModel.updateStatus("在线") }
        ) {
            Text("更新状态")
        }
    }
}

class UserViewModel : ViewModel() {
    private val _userStatus = MutableStateFlow("离线")
    val userStatus: StateFlow<String> = _userStatus.asStateFlow()
    
    fun updateStatus(status: String) {
        _userStatus.value = status
    }
}
```

*HarmonyOS ArkUI：*
```typescript
@Entry
@Component
struct ObserverView {
  @State userStatus: string = '离线'
  
  // @Watch监听数据变化
  @Watch('onStatusChange')
  @State watchedStatus: string = '离线'
  
  onStatusChange() {
    console.log(`状态变化：${this.watchedStatus}`)
  }
  
  build() {
    Column({ space: 16 }) {
      Text(`状态：${this.userStatus}`)
      
      Button('更新状态')
        .onClick(() => {
          this.userStatus = '在线'
          this.watchedStatus = '在线'
        })
    }
    .padding(16)
  }
}
```

## 9. 性能优化对比

| 优化维度 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 技术要点 |
|----------|----------------|----------------|-----------------|----------|
| **布局优化** | 减少嵌套层级 | - | - | 避免过度绘制 |
| **列表优化** | RecyclerView复用 | LazyColumn + key | LazyForEach + key | 虚拟化滚动 |
| **内存优化** | 手动管理生命周期 | DisposableEffect | aboutToDisappear | 资源清理 |
| **重绘优化** | invalidate()控制 | remember/key() | @State稳定性 | 避免不必要重绘 |
| **状态优化** | 手动缓存计算结果 | derivedStateOf | @Computed | 计算状态缓存 |
| **动画优化** | ValueAnimator | Animatable | 属性动画 | 流畅动画效果 |
| **启动优化** | Application优化 | - | - | 应用启动速度 |
| **副作用优化** | 手动管理异步操作 | LaunchedEffect作用域 | 生命周期管理 | 副作用生命周期管理 |

## 10. 开发体验对比

| 开发维度 | Android传统开发 | Android Compose | HarmonyOS ArkUI | 优势对比 |
|----------|----------------|----------------|-----------------|----------|
| **开发语言** | Java/Kotlin | Kotlin | ArkTS(TypeScript扩展) | 类型安全 + 现代语法 |
| **IDE支持** | Android Studio | Android Studio | DevEco Studio | 专业开发环境 |
| **热重载** | Instant Run | Live Edit | 热重载 | 快速开发调试 |
| **预览功能** | Layout Preview | @Preview注解 | @Preview装饰器 | 可视化开发 |
| **调试工具** | Debugger + Profiler | Layout Inspector | 组件树查看器 | UI结构分析 |
| **代码提示** | 智能补全 | 智能补全 | ArkTS语法提示 | 开发效率提升 |
| **学习曲线** | 较低 | 中等 | 中等 | 上手难度 |
| **开发效率** | 中等 | 高 | 高 | 代码简洁度 |
| **文档生态** | 非常成熟 | 丰富的社区资源 | 官方文档完善 | 学习资源 |

## 11. 迁移建议

### 11.1 从传统Android到Compose的迁移

1. **思维转换**
   - 从命令式编程转向声明式编程
   - 从手动UI更新转向状态驱动UI
   - 从View层次结构转向组合函数

2. **技术迁移**
   - XML布局 → @Composable函数
   - findViewById → 状态管理
   - Adapter模式 → LazyColumn + items
   - 手动事件处理 → 函数参数

3. **学习重点**
   - 掌握remember和mutableStateOf
   - 理解重组机制
   - 学习Modifier系统
   - 掌握导航组件

### 11.2 从传统Android到HarmonyOS ArkUI的迁移

1. **语言转换**
   - 从Java/Kotlin转向ArkTS
   - 学习TypeScript语法特性
   - 适应装饰器语法

2. **架构转换**
   - Activity/Fragment → Page/Component
   - View系统 → ArkUI组件
   - Intent导航 → Router API

3. **开发环境**
   - Android Studio → DevEco Studio
   - Gradle → 鸿蒙构建系统
   - Android SDK → HarmonyOS SDK

### 11.3 从Compose到HarmonyOS ArkUI的迁移

1. **语言适应**
   - Kotlin → ArkTS
   - 函数式组件 → 结构体组件
   - 类型系统差异

2. **概念映射**
   - @Composable → @Component
   - remember → @State
   - LazyColumn → List + ForEach
   - NavHost → Router

3. **开发工具**
   - Android Studio → DevEco Studio
   - Layout Inspector → 组件树查看器
   - Live Edit → 热重载

### 11.4 三方技术对比总结

| 对比维度 | Android传统开发 | Android Compose | HarmonyOS ArkUI |
|----------|----------------|----------------|------------------|
| **学习难度** | 低 | 中 | 中 |
| **开发效率** | 中 | 高 | 高 |
| **代码维护性** | 低 | 高 | 高 |
| **性能表现** | 中 | 高 | 高 |
| **生态成熟度** | 非常高 | 高 | 中 |
| **未来发展** | 维护模式 | 主流方向 | 新兴技术 |

### 11.5 学习路径建议

1. **传统Android开发者**
   - 先学习Compose，理解声明式UI
   - 再学习ArkUI，利用相似概念快速上手
   - 重点关注状态管理和组件化思维

2. **新手开发者**
   - 建议直接学习Compose或ArkUI
   - 跳过传统Android开发的复杂性
   - 培养现代UI开发思维

3. **跨平台需求**
   - 同时掌握Compose和ArkUI
   - 理解两者的设计差异
   - 建立统一的开发模式

4. **持续学习**
   - 关注技术发展趋势
   - 参与社区讨论
   - 实践项目验证