CREATE SCHEMA Process;
GO
CREATE SCHEMA [QCClass];
GO
CREATE SCHEMA [Project3];
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Process].[usp_CreateWorkFlowStepTableRowCountSequenceObject]
-- Create date: 05/01/2020
-- Description: Creates the Sequence Object for the WorkFlowStepTableRowCount in the WorkFlowSteps Table 
-- =============================================

DROP PROCEDURE IF EXISTS [Process].[usp_CreateWorkFlowStepTableRowCountSequenceObject];
GO

CREATE PROCEDURE [Process].[usp_CreateWorkFlowStepTableRowCountSequenceObject]
AS
BEGIN

    SET NOCOUNT ON;

    DROP SEQUENCE IF EXISTS [Process].[WorkFlowStepTableRowCountBy1];
    CREATE SEQUENCE [Process].[WorkFlowStepTableRowCountBy1]
    START WITH 1
    INCREMENT BY 1;

END;
GO


-- =========================================-==== 
-- Author: Anthony Ramnarain
-- Procedure: [Process].[CreateWorkFlowStepsTable]
-- Create date: 05/04/2020
-- Description: Truncates all the tables
-- =============================================

DROP PROCEDURE IF EXISTS [Process].[usp_CreateWorkFlowStepsTable];
GO

CREATE PROCEDURE [Process].[usp_CreateWorkFlowStepsTable]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();


    DROP TABLE IF EXISTS [Process].[WorkFlowSteps];
    CREATE TABLE [Process].[WorkFlowSteps]
    (
        [WorkFlowStepKey] INT IDENTITY(1, 1) NOT NULL,
        [WorkFlowStepDescription] [NVARCHAR](100) NOT NULL,
        [WorkFlowStepTableRowCount] INT NULL,
        [StartingDateTime] [DATETIME2](7) NULL
            DEFAULT SYSDATETIME(),
        [EndingDateTime] [DATETIME2](7) NULL
            DEFAULT SYSDATETIME(),
        [ClassTime] [CHAR](5) NULL
            DEFAULT ('7:45'),
        [LastName] [VARCHAR](30) NULL
            DEFAULT ('Ramnarain'),
        [FirstName] [VARCHAR](30) NULL
            DEFAULT ('Anthony'),
        [GroupName] [VARCHAR](30) NULL
            DEFAULT ('G7-3'),
        PRIMARY KEY CLUSTERED ([WorkFlowStepKey] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
    ) ON [PRIMARY];

    INSERT INTO [Process].WorkFlowSteps
    (
        StartingDateTime,
        EndingDateTime,
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount
    )
    VALUES
    (@StartTime, SYSDATETIME(), 'Created the Work Flow Steps table.',
     NEXT VALUE FOR [Process].WorkFlowStepTableRowCountBy1);

END;
GO

-- =========================================-==== 
-- Author: Jordon Johnson
-- Procedure: [Process].[usp_TrackWorkFlow]
-- Create date: 05/07/2020
-- Description: Creates a stored procedure to track the workflow
-- =============================================

GO
DROP PROCEDURE IF EXISTS [Process].[usp_TrackWorkFlow];
GO
CREATE PROCEDURE [Process].[usp_TrackWorkFlow]
    @StartTime DATETIME2(7),
    @EndingTime DATETIME2(7),
    @WorkFlowDescription NVARCHAR(100),
    @LastName [VARCHAR](30),
    @FirstName [VARCHAR](30)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Process].[WorkFlowSteps]
    (
        StartingDateTime,
        EndingDateTime,
        WorkFlowStepDescription,
        LastName,
        FirstName,
        WorkFlowStepTableRowCount
    )
    VALUES
    (@StartTime, @EndingTime, @WorkFlowDescription, @LastName, @FirstName,
     NEXT VALUE FOR [Process].WorkFlowStepTableRowCountBy1);

END;
GO

-- ============================================= 
-- Author: Tristen Aguilar
-- Procedure: [Project3].[DropAllForeignKeyConstraints]
-- Create date: 05/04/2020
-- Description: Truncates all the tables
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[DropAllForeignKeyConstraints];
GO

