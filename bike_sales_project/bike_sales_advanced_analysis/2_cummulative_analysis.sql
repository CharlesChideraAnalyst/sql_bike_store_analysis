/*
2.	Cumulative Analysis
What is cumulative Analysis? This simply means aggregating the data progressively over time. And 
this is an important technique to understand how our business is growing over time, 
how our business is progressing over time (i.e., whether the business is growing or declining)
-	Here we will be aggregating our measure with the cumulative. You can say is like adding our sales on top of each other.  
-	Here, we will split it by the date dimension because we want to track the progress over time 
-	-What we will do here is to
-	Find the running total sales by year
-	Or the moving Average of sales by month 
-	We will use the aggregate window functions to find out the cumulative values
*/

--  Question: 
    -- Calculate the total sales per month
    -- And the running total of sales over time


SELECT 
    DATE_TRUNC('month', order_date ) AS order_month,
    SUM(sales_amount) AS total_sales
FROM 
    gold.fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    DATE_TRUNC('month', order_date)
ORDER BY 
    DATE_TRUNC('month', order_date);
-- Now our date is aggregated for each month individually, 
-- Now we need a cummulative metric to run our sales

-- Using Subquery

SELECT 
    order_month,
    total_sales,
    SUM (total_sales) over (order by order_month) AS running_total_sales
FROM
    (
            
    SELECT 
        DATE_TRUNC('month', order_date ) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM 
        gold.fact_sales
    WHERE 
        order_date IS NOT NULL
    GROUP BY 
        DATE_TRUNC('month', order_date)
    ORDER BY 
        DATE_TRUNC('month', order_date)
      )
-- From the result we can see that our running_total_sales values are cummulative and it is going over the years
-- Now lets limit the running total for only one year each. 
-- So that for each new year, it will have to reset and start from scratch.
-- We will be using the window function  partition by.


SELECT 
    order_month,
    total_sales,
    SUM (total_sales) over (PARTITION BY order_month order by order_month) AS running_total_sales
FROM
    (
            
    SELECT 
        DATE_TRUNC('month', order_date ) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM 
        gold.fact_sales
    WHERE 
        order_date IS NOT NULL
    GROUP BY 
        DATE_TRUNC('month', order_date)
    ORDER BY 
        DATE_TRUNC('month', order_date)
      )

-- Our cummulative running total has reset for each year, what it means is that it will not add the sales of last year 
-- to the present year.


-- Now lets also analyize the moving average of the price
SELECT 
    order_month,
    total_sales,
    SUM (total_sales) over (PARTITION BY order_month order by order_month) AS running_total_sales,
    ROUND (AVG (avg_price) over (PARTITION BY order_month order by order_month), 2) AS moving_average_price
FROM
    (
            
    SELECT 
        DATE_TRUNC('month', order_date ) AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG (price) as avg_price
    FROM 
        gold.fact_sales
    WHERE 
        order_date IS NOT NULL
    GROUP BY 
        DATE_TRUNC('month', order_date)
    ORDER BY 
        DATE_TRUNC('month', order_date)
      )
-- what is the different between the Normanl aggregation and cummulative aggregation?
    -- We use the normal aggregation to check the performance of each induvidual roles
    -- But if you want to see a progression and you want to understand how your business is
    -- growing over time, you have to use the cummulative aggregation because you can see easily the progess 
    -- of your over the years. 