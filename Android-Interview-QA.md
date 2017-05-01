# Android面试题集合

-------
## Activity正常和异常情况下的生命周期

正常: onCreate()->onStart()->onResume()->onPause()->onStop()->onDestory()
回到后台(Home键、启动另外一个Acitivity): onPause()->onStop()
回到前台: onRestart()->onStart()->onResume()
被系统杀死(相关配置发生变化、低内存): onPause()->onSaveInstanceState()->onStop()->onDestory()
恢复:onCreate()->onStart()->onRestoreInstanceState()->onResume()

------
## Activity的四种启动模式

standard, singleTop, singleTask, singleInstance

------
## app如何保证后台服务不被杀死

Android的进程保活包括两个方面:

1. 提高进程的优先级,降低进程被杀死的概率.
2. 在进程被杀死后,进行拉活.

### 进程优先级

按照进程的重要性,划分为5级:

1. 前台进程(Foreground process)
2. 可见进程(Visible process)
3. 服务进程(Service process)
4. 后台进程(Background process)
5. 空进程(Empty process)

#### 前台进程-Foreground process

用户当前操作所必需的进程.如果一个进程满足以下任一条件,即视为前台进程:

1. 托管用户正在交互的 Activity(已调用 Activity 的 onResume() 方法)
2. 托管某个 Service,后者绑定到用户正在交互的 Activity
3. 托管正在“前台”运行的 Service(服务已调用 startForeground())
4. 托管正执行一个生命周期回调的 Service(onCreate()、onStart() 或 onDestroy())
5. 托管正执行其 onReceive() 方法的 BroadcastReceiver

通常,在任意给定时间前台进程都为数不多.只有在内存不足以支持它们同时继续运行这一万不得已的情况下,系统才会终止它们. 此时,设备往往已达到内存分页状态,因此需要终止一些前台进程来确保用户界面正常响应.

#### 可见进程-Visible process

没有任何前台组件、但仍会影响用户在屏幕上所见内容的进程.如果一个进程满足以下任一条件,即视为可见进程:

1. 托管不在前台、但仍对用户可见的 Activity(已调用其 onPause() 方法).例如,如果前台 Activity 启动了一个对话框,允许在其后显示上一 Activity,则有可能会发生这种情况.
2. 托管绑定到可见(或前台)Activity 的 Service.

可见进程被视为是极其重要的进程,除非为了维持所有前台进程同时运行而必须终止,否则系统不会终止这些进程.

#### 服务进程-Service process

正在运行已使用 startService() 方法启动的服务且不属于上述两个更高类别进程的进程.尽管服务进程与用户所见内容没有直接关联,但是它们通常在执行一些用户关心的操作(例如,在后台播放音乐或从网络下载数据).因此,除非内存不足以维持所有前台进程和可见进程同时运行,否则系统会让服务进程保持运行状态.

#### 后台进程-Background process

包含目前对用户不可见的 Activity 的进程(已调用 Activity 的 onStop() 方法).这些进程对用户体验没有直接影响,系统可能随时终止它们,以回收内存供前台进程、可见进程或服务进程使用. 通常会有很多后台进程在运行,因此它们会保存在 LRU (最近最少使用)列表中,以确保包含用户最近查看的 Activity 的进程最后一个被终止.如果某个 Activity 正确实现了生命周期方法,并保存了其当前状态,则终止其进程不会对用户体验产生明显影响,因为当用户导航回该 Activity 时,Activity 会恢复其所有可见状态.

#### 空进程-Empty process

不含任何活动应用组件的进程.保留这种进程的的唯一目的是用作缓存,以缩短下次在其中运行组件所需的启动时间. 为使总体系统资源在进程缓存和底层内核缓存之间保持平衡,系统往往会终止这些进程.

-------
### Android进程回收策略

Android中对于内存的回收,主要依靠LowMemoryKiller来完成,是一种根据OOM_ADJ阈值级别触发相应力度内存回收的机制.关于OOM_ADJ的说明如下:

