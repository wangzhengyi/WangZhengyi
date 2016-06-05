# 技术难点——统一网络框架

没有网络框架的情况:

1. 项目初始阶段,很多模块涉及网络通信,编写网络并发和回调代码占据工程师大部分开发时间.
2. 代码中充斥大量Http连接散乱代码,线程误用,内存资源浪费严重.
3. 缺少缓存机制,浪费用户流量.
4. 回调机制不统一,代码耦合度高,不便于通信协议切换. 


统一网络框架之后:

1. 代码简洁,使用简单.
2. 使用线程池配合生产者-消费者队列,提高并发效率.
3. 充分利用HTTP缓存机制,节约用户宝贵流量.
4. 使用Handler和Looper机制,统一主线程和子线程的数据通信.
5. 模块的高度解耦,便于后期通信协议的切换.

# 技术难点--统一右滑退出

新需求:

PD希望在手表的每个应用中都能通过右滑操作结束当前应用.

初始思路:

实现一个右滑退出控件,让每个应用集成,作为布局文件的顶层ViewGroup,从而实现右滑退出功能.

面临问题:

1. 虽然能够右滑退出,但是每个应用都去集成让代码变得冗余.
2. 有的应用是apk集成且拿不到源码,无法集成该控件.

最终解决方案:

1. 实现并优化滑动退出控件.
2. 深入理解View的Touch事件传递机制,从Framework入手,在DecorView中集成右滑退出控件.应用层不需要修改代码即具备右滑退出功能.

