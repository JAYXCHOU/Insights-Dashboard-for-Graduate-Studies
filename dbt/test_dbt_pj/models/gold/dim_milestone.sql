Select DISTINCT
    ID_form,
    form_name_th,
    form_name_en
FROM {{ref('silver_thesis_data')}}