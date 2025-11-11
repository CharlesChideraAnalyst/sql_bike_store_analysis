/*
Here we are going to explore the boundaries of the date that we have in the data sets.
-	What is the earliest and the latest date in my data
-	To also understand the time span we have in our business
-	We will be using the Min/Max functions
*/

-- Find the date of the First and Last order

SELECT 
        order_date
FROM    
        gold.fact_sales



-- To find the first date we will use the Min and Max function
SELECT 
        Min (order_date) AS first_order_date,
        Max (order_date) AS last_order_date
FROM    
        gold.fact_sales

-- From our query our   Min date is 2010
--                      Max date is 2014
-- with this we have explore the boundaries of our order date, the first and the last
-- From here we can understand very quickly that we are analyzing a four years of sales.

-- Let go ahead and Calculate How many years of sales we have in our business.
-- We will use a DATEDIFF command

SELECT  
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS order_range_years
FROM gold.fact_sales;

-- TO extract Months
SELECT  
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS order_range_months
FROM gold.fact_sales;


-- Lets find the youngest and the oldest customer in our business.

SELECT 
    MIN(birthdate) AS oldest_birthdate,
    MAX(birthdate) AS youngest_birthdate,
    DATE_PART('year', AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_age,
    DATE_PART('year', AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_age
FROM gold.dim_customers;
-- From exploring our date colum we can see that our oldest bike customer is 109years
-- and our youngest customer is 39 years old. 