CREATE PROCEDURE [Project3].[DropAllForeignKeyConstraints]
AS
BEGIN

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    ALTER TABLE QCClass.[InstructorDepartment]
    DROP CONSTRAINT IF EXISTS FK_Department,
                       FK_Instructor;

    ALTER TABLE QCClass.[BuildingRoom]
    DROP CONSTRAINT IF EXISTS FK_BuildingLocation,
                       FK_RoomLocation;

    ALTER TABLE QCClass.[Class]
    DROP CONSTRAINT IF EXISTS FK_Time,
                       FK_InstructorClass,
                       FK_BuildingRoom,
                       FK_Course,
                       FK_ModeOfInstruction;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Aguilar',
                                       @FirstName = 'Tristen',
                                       @WorkFlowDescription = 'Drops all foreign keys.';

END;
GO

-- =========================================-==== 
-- Author: Kenneth Nguyen
-- Procedure: [Project3].[TruncateAllTables]
-- Create date: 05/04/2020
-- Description: Truncates all the tables
-- =============================================

GO
DROP PROCEDURE IF EXISTS [Project3].[TruncateAllTables];

GO
CREATE PROCEDURE [Project3].[TruncateAllTables]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE [QCClass].[BuildingLocation];
    TRUNCATE TABLE [QCClass].[Class];
    TRUNCATE TABLE [QCClass].[Course];
    TRUNCATE TABLE [QCClass].[Department];
    TRUNCATE TABLE [QCClass].[Instructor];
    TRUNCATE TABLE [QCClass].[ModeOfInstruction];
    TRUNCATE TABLE [QCClass].[RoomLocation];
	TRUNCATE TABLE [QCClass].[InstructorDepartment];
	TRUNCATE TABLE [QCClass].[BuildingRoom];
	TRUNCATE TABLE [QCClass].[Time];

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Nguyen',
                                       @FirstName = 'Kenneth',
                                       @WorkFlowDescription = 'Truncated all tables.';

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project3].[CreateAndLoadTimeTable]
-- Create date: 05/08/2020
-- Description: Creates and loads the Time Table. 
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadTimeTable];
GO

CREATE PROCEDURE [Project3].[CreateAndLoadTimeTable]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE [Project3].[SequenceObjectForTimeId];
    CREATE SEQUENCE [Project3].[SequenceObjectForTimeId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS QCClass.[Time];
    CREATE TABLE QCClass.[Time]
    (
        TimeID INT NOT NULL,
        ClassStartingTime NVARCHAR(20) NULL,
        ClassEndingTime NVARCHAR(20) NULL,
        ClassDay NVARCHAR(9) NULL,
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Nguyen') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Kenneth') NOT NULL,
        GroupName VARCHAR(30)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT
            DEFAULT (1) NOT NULL,
        CONSTRAINT PK_Time
            PRIMARY KEY (TimeID)
    );

    INSERT INTO QCClass.[Time]
    (
        TimeID,
        ClassStartingTime,
        ClassEndingTime,
        ClassDay
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForTimeId],
           StartingTime,
           EndingTime,
           [Day]
    FROM
    (
        SELECT DISTINCT
               SUBSTRING([Time], 0, CHARINDEX('-', [Time])) AS StartingTime,
               SUBSTRING([Time], CHARINDEX('M', [Time]) + 4, LEN([Time])) AS [EndingTime],
               [Day]
        FROM groupnUploadfile.CoursesSpring2017
    ) AS Result;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Nguyen',
                                       @FirstName = 'Kenneth',
                                       @WorkFlowDescription = 'Creates and loads the Time Table. ';
END;
GO

-- =========================================-==== 
-- Author: Kenneth Nguyen
-- Procedure: [Project3].[CreateAndLoadDepartmentTable]
-- Create date: 05/02/2020
-- Description: Creates and loads the new Department table
-- =============================================

GO
DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadDepartmentTable];

