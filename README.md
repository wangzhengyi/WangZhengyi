# 王正一

****
## 基本信息

* 电话: +86-138-1147-5902
* 邮箱: wzyll1314@gmail.com
* 教育背景: 中国传媒大学计算机学院(2011-2014, 工学硕士, 计算机应用技术专业)
* 博客: <http://csdn.net/wzy_1988>
* Github: <https://github.com/wangzhengyi>

****
## 专业技能

* Android应用层: 熟练掌握Android UI实现, 自定义View, 多线程通信, 进程间通信, HTTP/HTTPS/Socket网络通信, 能够实现自定义网络请求框架, 并对Android源码有一定的研究.
* Android Framework层: 熟悉Android体系架构和JNI开发, 对AOSP ROM适配有一定的开发经验.
* 前端: 熟练掌握Vue框架使用.
* 编程语言: 熟练使用JAVA, PHP, C, Shell, JavaScript, 了解HTML, CSS.
* 数据库: 熟悉SQLite, MySQL, Redis.
* 运维: 熟悉Linux和Linux系统运维, 能够实现基于Nginx的负载均衡web服务器.
* 协作: 熟练使用repo, git, svn.
* 基础: 熟悉并掌握常用算法, 数据结构和设计模式.
* 英语: CET-6, Google无障碍搜索阅读英文资料.

****
## 社区项目(主力开发)

* [ThinDownloadManager](https://github.com/smanikandan14/ThinDownloadManager)
* [Volley源码分析](https://github.com/wangzhengyi/Volley)
* [EventBus源码分析](https://github.com/wangzhengyi/EventBusAnalysis)

****
## 工作经历

### 阿里巴巴 YunOS事业群 高级开发工程师 2014/02 - 至今

#### 应用中心项目 项目负责人

负责低性能手机上应用中心模块开发,具体包括:

* 自定义应用下载框架,基于RxJava和Retrofit打造,支持多线程下载和断点续传,并能智能判断是否需要断点续传.
* 主导项目的技术实现方案,采用了MVP+Volley+自定义下载框架的实现.
* 针对低端机进行性能优化,包括布局,内存和绘制.

#### 位置穿越项目 项目负责人

负责位置穿越项目整个应用层模块开发,具体包括:

* 主导整个项目技术方案的设计,服务端传输地理位置信息,应用层接收下发,反射调用Framework接口进行地址位置欺骗.
* MVC模式实现了整个应用层代码,项目分层合理,且实现大量自定义控件.
* 针对性能做了大量的优化,特别是内存优化方面.

#### 智能硬件-支付手表项目 应用主力开发

负责支付手表整个应用层模块开发,具体包括:

* 天气应用:自定义Volley Request获取并解析天气数据,自定义数据库结构存储地理位置信息,接入高德定位并通过Service定时拉取最新天气数据,实现Widget并通过Service操作RemoteView对Widget定时更新.
* 秒表、闹钟、计时器:为了适配圆形手表,设计并编写大量自定义控件,用来实现表盘、刻度等UI细节.独立设计并实现刻度替换算法,可以在表盘里合理的显示分钟进制刻度和小时进制刻度.并且提供ContentProvider和AIDL通信,便于其他进程获取闹钟、秒表等数据信息.
* 设置应用:在Android原生设置应用的基础上,根据手表UI重新实现设置应用,包括亮度调节、声音调节、WIFI模块等.
* 自定义控件:会抽象出通用自定义控件,打成jar包或集成到系统以Library Project形式提供给团队同学使用.

### 北京灵创众和科技有限公司  服务端研发工程师 2011/11 - 2013/09

1.  负责设计并实现用户消息系统,基于Redis数据库实现用户消息的实时存储, 读取, 删除等功能.
2.  负责设计并实现移动黄页搜索系统,基于Coreseek+Mysql+Redis的黄页搜索引擎,支持百万数据的索引,中文分词,准实时索引更新和数据筛选等功能.
3.  负责服务器运维工作.