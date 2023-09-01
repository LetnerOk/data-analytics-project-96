--data aggregation from the Last Paid Click attribution model

WITH Paid_Click AS
(
SELECT 
    s.visitor_id,
    visit_date,
    source AS utm_source,
    medium AS utm_medium,
    campaign AS utm_campaign,
    lead_id,
    created_at,
    COALESCE(amount, 0) AS amount,
    closing_reason,
    CASE 
        WHEN closing_reason = 'Успешная продажа' OR status_id = 142
        THEN 1 ELSE 0 
    END purchases,
    status_id,
    ROW_NUMBER() OVER(PARTITION BY s.visitor_id ORDER BY visit_date DESC) rn
FROM sessions s
LEFT JOIN leads l
ON s.visitor_id = l.visitor_id 
WHERE medium <> 'organic' 
),
Last_Paid_Click AS
(
SELECT *,
DATE_TRUNC('day', visit_date) AS day_visit_date
FROM Paid_Click
WHERE rn = 1
ORDER BY visit_date, utm_source, utm_medium, utm_campaign
),
vk_daily AS
(
SELECT 
    DATE_TRUNC('day', campaign_date) AS vk_campaign_date,
    SUM(daily_spent) AS total_vk_spent,
    utm_source,
    utm_medium,
    utm_campaign
FROM vk_ads
GROUP BY DATE_TRUNC('day',campaign_date), utm_source, utm_medium, utm_campaign
),
ya_daily AS
(
SELECT 
    DATE_TRUNC('day', campaign_date) AS ya_campaign_date,
    SUM(daily_spent) AS total_ya_spent,
    utm_source,
    utm_medium,
    utm_campaign
FROM ya_ads
GROUP BY DATE_TRUNC('day',campaign_date), utm_source, utm_medium, utm_campaign
),
leads AS
(
SELECT
    day_visit_date AS visit_date,
    lpc.utm_source,
    lpc.utm_medium,
    lpc.utm_campaign,
    COUNT(visitor_id) AS visitors_count,
    COUNT(lead_id) AS leads_count,
    SUM(purchases) AS purchases_count,
    SUM(amount) AS revenue
FROM Last_Paid_Click lpc
--ORDER BY visit_date, visitors_count DESC, l.utm_source, l.utm_medium, l.utm_campaign
GROUP BY day_visit_date, lpc.utm_source, lpc.utm_medium, lpc.utm_campaign
)
SELECT
    visit_date,
    l.utm_source,
    l.utm_medium,
    l.utm_campaign,
    visitors_count,
    COALESCE(total_ya_spent,0) + COALESCE(total_vk_spent,0) AS total_cost,
    leads_count,
    purchases_count,
    revenue
FROM leads l
LEFT JOIN vk_daily vk
ON l.visit_date = vk.vk_campaign_date AND
   l.utm_source = vk.utm_source AND
   l.utm_medium = vk.utm_medium AND
   l.utm_campaign = vk.utm_campaign
LEFT JOIN ya_daily ya
ON l.visit_date = ya.ya_campaign_date AND
   l.utm_source = ya.utm_source AND
   l.utm_medium = ya.utm_medium AND
   l.utm_campaign = ya.utm_campaign
ORDER BY visit_date, visitors_count DESC, l.utm_source, l.utm_medium, l.utm_campaign
--For top 15 by purchases_count change sorting and add filter with limit
--ORDER BY purchases_count DESC
--LIMIT 15