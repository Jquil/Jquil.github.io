# 兴起

Github搭站实现如下：

1. 文章以Markdown文件形式存储在七牛云上，图片也是

2. 手动配置JSON数据存储文章的信息

3. 通过http请求拿到markdown文件，并转化为html显示在页面上

4. 最后将完成好的Vue项目打包上传到Github上~





# 配置

这里附上搭建过程中所借鉴的文章：

1. [Github搭建个人站点](https://blog.csdn.net/weixin_43017662/article/details/98204416)

1. [绑定域名](https://www.cnblogs.com/liangmingshen/p/9561994.html)

1. [配置HTTPS](https://www.cnblogs.com/ichochy/p/11652961.html)


# 安装

1. 安装node.js -> [点击传送](https://nodejs.org/zh-cn/)

1. cmd全局安装脚手架：`npm install -g vue-cli`

1. 检查版本：`vue -V`

1. 切换到目录下安装应用：`vue init webpack {project-name}`（vue2.x使用`vue create {projectName}`）

1. 调试：`npm run dev`

1. 打包使用`npm run build` (打包后出现页面空白：[vue-cli创建项打包后打开页面为空白的问题解决](https://www.cnblogs.com/facefront/p/10954799.html))



# 插件

本项目用到大概以下插件

1. axios：数据请求 

2. vuex：状态管理

3. vue-lazyload：图片懒加载

4. marked：markdown解析


# 小结

emmm....

