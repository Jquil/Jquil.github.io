USE [TYLD_ZKDF]
GO

/****** Object:  StoredProcedure [dbo].[prc_PageResult]    Script Date: 2022/4/14 14:52:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
--/*-----存储过程 分页处理 孙伟 --创建 -------*/ 
  --/*-----存储过程 分页处理 浪尘 --修改----------*/ 
  --/*----- 对数据进行了分处理使查询前半部分数据与查询后半部分数据性能相同 -------*/ 
  create PROCEDURE [dbo].[prc_PageResult] 
  (  
  @tableName     nvarchar(4000),        ----要显示的表或多个表的连接 
  @showColumn     nvarchar(4000) = '*',    ----要显示的字段列表 
  @PageSize    int =1 ,        ----每页显示的记录个数 
 @CurrentPage        int = 1,        ----要显示那一页的记录 
 @ascColumn    nvarchar(4000) = null,    ----排序字段列表或条件 
 @bitOrderType        bit =11 ,        ----排序方法，为升序，为降序(如果是多字段排列Sort指代最后一个排序字段的排列顺序(最后一个排序字段不加排序标记)--程序传参如：' SortA Asc,SortB Desc,SortC ') 
 @strCondition    nvarchar(4000) = null,    ----查询条件,不需where 
 @pkColumn        nvarchar(40),        ----主表的主键 
 @Dist                 bit =0 ,           ----是否添加查询字段的 DISTINCT 默认不添加/添加 
 @PageCount    int =1  output,            ----查询结果分页后的总页数 
 @Counts    int =1  output                ----查询到的记录数 
 ) 
 AS 
 SET NOCOUNT ON 
 Declare @sqlTmp nvarchar(4000)        ----存放动态生成的SQL语句 
 Declare @strTmp nvarchar(4000)        ----存放取得查询结果总数的查询语句 
 Declare @strID     nvarchar(50)        ----存放取得查询开头或结尾ID的查询语句 
 Declare @strSortType nvarchar(10)    ----数据排序规则A 
 Declare @strFSortType nvarchar(10)    ----数据排序规则B 
 Declare @SqlSelect nvarchar(4000)         ----对含有DISTINCT的查询进行SQL构造 
 Declare @SqlCounts nvarchar(4000)          ----对含有DISTINCT的总数查询进行SQL构造 
 declare @timediff datetime  --耗时测试时间差 
 select @timediff=getdate() 
 if @Dist  =  0
 begin 
   set @SqlSelect = 'select ' 
   set @SqlCounts = 'Count(*)' 
 end 
 else 
 begin 
   set @SqlSelect = 'select distinct ' 
   set @SqlCounts = 'Count(DISTINCT '+@pkColumn+')' 
 end 
 
 if @bitOrderType= 0
 begin 
   set @strFSortType=' ASC ' 
   set @strSortType=' DESC ' 
 end 
 else 
 begin 
   set @strFSortType=' DESC ' 
   set @strSortType=' ASC ' 
 end 
 
 --------生成查询语句-------- 
 --此处@strTmp为取得查询结果数量的语句 
 if @strCondition is null or @strCondition=''     --没有设置显示条件 
 begin 
   set @sqlTmp =  @showColumn + ' From ' + @tableName 
   set @strTmp = @SqlSelect+' @Counts='+@SqlCounts+' FROM '+@tableName 
   set @strID = ' From ' + @tableName 
 end 
 else 
 begin 
   set @sqlTmp = + @showColumn + 'From ' + @tableName + ' where (1>0) ' + @strCondition 
   set @strTmp = @SqlSelect+' @Counts='+@SqlCounts+' FROM '+@tableName + ' where (1>0) ' + @strCondition 
   set @strID = ' From ' + @tableName + ' where (1>0) ' + @strCondition 
 end 
 ----取得查询结果总数量----- 
 exec sp_executesql @strTmp,N'@Counts int out ',@Counts out 
 declare @tmpCounts int 
 if @Counts =  0
   set @tmpCounts = 1 
 else 
   set @tmpCounts = @Counts 
     --取得分页总数 
   set @PageCount=(@tmpCounts+@PageSize-1)/@PageSize 
     /**//**//**//**当前页大于总页数 取最后一页**/ 
   if @CurrentPage>@PageCount 
       set @CurrentPage=@PageCount 
     --/*-----数据2分页分处理-------*/ 
   declare @CurrentPageIndex int --总数/页大小 
   declare @lastcount int --总数%页大小  
     set @CurrentPageIndex = @tmpCounts/@PageSize 
   set @lastcount = @tmpCounts%@PageSize 
   if @lastcount >  0
       set @CurrentPageIndex = @CurrentPageIndex +  1
   else 
       set @lastcount = @PageSize 
    --//***显示分页 
   if @strCondition is null or @strCondition=''     --没有设置显示条件 
   begin 
       if @CurrentPageIndex< 2 or @CurrentPage<=@CurrentPageIndex / 2  + @CurrentPageIndex % 2    --前半部分数据处理 
           begin  
               if @CurrentPage= 1
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(8))+' '+ @showColumn+' from '+@tableName                         
                       +' order by '+ @ascColumn +' '+ @strFSortType 
               else 
               begin 
                   if @bitOrderType= 1
                   begin                     
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(8))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' <(select min('+ @pkColumn +') from ('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-1) as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' order by '+ @ascColumn +' '+ @strFSortType+') AS TBMinID)' 
                       +' order by '+ @ascColumn +' '+ @strFSortType 
                   end 
                   else 
                   begin 
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(8))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' >(select max('+ @pkColumn +') from ('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-1) as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' order by '+ @ascColumn +' '+ @strFSortType+') AS TBMinID)' 
                       +' order by '+ @ascColumn +' '+ @strFSortType  
                   end 
               end     
           end 
       else 
           begin 
           set @CurrentPage = @CurrentPageIndex-@CurrentPage+ 1 --后半部分数据处理 
               if @CurrentPage <= 1  --最后一页数据显示                 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@lastcount as VARCHAR(6))+' '+ @showColumn+' from '+@tableName 
                       +' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType  
               else 
                   if @bitOrderType= 1
                   begin 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' >(select max('+ @pkColumn +') from('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-2)+@lastcount as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' order by '+ @ascColumn +' '+ @strSortType+') AS TBMaxID)' 
                       +' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType 
                   end 
                   else 
                   begin 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' <(select min('+ @pkColumn +') from('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-2)+@lastcount as Varchar(4)) +' '+ @pkColumn +' from '+@tableName 
                       +' order by '+ @ascColumn +' '+ @strSortType+') AS TBMaxID)' 
                       +' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType  
                   end 
           end 
   end 
    else --有查询条件 
   begin 
       if @CurrentPageIndex<2 or @CurrentPage<=@CurrentPageIndex /2  + @CurrentPageIndex % 2  --前半部分数据处理 
       begin 
               if @CurrentPage= 1
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName                         
                       +' where 1=1 ' + @strCondition + ' order by '+ @ascColumn +' '+ @strFSortType 
               else if(@bitOrderType=1) 
               begin                     
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' <(select min('+ @pkColumn +') from ('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-1) as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' where (1=1) ' + @strCondition +' order by '+ @ascColumn +' '+ @strFSortType+') AS TBMinID)' 
                       +' '+ @strCondition +' order by '+ @ascColumn +' '+ @strFSortType 
               end 
               else 
               begin 
                   set @strTmp=@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' >(select max('+ @pkColumn +') from ('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-1) as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' where (1=1) ' + @strCondition +' order by '+ @ascColumn +' '+ @strFSortType+') AS TBMinID)' 
                       +' '+ @strCondition +' order by '+ @ascColumn +' '+ @strFSortType  
               end            
       end 
       else 
       begin  
           set @CurrentPage = @CurrentPageIndex-@CurrentPage+1 --后半部分数据处理 
           if @CurrentPage <= 1  --最后一页数据显示 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@lastcount as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where (1=1) '+ @strCondition +' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType                      
           else if(@bitOrderType=1) 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' >(select max('+ @pkColumn +') from('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-2)+@lastcount as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' where (1=1) '+ @strCondition +' order by '+ @ascColumn +' '+ @strSortType+') AS TBMaxID)' 
                       +' '+ @strCondition+' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType     
           else 
                   set @strTmp=@SqlSelect+' * from ('+@SqlSelect+' top '+ CAST(@PageSize as VARCHAR(4))+' '+ @showColumn+' from '+@tableName 
                       +' where '+@pkColumn+' <(select min('+ @pkColumn +') from('+ @SqlSelect+' top '+ CAST(@PageSize*(@CurrentPage-2)+@lastcount as Varchar(20)) +' '+ @pkColumn +' from '+@tableName 
                       +' where (1=1) '+ @strCondition +' order by '+ @ascColumn +' '+ @strSortType+') AS TBMaxID)' 
                       +' '+ @strCondition+' order by '+ @ascColumn +' '+ @strSortType+') AS TempTB'+' order by '+ @ascColumn +' '+ @strFSortType             
       end     
   end 
------返回查询结果----- 
exec sp_executesql @strTmp 
select datediff(ms,@timediff,getdate()) as 耗时 
--print @strTmp 
SET NOCOUNT OFF 
GO

