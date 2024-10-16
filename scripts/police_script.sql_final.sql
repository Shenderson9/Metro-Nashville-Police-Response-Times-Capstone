WITH RECURSIVE date_range AS (
    SELECT MIN(DATE(call_rec)) AS start_date, MAX(DATE(call_rec)) AS end_date
    FROM police_kpi
),
all_dates AS (
    SELECT start_date::timestamp AS call_date
    FROM date_range
    UNION ALL
    SELECT call_date + INTERVAL '1 day'
    FROM all_dates
    WHERE call_date < (SELECT end_date::timestamp FROM date_range)
),
daily_calls AS (
    SELECT 
        zip,
        tencode_desc,
        response_code,
        DATE(call_rec) AS call_date,
        COUNT(*) AS total_calls,
        SUM(dispatch_to_arrival) AS sum_dispatch_to_arrival,
        SUM(received_to_arrival) AS sum_received_to_arrival,
        SUM(received_to_complete) AS sum_received_to_complete,
        SUM(received_to_dispatch) AS sum_received_to_dispatch
    FROM 
        police_kpi p
    GROUP BY 
        zip, tencode_desc, response_code, DATE(call_rec)
),
all_combo AS (
    SELECT 
        d.call_date,
        p.zip,
        p.tencode_desc,
        p.response_code
    FROM 
        all_dates d
    CROSS JOIN (SELECT DISTINCT zip, tencode_desc, response_code FROM police_kpi) p
)
SELECT 
    ac.zip,
    ac.tencode_desc,
    ac.response_code,
    ROUND(AVG(COALESCE(dc.total_calls, 0)), 2) AS avg_calls_per_day, 
    ROUND(AVG(dc.sum_dispatch_to_arrival), 0) AS avg_dispatch_to_arrival,
    ROUND(AVG(dc.sum_received_to_arrival), 0) AS avg_received_to_arrival,
    ROUND(AVG(dc.sum_received_to_complete), 0) AS avg_received_to_complete,
    ROUND(AVG(dc.sum_received_to_dispatch), 0) AS avg_received_to_dispatch
FROM 
    all_combo ac
LEFT JOIN 
    daily_calls dc
ON 
    ac.zip = dc.zip 
    AND ac.tencode_desc = dc.tencode_desc 
    AND ac.response_code = dc.response_code
    AND ac.call_date = dc.call_date

GROUP BY 
    ac.zip, ac.tencode_desc, ac.response_code
ORDER BY
    ac.zip, ac.tencode_desc, ac.response_code;