| ADJ级别 | 取值 | 解释 |
| ------  | -----| ------|
| UNKNOWN_ADJ | 16 | 一般指将要会缓存进程,无法获取确定值|
| CACHED_APP_MAX_ADJ | 15 | 不可见进程的adj最大值 |
| CACHED_APP_MIN_ADJ | 9 | 不可见进程的adj最小值 |
| SERVICE_B_AD | 8 | B List中的Service |
| PREVIOUS_APP_ADJ | 7 | 上一个App的进程(往往通过按返回键)|
| HOME_APP_ADJ | 6 | Home进程 |
| SERVICE_ADJ | 5 | 服务进程(Service process) |
| HEAVY_WEIGHT_APP_ADJ | 4 | 后台的重量级进程, system/rootdir/init.rc文件中设置 |
| BACKUP_APP_ADJ | 3 | 备份进程 |
| PERCEPTIBLE_APP_ADJ | 2 | 可感知进程,比如后台音乐播放 |
| VISIBLE_APP_ADJ | 1 | 可见进程|
| FOREGROUND_APP_ADJ | 0 | 前台进程 |
| PERSISTENT_SERVICE_ADJ | -11 | 关联着系统或persistent进程 |
| PERSISTENT_PROC_ADJ | -12 | 系统persistent进程,比如telephony |
| SYSTEM_ADJ | -16 | 系统进程 |
| NATIVE_ADJ | -17 | native进程(不被系统管理)|

其中,OOM_ADJ >= 4的为比较容易被杀死的Android进程,0 <= OOM_ADJ <= 3的表示不容易被杀死的Android进程,其他表示非Android进程(纯Linux进程).在Lowmemorykiller回收内存时会根据进程的优先级别杀死OOM_ADJ比较大的进程,对于优先级相同的进程则进一步受到进程所占内存和进程存活时间的影响.

Android手机中进程被杀死可能有如下情况:

| 进程杀死场景 | 调用接口 | 可能影响范围 |
| 触发系统进程管理机制 | Lowmemorykiller | 从进程importance值由大到小依次杀死,释放内存 |
| 被第三方应用杀死(无Root) | killBackgroundProcess | 只能杀死OOM_ADJ为4以上的进程 |
| 被第三方应用杀死(有Root) | force-stop或者kill|理论上可以杀死所有进程,一般只杀非系统关键进程和非前台和可见进程 |
| 厂商杀进程功能 | force-stop或者kill | 
| 用户主动“强行停止”进程| force-stop | 只能停用第三方进程 |

综上,可以得出减少进程被杀死概率无非就是想办法提高进程优先级,减少进程在内存不足等情况下被杀死的概率.

--------
### 提升进程优先级的方案

#### 利用Activity提升权限

方案设计思想:监控手机锁屏解锁事件,在屏幕锁屏时启动一个像素的Activity,在用户解锁时将Activity销毁掉,注意该Activity需要设计成用户无感知.

目标:通过该方案,可以使进程的优先级在屏幕锁屏时间由4提高为1.

方案适用范围:

* 适用场景:本方案主要解决第三方应用以及系统管理工具在检测到锁屏事件后一段时机内会杀死后台进程,已达到省电的目的.
* 适用版本:适用所有的Android版本.

具体代码实现:

1. 定义一像素的Activity

```java
public class KeepLiveActivity extends Activity {
    public static final String TAG = KeepLiveActivity.class.getSimpleName();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate: KeepLiveActivity->onCreate");
        KeepLiveManager.getInstance().initKeepLiveActivity(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume: KeepLiveActivity->onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause: KeepLiveActivity->onPause");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy: KeepLiveActivity->onDestroy");
    }
}
```

2. 单例KeepLiveManager,用于初始化、启动、关闭一像素Activity

```java
public class KeepLiveManager {
    public static KeepLiveManager sInstance = new KeepLiveManager();
    public WeakReference<KeepLiveActivity> mWeakActivityRef = null;

    private KeepLiveManager() {

    }

    public static KeepLiveManager getInstance() {
        return sInstance;
    }

    public void initKeepLiveActivity(KeepLiveActivity keepLiveActivity) {
        this.mWeakActivityRef = new WeakReference<>(keepLiveActivity);

        // 设置1像素透明窗口
        Window window = keepLiveActivity.getWindow();
        window.setGravity(Gravity.LEFT | Gravity.TOP);
        WindowManager.LayoutParams params = window.getAttributes();
        params.x = 0;
        params.y = 0;
        params.width = 1;
        params.height = 1;
        window.setAttributes(params);
    }

    /**
     * 启动一像素Activity
     * @param context
     */
    public void startKeepLiveActivity(Context context) {
        Intent intent = new Intent(context, KeepLiveActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    /**
     * 结束一像素Activity
     */
    public void finishKeepLiveActivity() {
        if (mWeakActivityRef != null) {
            Activity activity = mWeakActivityRef.get();
            if (activity != null && !activity.isFinishing()) {
                activity.finish();
            }
        }
    }
}
```


