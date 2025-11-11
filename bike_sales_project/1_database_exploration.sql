-- Explore all objects in the Database
SELECT  *
FROM    INFORMATION_SCHEMA.TABLES



-- Lets check colums that we have inside our database
-- Explore all colums in the Database
SELECT  *
FROM    INFORMATION_SCHEMA.COLUMNS
WHERE  
        TABLE_name  ='dim_customers'

-- Here we can see that we have 10 colums inside our table and 
-- this is how the colums are sorted inside our tables, and all the tables in it.

/* Now we can see that we are exploring the strcture of our database
and this is really helpful to ge the overview of the database and the projects.
also this is important to get a feeling about the projects and set the foundation 
of exploring the data inside those tables.
*/

