-- OUR CUSTOMER REPORT VIEW
-- This contain a 360 degree view of report about our customer 

/*
    Here we created a full view of our customer report and create a view for it
    so that from this full view we can go ahead and create a visualization for our customers
    it contain every details about our customer that we build.

    we dont need to go and query our facts, sales, and product table in order to get information for our csutomer
    every information need to get to know our customers are here.

    you just have to query from this view.
*/
 
 
 
 SELECT *
 FROM
    gold.customer_report