USE [MES_MaterialDB]
GO

/****** Object:  UserDefinedFunction [dbo].[F_ESP_TableBase_Split]    Script Date: 2022/8/29 15:34:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================
-- Author:		Rison.li
-- Create date: 2022-06-2
-- Description:	分割字符串
-- ModifyLog: 
-- Example: SELECT * FROM dbo.F_ESP_Pub_Split('a;2;v;e;3;',';')
-- =============================================
*/
CREATE FUNCTION [dbo].[F_ESP_TableBase_Split]
    (
        @SplitString NVARCHAR (MAX),     --源字符串
        @Separator   NVARCHAR (10) = ' ' --分隔符号，默认为空格
    )
RETURNS @SplitStringsTable TABLE --输出的数据表
    ( [id] INT IDENTITY (1, 1), [value] NVARCHAR (MAX))
AS
    BEGIN
        DECLARE @CurrentIndex INT;
        DECLARE @NextIndex INT;
        DECLARE @ReturnText NVARCHAR (MAX);

        SELECT @CurrentIndex = 1;
        WHILE ( @CurrentIndex <= LEN ( @SplitString ))
            BEGIN
                SELECT @NextIndex = CHARINDEX ( @Separator, @SplitString, @CurrentIndex );
                IF ( @NextIndex = 0 OR @NextIndex IS NULL )
                    BEGIN
                        SELECT @NextIndex = LEN ( @SplitString ) + 1;
                    END;

                SELECT @ReturnText = SUBSTRING ( @SplitString, @CurrentIndex, @NextIndex - @CurrentIndex );
                INSERT INTO @SplitStringsTable ( [value] )
                VALUES
                ( REPLACE ( REPLACE ( LTRIM ( @ReturnText ), CHAR ( 10 ), '' ), CHAR ( 13 ), '' ));
                SELECT @CurrentIndex = @NextIndex + 1;
            END;
        RETURN;
    END;
GO

