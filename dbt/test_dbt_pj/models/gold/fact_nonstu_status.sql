SELECT
    stu_id,
    snon_term,
    snon_year,
    snon_memo,
    nstu_id,
    nstu_status_type_thai,
    nstu_status_reason_thai,
    nstu_status_type_eng,
    nstu_status_reason_eng,
    sta_outdate
from {{ref('silver_stu_status')}} s
