--Jordon Johnson
--Database Systems Project
---------------------------------------------------NORTHWINDS QUERIES------------------------------------------------------

--Problem 1
--Complexity: Simple

--Proposition
--This query returns the specifications of each order placed, it identifies the productid, product name and quantity
--sold.

SELECT S.OrderId, S.ProductId, P.ProductName, S.Quantity
FROM Sales.OrderDetail AS S
   JOIN Production.Product AS P
   ON S.ProductId = P.ProductId
ORDER BY OrderId;

--Problem 2
--Complexity: Simple

--Proposition
--The query details the category name for each product and a concise description .

SELECT P.ProductId, P.ProductName, C.CategoryName, C."Description" 
FROM Production.Category AS C
    INNER JOIN Production.Product AS P
    ON P.CategoryId = C.CategoryId;

--Problem 4
--Complexity: Medium

--Proposition
--The query identifies the names of the top 10 products with the highest quantities sold. 

SELECT TOP (10) P.ProductID, P.ProductName, SUM(S.Quantity) AS "Total Quantity"
FROM Production.Product AS P
    INNER JOIN Sales.OrderDetail AS S
    ON P.ProductId = S.ProductId
GROUP BY P.ProductId, ProductName
ORDER BY "Total Quantity" DESC;

--Problem 4
--Complexity: Medium

--Proposition
--The query identifies the ten products that have generated the most revenue.

SELECT TOP (10) P.ProductID, P.ProductName, SUM(S.Quantity * S.UnitPrice) AS "Total Revenue"
FROM Production.Product AS P
    INNER JOIN Sales.OrderDetail AS S
    ON P.ProductId = S.ProductId
GROUP BY P.ProductId, ProductName
ORDER BY "Total Revenue" DESC;

--Problem 5
--Complexity: Complex

--Proposition
--The query below returns employees that have generated the most revenue over the period and their associated managers. 
--If the employee does not have a manager, it outputs a NULL value. 
--It also outputs the average discount the employee applies per order, as well as the total sales. It provides a warning 
--signal if employees are over-discounting or under-selling.
--It uses the managerid to determine if the employee is the CEO.

drop function dbo.is_ceo
GO

create function dbo.is_ceo
(
    @Empid int
)
returns nvarchar(8)
AS
BEGIN
    DECLARE @result as nvarchar(8)
    if exists(SELECT EmployeeManagerID from HumanResources.Employee
    where EmployeeManagerId IS NULL) 
    SET @result = 'YES'
    else 
    SET @result = 'No'
RETURN @result
END 

SELECT 
O.EmployeeId, E.EmployeeManagerId, dbo.is_ceo(E.EmployeeManagerId) AS IsCEO, CEILING (AVG(OD.DiscountPercentage) * 100) AS "Average Discount %",

CASE WHEN CEILING (AVG(OD.DiscountPercentage) * 100) > 6 THEN 'ALERT' ELSE 'OK' END AS DiscountSignal, 

SUM (OD.UnitPrice * OD.Quantity) AS "Total Revenue",

CASE WHEN SUM (OD.UnitPrice * OD.Quantity) > 140000.00 THEN 'OK' ELSE 'ALERT' END AS RevenueSignal

FROM HumanResources.Employee AS E
    LEFT OUTER JOIN
        (Sales.[Order] AS O
            INNER JOIN Sales.OrderDetail AS OD
            ON O.OrderId = OD.OrderID)
    ON E.EmployeeID = O.EmployeeID
GROUP BY O.EmployeeID, EmployeeManagerId
ORDER BY "Total Revenue" DESC;


--Problem 6
--Complexity: Complex

--Proposition
--The query prioritizes each customers based on total number of units purchased. It assigns a high priority flag
-- to customers with total quantity greater than 800, Medium to Customers with total quantities between 800 and 600, 
--and low to all others.

SELECT 
C.CustomerId, COUNT(O.OrderId) As "Total Number of Orders", 
SUM(OD.Quantity) AS "Total quantity",

