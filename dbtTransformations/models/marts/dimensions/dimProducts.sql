-- Dimension: Products (combines product + category attributes)
-- Creates a table in analyticalData schema
-- One row per product with aggregated metrics

SELECT
    -- Primary key
    productId,
    
    -- Product attributes (consistent per product - verified)
    MAX(productName) AS productName,
    MAX(productPrice) AS productPrice,
    MAX(productImage) AS productImage,
    MAX(categoryName) AS categoryName,
    MAX(categoryId) AS categoryId,
    MAX(departmentName) AS departmentName,
    MAX(departmentId) AS departmentId,
    MAX(productCategoryId) AS productCategoryId,
    
    -- Aggregated metrics
    COUNT(DISTINCT orderId) AS totalOrders,
    SUM(revenue) AS totalSales,
    SUM(profit) AS totalProfit,
    AVG(profitMarginPct) AS avgProfitMargin,
    AVG(orderItemQuantity) AS avgQuantityPerOrder,
    SUM(orderItemQuantity) AS totalQuantitySold,
    
    -- Calculated metrics
    SUM(revenue) / NULLIF(COUNT(DISTINCT orderId), 0) AS revenuePerOrder,
    SUM(profit) / NULLIF(SUM(revenue), 0) * 100 AS overallProfitMargin
    
FROM {{ ref('stgSupplyChainOrders') }}
GROUP BY productId

