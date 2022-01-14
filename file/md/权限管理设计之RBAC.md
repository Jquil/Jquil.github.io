<div align='center'>

![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/059ebf12dc254b83b82aa54baca630be~tplv-k3u1fbpfcp-zoom-crop-mark:1304:1304:1304:734.awebp)
</div>


# 前言

对于一个管理系统来说，权限是必不可少的。例如一个修改密码功能，你可以修改自己的密码，别人不能修改你的密码；

当你也忘记了自己的密码无法修改的时候，这时就会有一个“管理员”的角色帮你去重置密码；

这里就涉及到普通成员与管理员两种角色，我们需要根据不同角色去分配不同的权限


<div align='center'>

![](https://img-blog.csdnimg.cn/img_convert/096600c29945797e34c66c06399b170b.png)

</div>

RBAC，就是基于角色对于权限的控制；



# 页面权限

在管理系统中，根据不同的权限能访问不同的页面：举个例子，例如在系统的菜单列表中有一项是关于财务的，那么就只有财务人员有这个权限访问；

我们需要实现以下效果：
<div align='center'>

comm用户登录

admin用户登录
</div>

普通用户只能看到基本页面（我的），而admin用户可以看到所有页面；

### 数据库


数据库这里我们准备6张表，并塞一些数据进去：

<div align='center'>
user

role

user_role

page_list

page_item

permission_page
</div>



#### user

```
id - int - 主键 - 自增
name - 用户名
pass - 密码
```


#### role

```
id 
name - 角色名称
use - 是否启用
```


#### user_role

```
id
userId
roleId
```


#### page_list


```
id
name - 列表代号
title - 列表名称
ico - 列表ico
```

#### page_item

```
id
name - 子项代号
title - 子项标题
listId - 父菜单ID
```

#### permission_page

```
id
pageItemId
roleId
```


### 后端

数据库准备好了，我们来新建一个WebApi项目，加入以下套件：
- EntityFramework
- Newtonsoft.Json
- Microsoft.AspNet.Cors
- Microsoft.IdentityModel.JsonWebTokens

项目结构如下所示：
<div align='center'>

项目结构图
</div>

```

- project
|
|
-- Dao
|
---Model
|
--- BaseDao（初始化dbContext）
| 
--- UserDao
|
--- PermissionDao（getRole(User user)、getPagePermission(Role role)）
|
-- Service
|
--- UserService
```


返回的JSON格式：
```
{
    "page":[
        {
            "List":"User",
            "Title":"用户管理",
            "Ico":"",
            "Children":[
                {
                    "Name":"UserCenter",
                    "Title":"用户中心",
                },
                {
                    "Name":"AddUser",
                    "Title":"新增用户",
                }
            ]
        }
    ]
}
```

### 前端


前端我们使用Vue来实现，安装Vue项目并引入以下依赖：
```
// 安装Vue
// 引入VueX
// 引入ElementUI
```

参考：[vue-element-admin架构](https://github1s.com/PanJiaChen/vue-element-admin)



# 操作权限


操作权限，其实就是对于数据的增删改查。例如老板只需要看到数据，并可以检索，数据的增删改操作应该是由下面的员工来完成；


# 数据权限



```
{
    "menu":[
        {
            "id":1000,
            "name":"人员管理"
            "children":[
                {
                    "id":1001,
                    "name":"添加人员",
                    "path":"AddPerson"
                },
                {
                    "id":1002,
                    "name":"人员查看",
                    "path":"QueryPerson"
                },
                {
                    "id":1003,
                    "name":"人员操作",
                    "path":"EditPerson"
                },
            ]
        }
    ]
}
```

# 多角色权限合并操作



使用套件：Newtonsoft.Json
```
namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
           
            JArray root = JArray.Parse("[{\"List\":\"用戶管理\",\"Children\":[{\"Item\":\"用戶中心\"},{\"Item\":\"新增用戶\"},{\"Item\":\"修改用戶\"}]}]");
            JArray ja1  = JArray.Parse("[{\"List\":\"用戶管理\",\"Children\":[{\"Item\":\"用戶中心\"},{\"Item\":\"新增用戶\"},{\"Item\":\"修改用戶\"},{\"Item\":\"刪除用戶\"}]}]");
            JArray ja2  = JArray.Parse("[{\"List\":\"權限管理\",\"Children\":[{\"Item\":\"添加權限\"},{\"Item\":\"刪除權限\"},{\"Item\":\"修改權限\"}]}]");

            merge(ref root, ref ja1);
            merge(ref root, ref ja2);
            Console.WriteLine(root);
            Console.ReadKey(); 
        }


        static void merge(ref JArray root,ref JArray other) {
            JArray tempArr = new JArray();
            foreach(JObject objRoot in root){
                bool JObjectExit = false;
                JObject temp = null;
                foreach (JObject objOther in other)
                {
                    if (objRoot.ContainsKey("List") && objOther.ContainsKey("List"))
                    {
                        if (objRoot.Value<string>("List") == objOther.Value<string>("List"))
                        {
                            JObjectExit = true;
                            objRoot.Merge(objOther, new JsonMergeSettings
                            {
                                MergeArrayHandling = MergeArrayHandling.Union
                            });
                            break;
                        }
                        else
                        {
                            temp = objOther;
                        }
                    }
                }

                if (temp != null && !JObjectExit)
                {
                    tempArr.Add(temp);
                }
            }
            root.Merge(tempArr);
        }
    }
}
```

# 小结

角色的状态（启用、禁用） => 不删除


1. 如果没有登录，重定向到登录界面（不能访问其他界面）

2. 登录后返回该用户信息（角色、权限）

[【项目实践】一文带你搞定页面权限、按钮权限以及数据权限](https://zhuanlan.zhihu.com/p/296519030)

[如何实现后台管理系统中的权限管理？](https://www.jianshu.com/p/e55bbb3eee9e)

[知乎：后台系统的权限设计](https://zhuanlan.zhihu.com/p/34608415)

[RBAC权限管理模型：基本模型及角色模型解析及举例](http://www.woshipm.com/pd/440765.html)

[权限系统设计(2)：RBAC权限控制详解](https://www.zhoulujun.cn/html/Operation/PM/2020_0510_8425.html)

[后台权限管理系统设计（图文教程）](https://blog.csdn.net/qq_40147863/article/details/85320371)

[前端权限——页面权限](https://juejin.cn/post/6988003267972677663)

[如何将数据库SQL查询结果直接转为JSON](https://www.yisu.com/zixun/495450.html)

[C# JObject.Merge方法代碼示例](https://vimsky.com/zh-tw/examples/detail/csharp-ex-Newtonsoft.Json.Linq-JObject-Merge-method.html)

[初探EntityFramework——来自数据库的Code First](https://blog.csdn.net/xuchen_wang/article/details/98185191)