3. 动态注册Receiver,在灭屏时启动Activity,开屏时关闭Activity

```java
public class KeepLiveReceiver extends BroadcastReceiver {
    public static final String TAG = KeepLiveReceiver.class.getSimpleName();


    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        Log.d(TAG, "onReceive: KeepLiveReceiver receive action =" + action);

        if (Intent.ACTION_SCREEN_OFF.equals(action) || Intent.ACTION_USER_BACKGROUND.equals(action)) {
            KeepLiveManager.getInstance().startKeepLiveActivity(context);
        } else if (Intent.ACTION_SCREEN_ON.equals(action) || Intent.ACTION_USER_BACKGROUND.equals(action)) {
            KeepLiveManager.getInstance().finishKeepLiveActivity();
        }
    }
}
```


需要注意的是,开屏和灭屏广播需要动态注册,静态注册无效.

#### 利用Notification提升权限

方案设计思想:Android中Service的优先级为4,通过setForeground接口可以将后台Service设置为前台Service,使进程的优先级从4提升到2.

方案实现挑战:从Android2.3开始调用setForeground将后台Service设置为前台Service时,必须在系统通知栏发送一条通知,也就是前台Service与一条可见的通知绑定在一起.对于不需要常驻通知栏的应用来说,该方案虽好,但却是用户感知的,无法直接使用.

方案应对措施:通过实现一个内部Service,在KeepLiveService和其内部Service同时发生具有相同ID的Notification,然后将内部Service结束掉.随着内部Service的结束,Notification将会消失,但系统优先级依然保持为2.

具体代码实现:

1. 实现一个KeepLiveService,在onStartCommand里启动InnerService,注册当前服务为前台服务.

```java
public class KeepLiveService extends Service {
    private static final String TAG = KeepLiveService.class.getSimpleName();
    static KeepLiveService sKeepLiveService;
    public KeepLiveService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        sKeepLiveService = this;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // 模拟耗时操作
        new Thread(new Runnable() {
            @Override
            public void run() {
                while (true) {
                    Log.d(TAG, "run: do somethind waste time !!!");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();
        startService(new Intent(this, InnerService.class));
        return super.onStartCommand(intent, flags, startId);
    }

    public static class InnerService extends Service {

        @Override
        public int onStartCommand(Intent intent,int flags, int startId) {
            KeepLiveManager.getInstance().setForegroundService(sKeepLiveService, this);
            return super.onStartCommand(intent, flags, startId);
        }

        @Nullable
        @Override
        public IBinder onBind(Intent intent) {
            return null;
        }
    }
}
```



2. KeepLiveManager中setForegroundService实现.

```java
/**
 * 提升Service的优先级为前台Service
 */
public void setForegroundService(final Service keepLiveService, final Service innerService) {
    final int foregroundPushId = 1;
    Log.d(TAG, "setForegroundService: KeepLiveService->setForegroundService: " + keepLiveService + ", innerService:" + innerService);
    if (keepLiveService != null) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
            keepLiveService.startForeground(foregroundPushId, new Notification());
        } else {
            keepLiveService.startForeground(foregroundPushId, new Notification());
            if (innerService != null) {
                innerService.startForeground(foregroundPushId, new Notification());
                innerService.stopSelf();
            }
        }
    }
}
```

### 进程死后拉活的方案

#### 利用系统广播拉活

方法设计思想:在发生特定系统时,系统会发出响应的广播,通过在AndroidManifest中静态注册对应的广播监听器,即可在发生响应事件时拉活.

常用于拉活的广播事件包括:

