/********************************************************/
--Table name with aggregate_last_paid_click is cost_revenue
-- Metrics by source for LPC model
SELECT
   utm_source,
   ROUND(SUM(total_cost)/SUM(visitors_count), 2) AS CPU,
   ROUND(SUM(total_cost)/SUM(leads_count), 2) AS CPL,
   ROUND(SUM(total_cost)/SUM(purchases_count), 2) AS CPPU,
   ROUND((SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost), 2) AS ROI
FROM cost_revenue
GROUP BY utm_source
HAVING  SUM(total_cost) > 0
    AND SUM(visitors_count) > 0
    AND SUM(purchases_count) > 0
    AND SUM(revenue) > 0

/********************************************************/
-- Metrics by source, medium and campaign for LPC model
SELECT
   utm_source,
   utm_medium,
   utm_campaign,
   ROUND(SUM(total_cost)/SUM(visitors_count), 2) AS CPU,
   ROUND(SUM(total_cost)/SUM(leads_count), 2) AS CPL,
   ROUND(SUM(total_cost)/SUM(purchases_count), 2) AS CPPU,
   ROUND((SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost), 2) AS ROI
FROM cost_revenue
GROUP BY 1, 2, 3
HAVING  SUM(total_cost) > 0
    AND SUM(visitors_count) > 0
    AND SUM(purchases_count) > 0
    AND SUM(revenue) > 0

/********************************************************/
-- ROI >= 0 by source, medium and campaign with LPC model
SELECT
   utm_source,
   utm_medium,
   utm_campaign,
   SUM(revenue) AS revenue,
   SUM(total_cost) AS total_cost,
  ROUND((SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost), 2) AS ROI
FROM cost_revenue
GROUP BY 1, 2, 3
HAVING  SUM(total_cost) > 0
AND (SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost) >= 0
ORDER BY 6 DESC

/********************************************************/
-- ROI < 0 by source, medium and campaign with LPC model
SELECT
   utm_source,
   utm_medium,
   utm_campaign,
   SUM(revenue) AS revenue,
   SUM(total_cost) AS total_cost,
  ROUND((SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost), 2) AS ROI
FROM cost_revenue
GROUP BY 1, 2, 3
HAVING  SUM(total_cost) > 0
AND (SUM(revenue) - SUM(total_cost))*100.00/SUM(total_cost) < 0
ORDER BY 6 DESC

/********************************************************/
--Number of visitors per day
SELECT
    TO_CHAR(visit_date, 'YYYY-MM-DD') AS Day_of_month,
    COUNT(DISTINCT visitor_id)
FROM sessions s
GROUP BY 1
ORDER BY 2 DESC
;

/********************************************************/
--Number of visitors per month
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    COUNT(DISTINCT visitor_id) AS count_visitors
FROM sessions s
GROUP BY 1
;

/********************************************************/
-- Number of visitors by source per month
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    source,
    COUNT(DISTINCT visitor_id) AS count_visitors
FROM sessions s
GROUP BY 1,2
ORDER BY 3 DESC
;

/********************************************************/
-- Number of visitors by source/mediu/campaing  per month
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    s.source AS utm_source,
    s.medium AS utm_medium,
    s.campaign AS utm_campaign,
    COUNT(DISTINCT visitor_id) AS count_visitors
FROM sessions s
GROUP BY 1,2,3,4
ORDER BY 5 DESC
; 

/********************************************************/
-- Number of visitors by source/mediu/campaing per month for paid campaign
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    s.source AS utm_source,
    s.medium AS utm_medium,
    s.campaign AS utm_campaign,
    COUNT(DISTINCT visitor_id) AS count_visitors
FROM sessions s
WHERE s.medium != 'organic'
GROUP BY 1,2,3,4
HAVING COUNT(DISTINCT visitor_id) > 1
ORDER BY utm_source DESC, 5 DESC
; 

/********************************************************/
--Number of visitors by source per month for pie chart
WITH count_visit AS
(
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    source,
    s.medium,
    COUNT(DISTINCT visitor_id) AS count_visitors,
    CASE
        WHEN source = 'yandex' THEN source
        WHEN source = 'vk' THEN source
        WHEN s.medium = 'organic' THEN 'бесплатные источники'
        ELSE 'другие источники'
    END name_source 
FROM sessions s
GROUP BY 1,2, 3
)
SELECT 
    Month,
    name_source,
    SUM(count_visitors)
FROM count_visit
GROUP BY 1, 2
;

