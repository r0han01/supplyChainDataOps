-- Fact table: Orders (one row per order-item combination)
-- Creates a table in analyticalData schema
-- Grain: orderId + productId (one order can have multiple products)

SELECT
    -- Primary key (composite: orderId + productId)
    orderId,
    productId,
    
    -- Foreign keys to dimensions
    customerId,
    DATE(orderDate) AS dateKey,
    
    -- Financial metrics
    revenue,
    profit,
    profitMarginPct AS margin,
    orderItemQuantity AS quantity,
    orderItemTotal AS lineTotal,
    orderItemDiscount AS discount,
    orderItemDiscountRate AS discountRate,
    benefitPerOrder AS benefit,
    
    -- Operational metrics
    deliveryStatus,
    isLate,
    deliveryDelay,
    lateDeliveryRisk,
    shippingMode,
    orderStatus,
    paymentType,
    daysForShippingReal AS shippingDaysReal,
    daysForShipmentScheduled AS shippingDaysScheduled,
    
    -- Additional context (for filtering/grouping)
    orderCustomerId,
    orderItemId,
    categoryId,
    departmentId,
    orderRegion,
    market,
    
    -- Timestamps
    orderDate,
    shippingDate
    
FROM {{ ref('stgSupplyChainOrders') }}
WHERE orderId IS NOT NULL
  AND productId IS NOT NULL
  AND customerId IS NOT NULL
  AND orderDate IS NOT NULL