| 开机广播 | RECEIVE_BOOT_COMPLETED|
| 网络变化 | ACCESS_NETWORK_STATE<br>CHANGE_NETWORK_STATE<br>ACCESS_WIFI_STATE<br>CHANGE_WIFI_STATE<br>ACCESS_FINE_LOCATION<br>ACCESS_LOCATION_EXTRA_COMMANDS|
| 文件挂载 | MOUNT_UNMOUNT_FILESYSTEMS|
| 屏幕亮灭 | SCREEN_ON<br>SCREEN_OFF |
| 屏幕解锁 | RECEIVE_USER_PRESENT |
| 应用安装卸载 | PACKAGE_ADDED<br>PACKAGE_REMOVED|

方案适用范围:适用于全部Android平台,但存在如下几个缺点:

1. 广播接收器被管理软件、系统软件通过“自启管理”等功能禁用的场景无法接收到广播,从而无法自启动.
2. 系统广播事件不可控,只能保证发生事件时拉活进程,但无法保证进程挂掉后立即拉活.

#### 利用第三方广播拉活

方案设计思想:该方案总的设计思想与接收系统广播类似,不同的是该方案为接收第三方 Top 应用广播.

通过反编译第三方Top应用,如:手机QQ、微信、支付宝、UC浏览器等,以及友盟、信鸽、个推等 SDK,找出它们外发的广播,在应用中进行监听,这样当这些应用发出广播时,就会将我们的应用拉活.

方案适用范围:该方案的有效程度除与系统广播一样的因素外,主要受如下因素限制:

1. 反编译分析过的第三方应用的多少
2. 第三方应用的广播属于应用私有,当前版本中有效的广播,在后续版本随时就可能被移除或被改为不外发.

这些因素都影响了拉活的效果.

#### 利用系统Service机制拉活

方案设计思想:将Service设置为START_STICKY,利用系统机制在Service挂掉后自动拉活:

```java
@Override
public int onStartCommand(Intent intent, int flags, int startId) {
    return Service.START_STICKY;
}
```

方案在如下两种情况无法拉活:

1. Service 第一次被异常杀死后会在5秒内重启,第二次被杀死会在10秒内重启,第三次会在20秒内重启,一旦在短时间内 Service 被杀死达到5次,则系统不再拉起.
2. 进程被取得 Root 权限的管理工具或系统工具通过 forestop 停止掉,无法重启.


-------
## Service和IntentService的区别

### Service

Service是一个长期运行在后台的应用程序组件.

Service不是一个单独的进程,它和应用程序运行在同一个进程中,Service也不是一个线程,它运行在主线程中,所以不能直接处理耗时操作.如果直接把耗时操作放在Service的onStartCommand中,很容易导致ANR.在Service中,如果有耗时操作,必须启动一个线程来处理.

### IntentService

IntentService是继承于Service并处理异步请求的一个类.在IntentService内有一个工作线程来处理耗时操作,启动IntentService和启动传递的Service一样,同时,当任务执行完后,IntentService会自动停止,而不需要我们手动控制.另外,可以启动IntentService多次,而每一个耗时操作会以工作队列的方式在IntentService的onHandleIntent回调方法中执行,并且,每次只会执行一个工作线程,执行完第一个再执行第二个,以此类推.

IntentService同Service相比的好处:

1. 省去了我们在Service中手动开启线程的麻烦.
2. 当操作完成后,IntentService会自动退出.

-------
## 如何优雅的展示Bitmap大图

### 使用BitmapFactory.Options压缩图片

BitmapFactory这个类提供了多个解析方法(decodeByteArray,decodeFile,decodeResource等)用于创建Bitmap对象,我们应该根据图片的来源选择合适的方法.比如SD卡中图片就用decodeFile方法,网络上的图片就用decodeStream方法,资源文件中的图片就可以使用decodeResource方法.为此,每一种解析方法都提供了一个可选的BitmapFactory.Options参数,将这个参数的inJustDecodeBounds属性设置为true就可以让解析方法禁止为Bitmap分配内存,返回值也不再是一个Bitmap对象,而是null.虽然Bitmap是null,但是BitmapFactory.Options的outWidth、outHeight和outMimeType属性都会被赋值.这个技巧可以在加载图片之前就获取到图片的长宽值和MIME类型,从而根据情况对图片进行压缩.如下代码所示:

