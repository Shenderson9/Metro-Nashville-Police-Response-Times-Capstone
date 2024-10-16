WITH daily_call_counts AS (
    SELECT 
		tencode_desc,
        zip,
		precinct,
        DATE(min_received) AS call_date, 
        COUNT(*) AS call_count
    FROM 
        police_kpi
    GROUP BY 
        tencode_desc, precinct, zip, call_date
)
SELECT 
    police_kpi.zip,
    police_kpi.precinct, 
	police_kpi.tencode_desc,
    ROUND(AVG(call_count), 2) AS avg_calls_per_day,
    ROUND(AVG(dispatch_to_arrival), 0) AS avg_dispatch_to_arrival,
    ROUND(AVG(received_to_arrival), 0) AS avg_received_to_arrival,
    ROUND(AVG(received_to_complete), 0) AS avg_received_to_complete,
    ROUND(AVG(received_to_dispatch), 0) AS avg_received_to_dispatch
FROM 
    daily_call_counts
JOIN 
    police_kpi
ON 
    daily_call_counts.tencode_desc = police_kpi.tencode_desc
    AND daily_call_counts.zip = police_kpi.zip
    AND daily_call_counts.precinct = police_kpi.precinct
GROUP BY 
    police_kpi.tencode_desc, police_kpi.zip, police_kpi.precinct
ORDER BY 
    avg_calls_per_day DESC;