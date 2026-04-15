IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'sta_nonstu'
    AND schema_id = SCHEMA_ID('bronze')
)
BEGIN
    CREATE TABLE bronze.sta_nonstu(
        nstu_id char(2),
        nstu_des_thai nvarchar(255),
        nstu_des_eng nvarchar(255)
    );

    PRINT 'Created bronze.sta_nonstu';
END
ELSE
BEGIN
    PRINT 'bronze.sta_nonstu already exists';
END;