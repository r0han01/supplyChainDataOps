-- Analytics Mart: Customer Analytics
-- Pre-aggregated customer behavior and value metrics
-- Creates a table in martData schema for customer segmentation analysis

SELECT
    -- Customer dimensions
    dc.customerId,
    dc.customerSegment,
    dc.customerCountry,
    dc.customerState,
    dc.customerCity,
    
    -- Customer value segments (data-driven)
    CASE 
        WHEN dc.totalRevenue >= 10000 THEN 'High Value (10K+)'
        WHEN dc.totalRevenue >= 5000 THEN 'Medium Value (5K-10K)'
        WHEN dc.totalRevenue >= 2000 THEN 'Low-Medium Value (2K-5K)'
        ELSE 'Low Value (<2K)'
    END AS valueSegment,
    
    -- Customer metrics from dimension
    dc.totalOrders,
    dc.totalRevenue,
    dc.totalProfit,
    dc.avgOrderValue,
    dc.avgProfitMargin,
    dc.customerLifespanDays,
    dc.firstOrderDate,
    dc.lastOrderDate,
    
    -- Calculated metrics
    dc.totalRevenue / NULLIF(dc.totalOrders, 0) AS revenuePerOrder,
    dc.totalProfit / NULLIF(dc.totalRevenue, 0) * 100 AS overallProfitMargin,
    dc.totalOrders / NULLIF(DATEDIFF('day', dc.firstOrderDate, dc.lastOrderDate), 0) * 30 AS avgOrdersPerMonth
    
FROM {{ ref('dimCustomers') }} dc
WHERE dc.totalOrders > 0

