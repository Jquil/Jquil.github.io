# 前言

前面有学习过MySQL、SQL-Server，但在公司中的小项目，一般会使用这两种数据库。但在大一些的项目，基本都会使用SQL-Server以及Oracle

Oracle对比MySQL、SQL-Server有哪些优势呢？


具体参考该篇文章：[Oracle、MySQL、SQL Server的比较](https://www.cnblogs.com/liuguanghai/p/5382465.html)，总结就是Oracle的性能更佳，更安全



# 安装

[点击进入下载页面](https://www.oracle.com/cn/downloads/#category-database)，选择“Database 11g 标准版”下载

1. 启动`setup.exe`进入安装

2. 安装选项：选择“创建和配置数据库”

3. 系统类：选择“桌面类”

4. 典型安装：更改软件存放路径，以及设置管理员密码

5. 之后就是傻瓜式安装，安装过程中会遇到“口令管理”的按钮，点击设置sys/system/hr的密码

6. 安装完成后，启动`SQL PLUS`软件，使用以上三个用户之一进行连接，确认


具体参考该篇文章：[Oracle 11g安装](https://www.w3cschool.cn/oraclejc/oraclejc-41xa2qqv.html)

# 测试

> 实现创建用户并授权，建表，以及增删查改

在安装Oracle的过程中我们创建了一个全局数据库“****”

首先，在Oracle中有用户的概念，用户又有权限、角色之分

<div align='center'>

贴上用户权限，角色的图：https://www.oraclejsq.com/article/010100133.html

</div>

```
// 创建用户：
create user test                  -- 用户名
    identified by '123456'        -- 密码
    default tablespace dts_test   -- 表空间名
    temporary tablespace tts_test -- 临时表名空间
    profile DEFAULT               -- 数据文件（默认数据文件）
    account unlock;               -- 用户是否解锁（lock/unlock）

// 授予角色：
grant resource to test;
```

然后来了解Oracle中的数据类型：

<div align='center'>

贴上Oracle数据类型，https://www.oraclejsq.com/article/010100139.html

</div>


OK，了解基本的数据类型之后就可以创建数据库表了：
```
// 创建数据库表
create table test.student   // test用户下的student表
(
    sid number primary key,
    sname varchar(10) not null,
    sex char(1) default '男'
);

// 添加备注
comment on table  test.student is '学生信息表';
comment on column test.student.sname is '姓名';
```

为了避免总是需要加前缀(用户名)，我们退出重新使用刚创建的用户连接

接下来我们实现增删查改，语句其实都一样
```
// 增加
insert into student(sname,sex) values('张三','男'),('李四','女');

// 删除
delete from student where sname = '张三';

// 查询
select * from student;

// 修改
update student set sex = '男' where sname = '张三';
```

# 可视化

为了方便操作Oracle数据库（将数据可视化），这里我们使用一款PLSQL Developer的软件

根据该篇文章：[PLSQL Developer安装详细步骤](https://blog.csdn.net/qq_36501591/article/details/106410036) 一步步走即可~


# 进阶

> 使用触发器、存储过程

OK，有了PLSQL Developer之后，我们就可以很方便的写触发器，存储过程了~

Oracle中触发器、存储过程的写法也是差不多的

触发器：
```
create trigger tr_student
after insert
begin
    update student set name = :new.name + "//"
end
```


存储过程：
```
create procedure sp_student(name in varchar,sex in char)
as
sexs char;
begin
    if sex = '男' then sexs := '女';
    else sexs := '男';
    end if;
    insert into student(name,sex) values(name,sexs);
end
```


这里只是简单地使用了一下Oracle的触发器以及存储过程，这里贴上：[Oracle进阶存储过程（Procedure）](https://blog.csdn.net/qq_31652795/article/details/115938549)


# 小结

Oracle对比其他数据库，感觉上是会难一些。但在大体上基本是一致的：增删改查，左右内连接，还有触发器存储过程。不同的是语法上可能会有一些差异，以及提供的函数会有所不同。


OK，学习先到这了，最后贴上：[Oracle基本教程](https://www.oraclejsq.com/article/010100110.html) 以及 [进阶教程](https://www.yiibai.com/oracle/oracle-procedure.html)~