SELECT ClassName,
       CourseKey,
       COUNT(CourseKey) AS NumberOfClassesOffered,
       SUM(PARSE(Enrolled AS INT)) AS TotalEnrolled,
       SUM(PARSE(Limit AS INT)) AS Limit
FROM QCClass.Class
GROUP BY ClassName,
         CourseKey
ORDER BY ClassName;

SELECT 
	C.CourseName,
	I.InstructorFullName AS InstructorNames
FROM 
	[QCClass].Course AS C
	INNER JOIN [QCClass].[Instructor] AS I
	ON C.CourseID = I.InstructorID
GROUP By C.CourseName, I.InstructorFullName;

SELECT CASE
           WHEN i.InstructorFullName = ',' THEN
               'No Instructor'
           ELSE
               i.InstructorFullName
       END AS [Instructor Name],
       COUNT(orig.Department) AS [Number of Departments]
FROM QCClass.Department AS orig
    JOIN QCClass.Instructor AS i
        ON orig.DepartmentID = i.InstructorID
GROUP BY i.InstructorFullName
HAVING COUNT(orig.Department) > 1
ORDER BY COUNT(orig.Department) ASC;

SELECT Department, 
	  COUNT(InstructorFullName) as NumOfInstructors 
FROM 
	[QCClass].InstructorDepartment AS ID
	INNER JOIN [QCClass].Instructor AS I
	ON ID.InstructorKey = I.InstructorID
	INNER JOIN [QCClass].Department AS D
	ON ID.DepartmentKey = D.DepartmentID
GROUP BY Department;

SELECT
    C.CourseName,
    SUM(CAST(CL.Enrolled AS INT)) AS NumberOfStudents
FROM [QCClass].Course AS C
INNER JOIN
     [QCClass].[Class] AS CL
ON C.CourseID = CL.ClassID
AND C.ClassTime = '7:45'
GROUP BY (C.CourseName)

SELECT
	B.BuildingCode,
	SUM(BR.BuildingRoomID) AS NumOfRooms
FROM 
	[QCClass].[BuildingLocation] AS B
	INNER JOIN [QCClass].[BuildingRoom] AS BR
	ON B.BuildingID = BR.BuildingRoomID
GROUP BY B.BuildingCode;

