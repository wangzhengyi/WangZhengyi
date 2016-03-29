# 面试问题总结

#### Activity生命周期和当屏幕发生旋转时Activity的生命周期.

生命周期:

* onCreate(Bundle savedInstanceState)：可以进行一些初始化的工作在activity第一次被创建的时候调用。这里是你做所有初始化设置的地方──创建视图、绑定数据至列表等
* onStart()：Activity显示在前台，但还不可与用户交互
* onRestart()：在activity停止后，在再次启动之前被调用。
* onResume()：取得控制权,可以对此Activity进行操作此时activity位于堆栈顶部，并接受用户输入。
* onPause()：暂停，可见，但不可操作，此方法主要用来将未保存的变化进行持久化，停止类似动画这样耗费CPU的动作等
* onStop()：当activity不再为用户可见时调用此方法
* onDestroy()：在activity销毁时调用

首次启动：onCreate->onStart->onResume
按下返回键：onPause->onStop->onDestory
按下Home键：onPause->onSaveInstanceState->onStop
再次打开：onRestart->onStart->onResume

**屏幕旋转**
如果没有特殊配置，旋转屏幕，**Activity被销毁然后重建**，流程如下：
onPause->onSaveInstanceState->onStop->onDestory->onCreate->onStart->onRestoreInstanceState->onResume

如果配置了AndroidManifest.xml文件，设置了**android:configChanges属性**:
```xml
android:configChanges="keyboardHidden|orientation|screenSize"
```
这个时候就不会在销毁重建Activity了。这时候旋转屏幕只会调用onConfigurationChanged方法，有什么在屏幕旋转的逻辑可以重写该方法：
```java
public void onConfigurationChanged(Configuratin newConfig) {
    if (newConfig.orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
        // TODO:
    }
    super.onConfigurationChanged(newConfig);
}
```

#### android动画分类

补间动画(TweenAnimation)，具体包括：
1. AlphaAnimation.
2. ScaleAnimation.
3. TranlateAnimation.
4. RotateAnimation.

这四种动画都是作用在View上，可以通过mView.startAnimation调用。

属性动画(ObjectAnimator)，可以直接操作View的属性.

#### android四种启动模式

* standard
* singleTop
* singleInstance
* singleTask

#### 谈一下Service，如何启动和结束Service

Service主要用于在后台处理一些耗时的逻辑，或者去执行某些需要长期运行的任务。必要的时候我们甚至可以在程序退出的情况下，让Service在后台继续保持运行状态。

启动Service:
```java
context.startService(new Intent(context, Service.class));
```
关闭Service:
```java
context.stopService(new Intent(context, Service.class));
```

#### AIDL全称，如何使用AIDL

AIDL(Android Interface Definition Language)，用于进程间的IPC通信.
客户端使用代码:
```java
// bind service
Intent intentService = new Intent(ACTION_BIND_SERVICE);  
intentService.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);              MainActivity.this.bindService(intentService, mServiceConnection, BIND_AUTO_CREATE);

// ServiceConection
private ServiceConnection mServiceConnection = new ServiceConnection()  
{  
    @Override  
    public void onServiceDisconnected(ComponentName name)  
    {  
        mIMyService = null;  
    }  

    @Override  
    public void onServiceConnected(ComponentName name, IBinder service)  
    {  
        //通过服务端onBind方法返回的binder对象得到IMyService的实例，得到实例就可以调用它的方法了  
        mIMyService = IMyService.Stub.asInterface(service);  
        try {  
            Student student = mIMyService.getStudent().get(0);  
            showDialog(student.toString());  
        } catch (RemoteException e) {  
            e.printStackTrace();  
        }
    }  
};
```

#### 常用的设计模式

单例模式，观察者模式，适配器模式，策略模式，工厂模式，模板方法模式，责任链模式(Android Touch事件传递).

Java实现观察者模式代码实现。

* 定义观察者(Observer)需要实现的接口.
```java
public interface Observer {
	void update();
}
```

*定义抽象主题角色类.
```java
public abstract class Subject {
	public List<Observer> list = new LinkedList<Observer>;
	
	public void attach(Observer observer){    
        list.add(observer);
    }
    
    public void detach(Observer observer){
        list.remove(observer);
    }
    
    public void notifyObservers(){
        for(Observer observer : list){
            observer.update();
        }
    }
}
```


