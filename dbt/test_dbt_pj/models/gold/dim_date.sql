-- CREATE TABLE Dim_Date (
--     DateKey        INT PRIMARY KEY,
--     FullDate       DATE,
--     DayNumber      INT,
--     DayName        NVARCHAR(20),
--     DayOfWeek      INT,
--     WeekOfYear     INT,
--     MonthNumber    INT,
--     MonthName      NVARCHAR(20),
--     QuarterNumber  INT,
--     YearNumber     INT,
--     IsWeekend      BIT
-- );

WITH Numbers AS (
    SELECT TOP (5000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
)

SELECT
    CONVERT(INT, FORMAT(DATEADD(DAY, n, '2015-01-01'), 'yyyyMMdd')) AS date_key,
    DATEADD(DAY, n, '2015-01-01') AS FullDate,
    YEAR(DATEADD(DAY, n, '2015-01-01')) AS year_number,
    MONTH(DATEADD(DAY, n, '2015-01-01')) AS month_number,
    DAY(DATEADD(DAY, n, '2015-01-01')) AS day_number
FROM Numbers
WHERE DATEADD(DAY, n, '2015-01-01') <= '2025-12-31'

-- INSERT INTO Dim_Date
-- SELECT
--     CONVERT(INT, FORMAT(FullDate, 'yyyyMMdd')) AS DateKey,
--     FullDate,
--     DAY(FullDate) AS DayNumber,
--     DATENAME(WEEKDAY, FullDate) AS DayName,
--     DATEPART(WEEKDAY, FullDate) AS DayOfWeek,
--     DATEPART(WEEK, FullDate) AS WeekOfYear,
--     MONTH(FullDate) AS MonthNumber,
--     DATENAME(MONTH, FullDate) AS MonthName,
--     DATEPART(QUARTER, FullDate) AS QuarterNumber,
--     YEAR(FullDate) AS YearNumber,
--     CASE 
--         WHEN DATEPART(WEEKDAY, FullDate) IN (1,7) THEN 1 
--         ELSE 0 
--     END AS IsWeekend
-- FROM DateCTE
-- OPTION (MAXRECURSION 0);