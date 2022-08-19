【关于音频实现】
【1】[小米妙播适配说明](https://dev.mi.com/console/doc/detail?pId=2481)
【2】[音视频开发之旅（45)-ExoPlayer 音频播放器实践(一)](https://juejin.cn/post/6967642485765963790)
【3】[ExoPlayer使用讲解(基本使用)](https://juejin.cn/post/7069951881254010916)
【4】[Building a media browser service](https://blog.csdn.net/u014306335/article/details/88072735)

-------------------------------------------------------------->

【适配小米妙播思路】
1. 通过ExoPlayer实现音频播放
2. 注册MediaBrowserService
3. 构建MediaSessionCompat.Callback回调，处理播放、暂停、上一首、下一首、调整播放进度等操作
4. mMediaSession.setPlaybackState(builder.build()) // 及时更新播放状态信息：构建PlaybackState，传入播放状态、播放进度等信息，
5. mMediaSession.setMetadata(builder.build());       // 及时更新Meta信息：媒体meta信息（歌曲名、专辑名、歌手名、歌曲时长等）

-------------------------------------------------------------->

【其他】
【1】[StateLayout](https://liangjingkanji.github.io/StateLayout/retry/)

【2】[BaseQuickAdapter使用](https://juejin.cn/post/6920427163485700110)

【3】[Android开发笔记（一百七十一）使用Glide加载网络图片](https://cloud.tencent.com/developer/article/1633361)

【4】关于 FragmentContainer + BottomNavigationView 实现：
>>[JetPack系列—将Navigation与BottomNavigationView结合使用](https://juejin.cn/post/6993946629925502983)
>>[Android 安卓DataBinding（一）·基础](https://blog.csdn.net/qq_40881680/article/details/101714634)
>>[BottomNavigationView底部图标和文字的显示问题](https://blog.csdn.net/wangsen927/article/details/120808987)
>>[谈谈修改actionbar的背景色和title字体颜色](https://www.jianshu.com/p/c6ca571802d7)
>>[使用 NavigationUI 更新界面组件](https://developer.android.google.cn/guide/navigation/navigation-ui?hl=zh-cn)

【5】[kotlin--Flow结合Room运用](https://www.jianshu.com/p/e3d76dba1aa7)

【6】歌词滚动Widget
>> https://github.com/Moriafly/LyricViewX/blob/main/README-zh-CN.md
>> https://github.com/wangchenyan/lrcview
>> https://github.com/zhangliangming/HPLyrics