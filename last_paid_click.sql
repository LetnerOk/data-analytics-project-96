--Datamart for the Last Paid Click attribution model
WITH Last_Paid_Click AS
(
SELECT DISTINCT ON (s.visitor_id)
    s.visitor_id,
    visit_date,
    source AS utm_source,
    medium AS utm_medium,
    campaign AS utm_campaign,
    lead_id,
    created_at,
    amount,
    closing_reason,
    status_id
FROM sessions s
LEFT JOIN leads l
ON s.visitor_id = l.visitor_id 
WHERE medium <> 'organic' 
ORDER BY s.visitor_id, s.visit_date DESC
)
SELECT *
FROM Last_Paid_Click
ORDER BY visit_date, utm_source, utm_medium, utm_campaign
;
