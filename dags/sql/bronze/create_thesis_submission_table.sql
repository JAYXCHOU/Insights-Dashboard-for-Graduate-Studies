IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name = 'thesis_submission' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.thesis_submission(
        sub_stu                        char(7),
        save_time                      varchar(20),
    );
    PRINT 'Created bronze thesis_submission table';
END        
ELSE
    PRINT 'bronze thesis_submission table already exists';