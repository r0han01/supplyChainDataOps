-- Analytics Mart: Product Performance
-- Pre-aggregated product sales and profitability metrics
-- Creates a table in martData schema for product analysis

SELECT
    -- Product dimensions
    dp.productId,
    dp.productName,
    dp.categoryName,
    dp.departmentName,
    dp.productPrice,
    
    -- Aggregated metrics from dimension
    dp.totalOrders,
    dp.totalSales,
    dp.totalProfit,
    dp.avgProfitMargin,
    dp.totalQuantitySold,
    dp.avgQuantityPerOrder,
    
    -- Calculated metrics
    dp.totalSales / NULLIF(dp.totalOrders, 0) AS revenuePerOrder,
    dp.totalProfit / NULLIF(dp.totalSales, 0) * 100 AS overallProfitMargin,
    dp.totalQuantitySold / NULLIF(dp.totalOrders, 0) AS avgUnitsPerOrder,
    
    -- Performance rankings (for top/bottom analysis)
    ROW_NUMBER() OVER (ORDER BY dp.totalSales DESC) AS salesRank,
    ROW_NUMBER() OVER (ORDER BY dp.totalProfit DESC) AS profitRank,
    ROW_NUMBER() OVER (ORDER BY dp.avgProfitMargin DESC) AS marginRank
    
FROM {{ ref('dimProducts') }} dp
WHERE dp.totalOrders > 0

