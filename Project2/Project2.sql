USE BIClass8;
GO

CREATE SCHEMA [Process];
GO
CREATE SCHEMA [Project2];
GO
CREATE SCHEMA [DbSecurity];
GO

-- =========================================-==== 
-- Author: Kenneth Nguyen
-- Procedure: [Project2].[WorkFlowStepCounter] 
-- Create date: 04/01/2020
-- Description: Keeps track of the row number of a workflow step
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[WorkFlowStepCounter];
GO

CREATE PROCEDURE [Project2].[WorkFlowStepCounter]
AS
BEGIN

    DROP SEQUENCE Process.WorkFlowStepTableRowCountBy1;

    CREATE SEQUENCE Process.WorkFlowStepTableRowCountBy1
    AS INT
    START WITH 1
    INCREMENT BY 1;

END;

-- =============================================
-- Author: Tristen Aguilar
-- Procedure: [Project2].[CreateTrackWorkFlowStepsTable]
-- Create date: April 4th, 2020
-- Description: Creates the WorkFlowSteps where each stored procedure is tracked and listed
-- =============================================

GO
DROP PROCEDURE IF EXISTS [Project2].[CreateTrackWorkFlowStepsTable];

GO
CREATE PROCEDURE [Project2].[CreateTrackWorkFlowStepsTable] @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DROP TABLE IF EXISTS [Process].[WorkFlowSteps];

    CREATE TABLE [Process].[WorkFlowSteps]
    (
        WorkFlowStepKey INT NOT NULL IDENTITY(1, 1), -- primary key
        WorkFlowStepDescription NVARCHAR(100) NOT NULL,
        WorkFlowStepTableRowCount INT NULL
            DEFAULT (0),
        StartingDateTime DATETIME2(7) NULL
            DEFAULT (SYSDATETIME()),
        EndingDateTime DATETIME2(7) NULL
            DEFAULT (SYSDATETIME()),
        ClassTime CHAR(5) NULL
            DEFAULT ('07:45'),
        UserAuthorizationKey INT NOT NULL,
        CONSTRAINT PK_WorkFlowStep
            PRIMARY KEY (WorkFlowStepKey)
    );

    INSERT INTO Process.WorkFlowSteps
    (
        UserAuthorizationKey,
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount
    )
    VALUES
    (@GroupMemberUserAuthorizationKey, 'Created the Process.WorkFlowSteps table',
     NEXT VALUE FOR Process.WorkFlowStepTableRowCountBy1);

END;
GO

-- ========================================================================================================================= 
-- Author: Jordon Johnson
-- Procedure: [Process].[usp_TrackWorkFlow]
-- Create date: 04/04/2020
-- Description: This stored procedure creates work flow steps that allows us to efficiently track project tasks.    
-- =========================================================================================================================

DROP PROCEDURE IF EXISTS [Process].[usp_TrackWorkFlow];
GO

CREATE PROCEDURE [Process].[usp_TrackWorkFlow]
    @GroupMemberUserAuthorizationKey INT,
    @WorkFlowStepDescription NVARCHAR(100),
    @Start DATETIME2,
    @End DATETIME2
AS
BEGIN

    INSERT INTO [Process].[WorkFlowSteps]
    (
        WorkFlowStepDescription,
        UserAuthorizationKey,
        StartingDateTime,
        EndingDateTime,
        WorkFlowStepTableRowCount
    )
    VALUES
    (@WorkFlowStepDescription, @GroupMemberUserAuthorizationKey, @Start, @End,
     NEXT VALUE FOR Process.WorkFlowStepTableRowCountBy1);


END;
GO

-- ========================================================================================================================= 
-- Author: Brian Aguilar
-- Procedure: [Project2].[CreateUserAuthTable]
-- Create date: 04/04/2020
-- Description: Creates the UserAuthorization table  
-- =========================================================================================================================

DROP PROCEDURE IF EXISTS [Project2].[CreateUserAuthTable];
GO