```java
BitmapFactory.Options options = new BitmapFactory.Options();
options.inJustDecodeBounds = true;
BitmapFactory.decodeResource(getResources(), R.id.image, options);
int imageWidth = options.outWidth;
int imageHeight = options.outHeight;
String imageType = options.outMimeType;
```
为了避免OOM异常,最好在解析每张图片的时候都先检查一下图片的大小.
现在图片的大小已经知道了,我们就可以决定是把整张图片加载到内存中还是加载一个压缩版的图片到内存中.以下几个因素是我们需要考虑的:

1. 预估一下整张图片所需占用的内存.
2. 为了加载这一张图片你愿意提供多少内存.
3. 用于展示这张图片的控件的实际大小.
4. 当前设备的屏幕尺寸和分辨率.

比如,你的ImageView只有128*96像素的大小,只是为了显示一张缩略图,这时候把一张1024*768像素的图片完全加载到内存显然是不值得的.

那我们怎样才能对图片进行压缩呢？通过设置BitmapFactory.Options中的inSampleSize的值就可以实现了.比如我们有一张2048*1536像素的图片,将inSampleSize设置为4,就可以把这张图片压缩成512*384像素.原本加载这张图片需要占用13M的内存,压缩后就只需要占用0.75M了(假设图片是ARGB_8888类型,即每个像素点占用4个字节).下面的方法可以根据传入的宽和高,计算出合适的inSampleSize值:

```java
public static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
    // 源图片的宽度和高度
    final int width = options.outWidth;
    final int height = options.outHeight;
    int inSampleSize = 1;

    if (height > reqHeight || width > reqWidth) {
        final int heightRatio = Math.round((float)height / (float)reqHeight);
        final int widthRatio = Math.round((float)width / (float)reqWidth);
        inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
    }

    return inSampleSize;
}
```

使用这个方法,首先你要将BitmapFactory.Options的inJustDecodeBounds属性设置为true,解析一次图片.然后将BitmapFactory.Options连同期望的宽度和高度一起传递到到calculateInSampleSize方法中,就可以得到合适的inSampleSize值了.之后再解析一次图片,使用新获取到的inSampleSize值,并把inJustDecodeBounds设置为false,就可以得到压缩后的图片了.

```java
public static Bitmap decodeBitmapFromResource(Resource res, int redId, int reqWidth, int reqHeight) {
    final BitmapFactory.Options options = new BitmapFactory.Options();
    options.inJustDecodeBounds = true;
    BitmapFactory.decodeResource(res, resId, options);
    options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
    options.inJustDecodeBounds = false;
    return BitmapFactory.decodeResource(res, resId, options);
}
```

### 使用LRU图片缓存

这里给出一个LRU图片缓存的具体实现:
```java
public class BitmapCache {
    private LruCache<String, Bitmap> mCache = null;

    public BitmapCache(cacheSize) {
        mCache = new LruCache<String, Bimtap>(cacheSize) {
            @Override
            protected int sizeOf(String key, Bitmap value) {
                return value.getRowBytes * value.getHeight();
            }
        };
    }
    public Bimtap getBitmap(String key) {
        return mCache.get(key);
    }
    public void putBitmap(String key, Bitmap value) {
        mCache.put(key, value);
    }
}
```

-------
# Thread和HandleThread区别

Thread大家经常使用,是用来开辟一个线程,使用方法是:
```java
Thread thread = new Thread(new Runnable() {
    @Override
    public void run() {
        // do something waste time
    }
});
thread.start();
```

通过这种方法创建多个线程,会导致我们的程序越来越慢.这种时候,我们就可以通过HandlerThread来开辟一个线程,然后将Runnable扔到HandlerThread的处理队列中,顺序执行.参考代码:

```java
public void handleFirstBtnClick(View view) {
    Log.i(TAG, "handleFirstBtnClick: main thread id=" + Thread.currentThread().getId());
    final HandlerThread thread = new HandlerThread("my-handler-thread");
    thread.start();
    Handler handler = new Handler(thread.getLooper());
    handler.post(new Runnable() {
        @Override
        public void run() {
            Log.i(TAG, "run: I am run current thread=" + Thread.currentThread().getId());
            for (int i = 0; i < 10; i ++) {
                Log.i(TAG, "run: print msg i=" + i);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    });
}
```

