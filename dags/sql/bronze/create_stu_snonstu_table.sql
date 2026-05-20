IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'stu_snonstu'
    AND schema_id = SCHEMA_ID('bronze')
)
BEGIN
    CREATE TABLE bronze.stu_snonstu(
        stu_id char(7),
        snon_term char(1),
        snon_year char(4),
        snon_memo nvarchar(255),
        nstu_id char(2),
        sta_outdate char(10),
        loaded_at              DATETIME           DEFAULT GETDATE()
    );

    PRINT 'Created bronze.stu_snonstu';
END
ELSE
BEGIN
    PRINT 'bronze.stu_snonstu already exists';
END;