CREATE PROCEDURE [Project2].[CreateUserAuthTable] @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;

    DROP TABLE IF EXISTS [DbSecurity].[UserAuthorization];

    CREATE TABLE [DbSecurity].[UserAuthorization]
    (
        UserAuthorizationKey INT NOT NULL PRIMARY KEY,
        ClassTime NCHAR(5) NULL
            DEFAULT ('7:45'),
        IndividualProject NVARCHAR(60) NULL
            DEFAULT ('PROJECT 2 RECREATE THE BICLASS DATABASE STAR SCHEMA'),
        GroupMemberLastName NVARCHAR(35) NOT NULL,
        GroupMemberFirstName NVARCHAR(25) NOT NULL,
        GroupName NVARCHAR(20) NOT NULL
            DEFAULT ('G7-3'),
        DateAdded DATETIME2 NULL
            DEFAULT (SYSDATETIME())
    );

    SELECT @t1 = SYSDATETIME();

    INSERT INTO [DbSecurity].[UserAuthorization]
    (
        UserAuthorizationKey,
        GroupMemberLastName,
        GroupMemberFirstName
    )
    VALUES
    (1, 'Nguyen', 'Kenneth'),
    (2, 'Aguilar', 'Tristen'),
    (3, 'Johnson', 'Jordon'),
    (4, 'Noor', 'Aliem'),
    (5, 'Ramnarain', 'Anthony'),
    (6, 'Chung', 'Minjung'),
    (@GroupMemberUserAuthorizationKey, 'Aguilar', 'Brian');

    SELECT @t2 = SYSDATETIME();

    EXEC Process.usp_TrackWorkFlow @GroupMemberUserAuthorizationKey = 7,
                                   @WorkFlowStepDescription = 'Created the [DbSecurity].[UserAuthorization] table',
                                   @Start = @t1,
                                   @End = @t2;

END;
GO

-- ========================================================================================================================= 
-- Author: Brian Aguilar
-- Procedure: [Project2].[AddDateTime]
-- Create date: 04/04/2020
-- Description: Adds the UserAuthorizationKey, DateAdded, and DateOfLastUpdate columns to the existing tables   
-- =========================================================================================================================
DROP PROCEDURE IF EXISTS [Project2].[AddDateTime];
GO

CREATE PROCEDURE [Project2].[AddDateTime] @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimCustomer]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimCustomer]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimCustomer]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimGender]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimGender]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimGender]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimMaritalStatus]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimMaritalStatus]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimMaritalStatus]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimOccupation]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimOccupation]'
    )
    BEGIN;
        ALTER TABLE [CH01-01-Dimension].[DimOccupation]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimOrderDate]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimOrderDate]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimOrderDate]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (1 - 99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimTerritory]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimTerritory]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimTerritory]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Dimension].[SalesManagers]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[SalesManagers]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[SalesManagers]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (-99),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[UserAuthorizationKey]'
              AND TABLE_NAME = '[CH01-01-Fact].[Data]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Fact].[Data]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD [UserAuthorizationKey] INT NOT NULL
                DEFAULT (1),
            DateAdded DATETIME2 NULL
                DEFAULT (SYSDATETIME()),
            DateOfLastUpdate DATETIME2 NULL
                DEFAULT (SYSDATETIME());
    END;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @GroupMemberUserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Added the UserAuthKey, DateAdded, DateOfLastupdate to all tables',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ========================================================================================================================= 
-- Author: Minjung Chung
-- Procedure: [Project2].[DropAllForeignKeys]
-- Create date: 04/05/2020
-- Description: Dropped all foreign keys from CH01-01-Fact.Data table.   
-- =========================================================================================================================

DROP PROCEDURE IF EXISTS [Project2].[DropAllForeignKeys];
GO

CREATE PROCEDURE [Project2].[DropAllForeignKeys] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    DECLARE @DropFKeys VARCHAR(MAX)
        =
            (
                SELECT 'alter table ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.'
                       + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' drop constraint ' + QUOTENAME(name) + ';'
                FROM sys.foreign_keys
                FOR XML PATH('')
            );
    EXEC (@DropFKeys);

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Drops all foreign keys',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Minjung Chung
-- Procedure: [Project2].[TruncateAllTables]
-- Create date: 04/05/2020
-- Description: Truncates all the tables
-- ==============================================

DROP PROCEDURE IF EXISTS [Project2].[TruncateAllTables];
GO


CREATE PROCEDURE [Project2].[TruncateAllTables] @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    TRUNCATE TABLE [CH01-01-Dimension].[DimCustomer];
    TRUNCATE TABLE [CH01-01-Dimension].[DimGender];
    TRUNCATE TABLE [CH01-01-Dimension].[DimMaritalStatus];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOccupation];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOrderDate];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProduct];
    TRUNCATE TABLE [CH01-01-Dimension].[DimTerritory];
    TRUNCATE TABLE [CH01-01-Dimension].[SalesManagers];
    TRUNCATE TABLE [CH01-01-Fact].[Data];

    SELECT @t2 = SYSDATETIME();

    EXEC Process.usp_TrackWorkFlow @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                   @WorkFlowStepDescription = 'Truncates all the pre-modified tables',
                                   @Start = @t1,
                                   @End = @t2;

END;
GO