GO
CREATE PROCEDURE [Project3].[CreateAndLoadDepartmentTable] 
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForDepartmentId];
    CREATE SEQUENCE [Project3].[SequenceObjectForDepartmentId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS [QCClass].[Department];

    CREATE TABLE [QCClass].[Department]
    (
        DepartmentID INT NOT NULL,
        Department NVARCHAR(MAX) NULL,
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Nguyen') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Kenneth') NOT NULL,
        GroupName VARCHAR(30)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT
            DEFAULT (1) NOT NULL,
        CONSTRAINT PK_Department
            PRIMARY KEY (DepartmentID)
    );

    INSERT INTO [QCClass].[Department]
    (
        [DepartmentID],
        [Department]
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForDepartmentId],
           OD.D
    FROM
    (
        SELECT DISTINCT
               SUBSTRING([Course (hr, crd)], 0, CHARINDEX(' ', [Course (hr, crd)])) AS D
        FROM groupnUploadfile.CoursesSpring2017
        WHERE LEN([Course (hr, crd)]) > 0
    ) AS OD;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Nguyen',
                                       @FirstName = 'Kenneth',
                                       @WorkFlowDescription = 'Creates and loads the new Department table.';

END;
GO


-- ============================================= 
-- Author: Aliem Al Noor
-- Procedure: [Project3].[CreateAndLoadModeOfInstructionTable]
-- Create date: 5/5/2020
-- Description: Creates and loads [Project3].[ModeOfInstruction] Table
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadModeOfInstructionTable];
GO

CREATE PROCEDURE [Project3].[CreateAndLoadModeOfInstructionTable]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP TABLE IF EXISTS [QCClass].[ModeOfInstruction];

    --CREATION OF SEQUENCE OBJECT
    DROP SEQUENCE IF EXISTS [Project3].[ModeOfInstructionSequenceObject];
    CREATE SEQUENCE [Project3].[ModeOfInstructionSequenceObject]
    AS INT
    START WITH 1
    INCREMENT BY 1;

    --CREATION OF [QCClass].[ModeOfInstruction] TABLE
    CREATE TABLE [QCClass].[ModeOfInstruction]
    (
        [ModeID] INT IDENTITY(1, 1) NOT NULL,
        [ModeOfInstruction] VARCHAR(50) NULL,
        [ClassTime] CHAR(5) NOT NULL
            DEFAULT ('7:45'),
        [LastName] VARCHAR(30) NOT NULL
            DEFAULT ('Noor'),
        [FirstName] VARCHAR(30) NOT NULL
            DEFAULT ('Aliem'),
        [GroupName] VARCHAR(30) NOT NULL
            DEFAULT ('G7-3'),
        [DateAdded] DATETIME2(7) NOT NULL
            DEFAULT SYSDATETIME(),
        [DateOfLastUpdate] DATETIME2(7) NOT NULL
            DEFAULT SYSDATETIME(),
        [AuthorizedUserId] INT NULL
            DEFAULT (7),
        CONSTRAINT [PK_ModeOfInstruction]
            PRIMARY KEY CLUSTERED (ModeID ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON
                 ) ON [PRIMARY]
    ) ON [PRIMARY];

    --INSERTION OF [ModeID], and [ModeOfInstruction]
    SET IDENTITY_INSERT [QCClass].ModeOfInstruction ON;

    INSERT INTO [QCClass].[ModeOfInstruction]
    (
        [ModeID],
        [ModeOfInstruction]
    )
    SELECT NEXT VALUE FOR [Project3].[ModeOfInstructionSequenceObject],
           k17.[Mode of Instruction]
    FROM
    (
        SELECT DISTINCT
               [Mode of Instruction]
        FROM groupnUploadfile.CoursesSpring2017
        WHERE [Mode of Instruction] <> ''
    ) AS k17;

    SET IDENTITY_INSERT [QCClass].ModeOfInstruction OFF;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Noor',
                                       @FirstName = 'Aliem',
                                       @WorkFlowDescription = 'Creates and loads the new Mode Of Instruction table.';

END;
GO

-- =========================================-==== 
-- Author: Jordon Johnson
-- Procedure: [Project3].[CreateAndLoadBuildingLocationTable]
-- Create date: 05/07/2020
-- Description: Creates and loads the new Building Location table
-- =============================================

GO
DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadBuildingLocationTable];

