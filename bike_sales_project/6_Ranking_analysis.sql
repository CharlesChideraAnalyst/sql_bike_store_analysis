/*
What is Ranking?
Here we can order the value of our dimension by measures
-	To identify the top performance of our product sales
-	To identify the low performance of our product sales
Questions
-	Which 5 products generate the highest revenue?
-	What are the 5 worst performing products in terms of sales?
*/

-- 1.   Which 5 products generate the highest revenue?
SELECT 
            category,
            p.product_name, 
            SUM (s.sales_amount) total_revenue
FROM        gold.fact_sales s
LEFT join   gold.dim_products p
ON          p.product_key = s.product_key
GROUP BY    P.product_name, category
ORDER BY    total_revenue DESC
LIMIT 5 
-- From our reuslt we could see that our bikes (Mountain Bikes) generate the highest revenue 


-- 2.	What are the 5 worst performing products in terms of sales?

SELECT 
            category,
            p.product_name, 
            SUM (s.sales_amount) total_revenue
FROM        gold.fact_sales s
LEFT join   gold.dim_products p
ON          p.product_key = s.product_key
GROUP BY    P.product_name, category
ORDER BY    total_revenue ASC
LIMIT 5
-- From our result we could see that our worst selling products are Racking Socks, Bike wash Dissolver and tire tube



-- Lets check for our subcategory 

- 1.   Which 5 products generate the highest revenue?
SELECT 
            category,
            p.subcategory, 
            SUM (s.sales_amount) total_revenue
FROM        gold.fact_sales s
LEFT join   gold.dim_products p
ON          p.product_key = s.product_key
GROUP BY    P.subcategory, category
ORDER BY    total_revenue DESC
LIMIT 5 
-- From our reuslt we could see that our bikes still generate the highest revenue 
-- followed by the Accessories