日志:
```text
03-27 19:48:18.754 3950-3950/android.com I/MainActivity: handleFirstBtnClick: main thread id=1
03-27 19:48:18.757 3950-4065/android.com I/MainActivity: run: I am run current thread=2536
03-27 19:48:18.757 3950-4065/android.com I/MainActivity: run: print msg i=0
03-27 19:48:19.757 3950-4065/android.com I/MainActivity: run: print msg i=1
```

通过运行日志可以看出,handler去post的Runnable是运行在HandlerThread线程中的.

从源码的角度去分析,只需要注意一点:HandlerThread如何保证getLooper()的时候Looper对象已经创建成功了.

我们首先来看一下HandlerThread的getLooper()源码:
```java
public Looper getLooper() {
    if (!isAlive()) {
        // 如果线程已经死掉,return null
        return null;
    }
    
   // 使用了生产者-消费者模式,如果mLooper一直为null,则让出cpu进行循环等待被唤醒
    synchronized (this) {
        while (isAlive() && mLooper == null) {
            try {
                wait();
            } catch (InterruptedException e) {
            }
        }
    }
    return mLooper;
}
```

HandlerThread中Looper初始化是在run()函数中执行的:
```java
@Override
public void run() {
    mTid = Process.myTid();
    Looper.prepare();
    synchronized (this) {
        mLooper = Looper.myLooper();
        notifyAll();
    }
    Process.setThreadPriority(mPriority);
    onLooperPrepared();
    Looper.loop();
    mTid = -1;
}
```

可以看到,在run方法中,Looper对象进行了初始化,并且初始化成功后会调用notifyAll方法唤醒调用getLooper()方法的调用者.

-------
## 关于include,merge,stub三者的使用场景

### include标签

include标签常用于将布局中的公共部分提取出来供其他layout使用,以实现布局模块化.
下面是一个在main.xml中使用include引入另一个布局foot.xml的例子.main.xml代码如下:
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >
    <ListView
        android:id="@+id/simple_list_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_marginBottom="@dimen/dp_80" />
    <include layout="@layout/foot.xml" />
</RelativeLayout>
```

其中,include引入的foot.xml为公共的页面底部,代码如下:
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >
    <Button
        android:id="@+id/button"
        android:layout_width="match_parent"
        android:layout_height="@dimen/dp_40"
        android:layout_above="@+id/text" />
    <TextView
        android:id="@+id/text"
        android:layout_width="match_parent"
        android:layout_height="@dimen/dp_40"
        android:layout_alignParentBottom="true"
        android:text="@string/app_name" />
</RelativeLayout>
```
include标签唯一需要的属性是**layout**属性,指定需要包含的布局文件.可以定义android:id和android:layout_*属性来覆盖被引入布局根节点的对应属性值.注意,重新定义android:id后,子布局的顶节点android:id就变化了.

### ViewStub标签
ViewStub标签同include标签一样可以用来引入一个外部布局,不同的是,ViewStub引入的布局默认不会扩张,即既不会占用显示,也不会占用位置,从而在解析layout时节省cpu和内存.
ViewStub常用来引入那些默认不会显示,只在特殊情况下显示的布局,如进度布局、网络失败显示的刷新布局、信息出错出现的提示布局等.
下面以在一个布局main.xml中加入网络错误时的提示页面network_error.xml为例,main.xml代码如下:
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >

    <ViewStub
        android:id="@+id/network_error_layout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout="@layout/network_error" />
</RelativeLayout>
```

其中,network_error.xml为只有在网络错误时才需要显示的布局,默认不会被解析,示例代码如下:
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >
    <Button
        android:id="@+id/network_setting"
        android:layout_width="@dimen/dp_160"
        android:layout_height="wrap_content"
        android:layout_centerHorizontal="true"
        android:text="@string/network_setting" />
    <Button
        android:id="@+id/network_refresh"
        android:layout_width="@dimen/dp_160"
        android:layout_height="wrap_content"
        android:layout_below="@+id/network_setting"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="@dimen/dp_10"
        android:text="@string/network_refresh" />
</RelativeLayout>
```

