IF NOT EXISTS(
    SELECT * from sys.tables
    WHERE name = 'register' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.register(
        Stu_ID                         char(7),
        Reg_Year                       char(4),
        Reg_Term                       char(1),
        Subj_ID                        nvarchar(20),
        Subj_Rn                        char(2),
        Reg_Credit                     float,
        subj_nen                       nvarchar(255),
        subj_nth                       nvarchar(255),
        subj_id_th                     nvarchar(20)
    );
    PRINT 'Created bronze register table';
END
ELSE
    PRINT 'bronze register table already exists';
