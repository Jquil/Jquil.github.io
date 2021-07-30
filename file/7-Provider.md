# 前言

<div align='center'>

![](https://tse1-mm.cn.bing.net/th/id/OIP-C.dGA_jxp71N0wnGMj5zDyBgHaEc?w=597&h=280&c=7&o=5&pid=1.7)

</div>

在单个Widget中，我们可以用`setState({})`来更新状态，但在场景：多个Widget共用一个状态，就不能满足需求了

Flutter有这么一个库：Provider，它就可以来实现我们这样的需求

它类似于我们Vue中的Vuex，React中的Redux..


# 了解


使用之前，我们先了解在本次使用Provider中的接触到的几个对象：


\>> ChangeNotifierProvider


\>> Consumer：*更多细小的重绘达到性能的优化（主要功能）


这里主要使用：ChangeNotifierProvider，


# 使用

首先，加入依赖：
```
dependencies:
  provider: ^4.1.0
```

新建一个MusicProvider
```
class MusicProvider extends ChangeNotifier{

    Song _song;
    MusicProvider({ @required Song song }) : _song = song;
    bool disposed = false;
    
    Song get song => _song;

    void setSong(Song song){
        _song = song;
        notifyListeners();
    }

    @override  
    void dispose() {
        super.dispose();
        disposed = true;
    }

    @override
    void notifyListeners() {
        if (!disposed) {
          super.notifyListeners();
        }
    }
}
```


挂载到根组件上
```
class MyApp extends StatelessWidget {
  
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
          ChangeNotifierProvider<MusicProvider>{
              create: (_)=>MusicProvider(song)
          }
      ],
      child: MaterialApp(
        ...
      ),
    );
  }
}
```

然后我们在子组件上实现监听，更新：
```
class ChildWidget1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MusicProvider notifier = Provider.of(context);
    return Column(
        children:[
            Text('监听 =>:${context.watch<MusicProvider>().song.name}'),
            RaisedButton(
              child: Text('+'),
              onPressed: () {
                notifier.setSong(song);
            }),
        ]
    )
  }
}
```


# 小结

emmmmmm，这里只简单使用地使用了一下Provider，没有涉及到更高级的知识~

附上学习文章：

1. [Flutter状态管理：Provider4 入门教程（一）](https://juejin.cn/post/6844904179014582286)

2. [Flutter状态管理：Provider4 入门教程（二）](https://juejin.cn/post/6844904182676209677)

3. [Flutter-MultiProvider](https://blog.csdn.net/Mr_Tony/article/details/111581877)

4. [Flutter使用Provider](https://blog.csdn.net/sinat_17775997/article/details/106142558)