-- ============================================= 
-- Author: Jordon Johnson
-- Procedure: [Project2].[CreateSequenceObjectsForTables]
-- Create date: 04/05/2020
-- Description: Drops existing sequences and creates new sequence objects in their place
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[CreateSequenceObjectsForTables];
GO

CREATE PROCEDURE [Project2].[CreateSequenceObjectsForTables] @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project2].[DimCustomerSequenceObject];
    DROP SEQUENCE IF EXISTS [Project2].[DimOccupationSequenceObject];
    DROP SEQUENCE IF EXISTS [Project2].[DimProductSequenceObject];
    DROP SEQUENCE IF EXISTS [Project2].[DimTerritorySequenceObject];
    DROP SEQUENCE IF EXISTS [Project2].[SalesManagersSequenceObject];
    DROP SEQUENCE IF EXISTS [Project2].[DataSequenceObject];

    CREATE SEQUENCE [Project2].[DimCustomerSequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    MINVALUE-2147483648;

    CREATE SEQUENCE [Project2].[DimOccupationSequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    MINVALUE-2147483648;

    CREATE SEQUENCE [Project2].[DimTerritorySequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    MINVALUE-2147483648;

    CREATE SEQUENCE [Project2].[SalesManagersSequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    MINVALUE-2147483648;

    CREATE SEQUENCE [Project2].[DataSequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 2147483647
    MINVALUE-2147483648;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Created Sequence Objects for the tables in the BIClass Database.',
                                       @Start = @t1,
                                       @End = @t2;
END;
GO

-- ============================================= 
-- Author: Tristen Aguilar
-- Procedure: [Project2].[AlterTableIdentityKeysToSequenceObjects] 
-- Create date: 04/09/2020
-- Description: Drops the PK constraints, then drops the column, and finally re-creates the column to a sequence object
-- =============================================
DROP PROCEDURE IF EXISTS [Project2].[AlterTableIdentityKeysToSequenceObjects];
GO

CREATE PROCEDURE [Project2].[AlterTableIdentityKeysToSequenceObjects] @UserAuthorizationKey INT
AS
BEGIN
    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME(),
           @t2 = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Altered the PKs of various tables to Sequence Objects',
                                       @Start = @t1,
                                       @End = @t2;

    -- DROPS THE PK CONSTRAINTS AND THE PK COLUMN
    ALTER TABLE [CH01-01-Dimension].[DimCustomer]
    DROP CONSTRAINT PK__DimCusto__95011E644B0393BD,
         COLUMN [CustomerKey];

    ALTER TABLE [CH01-01-Dimension].[DimCustomer]
    ADD CustomerKey INT NOT NULL PRIMARY KEY
            DEFAULT 0;

    ALTER TABLE [CH01-01-Dimension].[DimOccupation]
    DROP CONSTRAINT PK__DimOccup__742667DA5F461D35,
         COLUMN [OccupationKey];

    ALTER TABLE [CH01-01-Dimension].[DimOccupation]
    ADD OccupationKey INT NOT NULL PRIMARY KEY
            DEFAULT 0;

    ALTER TABLE [CH01-01-Dimension].[DimProduct]
    DROP CONSTRAINT PK__DimProdu__3D21635C3B1A0109,
         COLUMN ProductKey;

    ALTER TABLE [CH01-01-Dimension].[DimProduct]
    ADD ProductKey INT NOT NULL PRIMARY KEY
            DEFAULT 0;

    ALTER TABLE [CH01-01-Dimension].[DimTerritory]
    DROP CONSTRAINT PK__DimTerri__C54B735DCD01EA76,
         COLUMN TerritoryKey;

    ALTER TABLE [CH01-01-Dimension].[DimTerritory]
    ADD TerritoryKey INT NOT NULL PRIMARY KEY
            DEFAULT 0;

    ALTER TABLE [CH01-01-Dimension].[SalesManagers]
    DROP CONSTRAINT PK__SalesMan__B619AC133431C719,
         COLUMN [SalesManagerKey];

    ALTER TABLE [CH01-01-Dimension].[SalesManagers]
    ADD SalesManagerKey INT NOT NULL PRIMARY KEY
            DEFAULT 0;

    ALTER TABLE [CH01-01-Fact].[Data]
    DROP CONSTRAINT PK_Data,
         COLUMN [SalesKey];

    ALTER TABLE [CH01-01-Fact].[Data] ADD SalesKey INT NOT NULL DEFAULT 0;

END;
GO

-- ============================================= 
-- Author: Aliem Al Noor
-- Procedure: [Project2].[LoadDimCustomer]
-- Create date: 04/08/2020
-- Description: Loads the DimCustomer data from the FileUpload.OriginallyLoadedData 
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimCustomer];
GO

CREATE PROCEDURE [Project2].[LoadDimCustomer] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    -- Insert into the customer table including the user auth key
    INSERT INTO [CH01-01-Dimension].[DimCustomer]
    (
        CustomerKey,
        CustomerName,
        UserAuthorizationKey
    )
    SELECT NEXT VALUE FOR [Project2].[DimCustomerSequenceObject] AS CustomerKey,
           C.CustomerName,
           @UserAuthorizationKey
    FROM
    (SELECT DISTINCT CustomerName FROM FileUpload.OriginallyLoadedData) AS C;

    SELECT @t2 = SYSDATETIME();

    --  Insert the user into the Process.WorkFlowTable
    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loading data into DimCustomer table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author:  Anthony Ramnarain
-- Procedure: [Project2].[LoadDimMaritalStatus]
-- Create date: 04/07/2020
-- Description: Loads the DimMaritalStatus data from the FileUpload.OriginallyLoadedData 
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimMaritalStatus];
GO

CREATE PROCEDURE [Project2].[LoadDimMaritalStatus] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimMaritalStatus]
    (
        [MaritalStatus],
        [MaritalStatusDescription],
        UserAuthorizationKey
    )
    SELECT DISTINCT
           old.MaritalStatus,
           CASE
               WHEN old.MaritalStatus = 'M' THEN
                   'Married'
               ELSE
                   'Single'
           END AS MaritalStatusDescription,
           @UserAuthorizationKey
    FROM FileUpload.OriginallyLoadedData AS old;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loading Data into the DimMaritalStatus Table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project2].[LoadDimGender]
-- Create date: 04/06/2020
-- Description: Loads the DimGender data from the FileUpload.OriginallyLoadedData 
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimGender];
GO

