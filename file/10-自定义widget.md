# 前言

Music-App 最后还存在一个问题，就是展示歌词的Widget没有实现




# 准备

首先，第一步需要格式化歌词

```
[ti:一个人的北京]
[ar:好妹妹乐队]
[al:南北]
[by:]
[offset:0]
[00:00.10]一个人的北京 - 好妹妹乐队
[00:00.20]词：秦昊
[00:00.30]曲：秦昊
[00:00.40]
[00:30.16]你有多久没有看到 满天的繁星
[00:37.34]城市夜晚虚伪的光明 遮住你的眼睛
[00:44.40]连周末的电影 也变得不再有趣
[00:51.71]疲惫的日子里 有太多的问题
[00:59.21]
[01:00.96]你有多久单身一人 不再去旅行
[01:08.20]习惯下班回到家里 冷冰冰的空气
[01:15.58]爱情这东西 你已经不再有勇气
[01:22.64]情歌有多动听 你就有多怀疑
[01:30.60]许多人来来去去 相聚又别离
[01:38.29]也有人喝醉哭泣 在一个人的北京
[01:45.16]也许我成功失意 慢慢的老去
[01:52.76]能不能让我留下片刻的回忆
[01:58.95]
[04:34.24]也有人匆匆逃离 这一个人的北京
[04:41.37]也许有一天我们 一起离开这里
[04:48.87]离开了这里 在晴朗的天气
[04:55.08]
```


写一个Model
```
class Lyric{
  String lyric;
  Duration startTime;
  Duration endTime;
 
  Lyric(this.lyric, {this.startTime, this.endTime});
 
  @override
  String toString() {
    return 'Lyric{lyric: $lyric, startTime: $startTime, endTime: $endTime}';
  }
}
```


转化：
```
static List<Lyric> formatLyric(String lyricStr) {
  RegExp reg = RegExp(r"^\[\d{2}");
 
  List<Lyric> result =
    lyricStr.split("\n").where((r) => reg.hasMatch(r)).map((s) {
    String time = s.substring(0, s.indexOf(']'));
    String lyric = s.substring(s.indexOf(']') + 1);
    time = s.substring(1, time.length - 1);
    int hourSeparatorIndex = time.indexOf(":");
    int minuteSeparatorIndex = time.indexOf(".");
    return Lyric(
      lyric,
      startTime: Duration(
        minutes: int.parse(
          time.substring(0, hourSeparatorIndex),
        ),
        seconds: int.parse(
          time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
        milliseconds: int.parse(time.substring(minuteSeparatorIndex + 1)),
      ),
    );
  }).toList();
 
 
  for (int i = 0; i < result.length - 1; i++) {
    result[i].endTime = result[i + 1].startTime;
  }
  result[result.length - 1].endTime = Duration(hours: 1);
  return result;
}
```



# 实现

实现分成几个部分：

1. 绘制出歌词

2. 跟随时间变化

3. 加动画



监听Provider:
```
model.instance.addListener();
```

AudioPlayer播放进度监听：
```
audioPlayer.onAudioPositionChanged.listen((p) async {
  // p参数可以获取当前进度，也是可以调整的，比如p.inMilliseconds
})
```


