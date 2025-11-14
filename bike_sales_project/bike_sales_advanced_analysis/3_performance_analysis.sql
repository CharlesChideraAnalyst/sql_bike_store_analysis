/*
3.	Performance Analysis: 
What is Performance Analysis? This is the process of comparing the current 
value with a target value to compare the performance of a specific category, 
and this will help us to measure the success to compare the performance

We will find the difference between the current sales and the set target for our current sales
-	Here we will always compare the measure with the target measure. 
-   We will use the window function. The aggregate window functions like the Sum, Average, Max, Min, or
-	The value window functions like Lead and Lag to measure the performance of our business.
*/

--Task
-- Analyze the yearly performance of products by comparing each product's sales to both 
-- its average sales performance and the previous year's sales

SELECT 
    s.order_date,
    p.product_name,
    s.sales_amount
FROM
    gold.fact_sales s
LEFT JOIN
    gold.dim_products p
ON s.product_key = p.product_key
-- Now the task is yearly performance so we dont need the date, the guranlity is the year

SELECT 
   EXTRACT (YEAR FROM s.order_date) AS order_year,
    p.product_name,
    SUM (s.sales_amount) AS current_sales
FROM
    gold.fact_sales s
LEFT JOIN
    gold.dim_products p
ON s.product_key = p.product_key
WHERE
    order_date IS NOT NULL
GROUP BY order_year,
        product_name
ORDER BY
        order_year DESC
-- With this result we have the solve the first task of analyzing the yearly performance of products


-- Task B
-- Now we have to compare the current sales 
-- with the averge sales performance of the products and the previous year sales 
-- Now we need the average and as well as the previous year sales

-- What it means is that we will compare each vaue to the previous year sales for the same product

-- We will use a window function CTE

WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) Avg_sales
FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year
-- Now from our result we can see the average of our first three value is 13,197
-- And from each row we have the current sales and side by side the average sales,
-- And same thing for the next product as well.

-- Now lets get the change in value between the current sales and the average sales

WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) AS Avg_sales,
    current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) AS diff_avg
FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year
-- As you can see from our result, now we are getting the comparison, that is we have the difference between 
-- the current sales and the average sales.

-- Now lets raise a flag, and make an indcator to show weather we are above the average or below the average or 
-- at the average. 
-- we will use the CASE WHEN statment in order to to this.

WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) AS Avg_sales,
    current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) AS diff_avg,
    CASE    WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) > 0 THEN 'Above Avg'
            WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) < 0 THEN 'Below Avg'
            ELSE    'Average'
    END avg_change

FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year
-- With this we are now comparing the performance of each product with the average


-- The Last task

-- Now lets compare our current sales with the previous year sales of our buisness to see if we are making progress in our business.

-- In other to access the sales of the previous year, we will use the window function calles 'LAG'


WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) AS Avg_sales,
    current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) AS diff_avg,
    CASE    WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) > 0 THEN 'Above Avg'
            WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) < 0 THEN 'Below Avg'
            ELSE    'Average'
    END avg_change,
LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales

FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year
-- From our result we not have the previous year sales, together with the current sales 
-- Now what we have to do is to subtract them, to compare there difference 


WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) AS Avg_sales,
    current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) AS diff_avg,
    CASE    WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) > 0 THEN 'Above Avg'
            WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) < 0 THEN 'Below Avg'
            ELSE    'Average'
    END avg_change,
LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year

FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year


-- Now lets raise a flag, and make an indcator to show weather we are increasing in sales or decreasing in sales  
-- we will use the CASE WHEN statment in order to to this.


WITH yearly_product_sales AS (
    SELECT 
    EXTRACT (YEAR FROM s.order_date) AS order_year,
        p.product_name,
        SUM (s.sales_amount) AS current_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON s.product_key = p.product_key
    WHERE
        order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND (AVG(current_sales) over (partition BY product_name), 2) AS Avg_sales,
    current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) AS diff_avg,
    CASE    WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) > 0 THEN 'Above Avg'
            WHEN current_sales - ROUND (AVG(current_sales) over (partition BY product_name), 2) < 0 THEN 'Below Avg'
            ELSE    'Average'
    END avg_change,
LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year,

CASE        WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'increase'
            WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decrease'
            ELSE 'No Change'
    END prev_year_change

FROM
    yearly_product_sales
ORDER BY    
    product_name,
    order_year
-- From our result for the first year of the product there is no change, because there is no previous year.
-- In this type of anaysis we call it year-over-year Analysis. 
-- This is good for long trends analysis.

-- So this is how we analyzes the perfomance of our business by comparing the current meausre with a target measure.
 