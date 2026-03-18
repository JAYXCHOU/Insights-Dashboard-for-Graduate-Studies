
WITH Numbers AS (
    SELECT TOP (DATEDIFF(DAY, '2015-01-01', '2025-12-31') + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)

SELECT
    CONVERT(INT, FORMAT(
        DATEADD(YEAR, 543, DATEADD(DAY, n, '2015-01-01')),
        'yyyyMMdd'
    )) AS date_key,
    DATEADD(DAY, n, '2015-01-01') AS FullDate,

    YEAR(DATEADD(YEAR, 543, DATEADD(DAY, n, '2015-01-01'))) AS year_number,
    MONTH(DATEADD(DAY, n, '2015-01-01')) AS month_number,
    DAY(DATEADD(DAY, n, '2015-01-01')) AS day_number

FROM Numbers