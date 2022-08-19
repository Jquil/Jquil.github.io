USE [MES_MaterialDB]
GO

/****** Object:  StoredProcedure [dbo].[P_ESP_Sys_UserMenuList]    Script Date: 2022/8/17 9:33:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











CREATE PROC [dbo].[P_ESP_Sys_UserMenuList]( 
	@userID NVARCHAR(50)
	)
AS
	SET NOCOUNT ON;
BEGIN
/*
-- =============================================
-- Author（作者）: ZNY
-- Create date（创建时间）: 2022-5-21
-- FunctionID(页面):用户登录后进入首页的菜单列表，根据权限展示
-- Description（备注）: 根据用户权限获取菜单列表，拿到子菜单需要向上递归，拿到相应的父级目录
-- ModifyLog（修改记录）: 
-- Example（测试用例）: exec P_ESP_Sys_UserMenuList  '321'
-- =============================================
*/

DECLARE @IsAdmin INT;

/*创建临时表*/
create table #AllMenu(
	UserId nvarchar(50) null,		/* 用户ID */
	ID nvarchar(50) null,			/* 菜单ID */
	MenuName nvarchar(50) null,		/* 菜单名称 */
	Sort nvarchar(50) null,			/* 菜单排序，父级归父级排序，子级归子级排序 */
	Url nvarchar(50) null,			/* 菜单地址 */
	Moduleflag nvarchar(50) null,
	Remark nvarchar(50) null,
	ParentId nvarchar(50) null,
	ParentName nvarchar(50) null,
	WorkflowProcessdefinitionId nvarchar(50) null,
	workflowProcessdefinitionName nvarchar(50) null,
	IsEncrypt nvarchar(50) null,
	IsShow nvarchar(50) null,
	IsDelete nvarchar(50) null,
	IsEnabled nvarchar(50) NULL,
	ControlName NVARCHAR(50) null
	)
	SET @IsAdmin = (SELECT COUNT(su.id) FROM dbo.T_ESP_Sys_Users su 
					LEFT JOIN dbo.T_ESP_Sys_UserRoles ur ON su.Id = ur.User_GuID
					LEFT JOIN dbo.T_ESP_Sys_Roles sr  ON ur.Role_GuID = sr.Id
					WHERE su.UserId = @userID  AND sr.RoleName='系统管理员');

	/*拿到所有的菜单列表*/
	IF(@IsAdmin > 0 )
	 BEGIN
		/* 系统管理员返回所有菜单 */
		INSERT INTO #AllMenu(UserId,ID,MenuName,Sort,Url,Moduleflag,Remark,ParentId,ParentName,WorkflowProcessdefinitionId,workflowProcessdefinitionName,IsEncrypt,IsShow,IsDelete,IsEnabled,ControlName)
		SELECT DISTINCT @userID
		 AS UserId, md.ID,md.MenuName,md.Sort,md.Url,md.Moduleflag,md.Remark
			 ,md.ParentId,mm.MenuName AS ParentName,md.WorkflowProcessdefinitionId,wpd.Workflowname AS workflowProcessdefinitionName
			 ,md.IsEncrypt,md.IsShow,md.IsDelete,md.IsEnabled,md.ControlName
			 FROM T_ESP_Sys_Menu md
			 LEFT JOIN  T_ESP_Sys_Menu mm ON md.ParentId =CAST(mm.ID AS NVARCHAR(50))
			 LEFT JOIN  T_ESP_Sys_WorkflowProcessDefinition wpd ON md.WorkflowProcessdefinitionId = CAST(wpd.Id AS NVARCHAR(50))
			 LEFT JOIN T_ESP_Sys_QuickMenu qk ON qk.ChildMenu_GuID = md.Id
			  WHERE ISNULL(md.IsDelete,'0')='0'
	 END
	 ELSE
	 BEGIN
		/*普通用户根据配置的权限拿相应的菜单 */
		INSERT INTO #AllMenu(UserId,ID,MenuName,Sort,Url,Moduleflag,Remark,ParentId,ParentName,WorkflowProcessdefinitionId,workflowProcessdefinitionName,IsEncrypt,IsShow,IsDelete,IsEnabled,ControlName)
		SELECT us.UserId, md.ID,md.MenuName,md.Sort,md.Url,md.Moduleflag,md.Remark
			 ,md.ParentId,mm.MenuName AS ParentName,md.WorkflowProcessdefinitionId,wpd.Workflowname AS workflowProcessdefinitionName
			 ,md.IsEncrypt,md.IsShow,md.IsDelete,md.IsEnabled,md.ControlName	
			 FROM T_ESP_Sys_Menu md
			 LEFT JOIN  T_ESP_Sys_Menu mm ON md.ParentId =CAST(mm.ID AS NVARCHAR(50))
			 LEFT JOIN  T_ESP_Sys_WorkflowProcessDefinition wpd ON md.WorkflowProcessdefinitionId = CAST(wpd.Id AS NVARCHAR(50))
			 LEFT JOIN T_ESP_Sys_QuickMenu qk ON qk.ChildMenu_GuID = md.Id
			 LEFT JOIN  T_ESP_Sys_RoleFunction rf ON rf.MenuAs_GuID = qk.id
			 LEFT JOIN  T_ESP_Sys_Roles rs ON rs.Id = rf.Role_GuID
			 LEFT JOIN  T_ESP_Sys_UserRoles ur ON ur.Role_GuID =rs.Id
			 LEFT JOIN  T_ESP_Sys_Users us ON us.Id = ur.User_GuID;		
	 END

	/*拿到用户拥有的菜单列表ISNULL(IsShow,'1') ='1' AND*/
	SELECT *  INTO  #MenuTab  FROM #AllMenu WHERE  ISNULL(IsEnabled,'1') ='1' AND ISNULL(IsDelete,'0')='0' AND  Userid = @userID ;

	/*
	向上递归
	根据用户菜单查找所属的上级菜单
	获取上级菜单，不在乎是否删除，作为父级菜单不应删除	
	2022-06-24 ：如果WITH 出现死循环时，检查菜单里面 本来应该为父级菜单的，改菜单的父级ParentId字段被赋值，导致该菜单变成了子级菜单。但是之前的子级菜单的父级却还是原来的ID
				 这种情况就会出现死循环，并且现有的菜单应该也对应的异常（该菜单在列表中消失了，其实就是改变了其父级菜单的状态），这种情况修正该菜单数据即可
	*/

	--WITH temp AS
	--(
	--	SELECT CAST(ID AS NVARCHAR(50)) AS ID,UserId,MenuName,Sort,Url,Moduleflag,Remark,ParentId,ParentName,CAST(WorkflowProcessdefinitionId AS NVARCHAR(50))AS WorkflowProcessdefinitionId,workflowProcessdefinitionName
	--	,IsEncrypt,IsShow,IsDelete,IsEnabled,ControlName FROM #MenuTab	
	--	UNION ALL
	--	SELECT  CAST(tb.ID AS NVARCHAR(50)) AS ID,tb.UserId,tb.MenuName,tb.Sort,tb.Url,tb.Moduleflag,tb.Remark,tb.ParentId,tb.ParentName,
	--	CAST(tb.WorkflowProcessdefinitionId AS NVARCHAR(50)) WorkflowProcessdefinitionId,tb.workflowProcessdefinitionName,tb.IsEncrypt,tb.IsShow,tb.IsDelete,tb.IsEnabled,tb.ControlName
	--	FROM #AllMenu tb INNER JOIN temp  tm ON tm.ParentId = tb.ID  AND( tb.UserId = tm.UserId OR tb.ID = tm.ParentId)
	--)
	--select distinct * from temp

	WITH temp AS
	(
		SELECT CAST(ID AS NVARCHAR(50)) AS ID,UserId,MenuName,Sort,Url,Moduleflag,Remark,ParentId,ParentName,CAST(WorkflowProcessdefinitionId AS NVARCHAR(50))AS WorkflowProcessdefinitionId,workflowProcessdefinitionName
		,IsEncrypt,IsShow,IsDelete,IsEnabled,ControlName FROM #MenuTab	
	),
	ob as(
		SELECT  CAST(tb.ID AS NVARCHAR(50)) AS ID,tb.UserId,tb.MenuName,tb.Sort,tb.Url,tb.Moduleflag,tb.Remark,tb.ParentId,tb.ParentName,
		CAST(tb.WorkflowProcessdefinitionId AS NVARCHAR(50)) WorkflowProcessdefinitionId,tb.workflowProcessdefinitionName,tb.IsEncrypt,tb.IsShow,tb.IsDelete,tb.IsEnabled,tb.ControlName
		FROM #AllMenu tb INNER JOIN temp  tm ON tm.ParentId = tb.ID  AND( tb.UserId = tm.UserId OR tb.ID = tm.ParentId)
	),
	oc as(
		select * from ob UNION ALL (
		SELECT CAST(ID AS NVARCHAR(50)) AS ID,UserId,MenuName,Sort,Url,
		Moduleflag,Remark,ParentId,ParentName,CAST(WorkflowProcessdefinitionId AS NVARCHAR(50))AS 
		WorkflowProcessdefinitionId,workflowProcessdefinitionName,IsEncrypt,IsShow,IsDelete,IsEnabled,ControlName FROM #MenuTab	)
	)
	--select distinct * from oc 
	--select DISTINCT * from oc  where MenuName like '%系统管理%'
	SELECT DISTINCT * into #UserMenuTab FROM oc;
	
	/*菜单列表 -- 当前没过滤没有拥有Query 权限的菜单 */
	--SELECT DISTINCT * into #UserMenuTab FROM oc;
	--SELECT DISTINCT * into #UserMenuTab FROM temp;


	/* 菜单下的功能定义 */
	SELECT us.UserId,fd.Id ,fd.FeatureName,fd.FeatureID, md.ID AS 'MenuGuid',md.MenuName
			INTO #UserQueryPoweTab
			 FROM T_ESP_Sys_Menu md
			 LEFT JOIN  T_ESP_Sys_Menu mm ON md.ParentId =CAST(mm.ID AS NVARCHAR(50))
			 LEFT JOIN  T_ESP_Sys_WorkflowProcessDefinition wpd ON md.WorkflowProcessdefinitionId = CAST(wpd.Id AS NVARCHAR(50))
			 LEFT JOIN  T_ESP_Sys_QuickMenu qk ON qk.ChildMenu_GuID = md.Id
			 LEFT JOIN  T_ESP_Sys_FunctionDefinitions fd ON fd.Id = qk.Feature_GuID
			 LEFT JOIN  T_ESP_Sys_RoleFunction rf ON rf.MenuAs_GuID = qk.id
			 LEFT JOIN  T_ESP_Sys_Roles rs ON rs.Id = rf.Role_GuID
			 LEFT JOIN  T_ESP_Sys_UserRoles ur ON ur.Role_GuID =rs.Id
			 LEFT JOIN  T_ESP_Sys_Users us ON us.Id = ur.User_GuID
			 WHERE us.UserId =@userID;


	/* 非管理员，则需要按照Query权限来展示页面 */
	IF(@IsAdmin = 0 )
	BEGIN	
		/* 处理用户没有 查询权限时，整个菜单不给用，所以这里只拿到拥有Query 权限的菜单 */
		SELECT * INTO #poweList FROM #UserQueryPoweTab WHERE  FeatureID='Query'  ;

		/* 过滤掉当前没有Query 权限的菜单*/
		DELETE FROM #UserMenuTab WHERE id NOT IN(SELECT MenuGuid FROM #poweList) AND ISNULL(ParentId,'')!=''  AND ISNULL(UserId,'') !='';

		/*返回*****************菜单列表************************** */
		SELECT * FROM #UserMenuTab;

		/*返回 *************** 菜单下的功能定义****************** */
		SELECT * FROM #UserQueryPoweTab WHERE MenuGuid IN(SELECT MenuGuid FROM #poweList);

		DROP TABLE #poweList;
	END
	ELSE
	BEGIN
	/*  管理员不需要过滤其他功能   */
	/*返回*****************菜单列表************************** */
	SELECT * FROM #UserMenuTab;

	/*返回 *************** 菜单下的功能定义****************** */
	SELECT * FROM #UserQueryPoweTab ;

	END

	
	/*
	执行结束，删除临时表
	*/
	DROP TABLE #MenuTab;
	DROP TABLE #AllMenu;
	DROP TABLE #UserMenuTab;
	DROP TABLE #UserQueryPoweTab;
	

 END;
 	SET NOCOUNT OFF


GO

