
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_register__dbt_tmp__dbt_tmp_vw" as SELECT
    Stu_ID                                              AS stu_id,
    Reg_Year,
    Reg_Term,
    Subj_ID,
    Subj_Rn,
    Reg_Credit,
    NULLIF(LTRIM(RTRIM(subj_nen)),  '''')                 AS subj_nen,
    NULLIF(LTRIM(RTRIM(subj_nth)),  '''')                 AS subj_nth,
    subj_id_th
FROM bronze.register
WHERE TRY_CAST(Stu_ID AS INT) >= 5800000;
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

   


  