GO
CREATE PROCEDURE [Project3].[CreateAndLoadBuildingLocationTable] 
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForBuildingLocation];
    CREATE SEQUENCE [Project3].[SequenceObjectForBuildingLocation]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS [QCClass].[BuildingLocation];

    CREATE TABLE [QCClass].[BuildingLocation]
    (
        BuildingID INT NOT NULL,
        BuildingCode [VARCHAR](50) NULL,
        ClassTime NCHAR(5) NULL
            DEFAULT ('7:45'),
        GroupMemberLastName NVARCHAR(30) NOT NULL
            DEFAULT ('Johnson'),
        GroupMemberFirstName NVARCHAR(30) NOT NULL
            DEFAULT ('Jordon'),
        GroupName NVARCHAR(30) NOT NULL
            DEFAULT ('G7-3'),
        DateAdded DATETIME2 NOT NULL
            DEFAULT (SYSDATETIME()),
        DateOfLastUpdate DATETIME2 NOT NULL
            DEFAULT (SYSDATETIME()),
        AuthorizedUserId INT
            DEFAULT (5) NOT NULL,
        CONSTRAINT [PK_BuildingLocation]
            PRIMARY KEY (BuildingID)
    );

    INSERT INTO [QCClass].[BuildingLocation]
    (
        BuildingID,
        BuildingCode
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForBuildingLocation],
           OD.BC
    FROM
    (
        SELECT DISTINCT
               LEFT(Location, 2) AS BC
        FROM groupnUploadfile.CoursesSpring2017
        WHERE LEN(LEFT(Location, 2)) > 0
    ) AS OD;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Johnson',
                                       @FirstName = 'Jordon',
                                       @WorkFlowDescription = 'Creates and loads the new Building Location table';

END;
GO

-- ============================================= 
-- Author: Kenneth Nguyen
-- Procedure: [Project3].[CreateAndLoadBuildingAndRoomTable]
-- Create date: 05/02/2020
-- Description: Creates and loads the new BuildingAndRoom Table
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadBuildingAndRoomTable];
GO

CREATE PROCEDURE [Project3].[CreateAndLoadBuildingAndRoomTable]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForBuildingRoomId];
    CREATE SEQUENCE [Project3].[SequenceObjectForBuildingRoomId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS QCClass.BuildingRoom;
    CREATE TABLE QCClass.[BuildingRoom]
    (
        BuildingRoomID INT NOT NULL,
        RoomLocationKey INT NOT NULL,
        BuildingLocationKey INT NOT NULL,
        ClassTime NCHAR(5) NULL
            DEFAULT ('7:45'),
        GroupMemberLastName NVARCHAR(30) NOT NULL
            DEFAULT ('Johnson'),
        GroupMemberFirstName NVARCHAR(30) NOT NULL
            DEFAULT ('Jordon'),
        GroupName NVARCHAR(30) NOT NULL
            DEFAULT ('G7-3'),
        DateAdded DATETIME2 NOT NULL
            DEFAULT (SYSDATETIME()),
        DateOfLastUpdate DATETIME2 NOT NULL
            DEFAULT (SYSDATETIME()),
        AuthorizedUserId INT
            DEFAULT (1) NOT NULL,
        CONSTRAINT PK_BuildingRoomID
            PRIMARY KEY (BuildingRoomID)
    );


    INSERT INTO QCClass.[BuildingRoom]
    (
        BuildingRoomID,
        BuildingLocationKey,
        RoomLocationKey
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForBuildingRoomId],
           R.BuildingID,
           R.RoomID
    FROM
    (
        SELECT DISTINCT
               BL.BuildingID,
               RL.RoomID
        FROM groupnUploadfile.CoursesSpring2017 AS CS
            INNER JOIN QCClass.[BuildingLocation] AS BL
                ON SUBSTRING(CS.[Location], 0, 3) = BL.BuildingCode
            INNER JOIN QCClass.[RoomLocation] AS RL
                ON SUBSTRING(
                                CS.[Location],
                                CHARINDEX(' ', CS.[Location]) + 1,
                                LEN(CS.[Location]) - CHARINDEX(' ', CS.[Location]) + 1
                            ) = RL.RoomNumber
    ) AS R;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Nguyen',
                                       @FirstName = 'Kenneth',
                                       @WorkFlowDescription = 'Creates and loads the new Building Location table';

END;
GO

-- ============================================= 
-- Author: Brian Aguilar
-- Procedure: [Project3].[CreateInstructorTable]
-- Create date: 05/07/2020
-- Description: Creates and loads the new instructor table
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateInstructorTable];
GO

