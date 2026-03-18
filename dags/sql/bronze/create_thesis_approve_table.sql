IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name = 'thesis_approve' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.thesis_approve(
        stu_id                         char(7),
        rn                             int,
        Gr_ID                          char(4),
        status_apv                     varchar(50),
        status_apv_desc                nvarchar(200),
        QA                             varchar(50),
        QA_desc                        nvarchar(200),
        QA_text                        nvarchar(MAX),
        apv_time                       varchar(20),
    );
    PRINT 'Created bronze thesis_approve table';
END        
ELSE
    PRINT 'bronze thesis_approve table already exists';