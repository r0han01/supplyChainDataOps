-- Analytics Mart: Clickstream Conversion
-- Pre-aggregated clickstream metrics by product, time, and event type
-- Creates a table in martData schema for conversion funnel analysis

SELECT
    -- Time dimensions
    dd.year,
    dd.quarter,
    dd.monthName AS month,
    dd.dateKey,
    fc.timeOfDay,
    fc.isWeekend,
    
    -- Product dimensions
    fc.product,
    dp.productId,
    dp.categoryName,
    dp.departmentName,
    
    -- Event dimensions
    fc.eventType,
    fc.pageType,
    
    -- Aggregated metrics
    COUNT(*) AS totalEvents,
    COUNT(DISTINCT fc.sessionId) AS uniqueSessions,
    COUNT(DISTINCT fc.product) AS uniqueProducts,
    
    -- Conversion metrics
    COUNT(CASE WHEN fc.eventType = 'Page View' THEN 1 END) AS pageViews,
    COUNT(CASE WHEN fc.eventType = 'Cart Add' THEN 1 END) AS cartAdds,
    ROUND(COUNT(CASE WHEN fc.eventType = 'Cart Add' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN fc.eventType = 'Page View' THEN 1 END), 0), 2) AS conversionRate,
    
    -- Session metrics
    COUNT(DISTINCT CASE WHEN fc.eventType = 'Page View' THEN fc.sessionId END) AS sessionsWithViews,
    COUNT(DISTINCT CASE WHEN fc.eventType = 'Cart Add' THEN fc.sessionId END) AS sessionsWithCartAdds
    
FROM {{ ref('factClickstream') }} fc
INNER JOIN {{ ref('dimDates') }} dd
    ON fc.dateKey = dd.dateKey
LEFT JOIN {{ ref('dimProducts') }} dp
    ON fc.productId = dp.productId
GROUP BY 
    dd.year,
    dd.quarter,
    dd.monthName,
    dd.dateKey,
    fc.timeOfDay,
    fc.isWeekend,
    fc.product,
    dp.productId,
    dp.categoryName,
    dp.departmentName,
    fc.eventType,
    fc.pageType

