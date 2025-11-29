-- Analytics Mart: Operational Performance
-- Pre-aggregated delivery and shipping metrics by status, mode, and geography
-- Creates a table in martData schema for operational dashboards

SELECT
    -- Time dimensions
    dd.year,
    dd.quarter,
    dd.monthName AS month,
    
    -- Operational dimensions
    fo.deliveryStatus,
    fo.shippingMode,
    fo.orderStatus,
    fo.paymentType,
    
    -- Geographic dimensions
    dc.customerCountry,
    dc.customerState,
    fo.orderRegion,
    fo.market,
    
    -- Aggregated metrics
    COUNT(DISTINCT fo.orderId) AS totalOrders,
    COUNT(*) AS totalOrderItems,
    COUNT(DISTINCT fo.customerId) AS uniqueCustomers,
    
    -- Delivery performance metrics
    AVG(fo.deliveryDelay) AS avgDeliveryDelayDays,
    AVG(fo.shippingDaysReal) AS avgShippingDaysReal,
    AVG(fo.shippingDaysScheduled) AS avgShippingDaysScheduled,
    SUM(CASE WHEN fo.isLate = 1 THEN 1 ELSE 0 END) AS lateDeliveries,
    COUNT(*) AS totalDeliveries,
    ROUND(SUM(CASE WHEN fo.isLate = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS lateDeliveryPercentage,
    
    -- Financial metrics
    SUM(fo.revenue) AS totalRevenue,
    SUM(fo.profit) AS totalProfit,
    AVG(fo.margin) AS avgProfitMargin
    
FROM {{ ref('factOrders') }} fo
INNER JOIN {{ ref('dimDates') }} dd
    ON fo.dateKey = dd.dateKey
INNER JOIN {{ ref('dimCustomers') }} dc
    ON fo.customerId = dc.customerId
GROUP BY 
    dd.year,
    dd.quarter,
    dd.monthName,
    fo.deliveryStatus,
    fo.shippingMode,
    fo.orderStatus,
    fo.paymentType,
    dc.customerCountry,
    dc.customerState,
    fo.orderRegion,
    fo.market

