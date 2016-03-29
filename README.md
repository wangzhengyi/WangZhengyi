# 王正一

****
## 基本信息

* 电话: +86-138-1147-5902
* 邮箱: wzyll1314@gmail.com
* 教育背景: 中国传媒大学计算机学院(2011级, 工学硕士, 计算机应用技术专业)
* 博客: <http://csdn.net/wzy_1988>
* Github: <https://github.com/wangzhengyi>

****
## 专业技能

* Android应用层: 熟练掌握Android UI实现, 自定义View, 多线程通信, 进程间通信, HTTP/HTTPS/Socket网络通信, 能够实现自定义网络请求框架, 并对Android源码有一定的研究.
* Android Framework层: 熟悉Android体系架构和JNI开发, 对AOSP ROM适配有一定的开发经验.
* 编程语言: 熟练使用JAVA, PHP, C, Shell, 了解HTML, CSS, JavaScript.
* 数据库: 熟悉SQLite, MySQL, Redis.
* 运维: 熟悉Linux和Linux系统运维, 能够实现基于Nginx的负载均衡web服务器.
* 协作: 熟练使用repo, git, svn.
* 基础: 熟悉并掌握常用算法, 数据结构和设计模式.
* 英语: CET-6, Google无障碍搜索阅读英文资料.

****
## 工作经历

### 阿里巴巴 YunOS事业群 研发工程师 2014/07 - 至今

#### 智能硬件-支付手表项目 2015/07 - 至今

负责支付手表整个应用层模块开发,具体包括:
* 天气应用:自定义Volley Request获取并解析天气数据,自定义数据库结构存储地理位置信息,接入高德定位并通过Service定时拉取最新天气数据,实现Widget并通过Service操作RemoteView对Widget定时更新.
* 秒表、闹钟、计时器:为了适配圆形手表,设计并编写大量自定义控件,用来实现表盘、刻度等UI细节.独立设计并实现刻度替换算法,可以在表盘里合理的显示分钟进制刻度和小时进制刻度.并且提供ContentProvider和AIDL通信,便于其他进程获取闹钟、秒表等数据信息.
* 设置应用:在Android原生设置应用的基础上,根据手表UI重新实现设置应用,包括亮度调节、声音调节、WIFI模块等.
* 密码锁:实现第三方密码锁功能,并且深入理解Keyguard锁屏机制,改写Framework的Keyguard代码,替换原生锁屏系统.
* 自定义控件:会抽象出通用自定义控件,打成jar包或集成到系统以Library Project形式提供给团队同学使用.

#### YunOS Rom适配 2014/11 - 2015/06

负责MTK机型的YunOS Rom适配.主要是通过编译和拼包的方式将YunOS的Rom和MTK具体机型的Rom进行拼装移植.具体包括:
* 编写Android.mk单独修改和编译模块,掌握Android Rom编译体系,并对boot.img和system.img进行解包和重新打包.
* 从abd log分析分析系统起机遇到的问题,并能通过修改init模块,分析zygote和system server源码来解决相应的问题.
* 编写Edify刷机脚本,通过Fastboot和Recovery对机型进行移植测试.并编译shell脚本,将重复过程脚本化.
* 熟悉Android Framework层jar包的作用和JNI层大部分动态库的作用,便于遇到问题时替换相应的so库.

该项目适配超过20款机型,并为YunOS增加了百万激活量.目前在刷机大师和刷机精灵网站上热门的YunOS Rom均为我负责研发.

#### YunOS移动端论坛 2014/07 - 2014/11

负责YunOS论坛移动端研发.这也是我刚接触Android就短期内独立研发并多次迭代上线的一款YunOS官方应用,目前在官方应用市场下载量超过百万.具体技术包括:

* 设计应用的实现架构和目录结构.
* 设计并封装了HTTP网络请求,提供队列机制对网络请求进行并发处理.
* 设计了ViewPager+Fragment的UI架构,并且自定义控件实现ViewPageIndicator,可跟随ViewPager进行滑动和颜色的改变,并能响应click事件.
* 封装并使用WebView,并定制JavaScript接口来进行特殊请求处理.

### 北京灵创众和科技有限公司 服务端研发工程师 2011/11 - 2013/09

#### 服务器运维 2011/12 - 2013/09
搭建服务器端的 LNMP 基础环境, 提出并实现基于bash脚本+rsync的增量代码部署方案,负责线上服务器安全加固, mysql、redis 数据备份和恢复等运维工作, 期间完成过服务器端 apache2+mod_php 到 nginx+fastcgi+fpm 的架构迁移.

#### 用户消息系统 2012/05 - 2012/09
构建好联系用户的消息存储系统. 基于Redis数据库设计并实现消息实时读取算法, 提供用户消息的实时存储, 读取, 删除等功能, 支撑了消息通知, 名片分享等业务功能的实现.

#### 移动黄页搜索系统 2011/12 - 2012/04
设计并构建基于 Coreseek+mysql+redis 的本地黄页数据移动搜索引擎, 提供支持 JSON的 API 查询接口, 支持百万数据的索引, 中文分词, 准实时索引更新, 数据筛选.