CREATE PROCEDURE [Project2].[LoadDimGender] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimGender]
    (
        Gender,
        GenderDescription,
        UserAuthorizationKey
    )
    SELECT DISTINCT
           old.Gender,
           CASE
               WHEN old.Gender = 'M' THEN
                   'Male'
               ELSE
                   'Female'
           END AS GenderDescription,
           @UserAuthorizationKey
    FROM FileUpload.OriginallyLoadedData AS old;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loading Gender data into Gender Table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Brian Aguilar
-- Procedure: [Project2].[LoadDimOccupation]
-- Create date: 04/05/2020
-- Description: Loads the DimOccupation data from the FileUpload.OriginallyLoadedData 
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimOccupation];
GO

CREATE PROCEDURE [Project2].[LoadDimOccupation] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimOccupation]
    (
        OccupationKey,
        Occupation,
        UserAuthorizationKey
    )
    SELECT NEXT VALUE FOR [Project2].[DimOccupationSequenceObject],
           O.Occupation,
           @UserAuthorizationKey
    FROM
    (SELECT DISTINCT Occupation FROM FileUpload.OriginallyLoadedData) AS O;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @WorkFlowStepDescription = 'Loading data into the DimOccupation Table',
                                       @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Minjung Chung
-- Procedure: [Project2].[LoadDimOrderDate]
-- Create date: 04/05/2020
-- Description: Loads the DimOrderDate data from the FileUpload.OriginallyLoadedData 
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimOrderDate];
GO

CREATE PROCEDURE [Project2].[LoadDimOrderDate] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimOrderDate]
    (
        OrderDate,
        MonthName,
        MonthNumber,
        [Year],
        UserAuthorizationKey
    )
    SELECT DISTINCT
           OrderDate,
           MonthName,
           MonthNumber,
           [Year],
           @UserAuthorizationKey
    FROM FileUpload.OriginallyLoadedData;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @WorkFlowStepDescription = 'Loading data into the DimOrderDate Table',
                                       @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Jordon Johnson
-- Procedure: [Project2].[LoadDimTerritory]
-- Create date: 04/05/2020
-- Description: Loads territory data from the FileUpload.OriginallyLoadedData tablr
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadDimTerritory];
GO

CREATE PROCEDURE [Project2].[LoadDimTerritory] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimTerritory]
    (
        TerritoryKey,
        TerritoryGroup,
        TerritoryCountry,
        TerritoryRegion,
        UserAuthorizationKey
    )
    SELECT NEXT VALUE FOR [Project2].[DimTerritorySequenceObject],
           TerritoryGroup,
           TerritoryCountry,
           TerritoryRegion,
           @UserAuthorizationKey
    FROM
    (
        SELECT DISTINCT
               TerritoryGroup,
               TerritoryCountry,
               TerritoryRegion
        FROM [FileUpload].OriginallyLoadedData
    ) AS T;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loading data into the DimTerritory Table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Tristen Aguilar
