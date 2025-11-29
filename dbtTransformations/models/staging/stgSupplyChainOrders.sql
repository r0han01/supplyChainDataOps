-- Staging model: Clean and standardize raw supply chain orders data
-- Creates a view in analyticalData schema
-- Includes all 57 columns from raw data for comprehensive downstream use

SELECT
    -- Identifiers
    orderId,
    customerId,
    orderCustomerId,
    productCardId AS productId,
    categoryId,
    productCategoryId,
    departmentId,
    orderItemId,
    
    -- Dates and time
    orderDate,
    shippingDate,
    daysForShippingReal,
    daysForShipmentScheduled,
    orderYear,
    orderMonth,
    orderQuarter,
    orderDayOfWeek,
    orderHour,
    
    -- Customer attributes
    customerSegment,
    customerCity,
    customerState,
    customerCountry,
    customerZipcode,
    customerFname,
    customerLname,
    customerStreet,
    salesPerCustomer,
    
    -- Product attributes
    productName,
    productPrice,
    productImage,
    categoryName,
    departmentName,
    
    -- Financial metrics
    sales AS revenue,
    orderProfitPerOrder AS profit,
    profitMarginPct,
    profitCategory,
    benefitPerOrder,
    orderItemProductPrice,
    orderItemDiscount,
    orderItemDiscountRate,
    orderItemProfitRatio,
    orderItemQuantity,
    orderItemTotal,
    
    -- Operational metrics
    deliveryStatus,
    deliveryDelay,
    isLate,
    lateDeliveryRisk,
    shippingMode,
    orderStatus,
    type AS paymentType,
    
    -- Geography
    orderCity,
    orderState,
    orderCountry,
    orderRegion,
    orderZipcode,
    market,
    latitude,
    longitude
    
FROM {{ source('raw', 'dataCoSupplyChainOrders') }}
WHERE orderId IS NOT NULL
  AND customerId IS NOT NULL
  AND orderDate IS NOT NULL
