IF NOT EXISTS(
    SELECT * from sys.tables
    WHERE name = 'subject' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.subject(
        subj_id                        nvarchar(20),
        subj_rn                        char(2),
        subj_nen_f                     nvarchar(255),
        subj_id_th                     nvarchar(20),
        subj_nth_f                     nvarchar(255),
        subj_credit                    float,
        subj_des_th                    nvarchar(max),
        subj_des_en                    nvarchar(max),
        cur_id                         nvarchar(10),
        cur_rn                         char(2),
        study_type                     char(1),
        tsubj_nen                      nvarchar(100)
    );
    PRINT 'Created bronze subject table';
END
ELSE
    PRINT 'bronze subject table already exists';
