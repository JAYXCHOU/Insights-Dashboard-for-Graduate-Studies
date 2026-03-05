IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name = 'scholar' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.scholar(
        stu_ID                         char(7),
        Sch_ID                         char(5),
        Scholar_thai                   nvarchar(255),
        Scholar_eng                    nvarchar(255),
        Rec_Syear                      char(4),
        F_Term                         char(1),
        Rec_Eyear                      char(4),
        L_Term                         char(1),
        GetDate                        char(10),
        FinalDate                      char(10),
        Amount                         float
    );
    PRINT 'Created bronze scholar table';
END        
ELSE
    PRINT 'bronze scholar table already exists';