/********************************************************/
--Number of visitors per month for free channel
SELECT
    TO_CHAR(visit_date, 'Month') AS Month,
    source,
    medium,
    COUNT(DISTINCT visitor_id) AS count_visitors
FROM sessions s
WHERE medium = 'organic'
GROUP BY 1, 2, 3
ORDER BY 4 DESC
;


/********************************************************/
--Number of visitors by source per day
SELECT
    TO_CHAR(visit_date, 'YYYY-MM-DD') AS Day_of_month,
    source,
    COUNT(DISTINCT visitor_id)
FROM sessions s
GROUP BY 1,2
ORDER BY 1, 3 DESC 
;

/********************************************************/
--Number of visitors by source per day for paid campaign
SELECT
    TO_CHAR(visit_date, 'YYYY-MM-DD') AS Day_of_month,
    source,
    COUNT(DISTINCT visitor_id)
FROM sessions s
WHERE s.medium != 'organic'
GROUP BY 1,2
ORDER BY 1, 3 DESC 
;

/********************************************************/
-- 10 sources with max of visitors number by source per week
WITH tab AS

(
SELECT
    source,
    COUNT(DISTINCT visitor_id) AS count_visitors,
    TO_CHAR(visit_date, 'WW') AS Num_week,
    ROW_NUMBER() OVER(partition BY TO_CHAR(visit_date, 'WW') ORDER BY COUNT(DISTINCT visitor_id) DESC) AS rn
FROM sessions s
GROUP BY source,TO_CHAR(visit_date, 'WW')
ORDER BY TO_CHAR(visit_date, 'WW'), 2 DESC
)

SELECT 
    Num_week,    
    source,
    count_visitors    
FROM tab
WHERE rn <= 10

/********************************************************/
--Number of leads per month 
SELECT
    TO_CHAR(created_at, 'Month'),
    COUNT(DISTINCT lead_id) count_leads
FROM leads
GROUP BY TO_CHAR(created_at, 'Month')
;

/********************************************************/
--Number of leads by source per month
SELECT 
     TO_CHAR(created_at , 'Month') AS Month,
     s.source,
     COUNT(DISTINCT lead_id) AS count_leads
FROM leads l
INNER JOIN sessions s
USING(visitor_id) 
GROUP BY 1, 2
ORDER BY 3 DESC
;

/********************************************************/
--Number of leads by source per month for pie chart
WITH count_lead AS
(
SELECT 
     TO_CHAR(created_at , 'Month') AS Month,
     s.source,
     s.medium,
     COUNT(lead_id) AS count_leads,
         CASE
        WHEN source = 'yandex' THEN 'yandex'
        WHEN source = 'vk' THEN 'vk'
        WHEN s.medium = 'organic' THEN 'бесплатные источники'
        ELSE 'другие источники'
    END name_source 
FROM leads l
INNER JOIN sessions s
USING(visitor_id) 
GROUP BY 1, 2, s.medium
)
SELECT 
    name_source,
    SUM(count_leads) AS group_of_leads
FROM count_lead
GROUP BY 1
;

/********************************************************/
--Number of leads by source/mediu/campaing per month
SELECT
    TO_CHAR(created_at, 'Month'),
    s.source AS utm_source,
    s.medium AS utm_medium,
    s.campaign AS utm_campaign,
    count(l.lead_id) AS lead_count
FROM leads AS l
INNER JOIN sessions AS s
    ON
        l.visitor_id = s.visitor_id
GROUP BY 1, 2, 3,4
HAVING count(l.lead_id) != 0
ORDER BY 5 DESC
;

/********************************************************/
--Number of leads by source per day
SELECT 
     TO_CHAR(created_at , 'YYYY-MM-DD') AS Day_of_month,
     s.source,
     COUNT(DISTINCT lead_id) AS count_leads
FROM leads l
INNER JOIN sessions s
USING(visitor_id) 
GROUP BY 1, 2
;

/********************************************************/
--Number of visitors and leads per month
SELECT 
     TO_CHAR(visit_date, 'Month') AS Month,
     COUNT(DISTINCT visitor_id) AS count_visitors,
     COUNT(DISTINCT lead_id) AS count_leads
FROM sessions s
LEFT JOIN leads l
USING(visitor_id) 
GROUP BY 1
;

