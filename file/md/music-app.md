# 重构

之前已经初步完成了「Music-App」的开发，但由于以下原因需要将项目重构一遍：

1. UI不美观

2. 些许功能未完成

3. 代码太乱

我们将模块、功能分解，一步步来实现~

# 模块

1. “我的”，包含「本地音乐、播放列表、收藏歌手、我的喜欢 以及 创建的歌单」入口

2. “排行榜”：展示各大音乐排行榜

3. “搜索”：实现热搜以及搜索历史

4. “歌词”：歌词滚动，播放/暂停，切换下一首

# 数据库

\>> **tb_song_list_info(歌单信息)**

|Column|Type|Other|Info|
|------------|---------|-------------|----------|
| Tsli\_id   | Integer | Primary key | 主键       |
| Tsli\_name | Text    |             | 歌单名称     |
| Tsli\_only | Integer |             | 唯一（是否可删） |

\>> **tb_song_list_{tsli_id}(歌单)**

|Column|Type|Other|Info|
|---------|---------|-------------|------|
| Tsl\_id | Integer | Primary key | 主键   |
| Ts\_id  | Integer |             | 歌曲id |


\>> **tb_song(歌曲)**

|Column|Type|Other|Info|
|---------------------|---------|-------------|-----------------|
| Ts\_id              | Integer | Primary key | 主键              |
| ts\_musicRid        | Text    |             | 歌曲id \(JSON数据\) |
| Ts\_name            | Text    |             | 歌曲名称            |
| Ts\_artist          | Text    |             | 歌手              |
| Ts\_artistId        | Integer |             | 歌手ID            |
| Ts\_albumpic        | Text    |             | 专辑照片            |
| Ts\_songTimeMinutes | Text    |             | 歌曲时长            |
| Ts\_hasmv           | Integer |             | 是否有MV           |

\>> **tb_collect_singer(收藏的歌手)**

|Column|Type|Other|Info|
|----------------|---------|-------------|-------|
| Tcs\_id        | Integer | Primary key | 主键    |
| Tcs\_artistrId | Integer |             | 歌手ID  |
| Tcs\_artist    | Text    |             | 歌手    |
| Tcs\_pic       | Text    |             | 歌手照片1 |
| Tcs\_upPcUrl   | Text    |             | 歌手照片2 |
| Tcs\_pic120    | Text    |             | 歌手照片3 |


\>> **tb_leaderboard(排行榜)**

|Column|Type|Other|Info|
|--------------|---------|-------------|------|
| Tl\_id       | Integer | Primary key | 主键   |
| Tl\_sourceId | Text    |             | 资源id |
| Tl\_pic      | Text    |             | 照片   |
| Tl\_name     | Text    |             | 名称   |


\>> **tb_hot_search(热搜)**

|Column|Type|Other|Info|
|----------|---------|-------------|-------|
| Ths\_id  | Integer | Primary key | 主键    |
| Ths\_key | Text    |             | 热搜关键字 |


\>> **tb_search_history(搜索历史)**

|Column|Type|Other|Info|
|----------|---------|-------------|-------|
| Tsh\_id  | Integer | Primary key | 主键    |
| Tsh\_key | Text    |             | 搜索关键字 |


\>> **tb_cache_song(缓存歌曲)**

|Column|Type|Other|Info|
|-------------|---------|-------------|------|
| Tcs\_id     | Integer | Primary key | 主键   |
| Tcs\_songId | Integer |             | 歌曲ID |


# 功能

## 播放器

播放歌曲逻辑如下：

1. 首先到缓存表中查是否存在该歌曲缓存信息

2. 有：判断缓存文件是否存在，存在则播放，不存在则删掉该缓存数据

3. 无：正常播放


实现步骤如下：

1. 添加网络权限

1. 加入`audioplayers`依赖

2. 调用其API播放

找到`project/android/app/src/main/AndroidManifest.xml`，添加权限：
```
<uses-permission android:name="android.permission.INTERNET" />
```

加入依赖：
```
dependencies:
  audioplayers: ^0.18.1
```

播放API：
```
// 播放缓存：
playLocal() async {
    int result = await audioPlayer.play(localPath, isLocal: true);
}

// 正常播放：
play() async {
    int result = await audioPlayer.play(url);
    if (result == 1) {
        // success
    }
}
```

## 缓存

缓存歌曲功能，我们大致需要经过以下步骤：

1. 授予文件读写权限

2. 加入`path_provider`插件，用于获取路径

3. 加入`dio`插件，用于拉取数据并下载


同样，添加权限：
```
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```


加入依赖：
```
dependencies:
  path_provider: ^2.0.2
  dio: ^4.0.0
```

并在控制台中执行：`flutter pub get`


dio下载
```
await Dio().download(url, path);
```


补充：在实现上我采用的是手动缓存，如果需要缓存的歌曲正在播放，就不download了。直接创建文件并将数据流写进去即可~


## 更新

Android App如果没有上架应用商店，就需要通过以下步骤：

1. 下载应用至本地

2. 授权安装应用权限

3. 打开安装包安装

虽然说只有三步，但实现起来还是颇为繁琐。所以这里用一个较为简便的方法：**用浏览器打开下载链接下载并安装**

这里通过[「url_launcher」](https://pub.dev/packages/url_launcher)的插件来实现：

加入依赖：
```
dependencies:
  url_launcher: ^6.0.12

// flutter pub get
```

例子代码：
```
_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
```


## 夜间模式

```
MaterialApp( 
    theme: ThemeData( 
        brightness: Brightness.light, 
        primaryColor: Colors.blue, 
    ), 
    darkTheme: ThemeData.dark()
);
```

参考文章：[快速适配 Flutter 之深色模式](https://zhuanlan.zhihu.com/p/138530205)

# 最终

最终实现效果图如下：

。。。。

# 小结


[Flutter开发之——文件及文件夹操作](https://blog.csdn.net/Calvin_zhou/article/details/117323711)

[优秀轮子](https://www.jianshu.com/p/a26ed51565a1)

`select last_insert_rowid() from table;`