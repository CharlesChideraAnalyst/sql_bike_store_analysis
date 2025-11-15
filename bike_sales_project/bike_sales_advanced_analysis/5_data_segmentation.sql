/*
5.	Data Segmentation
What is data segmentation? 
-	What we are going to do here is, we are going to group the data based on a specific range, 
    which means we are going to create new categories and aggregate the data based on the new category. 
    This will help us understand the correlation between the two measures.
-	Now we are going to have a measure by a measure
-	We are taking one measure and based on the range of the measure we will build a new categories or new dimension
-	We will use the CASE WHEN statement for this, because it is going to help us define the rules and based on the range 
    its going to create a new category and labels
*/

-- Task 1: Segment products into cost ranges and count how many products fall into each segment.
SELECT 
    product_key,
    product_name,
    cost
FROM
    gold.dim_products

-- Now lets convert the cost measure to dimension using the case when statement 
SELECT 
    product_key,
    product_name,
    cost,
CASE    WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
END cost_range
FROM
    gold.dim_products

-- Now we have the segment of the cost, we will then aggregate the data based on this new dimension

WITH Product_segment AS (
    SELECT 
        product_key,
        product_name,
        cost,
    CASE    WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
    END cost_range
    FROM
        gold.dim_products
)
SELECT 
    cost_range,
    COUNT (product_key) as total_products
FROM
    Product_segment
GROUP BY
    cost_range
ORDER BY
    total_products DESC

-- Now in the output we have our segmented measure and total number of products in each of those segment range
-- and from our result we can see that we alot of products that are not costing alot that is below 100 and the 
-- lowest is in the range that is above 1000


--  Task 2: 
/* 
    Group customers into three segments based on their spending behaviour:
    - VIP: Customers with at least 12 months of histroy and spending more than $5,000
    - Regular: Customers with at least 12 month of history but spending $5,000 or less
    - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

SELECT 
    c.customer_key,
    f.sales_amount,
    f.order_date
FROM    
    gold.fact_sales f
LEFT JOIN
    gold.dim_customers c 
ON f.customer_key = c.customer_key

-- Now lets calculate the lifespan.
-- In order to do that we need to find the first and the last order of the customer

SELECT 
    c.customer_key,
    SUM (f.sales_amount) AS total_spending,
    MIN (order_date) AS first_order,
    MAX (order_date) AS last_order
FROM    
    gold.fact_sales f
LEFT JOIN
    gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY    
    c.customer_key

-- To calculate our customer lifespan (which is between the first order and the last order)
SELECT 
    c.customer_key,
    SUM (f.sales_amount) AS total_spending,
    MIN (order_date) AS first_order,
    MAX (order_date) AS last_order,
    DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
        + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
        AS lifespan_months
FROM    
    gold.fact_sales f
LEFT JOIN
    gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY    
    c.customer_key

-- We have our lifespan, total spending, now lets create the segment based on the result
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM (f.sales_amount) AS total_spending,
        MIN (order_date) AS first_order,
        MAX (order_date) AS last_order,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan
    FROM    
        gold.fact_sales f
    LEFT JOIN
        gold.dim_customers c 
    ON f.customer_key = c.customer_key
    GROUP BY    
        c.customer_key
    )
SELECT 
    customer_key,
    total_spending,
    lifespan,
CASE    WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New Customer'
END customer_segment
FROM 
    customer_spending
-- Now as you can see we have derived a new dimension from two measures, the lifespan and the total spending

-- Finally lets find the total number of customers for each of the categories
-- This time lets use the subquery

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM (f.sales_amount) AS total_spending,
        MIN (order_date) AS first_order,
        MAX (order_date) AS last_order,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan
    FROM    
        gold.fact_sales f
    LEFT JOIN
        gold.dim_customers c 
    ON f.customer_key = c.customer_key
    GROUP BY    
        c.customer_key
    )
    -- Using Subquery

SELECT 
    customer_segment,
    COUNT (customer_key) AS total_customer
FROM (
    SELECT 
    customer_key,
    CASE    WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New Customer'
    END customer_segment
    FROM 
        customer_spending
)
    GROUP BY    
    customer_segment
ORDER BY    
    total_customer DESC
-- So from our result we can see that the highest number of our customer belong to the category new, followed by
-- the Regular customer and then our VIP customers.

-- Now we have fully segmented our customers based on their spending behaviours
-- And this help us to understand the spending behaviour of our customer in our business.
-- And of course this will help our stakeholders make smarter decisons