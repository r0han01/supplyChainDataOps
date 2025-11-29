-- Staging model: Clean and standardize raw clickstream data
-- Creates a view in analyticalData schema
-- Includes all relevant columns from raw data for downstream use

SELECT
    -- Identifiers
    sessionID AS sessionId,
    product,
    category,
    department,
    
    -- Dates and time
    date AS eventTimestamp,
    sessionDate,
    eventYear,
    eventMonth,
    eventQuarter,
    eventDayOfWeek,
    eventHourOfDay,
    month,
    hour,
    isWeekend,
    timeOfDay,
    
    -- Event attributes
    eventType,
    pageType,
    isCartAdd,
    
    -- Technical
    ip,
    url
    
FROM {{ source('raw', 'clickstreamEvents') }}
WHERE sessionID IS NOT NULL
  AND date IS NOT NULL
  AND product IS NOT NULL

