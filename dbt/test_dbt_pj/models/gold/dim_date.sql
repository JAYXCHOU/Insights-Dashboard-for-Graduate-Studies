WITH Numbers AS (
    SELECT TOP (DATEDIFF(DAY, '2015-01-01', '2030-12-31') + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)

SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), d, 112)) AS date_key,
    d AS full_date,
    CONVERT(VARCHAR(10), d, 111) AS date_display,

    DAY(d) AS day_number,
    CASE WHEN DATEPART(WEEKDAY, d) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,

    MONTH(d) AS month_number,
    DATENAME(MONTH, d) AS month_name,

    YEAR(d) AS year_number,
    DATEPART(QUARTER, d) AS quarter,

    DATEPART(WEEK, d) AS week_of_year,
    FORMAT(d, 'yyyy-MM') AS year_month,
    FORMAT(d, 'MMM-yyyy') AS month_year

FROM (
    SELECT DATEADD(DAY, n, '2015-01-01') AS d
    FROM Numbers
) t