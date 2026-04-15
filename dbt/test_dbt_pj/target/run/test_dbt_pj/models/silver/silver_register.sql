
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_register__dbt_tmp__dbt_tmp_vw" as SELECT
    r.Stu_ID                                              AS stu_id,
    r.Reg_Year,
    r.Reg_Term,
    r.Subj_ID,
    r.Subj_Rn,
    r.Reg_Credit,
    NULLIF(LTRIM(RTRIM(r.subj_nen)),  '''')                 AS subj_nen,
    NULLIF(LTRIM(RTRIM(r.subj_nth)),  '''')                 AS subj_nth,
    r.subj_id_th
FROM bronze.register r
LEFT JOIN silver_student_data sd
ON  r.stu_id = sd.stu_id
WHERE CAST(sd.stu_adm_year AS INT) >= 2558;
    ')

EXEC('
            SELECT * INTO "SeniorPJ_DB"."dbo"."silver_register__dbt_tmp" FROM "SeniorPJ_DB"."dbo"."silver_register__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS dbo.silver_register__dbt_tmp__dbt_tmp_vw')



    
    use [SeniorPJ_DB];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'dbo_silver_register__dbt_tmp_cci'
        AND object_id=object_id('dbo_silver_register__dbt_tmp')
    )
    DROP index "dbo"."silver_register__dbt_tmp".dbo_silver_register__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX dbo_silver_register__dbt_tmp_cci
    ON "dbo"."silver_register__dbt_tmp"

   


  