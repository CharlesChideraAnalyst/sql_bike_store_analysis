/* 
Here, what we will be doing is to calculate the key metric of the business (Big Numbers)
-	The highest level of aggregation of our data
-	We will use the sum, average, and count for any measures inside our data sets.
-	The total sales are calculated by summing the sales value
-	Aggregate functions together with the measures
*/

-- We will be analyzing 7 things here
/*
    1.  Find the Total Sales
    2.  Find how many items are sold
    3.  Find the average selling price
    4.  Find the Total number of Orders
    5.  Find the Total number of Products
    6.  Find the total number of customers
    7.  Find the total number of customers that has placed an order
*/

--1.     Find the Total Sales
SELECT 
        SUM (sales_amount) AS total_sales
FROM   
         gold.fact_sales


-- 2     Find how many items are sold
SELECT 
        SUM (quantity) AS items_sold
FROM   
         gold.fact_sales

-- 3      Find the average selling price
SELECT 
        AVG(price) AS Avg_selling_price
FROM   
         gold.fact_sales

-- 4      Find the Total number of Orders
SELECT 
        count (DISTINCT order_number) AS total_order
FROM  
         gold.fact_sales

-- 5      Find the Total number of Products

SELECT 
        count(DISTINCT product_key) AS total_product
FROM    gold.dim_products


-- 6       Find the total number of customers
SELECT 
        count(DISTINCT customer_key) AS total_customers
FROM    gold.dim_customers

-- 7      Find the total number of customers that has placed an order
SELECT 
        count(DISTINCT customer_key) AS total_ordered_customers
FROM    gold.fact_sales

/* Now lets collect all those measures and put them in One query 
in order to have an overview of all key numbers in our business
instead of us querying each one of them.

- So what we will do here is to generate a report that shoows all key metrics of the business.
*/

SELECT 'Total Sales' AS Measure_name, SUM (sales_amount) AS Measure_value
FROM    gold.fact_sales

UNION ALL
SELECT 'Total Quantity',  SUM (quantity)
FROM    gold.fact_sales

UNION ALL
SELECT 
        'Average Price', AVG (price)
FROM   gold.fact_sales

UNION ALL
SELECT    'Total Nr Orders', count (DISTINCT order_number)
FROM    gold.fact_sales

UNION ALL
SELECT 
        'Total Nr Product', count(DISTINCT product_key) 
FROM    gold.dim_products

UNION ALL
SELECT 
        'Total Nr Customer', count(DISTINCT customer_key) 
FROM    gold.dim_customers

UNION ALL
SELECT 
        'Total Nr Customer Ord', count(DISTINCT customer_key) 
FROM    gold.fact_sales


-- This is a super report at a glance you can see the key metric of the full big picture of our business sales