/********************************************************/
--Number of visitors, leads and clients by source per month with non-zero leads
WITH visit_lead AS
(
SELECT
    DISTINCT ON (s.visitor_id) s.visitor_id,
    visit_date,
    s.source,
    lead_id,
    closing_reason,
    CASE 
        WHEN closing_reason = 'Успешная продажа' OR status_id = 142
        THEN 1 ELSE 0 
    END purchases,
    status_id   
FROM sessions s
LEFT JOIN leads l
ON s.visitor_id = l.visitor_id
)
SELECT
     source,
     COUNT(visitor_id) AS count_visitors,
     COUNT(lead_id) AS count_leads,
     SUM(purchases) AS count_clients
FROM visit_lead
GROUP BY TO_CHAR(visit_date, 'Month'), source
HAVING COUNT(DISTINCT lead_id) != 0
ORDER BY 3 DESC
;

/********************************************************/
--Conversion of visitors to leads, leads to clients and visitors to clients
WITH visit_lead AS
(
SELECT
    DISTINCT ON (s.visitor_id) s.visitor_id,
    visit_date,
    s.source,
    lead_id,
    closing_reason,
    CASE 
        WHEN closing_reason = 'Успешная продажа' OR status_id = 142
        THEN 1 ELSE 0 
    END purchases,
    status_id   
FROM sessions s
LEFT JOIN leads l
ON s.visitor_id = l.visitor_id
)
SELECT
     source,
     ROUND(COUNT(lead_id) * 100.00 / COUNT(visitor_id), 2) AS conv_visit_to_lead,
     ROUND(SUM(purchases) * 100.00 / COUNT(lead_id), 2) AS conv_lead_to_client,
     ROUND(SUM(purchases) * 100.00 / COUNT(visitor_id), 2) AS conv_visit_to_client
FROM visit_lead
GROUP BY TO_CHAR(visit_date, 'Month'), source
HAVING COUNT(lead_id) != 0
ORDER BY 2 DESC, 3 DESC
;

/********************************************************/
--Number of visitors, leads and clients per month for Funnel
WITH visit_lead AS
(
SELECT
    DISTINCT ON (s.visitor_id)
    s.visitor_id,
    visit_date,
    lead_id,
    closing_reason,
    CASE 
        WHEN closing_reason = 'Успешная продажа' OR status_id = 142
        THEN 1 ELSE 0 
    END purchases,
    status_id   
FROM sessions s
LEFT JOIN leads l
ON s.visitor_id = l.visitor_id
)
SELECT
     COUNT(DISTINCT visitor_id) AS count_visitors,
     COUNT(DISTINCT lead_id) AS count_leads,
     SUM(purchases)
FROM visit_lead
GROUP BY TO_CHAR(day_visit_date, 'Month')
;

/********************************************************/
--Number of visitors, leads and purchases per month for Funnel with LPC model
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
AND visit_date <= created_at
WHERE medium != 'organic' 
),
Last_Paid_Click AS
(
SELECT *,
DATE_TRUNC('day', visit_date) AS day_visit_date
FROM Paid_Click
WHERE rn = 1
)
SELECT 
    COUNT(visitor_id) AS count_visitors,
    COUNT(lead_id) AS count_leads,
    SUM(purchases) AS count_purchases
FROM Last_Paid_Click
GROUP BY TO_CHAR(day_visit_date, 'Month')

/********************************************************/
--Total cost for yandex and vk per day
SELECT
    TO_CHAR(campaign_date, 'YYYY-MM-DD') AS day_of_month,
    utm_source,
    utm_medium,
    utm_campaign,
    SUM(daily_spent) AS spent 
FROM vk_ads vk
GROUP BY 1,2,3,4
UNION ALL
SELECT
    TO_CHAR(campaign_date, 'YYYY-MM-DD') AS day_of_month,
    utm_source,
    utm_medium,
    utm_campaign,
    SUM(daily_spent) AS spent  
FROM ya_ads ya
GROUP BY 1,2,3,4
ORDER BY campaign_date

/********************************************************/
--Total cost for yandex and vk per month
SELECT
    TO_CHAR(campaign_date, 'Month') AS month,
    utm_source,
    utm_medium,
    utm_campaign,
    SUM(daily_spent) AS spent 
FROM vk_ads vk
GROUP BY 1,2,3,4
UNION ALL
SELECT
    TO_CHAR(campaign_date, 'Month') AS month,
    utm_source,
    utm_medium,
    utm_campaign,
    SUM(daily_spent) AS spent  
FROM ya_ads ya
GROUP BY 1,2,3,4
ORDER BY 1
