WITH daily_call_counts AS (
    SELECT 
        zip,
        DATE(min_received) AS call_date, 
        COUNT(*) AS call_count
    FROM 
        police_kpi
    GROUP BY 
        zip, call_date
)
SELECT 
    zip, 
    ROUND(AVG(call_count), 2) AS avg_calls_per_day,
    ROUND(AVG(dispatch_to_arrival), 0) AS avg_dispatch_to_arrival,
    ROUND(AVG(received_to_arrival), 0) AS avg_received_to_arrival,
    ROUND(AVG(received_to_complete), 0) AS avg_received_to_complete,
    ROUND(AVG(received_to_dispatch), 0) AS avg_received_to_dispatch
FROM daily_call_counts
JOIN police_kpi
USING(zip)
GROUP BY 
    zip
ORDER BY 
    avg_calls_per_day DESC;