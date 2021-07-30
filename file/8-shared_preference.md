# 前言

<div align='center'>

![](https://tse1-mm.cn.bing.net/th/id/OIP-C.YsvrFsCT4PY90MeOa_W-5AHaEK?w=531&h=286&c=7&o=5&pid=1.7)
</div>

不是所有数据都需要使用数据库来作持久化存储的，Android中有`SharedPreferences`库来实现键值对的数据存储，Flutter中也有提供~



# 使用

首先，加入依赖：
```
shared_preferences: "^0.4.2"
```


新建一个文件：`MySP.dart`
```
class MySP{

    // 实现单例模式，构造器中获取
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Future<String> getString(String key) async {
        return prefs.getString(key);
    }


    void setString(String key, String value){
        prefs.setString(key,value);
    }


    // bool，int类型数据同样如此
}


```

# 小结

很简单，附上学习文章：

[Flutter数据存储之shared_preferences](https://www.jianshu.com/p/735b5684e900)