CREATE PROCEDURE [Project3].[CreateInstructorTable]
AS
BEGIN

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForInstructorId];
    CREATE SEQUENCE [Project3].[SequenceObjectForInstructorId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS [QCClass].[Instructor];
    CREATE TABLE [QCClass].[Instructor]
    (
        InstructorID INT NOT NULL,
        InstructorFullName NVARCHAR(50) NOT NULL,
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Aguilar') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Brian') NOT NULL,
        GroupName VARCHAR(45)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT NULL
            DEFAULT (2),
        CONSTRAINT PK_Instructor
            PRIMARY KEY (InstructorID)
    );

    INSERT INTO [QCClass].[Instructor]
    (
        [InstructorID],
        [InstructorFullName]
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForInstructorId],
           [B745].Instructor
    FROM
    (
        SELECT DISTINCT
               Instructor
        FROM groupnUploadfile.CoursesSpring2017
    ) AS B745;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Aguilar',
                                       @FirstName = 'Brian',
                                       @WorkFlowDescription = 'Creates and loads the new instructor table.';

END;
GO

-- =========================================-==== 
-- Author: Tristen Aguilar
-- Procedure: [Project3].[CreateCourseTable]
-- Create date: 05/07/2020
-- Description: Creates and loads the new course table.
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateCourseTable];
GO

CREATE PROCEDURE [Project3].[CreateCourseTable]
AS
BEGIN

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForCourseId];
    CREATE SEQUENCE [Project3].[SequenceObjectForCourseId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS QCClass.[Course];
    CREATE TABLE QCClass.[Course]
    (
        CourseID INT NOT NULL,
        CourseName NVARCHAR(50) NOT NULL,
        CourseHour NVARCHAR(2) NULL,
        CourseCredit NVARCHAR(2) NULL,
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Aguilar') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Tristen') NOT NULL,
        GroupName VARCHAR(45)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT NULL
            DEFAULT (3),
        CONSTRAINT PK_Course
            PRIMARY KEY (CourseID)
    );

    INSERT INTO QCClass.[Course]
    (
        CourseID,
        CourseName,
        CourseHour,
        CourseCredit
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForCourseId],
           CourseName,
           CourseHour,
           CourseCredit
    FROM
    (
        SELECT DISTINCT
               [Description] AS CourseName,
               SUBSTRING(
                            [Course (hr, crd)],
                            CHARINDEX('(', [Course (hr, crd)]) + 1,
                            CASE
                                WHEN SUBSTRING([Course (hr, crd)], CHARINDEX('(', [Course (hr, crd)]) + 2, 1) = ',' THEN
                                    1
                                ELSE
                                    2
                            END
                        ) AS CourseHour,
               SUBSTRING([Course (hr, crd)], CHARINDEX(',', [Course (hr, crd)]) + 2, 1) AS CourseCredit
        FROM groupnUploadfile.CoursesSpring2017
        WHERE Description <> ''
    ) AS Result;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Aguilar',
                                       @FirstName = 'Tristen',
                                       @WorkFlowDescription = 'Creates and loads the new course table.';

END;
GO

-- =========================================-==== 
-- Author: Anthony Ramnarain
-- Procedure: [Project3].[CreateAndLoadRoomLocationTable]
-- Create date: 05/04/2020
-- Description: Creates and loads the new Room Location table
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadRoomLocationTable];
GO

