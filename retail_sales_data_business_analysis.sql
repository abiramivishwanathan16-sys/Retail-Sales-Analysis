CREATE TABLE sales_data (
    order_id VARCHAR(50),
    order_date DATE,
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    age INT,
    gender VARCHAR(20),
    region VARCHAR(50),
    city VARCHAR(50),
    product_category VARCHAR(50),
    product_name VARCHAR(100),
    quantity NUMERIC,
    unit_price NUMERIC,
    discount_pct NUMERIC,
    sales_amount NUMERIC,
    profit NUMERIC,
    shipping_cost NUMERIC,
    payment_method VARCHAR(50),
    customer_satisfaction VARCHAR(30),
    return_flag VARCHAR(20),
    order_status VARCHAR(50),
    days_to_ship NUMERIC
);

COPY sales_data
FROM 'D:\data preprocessing\cleaned_retail_sales_data.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);

select * from sales_data

-- Business Performance
--1. What is the total revenue, total profit, total orders, and total quantity sold?

select sum(sales_amount)as total_revenue from sales_data

select sum(profit) as total_average from sales_data

select count(order_id) as total_orders from sales_data

select sum(quantity) as total_quantity from sales_data


-- 2.What is the Average Order Value (AOV)?

select sum(sales_amount) / count(order_id) as average_order_value from sales_data

-- 3.Which product category generates the highest revenue and profit?

select product_category,
sum(sales_amount) as total_revenue,
sum(profit) as total_profit
from sales_data
group by product_category
order by total_revenue desc;

-- "Electronics"	155642577.57	19107476.57

-- 4.Which products generate high revenue but comparatively low profit?
-- Customer

select product_name,
sum(sales_amount) as total_revenue,
sum(profit) as total_profit
from sales_data
group by product_name
having sum(sales_amount) > (select avg(sales_amount) from sales_data)
and sum(profit)<(select avg(profit)from sales_data)
order by total_revenue desc;

-- "Sugar"	141104.03	11466.80
-- "Flour"	136517.27	10872.00

-- 5. Who are the top 10 customers based on total spending?

select customer_id,customer_name,sum(sales_amount) as total_spending
from sales_data
group by customer_id,customer_name
order by total_spending desc
limit 10;

-- 6.Top revenue-generating products
select product_name, sum(sales_amount) as total_revenue
from sales_data
group by product_name
order by total_revenue desc limit 10;

-- 7. Which customers have placed the highest number of orders? 

select customer_id,customer_name,count(order_id) as high_order
from sales_data
group by customer_id,customer_name
order by high_order desc;

-- 8. Revenue from repeat/high-value customers
SELECT
    customer_id,
    customer_name,
    SUM(sales_amount) AS repeat_customer_revenue
FROM sales_data
WHERE customer_id IN (
    SELECT customer_id
    FROM sales_data
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
)
GROUP BY customer_id, customer_name
ORDER BY repeat_customer_revenue DESC;

-- 9.Regions generating most revenue and profit
select region,
sum(sales_amount) as total_revenue,
sum(profit) as total_profit
from sales_data
group by region
order by total_revenue desc;

--10.Regions with high sales but low profit
WITH region_performance AS (
    SELECT
        region,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY region
)
SELECT *
FROM region_performance
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM region_performance
)
AND total_profit < (
    SELECT AVG(total_profit)
    FROM region_performance
)
ORDER BY total_revenue DESC;


--11.How does discount affect profit?

SELECT
    discount_pct,
    AVG(profit) AS average_profit,
    SUM(sales_amount) AS total_revenue
FROM sales_data
GROUP BY discount_pct
ORDER BY discount_pct;

--12.High discount + low/negative profit

SELECT
    product_category,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    AVG(discount_pct) AS average_discount
FROM sales_data
GROUP BY product_category
HAVING AVG(discount_pct) >= 20
   AND SUM(profit) <= 0
ORDER BY total_profit;

--13.Overall return rate
SELECT
    COUNT(DISTINCT CASE
        WHEN return_flag = 'True' THEN order_id
    END) * 100.0
    / COUNT(DISTINCT order_id) AS return_rate
FROM sales_data;

--14.Categories with highest return rate
SELECT
    product_category,
    COUNT(DISTINCT CASE
        WHEN return_flag = 'True' THEN order_id
    END) * 100.0
    / COUNT(DISTINCT order_id) AS return_rate
FROM sales_data
GROUP BY product_category
ORDER BY return_rate DESC;

--15. overall return order and return rate
SELECT
    COUNT(DISTINCT CASE
        WHEN return_flag = 'True' THEN order_id
    END) AS returned_orders,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN return_flag = 'True' THEN order_id
        END) * 100.0
        / COUNT(DISTINCT order_id),
        2
    ) AS return_rate
FROM sales_data;

--16.overall Regions with longer shipping times
SELECT
    product_category,
    AVG(days_to_ship) AS average_shipping_days
FROM sales_data
GROUP BY product_category
ORDER BY average_shipping_days DESC;

--17 Monthly sales and profit
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY month
ORDER BY month;
--18 Month with highest revenue
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales_amount) AS total_revenue
FROM sales_data
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 1;
--19 Month with highest profit
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY month
ORDER BY total_profit DESC
LIMIT 1;

--20 High revenue + high profit categories
WITH category_performance AS (
    SELECT
        product_category,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY product_category
)
SELECT *
FROM category_performance
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM category_performance
)
AND total_profit > (
    SELECT AVG(total_profit)
    FROM category_performance
)
ORDER BY total_revenue DESC;

--21 High revenue + low profit categories
WITH category_performance AS (
    SELECT
        product_category,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY product_category
)
SELECT *
FROM category_performance
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM category_performance
)
AND total_profit < (
    SELECT AVG(total_profit)
    FROM category_performance
)
ORDER BY total_revenue DESC;