-- Procedure: [Project2].[LoadSalesManagers]
-- Create date: 04/05/2020
-- Description: Loads Sales Managers data from the FileUpload.OriginallyLoadedData table
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadSalesManagers];
GO

CREATE PROCEDURE [Project2].[LoadSalesManagers] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[SalesManagers]
    (
        SalesManagerKey,
        Category,
        SalesManager,
        Office,
        UserAuthorizationKey
    )
    SELECT NEXT VALUE FOR [Project2].[SalesManagersSequenceObject] AS SalesManagerKey,
           ProductCategory AS Category,
           SalesManager,
           Office = CASE
                        WHEN SalesManager LIKE N'Maurizio%'
                             OR SalesManager LIKE N'Marco%' THEN
                            'Redmond'
                        WHEN SalesManager LIKE N'Alberto%'
                             OR SalesManager LIKE N'Luis%' THEN
                            'Seattle'
                        ELSE
                            NULL
                    END,
           @UserAuthorizationKey
    FROM
    (
        SELECT DISTINCT
               ProductCategory,
               SalesManager
        FROM FileUpload.OriginallyLoadedData
    ) AS S;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loading data into the Sales Managers Table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- =============================================
-- Author:		Aliem Al Noor
-- Procedure:	[Project2].[CreateAndLoadProductCategory]
-- Create date: April 4th, 2020
-- Description:	Creates and loads the [CH01-01-Dimension].[DimProductCategory] table 
-- =============================================

--GRANDPARENT
DROP PROCEDURE IF EXISTS [Project2].[CreateAndLoadProductCategory];
GO

CREATE PROCEDURE [Project2].[CreateAndLoadProductCategory] @UserAuthorizationKey INT
AS
BEGIN

    DROP SEQUENCE IF EXISTS [Project2].[DimProductCategorySequenceObject];
    CREATE SEQUENCE [Project2].[DimProductCategorySequenceObject]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory];
    CREATE TABLE [CH01-01-Dimension].[DimProductCategory]
    (
        ProductCategoryKey INT NOT NULL PRIMARY KEY,
        ProductCategory VARCHAR(20) NULL
    );

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductCategory]
    (
        ProductCategoryKey,
        ProductCategory
    )
    SELECT NEXT VALUE FOR [Project2].[DimProductCategorySequenceObject],
           OLD.ProductCategory
    FROM
    (
        SELECT DISTINCT
               ProductCategory
        FROM FileUpload.OriginallyLoadedData
    ) AS OLD;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Creates and loads the [CH01-01-Dimension].[DimProductCategory] table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project2].[CreateAndLoadProductSubcategory]
-- Create date: 04/03/2020
-- Description: Creates and loads the [CH01-01-Dimension].[DimProductSubcategory] table 
-- =============================================

--PARENT
DROP PROCEDURE IF EXISTS [Project2].[CreateAndLoadProductSubcategory];
GO

CREATE PROCEDURE [Project2].[CreateAndLoadProductSubcategory] @UserAuthorizationKey INT
AS
BEGIN

    DROP SEQUENCE IF EXISTS [Project2].[ProductSubcategorySequenceObject];

    CREATE SEQUENCE [Project2].[ProductSubcategorySequenceObject]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory];

    CREATE TABLE [CH01-01-Dimension].[DimProductSubcategory]
    (
        [ProductSubcategoryKey] INT NOT NULL PRIMARY KEY,
        [ProductCategoryKey] INT NOT NULL,
        CONSTRAINT FK_DimProductCategory
            FOREIGN KEY (ProductCategoryKey)
            REFERENCES [CH01-01-Dimension].DimProductCategory (ProductCategoryKey),
        ProductSubcategory VARCHAR(20) NULL
    );

    -- Insert statements for procedure here
    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductSubcategory]
    (
        [ProductSubcategoryKey],
        [ProductCategoryKey],
        [ProductSubcategory]
    )
    SELECT NEXT VALUE FOR [Project2].[ProductSubcategorySequenceObject],
           SPS.ProductCategoryKey,
           SPS.ProductSubcategory
    FROM
    (
        SELECT DISTINCT
               old.ProductSubcategory,
               old.ProductCategory,
               dspc.ProductCategoryKey
        FROM FileUpload.OriginallyLoadedData AS old
            INNER JOIN [CH01-01-Dimension].[DimProductCategory] AS dspc
                ON old.ProductCategory = dspc.ProductCategory
    ) AS SPS;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Creates and loads the [CH01-01-Dimension].[DimProductSubcategory] table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project2].[CreateAndLoadProduct]
