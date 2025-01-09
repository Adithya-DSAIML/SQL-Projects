use sql_project;

USE sql_project;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- DATA CLEANING

# Checking the number of rows and the columns used in the dataset
select count(*) as total_rows from retail_sales;
select * from retail_sales;

# Checking for NULL values in the dataset
select * from retail_sales where transaction_id is NULL;
select * from retail_sales where sale_date is NULL;
select * from retail_sales where sale_time is NULL;
select * from retail_sales where transaction_id is NULL or sale_date is NULL or sale_time is NULL or
customer_id is NULL or gender is NULL or age is NULL or category is NULL or quantity is NULL or
price_per_unit is NULL or cogs is NULL or total_sale is NULL;

# Deleting the NULL values from the dataset
delete from retail_sales
where transaction_id is NULL or sale_date is NULL or sale_time is NULL or
customer_id is NULL or gender is NULL or age is NULL or category is NULL or quantity is NULL or
price_per_unit is NULL or cogs is NULL or total_sale is NULL;
select count(*) as total_rows from retail_sales;

-- DATA EXPLORATION
#Total number of sales?
select count(*) as total_sales from retail_sales;

# How many customers we have?
select count( distinct customer_id) as nbr_of_customers from retail_sales;

# How Many Categories do we have?
select distinct category from retail_sales;


-- DATA Analysis
#Q1 To retrieve all columns for sales made on '2022-11-05'
select * from retail_sales where sale_date = '2022-11-05';

#Q2 To retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 2 in the month of Nov-2022
select * from retail_sales
where category = 'Clothing' and sale_date between '2022-11-01' and '2022-11-30' and quantity >= 2;

#Q3 Write a SQL query to calculate the total sales (total_sale) and orders for each category
select category, sum(total_sale) as total_sales, count(*) as total_orders from retail_sales
group by category;

#Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category, round(avg(age),2) as average_age from retail_sales
where category like 'beauty'
group by category;

#Q5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales
where total_sale >= 1000;

#Q6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category,gender, count(transaction_id) as total_transaction from retail_sales
group by 1,2
order by 2;

#Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
with cte as (select year(sale_date) as years, month(sale_date) as months, avg(total_sale) as average_sale, rank() over(partition by year(sale_date) order by avg(total_sale) desc) as ranks
from retail_sales
group by year(sale_date), month(sale_date)
order by 1,3 desc)
select years, months, round(average_sale,2) as average_sale from cte
where ranks = 1;
-- The Month July in 2022 and February in 2023 are the best selling month

#Q8 Write a SQL query to find the top 5 customers based on the highest total sales 
select customer_id, sum(total_sale) as total_sales from retail_sales 
group by customer_id
order by 2 desc
limit 5;

#Q9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category, count(distinct customer_id) as unique_customer from retail_sales
group by category;

#Q10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
select 
case 
when hour(sale_time) < 12 then 'morning'
when hour(sale_time) between 12 and 17 then 'afternoon' 
else 'evening' end as shift_timing,count(transaction_id) as nbr_of_ordr_per_shift
from retail_sales
group by shift_timing