CREATE PROCEDURE [Project3].[CreateAndLoadRoomLocationTable]
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME2 = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForRoomId];
    CREATE SEQUENCE [Project3].[SequenceObjectForRoomId]
    START WITH 1
    INCREMENT BY 1;


    DROP TABLE IF EXISTS QCClass.[RoomLocation];
    CREATE TABLE QCClass.[RoomLocation]
    (
        RoomID INT NOT NULL,
        [RoomNumber] [NVARCHAR](50) NOT NULL,
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Ramnarain') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Tristen') NOT NULL,
        GroupName VARCHAR(45)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT NULL
            DEFAULT (6),
        CONSTRAINT PK_RoomLocation
            PRIMARY KEY (RoomID)
    );

    INSERT INTO QCClass.[RoomLocation]
    (
        RoomID,
        [RoomNumber]
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForRoomId],
           RoomNumber
    FROM
    (
        SELECT DISTINCT
               SUBSTRING(
                            CS.[Location],
                            CHARINDEX(' ', CS.[Location]) + 1,
                            LEN(CS.[Location]) - CHARINDEX(' ', CS.[Location]) + 1
                        ) AS [RoomNumber]
        FROM groupnUploadfile.CoursesSpring2017 AS CS
            LEFT OUTER JOIN QCClass.[BuildingLocation] AS BL
                ON SUBSTRING(CS.[Location], 0, 3) = BL.BuildingCode
    ) AS Result;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Ramnarain',
                                       @FirstName = 'Anthony',
                                       @WorkFlowDescription = 'Creates and adds foreign keys to the newly created tables.';
END;
GO

-- ============================================= 
-- Author: Brian Aguilar
-- Procedure: [Project3].[CreateAndLoadInstructorDepartmentTable]
-- Create date: 05/07/2020
-- Description: Creates and loads the new InstructorDepartmentTable.
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateInstructorDepartmentTable];
GO

CREATE PROCEDURE [Project3].[CreateInstructorDepartmentTable]
AS
BEGIN

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[SequenceObjectForInstructorDepartmentId];
    CREATE SEQUENCE [Project3].[SequenceObjectForInstructorDepartmentId]
    START WITH 1
    INCREMENT BY 1;

    DROP TABLE IF EXISTS QCClass.InstructorDepartment;
    CREATE TABLE [QCClass].[InstructorDepartment]
    (
        InstructorDepartmentID INT NOT NULL,
        DepartmentKey INT NOT NULL
            DEFAULT (-1),
        InstructorKey INT NOT NULL
            DEFAULT (-1),
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Aguilar') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Brian') NOT NULL,
        GroupName VARCHAR(45)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT NULL
            DEFAULT (2),
        CONSTRAINT PK_InstructorDepartment
            PRIMARY KEY (InstructorDepartmentID),
    );

    INSERT INTO QCClass.[InstructorDepartment]
    (
        InstructorDepartmentID,
        DepartmentKey,
        InstructorKey
    )
    SELECT NEXT VALUE FOR [Project3].[SequenceObjectForInstructorDepartmentId],
           DepartmentID,
           InstructorID
    FROM
    (
        SELECT DISTINCT
               I.InstructorID,
               D.DepartmentID
        FROM groupnUploadfile.CoursesSpring2017 AS CS
            INNER JOIN QCClass.[Instructor] AS I
                ON CS.Instructor = I.InstructorFullName
            INNER JOIN QCClass.[Department] AS D
                ON SUBSTRING(CS.[Course (hr, crd)], 0, CHARINDEX(' ', CS.[Course (hr, crd)])) = D.Department
        WHERE LEN(CS.[Course (hr, crd)]) > 0
    ) AS Result;


    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Aguilar',
                                       @FirstName = 'Brian',
                                       @WorkFlowDescription = 'Creates and loads the new InstructorDepartmentTable.';


END;
GO

-- ============================================= 
-- Author: Minjung Chung
-- Procedure: [Project3].[CreateAndLoadClassTable]
-- Create date: 5/5/2020
-- Description: Creates and loads [QCClass].[Class] table
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateAndLoadClass];
GO