-- Create date: April 3rd, 2020
-- Description: Alters the [CH01-01-Dimension].[DimProduct] by adding new keys and columns
-- =============================================

--CHILD
DROP PROCEDURE IF EXISTS [Project2].[CreateAndLoadProduct];
GO

CREATE PROCEDURE [Project2].[CreateAndLoadProduct] @UserAuthorizationKey INT
AS
BEGIN

    DROP SEQUENCE IF EXISTS [Project2].[DimProductSequenceObject];
    CREATE SEQUENCE [Project2].[DimProductSequenceObject]
    START WITH 1
    INCREMENT BY 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = '[ProductCategory]'
              OR COLUMN_NAME = 'ProductSubcategory'
                 AND TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
        DROP COLUMN ProductCategory,
             ProductSubcategory;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME = 'ProductSubcategoryKey'
              AND TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
       AND EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '[CH01-01-Dimension].[DimProduct]'
    )
    BEGIN
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD ProductSubcategoryKey INT NOT NULL
                DEFAULT (-1) CONSTRAINT FK_DimProductSubcategoryKey
                FOREIGN KEY (ProductSubcategoryKey) REFERENCES [CH01-01-Dimension].[DimProductSubcategory]
                (ProductSubcategoryKey);
    END;

    SET NOCOUNT ON;

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProduct]
    (
        ProductKey,
        ProductSubcategoryKey,
        ProductCode,
        ProductName,
        Color,
        ModelName
    )
    SELECT NEXT VALUE FOR [Project2].[DimProductSequenceObject],
           NEW.ProductSubcategoryKey,
           NEW.ProductCode,
           NEW.ProductName,
           NEW.Color,
           NEW.ModelName
    FROM
    (
        SELECT DISTINCT
               DPC.ProductSubcategoryKey,
               OLD.ProductCode,
               OLD.ProductName,
               OLD.Color,
               OLD.ModelName
        FROM FileUpload.OriginallyLoadedData AS OLD
            INNER JOIN [CH01-01-Dimension].[DimProductSubcategory] AS DPC
                ON DPC.ProductSubcategory = OLD.ProductSubcategory
    ) AS NEW;

    SELECT DP.ProductKey,
           DP.ProductCode,
           DP.ProductName,
           DP.Color,
           DP.ModelName,
           DPC.ProductSubcategoryKey
    FROM [CH01-01-Dimension].[DimProduct] AS DP
        INNER JOIN [CH01-01-Dimension].[DimProductSubcategory] AS DPC
            ON DP.ProductSubcategoryKey = DPC.ProductSubcategoryKey;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Creates and loads the [CH01-01-Dimension].[DimProduct] table',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO
----------------------------------------------------
-- ============================================= 
-- Author: Aliem Al Noor
-- Procedure: [Project2].[LoadData]
-- Create date: 04/05/2020
-- Description: Alters the columns in the CH01-01-Fact.Data table with their proper Foreign Key constraints
-- =============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadData];
GO

CREATE PROCEDURE [Project2].[LoadData] @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    DROP SEQUENCE IF EXISTS Project2.DataSequenceObject;
    CREATE SEQUENCE [Project2].[DataSequenceObject]
    START WITH 1
    INCREMENT BY 1;

    INSERT INTO [CH01-01-Fact].[Data]
    (
        SalesKey,
        SalesManagerKey,
        OccupationKey,
        TerritoryKey,
        ProductKey,
        CustomerKey,
        ProductCategory,
        SalesManager,
        ProductSubcategory,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        OrderQuantity,
        UnitPrice,
        ProductStandardCost,
        SalesAmount,
        OrderDate,
        MonthName,
        [Year],
        CustomerName,
        MaritalStatus,
        Gender,
        Education,
        Occupation,
        TerritoryRegion,
        TerritoryCountry,
        TerritoryGroup
    )
    SELECT NEXT VALUE FOR [Project2].[DataSequenceObject],
           SM.SalesManagerKey,
           DO.OccupationKey,
           DT.TerritoryKey,
           DP.ProductKey,
           DC.CustomerKey,
           OLD.ProductCategory,
           OLD.SalesManager,
           OLD.ProductSubcategory,
           OLD.ProductCode,
           OLD.ProductName,
           OLD.Color,
           OLD.ModelName,
           OLD.OrderQuantity,
           OLD.UnitPrice,
           OLD.ProductStandardCost,
           OLD.SalesAmount,
           OLD.OrderDate,
           OLD.MonthName,
           OLD.[Year],
           OLD.CustomerName,
           OLD.MaritalStatus,
           OLD.Gender,
           OLD.Education,
           OLD.Occupation,
           OLD.TerritoryRegion,
           OLD.TerritoryCountry,
           OLD.TerritoryGroup
    FROM FileUpload.OriginallyLoadedData AS OLD
        INNER JOIN [CH01-01-Dimension].[SalesManagers] AS SM
            ON SM.SalesManager = OLD.SalesManager
        INNER JOIN [CH01-01-Dimension].[DimOccupation] AS DO
            ON DO.Occupation = OLD.Occupation
        INNER JOIN [CH01-01-Dimension].[DimTerritory] AS DT
            ON DT.TerritoryGroup = OLD.TerritoryGroup
               AND DT.TerritoryCountry = OLD.TerritoryCountry
               AND DT.TerritoryRegion = OLD.TerritoryRegion
        INNER JOIN [CH01-01-Dimension].[DimProduct] AS DP
            ON DP.ProductName = OLD.ProductName
        INNER JOIN [CH01-01-Dimension].[DimCustomer] AS DC
            ON DC.CustomerName = OLD.CustomerName;

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Loaded the Fact.Data table with data',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Anthony Ramnarain
-- Procedure: [Project2].[AddForeignKeysToNewlyModifiedTables]
-- Create date: 04/05/2020
-- Description: Adds foreign keys to the modified tables 
-- ==============================================

