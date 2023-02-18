--- Queries for online retail dataset---
SELECT *
FROM online_retail;

---- Which countries produced the highest revenue---
SELECT t1.country, SUM(t1.revenue) total_revenue
FROM(
SELECT country, (unit_price * quantity) AS revenue
FROM online_retail
ORDER BY revenue DESC) t1
WHERE t1.country != 'United Kingdom'
GROUP BY t1.country
Order By total_revenue DESC;

--- Top 10 Customers with the highest revenue---
WITH t1 AS (
SELECT customer_id, (unit_price * quantity) AS revenue
FROM online_retail
ORDER BY revenue DESC
)
SELECT t1.customer_id, SUM(t1.revenue) total_revenue
FROM t1
WHERE t1.customer_id IS NOT NULL
GROUP BY t1.customer_id
Order By total_revenue DESC;

--- Most revenue by month---
WITH t1 AS (
SELECT EXTRACT('month' FROM invoice_date) new_month, (unit_price * quantity) AS revenue
FROM online_retail
ORDER BY revenue DESC
)

SELECT t1.new_month, SUM(t1.revenue) total_revenue
FROM t1
GROUP BY t1.new_month
ORDER BY total_revenue DESC;

---Top 10 countries which are generating the highest revenue and quantity sold---
WITH t1 AS (
SELECT country, quantity, (unit_price * quantity) AS revenue
FROM online_retail
ORDER BY revenue DESC
)
SELECT t1.country, SUM(t1.quantity) total_quantity, SUM(t1.revenue) total_revenue
FROM t1
WHERE t1.country != 'United Kingdom'
GROUP BY t1.country
Order By total_revenue DESC;

--- Which product generated the most revenue ---
WITH t1 AS (
SELECT description, (unit_price * quantity) AS revenue
FROM online_retail
)

SELECT t1.description, SUM(t1.revenue) total_revenue
FROM t1
GROUP BY t1.description
ORDER BY total_revenue DESC;

---- Which products didn't generate any money---
WITH t1 AS (
SELECT description, (unit_price * quantity) AS revenue
FROM online_retail
)

SELECT t1.description, SUM(t1.revenue) total_revenue
FROM t1
GROUP BY t1.description
HAVING SUM(t1.revenue) =0;

--- Customers first order date and amount they spent ---
SELECT customer_id, invoice_date, ROW_NUMBER() OVER (PARTITION BY customer_id), 
(unit_price * quantity) amount
FROM online_retail;

--- The number of repeat and new customers by order month ---
WITH first_visit AS (
SELECT customer_id, MIN (EXTRACT ('month' FROM invoice_date)) first_month
FROM online_retail
GROUP BY customer_id
)

SELECT EXTRACT ('month' FROM invoice_date) AS visit_month,
SUM (CASE WHEN EXTRACT ('month' FROM invoice_date) = f.first_month THEN 1 ELSE 0 END) AS new_customer,
SUM (CASE WHEN EXTRACT ('month' FROM invoice_date) != f.first_month THEN 1 ELSE 0 END) AS repeat_customer
FROM online_retail o
JOIN first_visit f
ON o.customer_id = f.customer_id
GROUP BY 1;

--- What day of week generated the most revenue ---
WITH t1 AS (
SELECT EXTRACT('isodow' FROM invoice_date) day_of_week, (unit_price * quantity) AS revenue
FROM online_retail	
)

SELECT CASE WHEN t1.day_of_week = 1 THEN 'Monday'
WHEN t1.day_of_week = 2 THEN 'Tuesday'
WHEN t1.day_of_week = 3 THEN 'Wednesday'
WHEN t1.day_of_week = 4 THEN 'Thursday'
WHEN t1.day_of_week = 5 THEN 'Friday'
WHEN t1.day_of_week = 6 THEN 'Saturday'
WHEN t1.day_of_week = 7 THEN 'Sunday' END AS day_of_week,
SUM(t1.revenue) total_revenue
FROM t1
GROUP BY t1.day_of_week
ORDER BY total_revenue DESC;

--- Month over Month Revenue Growth---
SELECT t1.months, SUM(t1.revenue), SUM(t1.revenue) - LAG (SUM(t1.revenue)) OVER (ORDER BY t1.months) AS revenue_growth
FROM (
SELECT EXTRACT('month' FROM invoice_date) months, (unit_price * quantity) AS revenue
FROM online_retail
) t1
GROUP BY t1.months;

--- Stored Procedure used to determine which products had a quantity less than 10---
CREATE PROCEDURE retail_details (quantity_amount int)
LANGUAGE SQL
AS $$
SELECT description, SUM(quantity) total_quantity
FROM online_retail
GROUP BY description
HAVING SUM(quantity) < quantity_amount
$$;

CALL retail_details (10);