CREATE PROCEDURE [Project3].[CreateAndLoadClass]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    DROP SEQUENCE IF EXISTS [Project3].[ClassSequence];
    CREATE SEQUENCE [Project3].[ClassSequence]
    AS INT
    START WITH 1
    INCREMENT BY 1
    MINVALUE-2147483648
    MAXVALUE 2147483647;

    DROP TABLE IF EXISTS [QCClass].[Class];

    CREATE TABLE [QCClass].[Class]
    (
        ClassID INT NOT NULL,
        TimeKey INT NOT NULL
            DEFAULT (-1),
        InstructorKey INT NOT NULL
            DEFAULT (-1),
        BuildingRoomKey INT NOT NULL
            DEFAULT (-1),
        CourseKey INT NOT NULL
            DEFAULT (-1),
        ModeOfInstructionKey INT NOT NULL
            DEFAULT (-1),
        [Limit] VARCHAR(50) NULL,
        Enrolled VARCHAR(50) NULL,
        ClassName NVARCHAR(40) NOT NULL
            DEFAULT ('Not Provided'),
        ClassTime CHAR(5) NULL
            DEFAULT ('7:45'),
        LastName VARCHAR(30)
            DEFAULT ('Chung') NOT NULL,
        FirstName VARCHAR(30)
            DEFAULT ('Minjung') NOT NULL,
        GroupName VARCHAR(30)
            DEFAULT ('G7-3') NOT NULL,
        DateAdded DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        DateOfLastUpdate DATETIME2(7)
            DEFAULT SYSDATETIME() NOT NULL,
        AuthorizedUserId INT NULL
            DEFAULT (4),
        CONSTRAINT PK_Class
            PRIMARY KEY CLUSTERED ([ClassID] ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON
                 ) ON [PRIMARY]
    ) ON [PRIMARY];

    INSERT INTO [QCClass].[Class]
    (
        ClassID,
        TimeKey,
        InstructorKey,
        BuildingRoomKey,
        CourseKey,
        ModeOfInstructionKey,
        [Limit],
        [Enrolled],
        ClassName
    )
    SELECT NEXT VALUE FOR [Project3].[ClassSequence],
           TimeID,
           InstructorID,
           BuildingRoomID,
           CourseID,
           ModeID,
           [Limit],
           [Enrolled],
           [Description]
    FROM
    (
        SELECT CS.[Description],
               CS.[Limit],
               CS.[Enrolled],
               I.InstructorID,
               Course.CourseID,
               BR.BuildingRoomID,
               MOI.ModeID,
               TS.TimeID
        FROM QCClass.Instructor AS I
            INNER JOIN groupnUploadfile.CoursesSpring2017 AS CS
                ON CS.Instructor = I.InstructorFullName
            INNER JOIN [QCClass].[Course] AS Course
                ON CS.[Description] = Course.CourseName
                   AND SUBSTRING(
                                    CS.[Course (hr, crd)],
                                    CHARINDEX('(', CS.[Course (hr, crd)]) + 1,
                                    CASE
                                        WHEN SUBSTRING(
                                                          CS.[Course (hr, crd)],
                                                          CHARINDEX('(', CS.[Course (hr, crd)]) + 2,
                                                          1
                                                      ) = ',' THEN
                                            1
                                        ELSE
                                            2
                                    END
                                ) = Course.CourseHour
                   AND SUBSTRING(CS.[Course (hr, crd)], CHARINDEX(',', CS.[Course (hr, crd)]) + 2, 1) = Course.CourseCredit
            INNER JOIN [QCClass].[RoomLocation] AS RL
                ON SUBSTRING(
                                CS.[Location],
                                CHARINDEX(' ', CS.[Location]) + 1,
                                LEN(CS.[Location]) - CHARINDEX(' ', CS.[Location]) + 1
                            ) = RL.RoomNumber
            INNER JOIN [QCClass].[BuildingLocation] AS BL
                ON SUBSTRING(CS.[Location], 0, 3) = BL.BuildingCode
            INNER JOIN [QCClass].BuildingRoom AS BR
                ON RL.RoomID = BR.RoomLocationKey
                   AND BL.BuildingID = BR.BuildingLocationKey
            INNER JOIN [QCClass].[ModeOfInstruction] AS MOI
                ON CS.[Mode of Instruction] = MOI.ModeOfInstruction
            INNER JOIN [QCClass].[Time] AS TS
                ON SUBSTRING(CS.[Time], 0, CHARINDEX('-', CS.[Time])) = TS.ClassStartingTime
                   AND SUBSTRING(CS.[Time], CHARINDEX('M', CS.[Time]) + 4, LEN(CS.[Time])) = TS.ClassEndingTime
                   AND CS.[Day] = TS.[ClassDay]
    ) AS R;

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Chung',
                                       @FirstName = 'Minjung',
                                       @WorkFlowDescription = 'Creates and loads the new Class table.';

END;
GO

