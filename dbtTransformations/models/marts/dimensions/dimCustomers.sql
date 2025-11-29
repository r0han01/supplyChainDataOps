-- Dimension: Customers (combines customer attributes + geography)
-- Creates a table in analyticalData schema
-- One row per customer with aggregated metrics

SELECT
    -- Primary key
    customerId,
    
    -- Customer attributes (consistent per customer - verified)
    customerSegment,
    customerCity,
    customerState,
    customerCountry,
    customerZipcode,
    customerFname,
    customerLname,
    customerStreet,
    
    -- Aggregated metrics
    COUNT(DISTINCT orderId) AS totalOrders,
    SUM(revenue) AS totalRevenue,
    SUM(profit) AS totalProfit,
    AVG(revenue) AS avgOrderValue,
    AVG(profitMarginPct) AS avgProfitMargin,
    MIN(orderDate) AS firstOrderDate,
    MAX(orderDate) AS lastOrderDate,
    DATEDIFF('day', MIN(orderDate), MAX(orderDate)) AS customerLifespanDays,
    
    -- Calculated metrics
    SUM(revenue) / NULLIF(COUNT(DISTINCT orderId), 0) AS revenuePerOrder,
    SUM(profit) / NULLIF(SUM(revenue), 0) * 100 AS overallProfitMargin
    
FROM {{ ref('stgSupplyChainOrders') }}
GROUP BY 
    customerId,
    customerSegment,
    customerCity,
    customerState,
    customerCountry,
    customerZipcode,
    customerFname,
    customerLname,
    customerStreet