CASE 
When SUM(OD.Quantity) > 800 THEN 'High Priority'
When SUM(OD.Quantity) < 800 AND SUM(OD.Quantity) > 600 THEN 'Medium Priority'
ELSE 'Low Priority'
END AS Priority

FROM Sales.OrderDetail AS OD
    JOIN
        (Sales.Customer AS C
        JOIN Sales.[Order] As O
        ON C.CustomerId = O.CustomerId)
    ON OD.OrderId = O.OrderId
GROUP BY C.CustomerId
ORDER BY "Total Quantity" DESC ;


---------------------------------------------------ADVENTUREWORKS2014------------------------------------------------------
--Problem 7
--Complexity: Simple

--Proposition
-- The query identifies the jobtitle of employees who've made sales but are not direct salesmen.


SELECT E.JobTitle , S.BusinessEntityID
FROM Sales.SalesPerson AS S
   JOIN HumanResources.Employee AS E
   ON S.BusinessEntityID = E.BusinessEntityID
WHERE E.JobTitle != 'Sales Representative';

--Problem 8
--Complexity: Simple

--Proposition
-- The query returns employees from each department, that is no longer with the company and determines how long did they've left.

SELECT P.FirstName, P.LastName,  DATEDIFF(year, EDH.startdate, EDH.enddate) AS 'YEARS WORKED'
FROM HumanResources.EmployeeDepartmentHistory AS EDH
INNER Join Person.Person AS P
ON EDH.BusinessEntityID = P.BusinessEntityID
WHERE DATEDIFF(year, EDH.startdate, EDH.enddate) is not null
ORDER BY 'YEARS WORKED';

--Problem 9
--Complexity: Medium

--Proposition
--The query identifies the average salary for males and females within each organizational level. 
--It also specifies the total number of males and females within each organizational group. 

SELECT E.OrganizationLevel , E.Gender, AVG(EPH.Rate) AS AverageHourlyRate, COUNT(*) AS TotalEmployees
FROM HumanResources.EmployeePayHistory AS EPH
    JOIN HumanResources.Employee AS E
    ON EPH.BusinessEntityID = E.BusinessEntityID
GROUP BY E.OrganizationLevel, E.Gender
ORDER BY E.OrganizationLevel;



--Problem 10
--Complexity: Medium

--Proposition
--The query identifies the average tenure for each job titile.

SELECT E.OrganizationLevel, E.JobTitle, AVG(DATEDIFF(year, EDH.StartDate, '2020')) AS AverageTenure, COUNT(*) AS NumOfEmployees
FROM HumanResources.Employee AS E
    JOIN HumanResources.EmployeeDepartmentHistory AS EDH
    ON EDH.BusinessEntityID = E.BusinessEntityID
WHERE EDH.EndDate IS NULL
GROUP BY E.OrganizationLevel, E.JobTitle
ORDER BY E.OrganizationLevel;
                                                     
                                             
                                                     


--Problem 11
--Complexity: Medium

--Proposition
-- The query computes the total number of vacation hours for each department, 
--it outputs the average vacation per employee as well as the employee count per department.

SELECT EDH.DepartmentId, D.Name, SUM(E.VacationHours) AS "Total Vacation Hours", COUNT(*) AS 'Employee Count', AVG(E.VacationHours)
FROM HumanResources.Employee AS E
JOIN HumanResources.EmployeeDepartmentHistory AS EDH
ON EDH.BusinessEntityID = E.BusinessEntityID
INNER JOIN HumanResources.Department AS D
ON EDH.DepartmentID = D.DepartmentID
GROUP BY EDH.DepartmentId, D.Name
ORDER BY EDH.DepartmentID;
                                                
                                                     
--Problem 12
--Complexity: Complex
                                                     
--Proposition
-- The query calculates the average hourly rate per department, as well as the total number of employees.
-- It assigns the top three departments as high priority