DROP PROCEDURE IF EXISTS [Project2].[AddForeignKeysToNewlyModifiedTables];
GO

CREATE PROCEDURE [Project2].[AddForeignKeysToNewlyModifiedTables] @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2;

    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_DimCustomer_Data
        FOREIGN KEY (CustomerKey)
        REFERENCES [CH01-01-Dimension].[DimCustomer] (CustomerKey),
        CONSTRAINT FK_DimGender_Data
        FOREIGN KEY (Gender)
        REFERENCES [CH01-01-Dimension].[DimGender] (Gender),
        CONSTRAINT FK_DimMaritalStatus_Data
        FOREIGN KEY (MaritalStatus)
        REFERENCES [CH01-01-Dimension].[DimMaritalStatus] (MaritalStatus),
        CONSTRAINT FK_DimOccupation_Data
        FOREIGN KEY (OccupationKey)
        REFERENCES [CH01-01-Dimension].[DimOccupation] (OccupationKey),
        CONSTRAINT FK_DimOrderDate_Data
        FOREIGN KEY (OrderDate)
        REFERENCES [CH01-01-Dimension].[DimOrderDate] (OrderDate),
        CONSTRAINT FK_DimProduct_Data
        FOREIGN KEY (ProductKey)
        REFERENCES [CH01-01-Dimension].[DimProduct] (ProductKey),
        CONSTRAINT FK_DimTerritory_Data
        FOREIGN KEY (TerritoryKey)
        REFERENCES [CH01-01-Dimension].[DimTerritory] (TerritoryKey),
        CONSTRAINT FK_SalesManager_Data
        FOREIGN KEY (SalesManagerKey)
        REFERENCES [CH01-01-Dimension].[SalesManagers] (SalesManagerKey);

    SELECT @t1 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Added Foreign Key relationships to the Fact.Data table',
                                       @Start = @t1,
                                       @End = @t1;

END;
GO

-- ============================================= 
-- Author: Anthony Ramnarain
-- Procedure: Process.usp_ShowWorkFlowSteps
-- Create date: 04/01/2020
-- Description: Shows all steps from TrackWorkFlow table
-- ==============================================

DROP PROCEDURE IF EXISTS Process.usp_ShowWorkFlowSteps;
GO
CREATE PROCEDURE Process.usp_ShowWorkFlowSteps @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2;
    SELECT @t1 = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Shows all steps from TrackWorkFlow table',
                                       @Start = @t1,
                                       @End = @t1;

    SELECT WorkFlowStepKey,
           WorkFlowStepDescription,
           WorkFlowStepTableRowCount,
           StartingDateTime,
           EndingDateTime,
           ClassTime,
           UserAuthorizationKey
    FROM [Process].[WorkFlowSteps];

END;
GO

