WITH base_data AS (
    SELECT
        stu_ID,
        Sch_ID,

        -- clean text + handle NULL
        NULLIF(LTRIM(RTRIM(Scholar_thai)), '') AS Scholar_thai,
        NULLIF(LTRIM(RTRIM(Scholar_eng)), '') AS Scholar_eng,

        RIGHT('0000' + LTRIM(RTRIM(Rec_Syear)), 4) AS Rec_Syear,
        LTRIM(RTRIM(F_Term)) AS F_Term,
        RIGHT('0000' + LTRIM(RTRIM(Rec_Eyear)), 4) AS Rec_Eyear,
        LTRIM(RTRIM(L_Term)) AS L_Term,

        -- clean date string + NULL handling
        NULLIF(LTRIM(RTRIM(GetDate)), '') AS GetDate,
        NULLIF(LTRIM(RTRIM(FinalDate)), '') AS FinalDate,

        -- clean amount (remove comma)
        TRY_CAST(REPLACE(Amount, ',', '') AS float) AS Amount

    FROM bronze.scholar
    WHERE TRY_CAST(stu_id AS INT) >= 5800000
),

clean_date AS (
    SELECT
        *,
        REPLACE(GetDate, '/', '') AS GetDate_clean,
        REPLACE(FinalDate, '/', '') AS FinalDate_clean
    FROM base_data
),

fix_date AS (
    SELECT
        *,

        -- FIX GetDate
        CASE
            WHEN LEN(GetDate_clean) = 8 THEN GetDate_clean
            WHEN LEN(GetDate_clean) = 7 
                THEN LEFT(GetDate_clean,4) + '0' + RIGHT(GetDate_clean,3)
            WHEN LEN(GetDate_clean) = 6 
                THEN LEFT(GetDate_clean,6) + '01'
            ELSE NULL
        END AS GetDate_fixed,

        -- FIX FinalDate
        CASE
            WHEN LEN(FinalDate_clean) = 8 THEN FinalDate_clean
            WHEN LEN(FinalDate_clean) = 7 
                THEN LEFT(FinalDate_clean,4) + '0' + RIGHT(FinalDate_clean,3)
            WHEN LEN(FinalDate_clean) = 6 
                THEN LEFT(FinalDate_clean,6) + '01'
            ELSE NULL
        END AS FinalDate_fixed

    FROM clean_date
),

final_data AS (
    SELECT DISTINCT  
        stu_ID,
        Sch_ID,
        Scholar_thai,
        Scholar_eng,

        Rec_Syear,
        F_Term,
        Rec_Eyear,
        L_Term,

        -- validate date
        CASE 
            WHEN LEN(GetDate_fixed) = 8 THEN GetDate_fixed 
            ELSE NULL 
        END AS GetDate,

        CASE 
            WHEN LEN(FinalDate_fixed) = 8 THEN FinalDate_fixed 
            ELSE NULL 
        END AS FinalDate,

        Amount

    FROM fix_date
)
SELECT
    f.stu_ID,
    f.Sch_ID,
    f.Scholar_thai,
    f.Scholar_eng ,
    f.Rec_Syear,
    f.F_Term,
    f.Rec_Eyear,
    f.L_Term,
    f.GetDate,
    f.FinalDate,
    f.Amount
    -- f.stu_adm_year

FROM
final_data f

Left join silver_student_data sd
ON  f.stu_id = sd.stu_id

WHERE CAST(sd.stu_adm_year AS INT) >= 2558;

