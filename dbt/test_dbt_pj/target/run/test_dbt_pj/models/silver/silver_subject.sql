
  
    USE [SeniorPJ_DB];
    USE [SeniorPJ_DB];
    
    

    

    
    USE [SeniorPJ_DB];
    EXEC('
        create view "dbo"."silver_subject__dbt_tmp__dbt_tmp_vw" as SELECT
    subj_id,
    subj_rn,
    NULLIF(LTRIM(RTRIM(subj_nen_f)), '''')                AS subj_nen_f,
    subj_id_th,
    NULLIF(LTRIM(RTRIM(subj_nth_f)), '''')                AS subj_nth_f,
    subj_credit,
    subj_des_th,
    subj_des_en,
    cur_id,
    cur_rn,
    study_type,
    NULLIF(LTRIM(RTRIM(tsubj_nen)),  '''')                AS tsubj_nen
FROM bronze.subject;
    ')

EXEC('
            SELECT * INTO "SeniorPJ_DB"."dbo"."silver_subject__dbt_tmp" FROM "SeniorPJ_DB"."dbo"."silver_subject__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS dbo.silver_subject__dbt_tmp__dbt_tmp_vw')



    
    use [SeniorPJ_DB];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'dbo_silver_subject__dbt_tmp_cci'
        AND object_id=object_id('dbo_silver_subject__dbt_tmp')
    )
    DROP index "dbo"."silver_subject__dbt_tmp".dbo_silver_subject__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX dbo_silver_subject__dbt_tmp_cci
    ON "dbo"."silver_subject__dbt_tmp"

   


  