延迟加载 跟踪实体 

# 前言

之前有用过Entity FrameWork，很大程度上简便我们数据库操作，这一节我们来深入学习这门框架。

Entity Framework，其实就是一门ORM框架：

> ORM（Object Relational Mapping）-- 对象关系映射。其主要作用是在编程中，把面向对象的概念跟数据库中表的概念对应起来。举例来说就是，我定义一个对象，那就对应着一张表，这个对象的实例，就对应着表中的一条记录。

OK，对ORM有了一个概念后，来看一下EF的架构图：

<div align='center'>

![](https://docs.microsoft.com/zh-tw/dotnet/framework/data/adonet/ef/media/wd-efarchdiagram.gif)
</div>

我们知道EF是可以实现对多种数据库进行操作，从架构图可以看出底层是通过**ADO.NET**来实现的~

# ADO.NET

ADO.NET可以帮助我们连接并访问关系数据库与非数据库型数据源（例如XML，Excel或是文字档资料），这里我们就简单使用一下把~

我们在SQLs中就准备了一张User表，数据表结构如下:

<div align='center'>

User数据表结构（id，name，age）
</div>

通过ADO.NET访问数据库表代码如下：
```

```

实现效果如下:
<div align='center'>

ADO.NET访问数据库效果
</div>


再贴上一张关于ADO.NET的架构图：
<div align='center'>

![](https://statics.codedefault.com/uploads/u/course/2021/09/76o0ym4o39.png)
</div>

# EF的三种模式

EF使用方式有三种：Database、Model、Code；Model First基本没人使用，故这里只介绍Database First & Code Fist模式

- Database Fist：基于已存在的数据库生成实体

- Code First：代码编写出实体模型，并生成数据库（但也可通过基于数据库的形式生成实体）

我们来详解一下这两种方式的区别：

## Database First
```

```


当我们通过Database First使用EF时，会为我们创建一个edmx格式的文件，里面就是保存了数据表与实体的映射

详细看看

SSDL 存储模型定义语言 - 存储层：数据库表

CSDL 概念模型定义语言 - 概念层：实体

C-S 概念与存储之间的映射语言 - 映射层：数据库表与实体的映射


## Code First

```

```


采用注解的方式或者配置类的方式




# 简单实现ORM

Entity Framework是一门ORM框架，ORM的思想就是将表映射为实体，通过操作实体来操作数据表

在EF中我们看到了有两种映射思想，一种XML映射思想，一种是标识特性的方式，我们这里用第二种~


### 获取表结构

打开我们的SQLServer，新增一个查询（记得切换测试使用的数据库）：
```
select TABLE_NAME,TABLE_TYPE,TABLE_CATALOG,TABLE_SCHEMA from INFORMATION_SCHEMA.TABLES
```

结果如下：
<div align='center'>

 ![](https://static.jqwong.cn/202201021705720.PNG)
</div>
可以看到，这条指令就帮我们找到了该数据库下的所有数据表

然后我们再来使用这条指令：
```
select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE from INFORMATION_SCHEMA.COLUMNS t where t.TABLE_NAME = 'tbUser'
```

结果如下：
<div align='center'>

 ![](https://static.jqwong.cn/202201021707108.PNG)
</div>

帮我们找到的对应数据表的字段信息，我们新建一个控制台应用，实现上述功能：

首先安装套件：**System.Data.SqlClient**，主程序代码如下：

```
namespace ConsoleApp1
{
    class Program
    {
        // 配置数据库连接信息
        private const string connStr = "server=DESKTOP-CJRAS5T\\SQLEXPRESS;database=test;Trusted_Connection=SSPI";
        private static SqlConnection conn;

        static void Main(string[] args)
        {
            try
            {
                conn = new SqlConnection(connStr);
                conn.Open();
                Console.WriteLine("Connection Success");
                SqlDataAdapter adapter_tbs = new SqlDataAdapter("select TABLE_NAME,TABLE_TYPE,TABLE_CATALOG,TABLE_SCHEMA from INFORMATION_SCHEMA.TABLES", conn);
                DataSet set_tbs = new DataSet();
                adapter_tbs.Fill(set_tbs);
                SqlDataAdapter adapter_struct;
                DataSet set_struct = new DataSet();
                foreach (DataRow tbRow in set_tbs.Tables[0].Rows) {
                    Console.WriteLine($"Table:{tbRow[0]}");
                    adapter_struct = new SqlDataAdapter($"select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE from INFORMATION_SCHEMA.COLUMNS t where t.TABLE_NAME = '{tbRow[0]}';", conn);
                    set_struct.Clear();
                    adapter_struct.Fill(set_struct);
                    foreach (DataRow structRow in set_struct.Tables[0].Rows) {
                        Console.WriteLine($"Column:{structRow[0]},Type:{structRow[1]}");
                    }
                }
            }
            catch(Exception e)
            {
                Console.WriteLine(e.Message);
            }
            Console.ReadKey();
        }
    }
}
```

最后成功输出（因为数据库里只有一张表，所以这里只输出一张表的信息）：
<div align='center'>

![](https://static.jqwong.cn/202201021711245.PNG)
</div>  



配置数据库连接

特性（Table,Column）

T4模板生成实体，表示特性 继承IEntity

数据库上下文


```

dbContext.Query<User>(Expression<Func<T,bool>> exp)
select * from user where name = 'Jq'

dbContext.Add(Entity)
insert into tb(column) values(value)

dbContext.Delete<User>("name = 'Jq'")
delete from tb where name = 'Jq'

dbContext.Update(item => item.name = 'Jq',newEntity)
update tb set column1=value1 ... where name = 'Jq'
```





# 小结

获取数据库服务器中的数据库

获取数据库中的表

获取表的字段，类型，映射生成xml文件

通过xml文件自动生成Model

并发处理

犧牲性能 追踪状态

T4模板

<div align='center'>

![](https://img-blog.csdnimg.cn/2020051820273496.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2Nob25iaQ==,size_16,color_FFFFFF,t_70#pic_center)
</div>

[Entity Framework入门教程](https://www.cnblogs.com/wyy1234/p/9625583.html)

[Entity Framework教程(第二版)](https://www.cnblogs.com/lsxqw2004/p/4701979.html)

[EntityFramework之摸索EF底层（八）](https://www.cnblogs.com/CreateMyself/p/4783027.html)

[EF(一) -- EF简介](https://blog.csdn.net/chonbi/article/details/106200656)

[C#+ADO.NET数据库入门教程](https://codedefault.com/course/subject/csharp-adonet-mssql-server-example)

[C# ADO.NET数据库操作及常用类概述](http://c.biancheng.net/view/3004.html)

[C# ORM学习笔记：使用特性+反射实现简单ORM ](https://www.cnblogs.com/atomy/p/12764967.html)

[EF下CodeFirst、DBFirst与ModelFirst分析](https://blog.csdn.net/u010191243/article/details/44755977)

[学习Entity Framework 中的Code First](https://www.cnblogs.com/Wayou/archive/2012/09/20/EF_CodeFirst.html)

[Entity Framework Code First属性映射约定 ](https://www.cnblogs.com/libingql/p/3352058.html)

串口 4750