LyricWidget
```
/* 实现思路大致如下：
    1. Widget需要歌词信息，用来绘制歌词文本
    2. 监听歌曲播放进度，获取时间
    3. 通过时间找到此时应该高亮的行号
    4. 执行动画

   存在问题：
    1. 监听歌曲，如何获取到当前播放时间 
    2. 如何将播放时间将动画绑定起来
    3. 切换到下一首歌曲了，如何更新页面 
*/

class LyricWidget extends CustomPainter with ChangeNotifier {

    List<Lyric> lyric;                  // 歌词信息
    int curLine;                        // 当前行
    Paint linePaint;                    // 绘制当前行的画笔
    List<TextPainter> lyricPaints = []; // 其他歌词：绘制文本
    double totalHeight = 0;             // 总长度
    double _offsetY = 0;                // Y轴偏移量
    bool isDragging = false;            // 是否正在拖动：不实现


    /* 构造器：
        1. 初始化画笔（用于绘制当前行）
        2. 将歌词都加入到List<TextPainter>中，TextPainter是用于绘制文本的工具
        3. 调用_layoutTextPainters
    */
    LyricWidget(this.lyric, this.curLine) {
        linePaint = Paint()
            ..color = Colors.white12
            ..strokeWidth = ScreenUtil().setWidth(1);
        lyricPaints.addAll(lyric
            .map((l) => TextPainter(
                text: TextSpan(text: l.lyric, style: commonGrayTextStyle),
                textDirection: TextDirection.ltr))
            .toList());

        // 首先对TextPainter 进行 layout，否则会报错
        _layoutTextPainters();
    }


    /* 该方法在构造器中调用：
        1. 将歌词文本都布局出来（没有绘制）
        2. 计算出总高度
    */
    void _layoutTextPainters() {
        lyricPaints.forEach((lp) => lp.layout());

        // 延迟一下计算总高度
        Future.delayed(Duration(milliseconds: 300), () {
        totalHeight = (lyricPaints[0].height + ScreenUtil().setWidth(30)) *
            (lyricPaints.length - 1);
        });
    }


    /* 绘制歌词：
        1. 计算出widget中间位置
        2. 绘制歌词
    */
    void paint(Canvas canvas, Size size) {
        var y = _offsetY + size.height / 2 + lyricPaints[0].height / 2;
        for (int i = 0; i < lyric.length; i++) {
            if (y > size.height || y < (0 - lyricPaints[i].height / 2)) {
            }
            else {
                // 高亮
                if (curLine == i) {
                    lyricPaints[i].text = TextSpan(text: lyric[i].lyric, style: commonWhiteTextStyle);
                    lyricPaints[i].layout();
                }
                // 默认
                else {
                    lyricPaints[i].text = TextSpan(text: lyric[i].lyric, style: commonGrayTextStyle);
                    lyricPaints[i].layout();
                }
                // 设置偏移
                lyricPaints[i].paint(
                    canvas,
                    Offset((size.width - lyricPaints[i].width) / 2, y),
                );
            }
            // 计算偏移量
            y += lyricPaints[i].height + ScreenUtil().setWidth(30);
    }



    // 用于重绘
    @override
    bool shouldRepaint(LyricWidget oldDelegate) {
        return oldDelegate._offsetY != _offsetY;
    }


    // set
    set offsetY(double value) {
        // 判断如果是在拖动状态下
        if (isDragging) {
            
        }
        else {
            _offsetY = value;
        }
        notifyListeners();
    }


    /* 查找高亮歌词所在行
        params1: 时间
    */
    static int findLyricIndex(double curDuration) {
        for (int i = 0; i < lyric.length; i++) {
            if (curDuration >= lyric[i].startTime.inMilliseconds &&
                curDuration <= lyric[i].endTime.inMilliseconds) {
                return i;
            }
        }
        return 0;
    }


    /// 计算传入行和第一行的偏移量
    double computeScrollY(int curLine) {
        return (lyricPaints[0].height + ScreenUtil().setWidth(30)) * (curLine + 1);
    }

    /* 滚动动画
        没有更新
    */
    void startLineAnim(int curLine) {
        // 判断当前行和 customPaint 里的当前行是否一致，不一致才做动画
        if (_lyricWidget.curLine != curLine) {
            // 如果动画控制器不是空，那么则证明上次的动画未完成，
            // 未完成的情况下直接 stop 当前动画，做下一次的动画
            if (_lyricOffsetYController != null) {
                _lyricOffsetYController.stop();
            }

            // 初始化动画控制器，切换歌词时间为300ms，并且添加状态监听，
            // 如果为 completed，则消除掉当前controller，并且置为空。
            _lyricOffsetYController = AnimationController(
                vsync: this, duration: Duration(milliseconds: 300))
                ..addStatusListener((status) {
                    if (status == AnimationStatus.completed) {
                        _lyricOffsetYController.dispose();
                        _lyricOffsetYController = null;
                    }
                }
            );


            // 计算出来当前行的偏移量
            var end = _lyricWidget.computeScrollY(curLine) * -1;

            // 起始为当前偏移量，结束点为计算出来的偏移量
            Animation animation = Tween<double>(begin: _lyricWidget.offsetY, end: end)
                .animate(_lyricOffsetYController);

            // 添加监听，在动画做效果的时候给 offsetY 赋值
            _lyricOffsetYController.addListener(() {
                _lyricWidget.offsetY = animation.value;
            });

            // 启动动画
            _lyricOffsetYController.forward();
        }
    }
}
```


Widget写好了，最后就是放在我们的页面上：
```
return CustomPaint(
    size: Size(width,height),
    painter: lyricWidget(歌词，初始行0),
);
```


# 小结

参考：

[CSDN：Flutter搭建网易云歌词](https://blog.csdn.net/qq_23756803/article/details/102814343)

以及该文章项目 - [github下的两个文件：](https://github.com/fluttercandies/NeteaseCloudMusic/blob/master/netease_cloud_music/lib/pages/play_songs)

1. `lyric_page.dart => 歌词页面`

2. `widget_lyric.dart => 歌词Widget`

