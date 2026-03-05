IF NOT EXISTS(
    SELECT * from sys.tables 
    WHERE name ='curriculum_cyc' and SCHEMA_id = SCHEMA_id('bronze')
)
BEGIN
    CREATE TABLE bronze.curriculum_cyc(
        cur_id                         char(5),
        cur_rn                         char(2),
        study_type                     char(1),
        [plan]                         VARCHAR(5),
        mm                             float,
        max_term                       int,
    );
    PRINT 'Created bronze curriculum_cyc table';
END        
ELSE
    PRINT 'bronze curriculum_cyc table already exists';