-- ============================================= 
-- Author: Aliem Al Ramnarain
-- Procedure: Process.usp_TotalExecutionTime
-- Create date: 04/10/2020
-- Description: Shows all steps from TrackWorkFlow table
-- ==============================================
DROP PROCEDURE Process.usp_TotalExecutionTime;
GO
CREATE PROCEDURE Process.usp_TotalExecutionTime @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    SELECT DATEDIFF(MILLISECOND, MIN(StartingDateTime), MAX(EndingDateTime)) AS [Total Execution Time to Load the Star Schema]
    FROM [Process].[WorkFlowSteps];

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Returns the total execution time to load the Star Schema',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Aliem Al Ramnarain
-- Procedure: Process.usp_MemberExecutionTime
-- Create date: 04/10/2020
-- Description: Shows all steps from TrackWorkFlow table
-- ==============================================
DROP PROCEDURE Process.usp_MemberExecutionTime;
GO
CREATE PROCEDURE Process.usp_MemberExecutionTime @UserAuthorizationKey INT
AS
BEGIN

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    SELECT CONCAT(UA.GroupMemberFirstName, ' ', UA.GroupMemberLastName) AS [Group Member],
           COUNT(WS.UserAuthorizationKey) AS [Number of Stored Procedures Executed],
           SUM(DATEDIFF(MILLISECOND, WS.StartingDateTime, WS.EndingDateTime)) AS [Total Execution Time]
    FROM Process.WorkFlowSteps AS WS
        INNER JOIN [DbSecurity].[UserAuthorization] AS UA
            ON UA.UserAuthorizationKey = WS.UserAuthorizationKey
    GROUP BY CONCAT(UA.GroupMemberFirstName, ' ', UA.GroupMemberLastName);

    SELECT @t2 = SYSDATETIME();

    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = @UserAuthorizationKey,
                                       @WorkFlowStepDescription = 'Returns the total execution time for each team members stored procedure',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project2].[LoadStarSchema]
-- Create date: 04/01/2020
-- Description: Loads the Star Schema with all modified tables
-- ==============================================

DROP PROCEDURE IF EXISTS [Project2].[LoadStarSchema];
GO

CREATE PROCEDURE [Project2].[LoadStarSchema]
AS
BEGIN

    DECLARE @t1 DATETIME2,
            @t2 DATETIME2;
    SELECT @t1 = SYSDATETIME();

    EXEC [Project2].[WorkFlowStepCounter];
    EXEC [Project2].[CreateTrackWorkFlowStepsTable] @GroupMemberUserAuthorizationKey = 2;
    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = 3,
                                       @WorkFlowStepDescription = 'Created the TrackWorkFlow stored procedure',
                                       @Start = @t1,
                                       @End = @t1;
    EXEC [Project2].[CreateUserAuthTable] @GroupMemberUserAuthorizationKey = 7;
    EXEC [Project2].[AddDateTime] @GroupMemberUserAuthorizationKey = 7;

    -- Drops all foreign keys in Fact.Data table
    EXEC [Project2].[DropAllForeignKeys] @UserAuthorizationKey = 6;

    -- Truncate all tables
    EXEC [Project2].[TruncateAllTables] @UserAuthorizationKey = 6;

    -- Counts all rows in every table
    EXEC [Project2].[CreateSequenceObjectsForTables] @UserAuthorizationKey = 3;
    EXEC [Project2].[AlterTableIdentityKeysToSequenceObjects] @UserAuthorizationKey = 2;

    -- Load each tables data into the appropriate table
    EXEC [Project2].[LoadSalesManagers] @UserAuthorizationKey = 2;
    EXEC [Project2].[LoadDimGender] @UserAuthorizationKey = 1;
    EXEC [Project2].[LoadDimMaritalStatus] @UserAuthorizationKey = 5;
    EXEC [Project2].[LoadDimOccupation] @UserAuthorizationKey = 7;
    EXEC [Project2].[LoadDimOrderDate] @UserAuthorizationKey = 6;
    EXEC [Project2].[LoadDimTerritory] @UserAuthorizationKey = 3;
    EXEC [Project2].[LoadDimCustomer] @UserAuthorizationKey = 4;
    EXEC [Project2].[CreateAndLoadProductCategory] @UserAuthorizationKey = 4;
    EXEC [Project2].[CreateAndLoadProductSubcategory] @UserAuthorizationKey = 1;
    EXEC [Project2].[CreateAndLoadProduct] @UserAuthorizationKey = 1;
    EXEC [Project2].[LoadData] @UserAuthorizationKey = 4;

    --  Setup all of the Foreign Key relationships
    EXEC [Project2].[AddForeignKeysToNewlyModifiedTables] @UserAuthorizationKey = 5;

    SELECT @t2 = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @GroupMemberUserAuthorizationKey = 1,
                                       @WorkFlowStepDescription = 'Loads the Star Schema',
                                       @Start = @t1,
                                       @End = @t2;

END;
GO

EXEC [Project2].[LoadStarSchema];

EXEC Process.usp_TotalExecutionTime @UserAuthorizationKey = 4;
EXEC Process.usp_MemberExecutionTime @UserAuthorizationKey = 4;
EXEC Process.usp_ShowWorkFlowSteps @UserAuthorizationKey = 5;