create function dbo.priority
(
    @id int
)
returns int
AS
BEGIN
    DECLARE @result as nvarchar(50)
    if exists(SELECT DepartmentID from HumanResources.EmployeeDepartmentHistory
    where DepartmentId = 7) 
    SET @result = 1
    else 
    SET @result = 0
RETURN @result 
END 


SELECT D.Name, AVG(EPH.Rate) AS 'Average Rate', COUNT(DISTINCT EDH.BusinessEntityID) AS NumberofEmployees, 
dbo.priority(EDH.DepartmentID) As 'Rate Priority'
FROM HumanResources.EmployeePayHistory AS EPH
    JOIN HumanResources.EmployeeDepartmentHistory AS EDH
    ON EDH.BusinessEntityID = EPH.BusinessEntityID
    JOIN HumanResources.Department AS D
    ON D.DepartmentID = EDH.DepartmentID
GROUP BY D.Name, EDH.DepartmentID
ORDER BY 'Average Rate' DESC;


--Problem 13
--Complexity: Complex
-- The query finds the cumulative PTO(Vacation hours +sick hours) for each business entity.

CREATE FUNCTION dbo.total(@n int, @m int)
RETURNS int
AS
BEGIN
    declare @result int
    SELECT @result = @m + @n
RETURN @result
END

SELECT EDH.BusinessEntityID, SUM(dbo.total(E.VacationHours,E.SickLeaveHours)) AS 'Cummulative PTO'
FROM HumanResources.Employee AS E
    JOIN HumanResources.EmployeeDepartmentHistory AS EDH
    ON E.BusinessEntityID = EDH.BusinessEntityID
    JOIN HumanResources.Department AS D
    ON D.DepartmentID = EDH.DepartmentID
GROUP BY EDH.BusinessEntityID;
                                                    
--Problem 14
--Complexity: Complex
                                           
--Proposition
-- The query identifies the total number of males and females employed in the year 2013.
-- It uses flags to determine if the total is below the intended target for the year.
                                           
create function dbo.gendergap
(
    @gen nvarchar(50)
)
returns nvarchar
AS
BEGIN
    DECLARE @result as nvarchar(50)
    if exists(SELECT Gender from HumanResources.Employee
    where Gender = 'M') 
    SET @result = 'RED'
    else 
    SET @result = 'GREEN'
RETURN @result 
END 

SELECT YEAR(EDH.startdate), E.Gender, COUNT(E.Gender) AS 'Total', dbo.gendergap(E.Gender) AS Status
FROM HumanResources.Employee AS E
    JOIN HumanResources.EmployeeDepartmentHistory AS EDH
    ON EDH.BusinessEntityID = E.BusinessEntityID
        INNER JOIN HumanResources.Department AS D
        ON EDH.DepartmentID = D.DepartmentID
Where YEAR(EDH.startdate) = 2013
GROUP BY YEAR(EDH.startdate), E.Gender;
                                                     

--Problem 15
--Complexity: Complex

--Proposition
-- The query identifies total profits and taxes in each territory.
                                           
CREATE FUNCTION dbo.sub(@n float, @m float)
RETURNS float
AS
BEGIN
    declare @result float
    SELECT @result = @m - @n
RETURN @result
END

      
SELECT ST.TerritoryID, COUNT(DISTINCT SOD.ProductID) AS 'Total', SUM(SOH.TaxAmt) As 'Total taxes', SUM(dbo.sub(ST.SalesYTD,CostYTD)) AS Profit
FROM Sales.SalesTerritory AS ST
    JOIN Sales.SalesOrderHeader AS SOH
    ON ST.TerritoryID = SOH.TerritoryID
        JOIN Sales.SalesOrderDetail AS SOD
        ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY ST.TerritoryID;
                                           
                                           

                                                     




---------------------------------------------------ADVENTUREWORKSDW2016------------------------------------------------------

--Problem 16
--Complexity: Simple

--Proposition
-- The query displays the first name, lastname and city of customers with the same geographical region.

