/* 
1.	Change over time: What is change over time? This is a technique to analyze how a measure evolves over time 
Why is this important
-	To help track trends and identify seasonality of our data
-	Here, we will aggregate a measure based on the data dimension
-	This will enable us to track how our business is doing over the course of the year 
*/

-- Question: Find the sales perfomance over time
SELECT 
    order_date,
    SUM(sales_amount) AS total_sales
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    order_date
ORDER BY
    order_date
-- From our result you will see that for each day we have a total sales
-- we dont aggregate the data on the day level we will need to have a higher aggregations like the years
-- So let aggregate and extract the day from the year. We will change from daily sales to yearly sales


SELECT 
    EXTRACT(YEAR FROM order_date) AS yearly_order,
    SUM(sales_amount) AS total_sales
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM order_date)
ORDER BY
    EXTRACT(YEAR FROM order_date);
/*
    -- Now we are at the year and we have only 5 years
    -- Now it is very easy to analyze the perfomance of our business over the years
From our result, the first year was the lowest and 2013 was the highest sales and it also went donw massively in 2014
*/


-- Lets further to count the total customers over the years to know if we are gaining or lossing customer over the years
-- and the total quantity of products
SELECT 
    EXTRACT(YEAR FROM order_date) AS yearly_order,
    SUM(sales_amount) AS total_sales,
    count (DISTINCT customer_key)   AS total_customer,
    SUM (quantity) AS total_quantity
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM order_date)
ORDER BY
    EXTRACT(YEAR FROM order_date);
-- From our result we have a clear picture and we can see if the revenue is increasing or decreasing over the time,
-- What is the best and worst year, are we gaining customer over time is there any trends that we can spot?
-- This gives us the high level long-time view of our data and of course it helps for strategic decision making


-- Now lets aggregate our data down to the month to know how each months are performing on average.
-- we will just swicth the function from year to months.

SELECT 
    EXTRACT(MONTH FROM order_date) AS monthly_order,
    SUM(sales_amount) AS total_sales,
    count (DISTINCT customer_key)   AS total_customer,
    SUM (quantity) AS total_quantity
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    EXTRACT(MONTH FROM order_date)
ORDER BY
    total_sales DESC
-- From our result we could see that the best month for our bike sales is on December, and the worst month sales is on Febuary
-- With this result we are now understanding the seasonality of our business and the trends parttern of our business 


-- Now lets further make it more specific for each year

SELECT 
    EXTRACT(YEAR FROM order_date) AS YEAR_order,
    EXTRACT(MONTH FROM order_date) AS monthly_order,
    SUM(sales_amount) AS total_sales,
    count (DISTINCT customer_key)   AS total_customer,
    SUM (quantity) AS total_quantity
FROM
    gold.fact_sales
WHERE
    order_date IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    YEAR_order,
    total_sales DESC

-- From our result we now have all the months of all years and we now have a clearly view of what each month is doing over the year.

