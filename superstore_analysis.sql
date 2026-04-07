CREATE DATABASE superstore_analysis;
USE superstore_analysis;

USE superstore_analysis;
SELECT COUNT(*) FROM superstore;
SELECT * FROM superstore LIMIT 5;

USE superstore_analysis;

-- How many orders are losing money?
SELECT 
  COUNT(*) AS total_orders,
  SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_making_orders,
  ROUND(100 * SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS loss_rate_pct,
  ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2) AS total_losses,
  ROUND(SUM(CASE WHEN profit > 0 THEN profit ELSE 0 END), 2) AS total_gains
FROM superstore;

SELECT 
  category,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_orders,
  ROUND(100 * SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS loss_rate_pct,
  ROUND(SUM(profit), 2) AS net_profit
FROM superstore
GROUP BY category
ORDER BY net_profit ASC;

-- QUERY 1 — Sales & Profit Overview by Region
SELECT 
  region,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(profit), 2) AS avg_profit_per_order,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;

-- QUERY 2 — Performance by Customer Segment
SELECT 
  segment,
  COUNT(*) AS total_orders,
  COUNT(DISTINCT `Customer ID`) AS unique_customers,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(sales), 2) AS avg_order_value,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY segment
ORDER BY total_profit DESC;

-- QUERY 3 — Category & Sub-Category Deep Dive
SELECT 
  category,
  `Sub-Category`,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY category, `Sub-Category`
ORDER BY category, total_profit DESC;

-- QUERY 4 — Top 10 Most Profitable States
SELECT 
  state,
  region,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_profit DESC
LIMIT 10;

-- QUERY 4 — Top 10 Most Profitable States
SELECT 
  state,
  region,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_profit DESC
LIMIT 10;

-- QUERY 5 — Bottom 10 States by Profit (Loss Hotspots)
SELECT 
  state,
  region,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_profit ASC
LIMIT 10;

-- QUERY 6 — Discount Impact on Profit
SELECT
  CASE
    WHEN discount = 0 THEN 'No Discount'
    WHEN discount BETWEEN 0.01 AND 0.20 THEN 'Low (1-20%)'
    WHEN discount BETWEEN 0.21 AND 0.40 THEN 'Medium (21-40%)'
    ELSE 'High (40%+)'
  END AS discount_band,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(profit), 2) AS avg_profit_per_order,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY discount_band
ORDER BY avg_profit_per_order DESC;

-- QUERY 7 — Monthly Sales Trend (Year over Year)
SELECT
  YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS order_year,
  MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS order_month,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- QUERY 8 — Top 10 Most Profitable Products
SELECT 
  `Product Name`,
  category,
  `Sub-Category`,
  COUNT(*) AS times_ordered,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY `Product Name`, category, `Sub-Category`
ORDER BY total_profit DESC
LIMIT 10;

-- QUERY 9 — Top 10 Loss-Making Products
SELECT 
  `Product Name`,
  category,
  `Sub-Category`,
  COUNT(*) AS times_ordered,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(AVG(discount) * 100, 1) AS avg_discount_pct
FROM superstore
GROUP BY `Product Name`, category, `Sub-Category`
ORDER BY total_profit ASC
LIMIT 10;

-- QUERY 10 — CTE: Region × Segment × Category Performance Matrix
WITH performance_matrix AS (
  SELECT
    region,
    segment,
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct,
    CASE
      WHEN SUM(profit) > 0 AND 100 * SUM(profit) / SUM(sales) >= 15 THEN 'High Performer'
      WHEN SUM(profit) > 0 AND 100 * SUM(profit) / SUM(sales) < 15 THEN 'Moderate Performer'
      ELSE 'Loss Maker'
    END AS performance_band
  FROM superstore
  GROUP BY region, segment, category
)
SELECT *
FROM performance_matrix
ORDER BY total_profit DESC;

SELECT 
  ROUND(SUM(profit), 2) AS total_losses
FROM superstore
WHERE profit < 0;

SELECT 
  state,
  region,
  COUNT(*) AS total_orders,
  ROUND(SUM(sales), 2) AS total_sales,
  ROUND(SUM(profit), 2) AS total_profit,
  ROUND(100 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_profit DESC;



