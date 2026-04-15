
INSERT INTO bronze.sta_nonstu(
    nstu_id,
    nstu_des_thai,
    nstu_des_eng
)
SELECT
    RIGHT('00' + CAST(nstu_id AS varchar), 2),
    nstu_des,
    nstu_desEn
FROM dbo.ICT_sta_nonstu s

WHERE NOT EXISTS (
    SELECT 1
    FROM bronze.sta_nonstu b
    WHERE b.nstu_id = RIGHT('00' + CAST(s.nstu_id AS varchar), 2)
);
