-- Fact table: Clickstream Events (one row per event)
-- Creates a table in analyticalData schema
-- Grain: sessionId + product + eventTimestamp

SELECT
    -- Primary key (composite: sessionId + product + eventTimestamp)
    sessionId,
    product,
    eventTimestamp,
    
    -- Foreign keys to dimensions
    dp.productId,  -- Matched via productName (LEFT JOIN for unmatched products)
    DATE(eventTimestamp) AS dateKey,
    
    -- Event metrics
    eventType,
    pageType,
    timeOfDay,
    isCartAdd,
    isWeekend,
    
    -- Additional context
    category,
    department,
    eventYear,
    eventMonth,
    eventQuarter,
    eventDayOfWeek,
    eventHourOfDay,
    sessionDate,
    ip,
    url
    
FROM {{ ref('stgClickstream') }} cs
LEFT JOIN {{ ref('dimProducts') }} dp
    ON cs.product = dp.productName
WHERE sessionId IS NOT NULL
  AND eventTimestamp IS NOT NULL
  AND product IS NOT NULL

