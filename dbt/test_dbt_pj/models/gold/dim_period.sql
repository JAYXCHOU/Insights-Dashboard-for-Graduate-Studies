Select * FROM(
    VALUES
    ('1','phase1', 'ก่อนสอบวิทยานิพนธ์', 'วันที่ส่งgr.1 - วันที่ผ่านgr.2'),
    ('2', 'phase2','ทำวิทยานิพนธ์','วันที่ผ่าน gr.2 - วันที่ส่ง e-thesis ครั้งแรก'),
    ('3', 'phase3','แก้วิทยานิพนธ์', 'วันที่ส่ง e-thesis ครั้งแรก - วันที่ e-thesis อนุมัติผ่าน'),
    ('4', 'phase4','รอตีพิมพ์', 'วันที่ e-thesis อนุมัติผ่าน - วันที่ยื่นgr.5')
) AS dim_period(period_id, period_id_name, period_name, period_desc)