-- ============================================================
-- 15 QUERIES (>=4 nested, >=4 joins)
-- ============================================================

USE supermarket_chain;

-- ------------------------------------------------------------
-- Q1 (JOIN): Retrieves each customer together with their loyalty card 
-- details and the point of sale
-- ------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name,
       lc.card_id, lc.points_balance,
       p.point_id, p.name AS point_name, p.city
FROM CUSTOMER c
JOIN LOYALTY_CARD lc ON lc.customer_id = c.customer_id
JOIN POINT_OF_SALE p  ON p.point_id = lc.point_id
ORDER BY p.city, c.last_name;

-- ------------------------------------------------------------
-- Q2 (JOIN): List all transactions with customer details
-- ------------------------------------------------------------
SELECT t.transaction_id, t.`date`, t.payment_method, t.total_price,
       c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name
FROM `TRANSACTION` t
JOIN CUSTOMER c ON c.customer_id = t.customer_id
ORDER BY t.`date`, t.transaction_id;

-- ------------------------------------------------------------
-- Q3 (JOIN + aggregation): Recompute totals from line items (audit stored total_price)
-- ------------------------------------------------------------
SELECT t.transaction_id,
       t.total_price AS stored_total,
       ROUND(SUM(pit.quantity * pit.unit_price), 2) AS computed_total,
       ROUND(t.total_price - SUM(pit.quantity * pit.unit_price), 2) AS diff
FROM `TRANSACTION` t
JOIN PRODUCT_IN_TRANSACTION pit ON pit.transaction_id = t.transaction_id
GROUP BY t.transaction_id, t.total_price
ORDER BY ABS(diff) DESC, t.transaction_id;

-- ------------------------------------------------------------
-- Q4 (JOIN + aggregation): Top 5 products by units sold
-- ------------------------------------------------------------
SELECT pr.product_id, pr.name,
       SUM(pit.quantity) AS units_sold
FROM PRODUCT pr
JOIN PRODUCT_IN_TRANSACTION pit ON pit.product_id = pr.product_id
GROUP BY pr.product_id, pr.name
ORDER BY units_sold DESC
LIMIT 5;

-- ------------------------------------------------------------
-- Q5 (JOIN + aggregation): Revenue by product category
-- ------------------------------------------------------------
SELECT pr.category,
       ROUND(SUM(pit.quantity * pit.unit_price), 2) AS revenue
FROM PRODUCT pr
JOIN PRODUCT_IN_TRANSACTION pit ON pit.product_id = pr.product_id
GROUP BY pr.category
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- Q6 (NESTED): Loyalty cards with balance above average balance
-- ------------------------------------------------------------
SELECT card_id, customer_id, points_balance
FROM LOYALTY_CARD
WHERE points_balance > (SELECT AVG(points_balance) FROM LOYALTY_CARD)
ORDER BY points_balance DESC;

-- ------------------------------------------------------------
-- Q7 (NESTED): Products that have NEVER been sold
-- ------------------------------------------------------------
SELECT p.product_id, p.name
FROM PRODUCT p
WHERE p.product_id NOT IN (
  SELECT DISTINCT pit.product_id
  FROM PRODUCT_IN_TRANSACTION pit
)
ORDER BY p.product_id;

-- ------------------------------------------------------------
-- Q8 (NESTED): Customers who bought a specific product (example: Olive Oil 1L = product_id 204)
-- ------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name
FROM CUSTOMER c
WHERE c.customer_id IN (
  SELECT t.customer_id
  FROM `TRANSACTION` t
  WHERE t.transaction_id IN (
    SELECT pit.transaction_id
    FROM PRODUCT_IN_TRANSACTION pit
    WHERE pit.product_id = 204
  )
)
ORDER BY c.customer_id;

-- ------------------------------------------------------------
-- Q9 (JOIN + aggregation): For each transaction, number of distinct products and total items
-- ------------------------------------------------------------
SELECT t.transaction_id, t.`date`,
       COUNT(DISTINCT pit.product_id) AS distinct_products,
       SUM(pit.quantity) AS total_items
FROM `TRANSACTION` t
JOIN PRODUCT_IN_TRANSACTION pit ON pit.transaction_id = t.transaction_id
GROUP BY t.transaction_id, t.`date`
ORDER BY total_items DESC;

-- ------------------------------------------------------------
-- Q10 (NESTED + JOIN): Latest transaction per customer (by date; ties possible)
-- ------------------------------------------------------------
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer,
       t.transaction_id, t.`date`, t.total_price
FROM CUSTOMER c
JOIN `TRANSACTION` t ON t.customer_id = c.customer_id
WHERE t.`date` = (
  SELECT MAX(t2.`date`)
  FROM `TRANSACTION` t2
  WHERE t2.customer_id = c.customer_id
)
ORDER BY t.`date` DESC, c.customer_id;

-- ------------------------------------------------------------
-- Q11 (JOIN + aggregation): Net points movement per customer (earned - redeemed)
-- ------------------------------------------------------------
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer,
       SUM(pm.points_delta) AS net_points
FROM CUSTOMER c
JOIN LOYALTY_CARD lc ON lc.customer_id = c.customer_id
JOIN POINTS_MOVEMENT pm ON pm.card_id = lc.card_id
GROUP BY c.customer_id, customer
ORDER BY net_points DESC;

-- ------------------------------------------------------------
-- Q12 (NESTED): Customers who have NO transactions
-- ------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name
FROM CUSTOMER c
WHERE NOT EXISTS (
  SELECT 1
  FROM `TRANSACTION` t
  WHERE t.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- ------------------------------------------------------------
-- Q13 (JOIN): Stock overview: show store + product + remaining quantity
-- ------------------------------------------------------------
SELECT pos.point_id, pos.name AS store_name, pos.city,
       pr.product_id, pr.name AS product_name,
       pop.quantity AS stock_qty
FROM POINT_OFFERS_PRODUCT pop
JOIN POINT_OF_SALE pos ON pos.point_id = pop.point_id
JOIN PRODUCT pr ON pr.product_id = pop.product_id
ORDER BY pos.point_id, pr.product_id;

-- ------------------------------------------------------------
-- Q14 (NESTED): Stores that accept ALL payment methods that exist in the system
-- ------------------------------------------------------------
SELECT pos.point_id, pos.name, pos.city
FROM POINT_OF_SALE pos
WHERE NOT EXISTS (
  SELECT 1
  FROM (SELECT DISTINCT payment_method FROM PAYMENT_METHOD) allm
  WHERE NOT EXISTS (
    SELECT 1
    FROM PAYMENT_METHOD pm
    WHERE pm.point_id = pos.point_id
      AND pm.payment_method = allm.payment_method
  )
)
ORDER BY pos.point_id;

-- ------------------------------------------------------------
-- Q15 (NESTED + JOIN + HAVING): Big spenders = customers whose total spend > average customer spend
-- ------------------------------------------------------------
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer,
       ROUND(SUM(t.total_price), 2) AS total_spend
FROM CUSTOMER c
JOIN `TRANSACTION` t ON t.customer_id = c.customer_id
GROUP BY c.customer_id, customer
HAVING SUM(t.total_price) > (
  SELECT AVG(customer_total)
  FROM (
    SELECT SUM(t2.total_price) AS customer_total
    FROM `TRANSACTION` t2
    GROUP BY t2.customer_id
  ) AS totals
)
ORDER BY total_spend DESC;