在Java中,通过(ViewStub)findViewById(id)找到ViewStub,通过stub.inflate()展开ViewStub,然后得到子View,如下:
```java
private View networkErrorView;

private void showNetError() {
    if (networkErrorView != null) {
        networkErrorView.setVisibility(View.VISIBLE);
        return;
    }

    ViewStub stub = (ViewStub)findViewById(R.id.network_error_layout);
    networkErrorView = stub.inflate();
}

private void showNormal() {
    if (networkErrorView != null) {
        networkErrorView.setVisibility(View.GONE);
    }
}
```
在上面showNetError()中展开了ViewStub,同时我们对networkErrorView进行了保存,这样下次就不用继续inflate.

### merge标签

在使用了include后可能导致布局嵌套过多,多余不必要的layout节点容易导致布局解析变慢.可以通过hierarchy viewer去分析.(Android Studio->Tools->Android->Android Device Monitor)

merge标签可用于两种典型情况:

1. 布局顶点是FrameLayout且不需要设置background或者padding等属性,可以用merge代替,因为Activity内容视图的parent view就是FrameLayout.
2. 某布局作为子布局被其他布局include时,使用merge当做该布局的顶节点,这样在被引入时顶节点会自动被忽略,而将其子节点全部合并到主布局中.

-------
## Java是值传递还是引用传递

首先,需要明确一点概念,**“一切传引用本质上还是传值”**.所以,归根节点都是值传递.
但是,还是要从基本类型和引用类型去做一个区分:

* 基本类型: 参数中是基本类型的值,也就是所谓的值传递.
* 引用类型:参数中是实际对象的地址,也就是所谓的引用传递.

举个很有代表性的例子:
```java
// 第一个例子:提供了改变自身方法的引用类型
StringBuilder sb = new StringBuilder("iphone");
void foo(StringBuilder builder) {
    builder.append("4");
}
foo(sb); // sb被改变了,变成了“iphone4”

// 第二个例子:提供了改变自身方法的引用类型,但是不使用,而是使用赋值运算符
StringBuilder sb1 = new StringBuilder("iphone");
void foo1(StringBuilder builder) {
    builder = new StringBuilder("android");
}
foo1(sb1); // sb1没有改变,还是“iphone”
```

接下来,解释一下为什么第一和第二例子的结果不同.

第三个例子中:
```text
sb(0x11) -> "iphone"
builder(0x11) -> "iphone"
```
因为builder和sb是同一对象的引用,因此当builder指向的内容改变时,sb内容也发生了改变.

第四个例子中:
```text
sb1(0x11) -> "iphone"
builder(0x11) -> "iphone"
```
当运行**builder = new StringBuilder("android")**之后,builder的内容可能变为0x12,因此builder指向内容的改变不会影响到sb1.
```text
sb1(0x11) -> "iphone"
builder(0x12) -> "android"
```
从上面这两个例子的分析,也可以看出,引用传递的本质也是值传递.

------
## final和static关键字的区别

### static

1. static变量
    static修饰的变量称为静态变量或者类变量.静态变量在内存中只有一个拷贝,JVM在加载类的过程中完成静态变量的内存分配（分配在方法区中）,可以通过类名直接访问.
2. static代码块
    static代码块是类加载过程中的初始化阶段时自动执行的.如果static代码块有多个,JVM将按照它们在类中出现的先后顺序依次执行它们.
3. static方法
    static方法中只能访问静态变量和静态方法.
4. static类
    一般只有内部类可以用static修饰,表示静态内部类.

### final

final关键字可以修饰变量、方法、类:

* final修饰变量,该变量只能被赋值一次.
* final修饰方法,该方法不能被子类重写.
* final修饰类,该类不能被继承.

-------
## 深拷贝和浅拷贝的区别

定义如下:

* 浅拷贝:使用一个已知实例对新创建的实例成员变量逐个赋值,这个方式被称为浅拷贝.
* 深拷贝: 当一个类的拷贝构造方法,不仅要复制对象的所有非引用成员变量值,还要为引用类型的成员变量创建新的实例,并且初始化为形式参数实例值.这个方式称为深拷贝.



