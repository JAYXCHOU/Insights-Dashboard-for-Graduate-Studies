IF NOT EXISTS(
    SELECT * from sys.tables
    WHERE name = 'grade_stu' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.grade_stu(
        Stu_ID                         char(7),
        Reg_Year                       char(4),
        Reg_Term                       char(1),
        Subj_ID                        nvarchar(20),
        Subj_Rn                        char(2),
        Credit                         float,
        Reg_Grad                       nvarchar(10)
    );
    PRINT 'Created bronze grade_stu table';
END
ELSE
    PRINT 'bronze grade_stu table already exists';