SELECT C.Firstname, C.Lastname, G.City
FROM dbo.DimCustomer AS C
    JOIN dbo.DimGeography AS G
     ON C.GeographyKey = G.GeographyKey;


--Problem 17
--Complexity: Medium

--Proposition
-- The query outputs the name of products where the UNITS OUT is greater than the UNITS IN, 
-- it calculates the total number of days this occured in 2013 for each product.

SELECT DP.EnglishProductName AS 'Product Name', COUNT(DISTINCT MovementDate) AS 'Number of Days Imbalanced'
FROM dbo.FactProductInventory AS I
    JOIN dbo.DimProduct AS DP
    ON I.ProductKey = DP.ProductKey
WHERE  UnitsIn < UnitsOut AND YEAR(MovementDate) =2013
GROUP BY DP.EnglishProductName
ORDER BY 'Number of Days Imbalanced' DESC;


--Problem 18
--Complexity: Medium

-- Proposition
-- The query finds the total annual sales for business types among resellers in the city of London.

SELECT DR.BusinessType, SUM(DR.AnnualSales) AS 'Total Annual Sales per Business Type in London'
FROM DimReseller AS DR
    JOIN DimGeography AS DG
    ON  DG.GeographyKey = DR.GeographyKey
WHERE DG.City = 'London'
GROUP BY DR.BusinessType;


--Problem 19
--Complexity: Medium

--Proposition
-- The query displays the top 20% highest projected profit(listprice-standard cost) for each product
-- in the product table, it calculates the markup percentage and unit balance.

SELECT DP.ProductKey, AVG (DP.ListPrice - DP.StandardCost) AS 'Profit Projection', 
AVG (DP.ListPrice - DP.StandardCost)/AVG(DP.ListPrice) * 100 AS 'Markup Percentage %', AVG(I.UnitsBalance) AS 'Unit Balance'
FROM dbo.FactProductInventory AS I
    JOIN dbo.DimProduct AS DP
    ON I.ProductKey = DP.ProductKey
WHERE  DP.ListPrice IS NOT NULL AND  DP.StandardCost IS NOT NULL AND YEAR(MovementDate) =2013
GROUP BY DP.ProductKey
ORDER BY 'Profit Projection' DESC;


--Problem 20
--Complexity: Complex

--Proposition
-- The query identifies the daily total for each customer who placed an order online in Australia. 
-- It converts the sales amount from US dollars to Australian Dollars.
-- If the converted amount exceeds $200,000, duty charges apply.
-- If the total number of item exceeds 3000, duty charges apply.


CREATE FUNCTION dbo.Product(@n float, @m float)
RETURNS float
AS
BEGIN
    declare @result FLOAT
    SELECT @result = @m * @n
RETURN @result
END

SELECT FIS.CustomerKey, FIS.OrderDate, SUM(SalesAmount) AS 'US Amount $', AVG(EndOfDayRate) AS RATE, 
SUM(dbo.Product(FIS.SalesAmount,FCR.EndOfDayRate)) AS 'Aussie Conversion $', 
COUNT(DP.ProductKey) AS 'Total Items',
                
CASE WHEN COUNT(DP.ProductKey) > 3000 AND SUM(dbo.Product(FIS.SalesAmount,FCR.EndOfDayRate)) > 200000 
     THEN 'ALERT' ELSE 'OK' END AS Signal

FROM FactInternetSales AS FIS
    INNER JOIN FactCurrencyRate FCR
    ON FIS.CurrencyKey = FCR.CurrencyKey
    INNER JOIN DimProduct AS DP
    ON DP.ProductKey = FIS.ProductKey
    INNER JOIN DimCurrency AS DC
    ON DC.CurrencyKey = FIS.CurrencyKey
GROUP BY FIS.CustomerKey, FIS.OrderDate, DC.CurrencyName
HAVING DC.CurrencyName = 'Australian Dollar' 
ORDER BY FIS.CustomerKey, FIS.OrderDate;
