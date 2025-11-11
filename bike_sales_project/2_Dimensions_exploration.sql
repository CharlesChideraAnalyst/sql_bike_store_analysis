/* Here, we will be identifying the unique values (or categories) in each dimension that we have inside our database. This will help us understand 
-	What are the categories, which countries, and what are the product types that we have inside our database? (recognizing  how data might be grouped or segmented, which is useful for later analysis) We will explore the DISTINCT
1.	Let's start with the customer table and the column country to explore the countries our customer comes from
*/


--Exlpore the Countries
SELECT  DISTINCT country
FROM    gold.dim_customers  
-- From the result we can see that we have 6 countries
-- this is to understand the geographical spread of our business
-- So we have customers from our business that comes from 6 different countries  



-- Explore all the product Categoiries "The Major Division" inside our business
SELECT  DISTINCT category
FROM    gold.dim_products
--From our output you will see we have four categories from our product table
-- This is giving us the overview of the product range what are the major division
-- inside our business.

-- Let dive deeper to see the subcategories on our product
SELECT DISTINCT category,
        subcategory,
        product_name
FROM    gold.dim_products
ORDER BY category ASC
-- Here we can see that our categories are now splitted into more specific group
-- Also we can see that our subcategory has more details about our products. 
-- Now we know the breakdown of the products we are analyzing, and how the data is organized