-- =========================================-==== 
-- Author: Brian Aguilar
-- Procedure: [Project3].[CreateForeignKeys]
-- Create date: 05/07/2020
-- Description: Creates and adds foreign keys to the newly created tables
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[CreateForeignKeys];
GO

CREATE PROCEDURE [Project3].[CreateForeignKeys]
AS
BEGIN
    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    ALTER TABLE QCClass.InstructorDepartment
    ADD CONSTRAINT FK_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES QCClass.[Department] (DepartmentID),
        CONSTRAINT FK_Instructor
        FOREIGN KEY (InstructorKey)
        REFERENCES QCClass.[Instructor] (InstructorID);

    ALTER TABLE QCClass.[BuildingRoom]
    ADD CONSTRAINT FK_BuildingLocation
        FOREIGN KEY (BuildingLocationKey)
        REFERENCES QCClass.[BuildingLocation] (BuildingID),
        CONSTRAINT FK_RoomLocation
        FOREIGN KEY (RoomLocationKey)
        REFERENCES QCClass.[RoomLocation] (RoomID);

    ALTER TABLE QCClass.[Class]
    ADD CONSTRAINT FK_Time
        FOREIGN KEY (TimeKey)
        REFERENCES QCClass.[Time] (TimeID),
        CONSTRAINT FK_InstructorClass
        FOREIGN KEY (InstructorKey)
        REFERENCES QCClass.[Instructor] (InstructorID),
        CONSTRAINT FK_BuildingRoom
        FOREIGN KEY (BuildingRoomKey)
        REFERENCES QCClass.[BuildingRoom] (BuildingRoomID),
        CONSTRAINT FK_Course
        FOREIGN KEY (CourseKey)
        REFERENCES QCClass.[Course] (CourseID),
        CONSTRAINT FK_ModeOfInstruction
        FOREIGN KEY (ModeOfInstructionKey)
        REFERENCES QCClass.[ModeOfInstruction] (ModeID);

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Aguilar',
                                       @FirstName = 'Brian',
                                       @WorkFlowDescription = 'Creates and adds foreign keys to the newly created tables.';

END;
GO

-- ============================================= 
-- Author: Aliem Al Noor
-- Procedure: [Project3].[BuildQueensClassScheduleSpring2017]
-- Create date: 5/5/2020
-- Description: Builds the QueensClassScheduleSpring2017 database.
-- =============================================

DROP PROCEDURE IF EXISTS [Project3].[BuildQueensClassScheduleSpring2017];
GO

CREATE PROCEDURE [Project3].[BuildQueensClassScheduleSpring2017]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7);
    SET @StartTime = SYSDATETIME();

    EXEC [Process].[usp_CreateWorkFlowStepTableRowCountSequenceObject];
    EXEC [Process].[usp_CreateWorkFlowStepsTable];

	EXEC [Project3].[DropAllForeignKeyConstraints];
	EXEC [Project3].[TruncateAllTables];

    EXEC [Project3].[CreateAndLoadTimeTable];
    EXEC [Project3].[CreateAndLoadDepartmentTable];
    EXEC [Project3].[CreateAndLoadModeOfInstructionTable];
    EXEC [Project3].[CreateAndLoadBuildingLocationTable];
    EXEC [Project3].[CreateAndLoadRoomLocationTable];
    EXEC [Project3].[CreateAndLoadBuildingAndRoomTable];
    EXEC [Project3].[CreateInstructorTable];
    EXEC [Project3].[CreateInstructorDepartmentTable];
    EXEC [Project3].[CreateCourseTable];
    EXEC [Project3].[CreateAndLoadClass];
    EXEC [Project3].[CreateForeignKeys];

    DECLARE @ET DATETIME2(7);
    SELECT @ET = SYSDATETIME();
    EXEC [Process].[usp_TrackWorkFlow] @StartTime = @StartTime,
                                       @EndingTime = @ET,
                                       @LastName = 'Noor',
                                       @FirstName = 'Aliem',
                                       @WorkFlowDescription = 'Builds the QueensClassScheduleSpring2017 database.';

    SELECT *
    FROM Process.WorkFlowSteps;

END;
GO

EXEC [Project3].[BuildQueensClassScheduleSpring2017]


