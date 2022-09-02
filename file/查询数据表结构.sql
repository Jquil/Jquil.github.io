USE [MES_MaterialDB]
GO

/****** Object:  StoredProcedure [dbo].[proc_QuerytableInfo]    Script Date: 2022/8/29 15:35:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
create procedure [dbo].[proc_QuerytableInfo]      
(      
    @tbName    varchar(50)    
)      
as      
select
        表名=case when a.colorder=1 then d.name else '' end,      
        表说明=case when a.colorder=1 then isnull(f.value,'') else '' end,      
        字段序号=a.colorder,      
        字段名=a.name,      
        标识=case when COLUMNPROPERTY( a.id,a.name,'IsIdentity')=1 then '√'else '' end,      
        主键=case when exists(select 1 from sysobjects where xtype='PK' and name in (      
            select name from sysindexes where indid in(      
                select indid from sysindexkeys where id = a.id AND colid=a.colid      
            ))) then '√' else '' end,      
        类型=b.name,      
        占用字节数=a.length,      
        长度=COLUMNPROPERTY(a.id,a.name,'PRECISION'),      
        小数位数=isnull(COLUMNPROPERTY(a.id,a.name,'Scale'),0),      
        允许空=case when a.isnullable=1 then '√'else '' end,      
        默认值=isnull(e.text,''),      
        字段说明=isnull(g.[value],'')      
      from syscolumns a      
        left join systypes b on a.xtype=b.xusertype      
        inner join sysobjects d on a.id=d.id  and d.xtype='U' and  d.name<>'dtproperties'      
        left join syscomments e on a.cdefault=e.id      
     
  left join sys.extended_properties g on a.id=g.major_id AND a.colid = g.minor_id      
        left join sys.extended_properties f on d.id=f.major_id and f.minor_id=0      
     where d.name=@tbName    --如果只查询指定表,加上此条件      
     order by a.id,a.colorder 
GO

