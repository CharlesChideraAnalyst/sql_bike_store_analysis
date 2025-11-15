/*
Customer Report: Building customer reports. 
As the last step in my project, I try to collect all the different types of explorations and the analysis I have done in my datasets so I can put everything in one view and then offer it to our stakeholders, so as to make a quick analysis for decision making.
Now, let's bring the requirements below into one big script to build our customer reports

Customer Report
Purpose:
-	This report consolidates key customer metrics and behaviors

                        Highlights
                    ==================
1.	Gather essential fields such as name, age, and transaction details.
2.	Aggregate customer-level metrics
3.  Segments customers into categories (VIP, Regular, New) and age groups
        - 	Total orders
        -	total sales
        -	Total quantity purchased
        - 	Total products
        -	lifespan 
4.	Calculate valuable KPIs:
        - 	Recency (months since last order)
        -	Average order value
*/

--1.    Base Query: Retrieves core columns from tables we need for our report
SELECT 
    s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    c.first_name,
    c.last_name,
    c.birthdate
FROM
    gold.fact_sales s 
LEFT JOIN
    gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE
    order_date IS NOT NULL

-- Now lets take a look at our colums listed to see if we can make any type of transformation to prepare them for aggregation
-- 1. So lets put the customer first and last name together in one colum as customer name

SELECT 
    s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
    c.birthdate
FROM
    gold.fact_sales s 
LEFT JOIN
    gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE
    order_date IS NOT NULL

--2. Lets change the birthdate colum, because we dont need the birthdate just the age
SELECT 
    s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
    DATE_PART('year', AGE(CURRENT_DATE, c.birthdate)) AS age

FROM
    gold.fact_sales s 
LEFT JOIN
    gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE
    order_date IS NOT NULL

-- Now that we have all the data that we need for our report lets put it in CTE

WITH customer_base_query AS(
    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
        DATE_PART('year', AGE(CURRENT_DATE, c.birthdate)) AS age

    FROM
        gold.fact_sales s 
    LEFT JOIN
        gold.dim_customers c
    ON c.customer_key = s.customer_key
    WHERE
        order_date IS NOT NULL
)
SELECT *
FROM
    customer_base_query

-- Now lets move further to the next step:
-- Aggregate customer-level metrics. Segments customers into categories (VIP, Regular, New) and age groups


WITH customer_base_query AS(
    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
        DATE_PART('year', AGE(CURRENT_DATE, c.birthdate)) AS age

    FROM
        gold.fact_sales s 
    LEFT JOIN
        gold.dim_customers c
    ON c.customer_key = s.customer_key
    WHERE
        order_date IS NOT NULL
)
SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
-- Aggregations
        COUNT (DISTINCT order_date) AS total_orders,
        SUM (sales_amount) AS total_sales,
        SUM (quantity) AS total_quantity,
        COUNT (DISTINCT product_key) AS total_products,
        MAX (order_date) AS last_order_date,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan
FROM
    customer_base_query
GROUP BY
    customer_key,
        customer_number,
        customer_name,
        age

-- Now that we are have done the aggregation, lets now move to 
-- Segments customers into categories (VIP, Regular, New) and age groups

WITH customer_base_query AS(
    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
        DATE_PART('year', AGE(CURRENT_DATE, c.birthdate)) AS age

    FROM
        gold.fact_sales s 
    LEFT JOIN
        gold.dim_customers c
    ON c.customer_key = s.customer_key
    WHERE
        order_date IS NOT NULL
),

customer_aggregation AS (
SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
-- Aggregations
        COUNT (DISTINCT order_date) AS total_orders,
        SUM (sales_amount) AS total_sales,
        SUM (quantity) AS total_quantity,
        COUNT (DISTINCT product_key) AS total_products,
        MAX (order_date) AS last_order_date,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan
FROM
    customer_base_query
GROUP BY
    customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
            CASE 
                WHEN age <20 THEN 'Under 20'
                WHEN age between 20 AND 29 THEN '20-29'
                WHEN age between 30 AND 29 THEN  '30-39'
                WHEN age between 40 AND 49 THEN '40-49'
                ELSE '50 and above'
            END AS age_segment,
        total_orders,
        total_sales,
         total_quantity,
        total_products,
        lifespan,
            CASE    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
                     WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New Customer'
    END customer_segment
FROM
    customer_aggregation

-- Finally lets move over to the last requirment: Calculate valuable KPIs:
--       -	Average order value
-- In order to compute the Average order value, 
-- We have to divide Average order value = Total Sales/Total Nr. of Orders


WITH customer_base_query AS(
    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
        DATE_PART('year', AGE(CURRENT_DATE, c.birthdate)) AS age

    FROM
        gold.fact_sales s 
    LEFT JOIN
        gold.dim_customers c
    ON c.customer_key = s.customer_key
    WHERE
        order_date IS NOT NULL
),

customer_aggregation AS (
SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
-- Aggregations
        COUNT (DISTINCT order_date) AS total_orders,
        SUM (sales_amount) AS total_sales,
        SUM (quantity) AS total_quantity,
        COUNT (DISTINCT product_key) AS total_products,
        MAX (order_date) AS last_order_date,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan
FROM
    customer_base_query
GROUP BY
    customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
            CASE 
                WHEN age <20 THEN 'Under 20'
                WHEN age between 20 AND 29 THEN '20-29'
                WHEN age between 30 AND 29 THEN  '30-39'
                WHEN age between 40 AND 49 THEN '40-49'
                ELSE '50 and above'
            END AS age_segment,
        total_orders,
        total_sales,
        total_quantity,
        total_products,
        lifespan,
            CASE    
                WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
                WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
                ELSE 'New Customer'
            END customer_segment,
        
-- Compute average order value 
        total_sales / total_orders AS Avg_order_value,
-- Compute average monthly spend 
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM
    customer_aggregation

-- Now we have the full report of the customers

-- Now what we will do is to take the whole query and put it in our database as a VIEW
-- Once we have the VIEW report in the database we can now share it with our stakeholders and 
-- Further we will create a dashboard using Tableau to vizualize the data

-- The puprose of this is so that we dont have to go through all the step we took to prepare the data
-- Once we connect to the VIEW we can easily make analysis from there.



 