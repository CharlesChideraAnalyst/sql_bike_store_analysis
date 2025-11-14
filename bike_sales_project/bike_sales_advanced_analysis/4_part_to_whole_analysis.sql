/*
4.	Part–to–Whole Analysis
What is Part-to-whole Analysis? This is used to find out the proportion of a part relative to the whole. 
Analyze how an Individual part is performing relative to the overall, so we can understand which category has the greatest impact on the business.
Here we will pick one of our measures divide it by the total of the measure and multiple it by 100 in order to find the percentage by a specific dimension.
Example is to take the sales and divide the sales by the total sales multiple by 100 by that category
*/

-- Question: Which categories contribute the most to overall sales?
SELECT 
    category,
    SUM (sales_amount) AS total_sales
FROM 
    gold.fact_sales s
LEFT JOIN
    gold.dim_products p
ON p.product_key = s.product_key
GROUP BY
    category

-- Now in order to calculate the percentage we need two measure
-- The total sales for each category
-- The total sales accross all category using window function CTE
WITH category_sales AS (
    SELECT 
        category,
        SUM (sales_amount) AS total_sales
    FROM 
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON p.product_key = s.product_key
    GROUP BY
        category
)
SELECT 
    category,
    total_sales
FROM
    category_sales


-- Now what we want to do is to aggregate all those values to get the total sales of the whole dataset
WITH category_sales AS (
    SELECT 
        category,
        SUM (sales_amount) AS total_sales
    FROM 
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON p.product_key = s.product_key
    GROUP BY
        category
)
SELECT 
    category,
    total_sales,
    SUM (total_sales) OVER () overall_sales
    -- In order to get the overall big number of the total sales, we will not
    -- defined anything, because we dont want to partition the data, or introduced any dimension, only the big number.
FROM
    category_sales

-- Now from our result, we have the total sales of our category by side to side the overall_sales of the overall sales category


-- Now we have them side by side, we can very easily calculate the path to whole (or the percentage)

WITH category_sales AS (
    SELECT 
        category,
        SUM (sales_amount) AS total_sales
    FROM 
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
    ON p.product_key = s.product_key
    GROUP BY
        category
)
SELECT 
    category,
    total_sales,
    SUM (total_sales) OVER () overall_sales,
    -- In order to get the overall big number of the total sales, we will not
    -- defined anything, because we dont want to partition the data, or introduced any dimension, only the big number.
    CONCAT (ROUND((total_sales / SUM (total_sales) OVER ()) * 100 ,2), '%') AS percentage_of_sales 
FROM
    category_sales
ORDER BY
    total_sales DESC
/*
-- By looking at the result we will see that our bike category is dominating, it is the overwhelming top performing 
-- it is making 96% of our total sales of business. This means most of the business revenue comes from the bike,
-- Accessories and clothing, really is the minior contributors to our business which is not really good for our business
-- This is actually a dangerous thing if you have like one category dominating the overall perfomace of our business that means
-- you are over relying on only one category in your business and if this category failes that means the whole business is going to fail

So looking to this either the business has to decide removing all those products by those two categories 
or to focus more on bringing more revenue for the products that are inside those two categories.

This insight is really amazing for the business and help the stake holders to understand what is going on quickyl,
and make a better decision.

This is why the part to whole analyzes is very important because by just looking at the total sales numbers it will be 
really hard to understand the important of the categories, but by seeing the data as percentage how each category is contributin 
to the whole sales of the business, makes it easier to understand which category is underperforming or top performing



