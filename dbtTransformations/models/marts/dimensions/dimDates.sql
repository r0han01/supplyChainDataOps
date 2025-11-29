-- Dimension: Dates
-- Creates a table in analyticalData schema
-- One row per unique date from order dates

SELECT DISTINCT
    DATE(orderDate) AS dateKey,
    
    -- Year attributes
    orderYear AS year,
    
    -- Quarter attributes
    orderQuarter AS quarter,
    CASE 
        WHEN orderQuarter = 'Q1' THEN 1
        WHEN orderQuarter = 'Q2' THEN 2
        WHEN orderQuarter = 'Q3' THEN 3
        WHEN orderQuarter = 'Q4' THEN 4
    END AS quarterNumber,
    
    -- Month attributes
    orderMonth AS month,
    TO_CHAR(DATE(orderDate), 'MMMM') AS monthName,
    
    -- Day attributes
    orderDayOfWeek AS dayOfWeek,
    DAYOFWEEK(DATE(orderDate)) AS dayOfWeekNumber,
    DAY(DATE(orderDate)) AS dayOfMonth,
    
    -- Business logic
    CASE 
        WHEN orderDayOfWeek IN ('Saturday', 'Sunday') THEN TRUE 
        ELSE FALSE 
    END AS isWeekend,
    
    -- Fiscal year (assuming calendar year = fiscal year)
    orderYear AS fiscalYear,
    orderQuarter AS fiscalQuarter
    
FROM {{ ref('stgSupplyChainOrders') }}
WHERE orderDate IS NOT NULL
ORDER BY dateKey

