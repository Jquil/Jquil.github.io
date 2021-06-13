# 配置

这里附上搭建过程中所借鉴的文章：

1. [Github搭建个人站点](https://blog.csdn.net/weixin_43017662/article/details/98204416)

1. [绑定域名](https://www.cnblogs.com/liangmingshen/p/9561994.html)

1. [配置HTTPS](https://www.cnblogs.com/ichochy/p/11652961.html)

以及在配置HTTPS时修改掉的DNS服务器，这里备份下：

- dns7.hichina.com
- dns8.hichina.com

\>> **补充：**

这里附上一些工具：

- [阿里云运维检查平台](https://zijian.aliyun.com/?spm=a2c1d.8251892.content.2.25a95b76j67Bb2)

- [iconfont-阿里巴巴矢量图标库](https://www.iconfont.cn/)

# 前端

前端我是采用Vue框架编写，这里再说一下安装流程，温习一下：

1. 安装Node.js，进入官网下载

1. 安裝腳手架：`npm install -g vue-cli`

1. 安裝webpack：`npm install -g webpack`

1. Vue-CLI3可以通過`vue init projectName` 安裝，CLI2的通過`vue create webpack projectName` 安裝

1. 安裝完成後，切換到目錄下，`npm run dev`啟動

1. 完成项目后，通过`npm run build` 打包项目
(打包后出现页面空白：[vue-cli创建项打包后打开页面为空白的问题解决](https://www.cnblogs.com/facefront/p/10954799.html))

## 特色

> 下面说一下，在编写过程的一些特色点：

### 路由跳转

hash&browser


### 高亮菜单

不依赖框架如何实现呢？

---

### 组件之间事件的传递

### Vuex?

## 知识点

1. this.$nextTick()

2. 监听window滑动，判断是否滑动到底部 
   - [添加监听事件](https://www.cnblogs.com/jiayeyuan/p/10120409.html)
   - [判断滑动到底部](https://www.cnblogs.com/winyh/p/7526346.html)

3. Markdown解析器：`npm install marked`
   - `npm install highlight.js --save-dev`：

4. axios安装：`npm install axios --save`
   - [如何在Vue中使用Axios](https://blog.csdn.net/qq_30631063/article/details/107099336)
   - [菜鸟教程：axios](https://www.runoob.com/vue2/vuejs-ajax-axios.html)

5. 图片懒加载：`npm install vue-lazyload --save-dev`
   - [vue 图片懒加载（以及踩过的坑）](https://www.cnblogs.com/lovebear123/p/13503300.html)

6. Vuex安裝：`npm install vuex --save`
   - [五分钟搞懂Vuex](https://www.cnblogs.com/chinabin1993/p/9848720.html)
   - [Vue 爬坑之路（四）—— 与 Vuex 的第一次接触](https://www.cnblogs.com/wisewrong/p/6344390.html)

7. 
# 错误信息

\>> `npm run dev`启动应用时报出一下错误信息：
```
You may use special comments to disable some warnings.
Use // eslint-disable-next-line to ignore the next line.
Use /* eslint-disable */ to ignore all warnings in a file.
```

解决：找到build>webpack.base.conf.js文件，mould对象-rules属性，注释第一行
```
//...(config.dev.useEslint ? [createLintingRule()] : []),
```

参考文章：[Vue—解决“You may use special comments...](https://blog.csdn.net/qq_41999034/article/details/109078474)

---

<br>

\>> axios使用在IE上出現错误：`[Vue warn]: Error in created hook: "ReferenceError: 'Promise' 未經定義"`

解决：- `npm install --save babel-polyfill` 并 `import ''babel-polyfill'`

参考文章：[Error in created hook: "ReferenceError: “Promise”未定义" Vue-cli 项目 谷歌没错，IE报错“Promise”未定义"](https://www.pianshen.com/article/2612307021/)

---

<br>

\>> Vuex在IE上使用报：`SCRIPT5022: [vuex] vuex requires a Promise polyfill in this browser.`

解决：同样是安装babel，不过需要修改配置文件并重启vue项目

参考文章：[SCRIPT5022: [vuex] vuex requires a Promise polyfill in this browser.](https://blog.csdn.net/qq_40101922/article/details/89467554)

---

<br>

\>> IE上img不能使用object-fix属性

解决-参考文章（参考实践）：[ie input兼容 vue_解决object-fit兼容IE浏览器实现图片自适应](https://blog.csdn.net/weixin_39944233/article/details/112434162)

---

\>> Uncaught (in promise) NavigationDuplicated: Avoided redundant navigation to

出现这个问题是因为：路由重复添加了，可以在路由文件中配置，但并不能满足我的需求。

我的需求原本实现是：点击搜索按钮，跳转到搜索页面，这就导致了报错；

后面改为：点击搜索按钮，判断当前路由是否为搜索页面，

1. 否：跳转

2. 是：通过传递事件给搜索组件，进行重新搜索

附上-参考文章：[VUE报错UNCAUGHT (IN PROMISE) NAVIGATIONDUPLICATED: AVOIDED REDUNDANT NAVIGATION TO CURRENT LOCATION: “](https://www.freesion.com/article/50421404573/)


以及：[Vue兄弟组件间传值 之 事件总线](https://blog.csdn.net/lianghecai52171314/article/details/109847553)

补充：在实现事件总线后，出现反复调用的问题，因此我们需要在组件销毁后，对事件也进行销毁：[解决vue全局事件总线bus反复调用的问题](https://blog.csdn.net/qq_40775604/article/details/101772782)

---

使用正则表达式替换之后，会影响到其他组件

搞不懂，使用的又不是同一个对象，难道说在替换的时候对根数据也替换了??? 应该不会吧

附上：[vue数据改变影响其他数据的问题](https://blog.csdn.net/qq379682421/article/details/114656510)


# 搭站思路

因为没钱续费服务器，只能通过Github来搭站了。

Github也能实现：搭站、文件存储。但对于后端，就没办法实现了

那么网站是如何实现网站的增删改查的呢？

很简单，手动输入....

1. 文章就用Markdown编写，最后存储为md文件，上传到文件夹中

2. 写个JSON文件，存储所有文章简要信息

3. 最后请求时，通过JS请求文件并解析Markdown

因此添加/删除文章时，在JSON文件中修改

而对于修改则直接修改Markdown文件即可

查询则交给前端处理....

# 概念

computed

methods

created

mounted

data

# git

这里简单说下在使用git上传到仓库的操作以及遇到的问题：

```
git init
git add .
git commit -m "提交信息"
git remote add origin 仓库地址
git push -u origin master
``` 

问题1：在提交代码时出现了这么个警告：
```
Warning: Permanently added the RSA host key for IP address 'xxx.xxx.xxx.xxx' to the list of known hosts.
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

百度了一下，说github没有公钥：[解决文章](https://blog.csdn.net/yushuangping/article/details/84240863)

---

问题2：在解决完上第一个问题后，又出现了一个问题：
```
 ! [rejected]        master -> master (fetch first)
error: failed to push some refs to 'git@github.com:xxxxxx'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

继续百度，说：github中的README.md不在本地代码目录中，需要合并 => [解决文章](https://blog.csdn.net/weixin_43264399/article/details/87350219)

即：`git pull --rebase origin master`

# 小结
