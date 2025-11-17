/*
Product report
Build a product report:
This report will build complete insights into the products of the business.
As the last step in my project, I try to collect all the different types of explorations and the analysis I have done in our 
datasets so I can put everything in one view and then offer it to our stakeholders, so as to make a quick analysis for decision making.
Now, let's bring the requirements below into one big script to build our product reports


Purpose:
	This report consolidates key product metrics and behaviors.

Highlights:
1.	 Gathers essential fields such as product name, category, subcategory, and cost.
2.	Segment products by revenue to identify high-performance, Mid-Range, or low-performers.
3.	Aggregates product-level metrics:
    -   Total Orders
    -   Total sales
    -   Total quantity sold
    -   Total customer (unique)
    -   Lifespan (in Months)
4.	Calculate Valuable KPIs:
    -   Recency (Months since last sales)
    -   Average order revenue (AOR)
    -   Average monthly revenue
*/

--1.    Base Query: Retrieves core columns from tables we need for our report
WITH product_base_query AS (
SELECT 
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost

FROM
    gold.fact_sales f
LEFT JOIN
    gold.dim_products p 
ON f.product_key = p.product_key
WHERE
    order_date IS NOT NULL
)
SELECT *
FROM    
    product_base_query

-- Now lets take a look at our colums listed to see if we can make any type of transformation to prepare them for aggregation
-- 1.Summarize key metrics at the product level

WITH product_base_query AS (
SELECT 
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost

FROM
    gold.fact_sales f
LEFT JOIN
    gold.dim_products p 
ON f.product_key = p.product_key
WHERE
    order_date IS NOT NULL
)
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
     DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) 
            AS lifespan,
    MAX(order_date) AS last_sales_date,
    COUNT (DISTINCT order_date) AS total_orders,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales,
    ROUND(SUM(sales_amount) / SUM(quantity), 2) AS avg_price_per_unit

FROM    
    product_base_query
    GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost


-- 3. Final Query: Let combine all product result into one output


WITH product_base_query AS (
    SELECT 
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

product_aggregation AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) AS lifespan,
        MAX(order_date) AS last_sales_date,
        COUNT(DISTINCT order_date) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        ROUND(SUM(sales_amount) / SUM(quantity), 2) AS avg_price_per_unit
    FROM product_base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    lifespan,
    last_sales_date,

    -- Recency
    DATE_PART('year', AGE(CURRENT_DATE, last_sales_date)) * 12 +
    DATE_PART('month', AGE(CURRENT_DATE, last_sales_date)) AS recency_in_months,

    -- Product Segment
    CASE
        WHEN total_sales > 5000 THEN 'High Performance'
        WHEN total_sales = 5000 THEN 'Mid Range'
        ELSE 'Low Performance'
    END AS product_segment,

    total_orders,
    total_customers,
    total_quantity,
    total_sales,
    avg_price_per_unit,

    -- Average Order Revenue
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregation;


-- Now lets put all our query in a view 

CREATE VIEW gold.product_report AS
WITH product_base_query AS (
    SELECT 
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

product_aggregation AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
            + 12 * DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) AS lifespan,
        MAX(order_date) AS last_sales_date,
        COUNT(DISTINCT order_date) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales,
        ROUND(SUM(sales_amount) / SUM(quantity), 2) AS avg_price_per_unit
    FROM product_base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    lifespan,
    last_sales_date,

    -- Recency
    DATE_PART('year', AGE(CURRENT_DATE, last_sales_date)) * 12 +
    DATE_PART('month', AGE(CURRENT_DATE, last_sales_date)) AS recency_in_months,

    -- Product Segment
    CASE
        WHEN total_sales > 5000 THEN 'High Performance'
        WHEN total_sales = 5000 THEN 'Mid Range'
        ELSE 'Low Performance'
    END AS product_segment,

    total_orders,
    total_customers,
    total_quantity,
    total_sales,
    avg_price_per_unit,

    -- Average Order Revenue
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregation;



 -- OUR PRODUCT REPORT VIEW
 -- This contain a 360 degree view of report about our products 
 
 

SELECT *
FROM
    gold.product_report
