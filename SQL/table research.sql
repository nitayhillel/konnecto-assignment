SELECT min(created_time),
       max(created_time),
       COUNT(*) row_count

FROM assignment.public.assignment_click_stream cs
;

SELECT * 

FROM assignment_click_stream

WHERE user_id = 1106610618 
--AND referrer_url IS NOT NULL
AND created_time between to_timestamp('2023-03-03 02:10:35.000') and to_timestamp('2023-03-03 05:10:35.000')

ORDER BY created_time

;
