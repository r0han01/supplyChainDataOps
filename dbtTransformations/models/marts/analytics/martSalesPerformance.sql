-- Analytics Mart: Sales Performance
-- Pre-aggregated sales metrics by time period, customer segment, and product category
-- Creates a table in martData schema for BI dashboards

SELECT
    -- Time dimensions
    dd.year,
    dd.quarter,
    dd.monthName AS month,
    dd.dateKey,
    
    -- Customer dimensions
    dc.customerSegment,
    dc.customerCountry,
    dc.customerState,
    
    -- Product dimensions
    dp.categoryName,
    dp.departmentName,
    
    -- Aggregated metrics
    COUNT(DISTINCT fo.orderId) AS totalOrders,
    COUNT(*) AS totalOrderItems,
    COUNT(DISTINCT fo.customerId) AS uniqueCustomers,
    COUNT(DISTINCT fo.productId) AS uniqueProducts,
    
    -- Financial metrics
    SUM(fo.revenue) AS totalRevenue,
    SUM(fo.profit) AS totalProfit,
    AVG(fo.margin) AS avgProfitMargin,
    SUM(fo.quantity) AS totalUnitsSold,
    AVG(fo.revenue) AS avgRevenuePerItem,
    AVG(fo.profit) AS avgProfitPerItem,
    
    -- Calculated metrics
    SUM(fo.revenue) / NULLIF(COUNT(DISTINCT fo.orderId), 0) AS revenuePerOrder,
    SUM(fo.profit) / NULLIF(SUM(fo.revenue), 0) * 100 AS overallProfitMargin,
    SUM(fo.quantity) / NULLIF(COUNT(DISTINCT fo.orderId), 0) AS avgUnitsPerOrder
    
FROM {{ ref('factOrders') }} fo
INNER JOIN {{ ref('dimDates') }} dd
    ON fo.dateKey = dd.dateKey
INNER JOIN {{ ref('dimCustomers') }} dc
    ON fo.customerId = dc.customerId
INNER JOIN {{ ref('dimProducts') }} dp
    ON fo.productId = dp.productId
GROUP BY 
    dd.year,
    dd.quarter,
    dd.monthName,
    dd.dateKey,
    dc.customerSegment,
    dc.customerCountry,
    dc.customerState,
    dp.categoryName,
    dp.departmentName

