Select * FROM(
    VALUES
    ('1','phase1', 'ก่อนสอบวิทยานิพนธ์'),
    ('2', 'phase2','ทำวิทยานิพนธ์'),
    ('3', 'phase3','แก้วิทยานิพนธ์'),
    ('4', 'phase4','รอตีพิมพ์')
) AS dim_period(period_id, period_id_name, period_name)