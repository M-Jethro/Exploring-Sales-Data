-- inspecting, analysing data from Kaggle - Sales data

SELECT * FROM claver_projects.sales_data;

-- checking the unique values of each column

select distinct dealsize 
from sales_data; -- small, medium, large
select distinct country
from sales_data; -- 19 countries
select distinct status
from sales_data; -- shipped, disputed, in process, cancelled, on hold, resolved
select distinct year_id
from sales_data; -- 2003, 2004, 2005
select distinct productline 
from sales_data; -- motorcycles, classic cars, trucks and buses, vintage cars, planes, ships, trains
select distinct territory 
from sales_data; -- NA, EMEA, APAC, Japan

-- ANALYSIS

-- finding the sales by the product line
select productline, round(sum(sales), 0) 'total sales'
from sales_data
group by productline
order by 2 desc;

-- the year that had the highest sales
select year_id, round(sum(sales), 0) 'total sales'
from sales_data
group by year_id
order by 2 desc;

-- deal size with the highest sales
select dealsize, round(sum(sales), 0) 'total sales'
from sales_data
group by dealsize
order by 2 desc;

-- sales per month per year. What are the best months?
select month_id, 
       round(sum(sales), 0) as 'total sales', 
       count(ordernumber) as orders 
from sales_data
where year_id = 2003
group by month_id
order by 3 desc;

-- we find the city with the most sales per country?
select city, 
       round(sum(sales),0) as Revenue, 
       country
from sales_data
-- where country = 'UK'
group by country
order by 1 desc;

-- What is the best product in United States?
select country, 
       YEAR_ID, 
       PRODUCTLINE, 
       round(sum(sales),0) Revenue
from sales_data
where country = 'USA' -- you can choose and use any country of choice
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc;

-- for the years of 2003 and 2004, November was the by far the best performing months for the company
-- what products are sold in November?
select month_id as month, 
       round(sum(sales), 0) as 'total sales', 
       count(ordernumber) as orders,
       productline
from sales_data
where month_id = 11 and year_id = 2003
group by productline
order by 2 desc; -- Classic cars, vintage cars bring in the most revenue in the months of November for both 2003, 2004

-- we find out who our best customers are.
select customername, 
       round(sum(sales), 0) as 'total sales', 
       count(ordernumber) as orders,
       productline
from sales_data
group by customername
order by 2 desc;

alter table sales_data
add column order_date datetime after orderdate;

update sales_data
set order_date = STR_TO_DATE(orderdate, "%m/%d/%Y %H:%i");

rollback; 

-- we use the RFM (Recency - Frequency - Monetary Value) analysis to segment our clents
with rfm as
            (
              select customername, 
			         round(sum(sales), 0) as 'Money Value as Sales', 
					 count(ordernumber) as 'Frequency',
                     max(order_date) as 'customer last order date',
	                (select max(order_date) from claver_projects.sales_data) as 'sales latest order date',
                    datediff((select max(order_date) from claver_projects.sales_data), max(order_date)) as Recency
             from sales_data
             group by customername
               ),
               
RFM_Calc as -- we created an alias for the rfrm calculation done herein below
(               
select *,
       ntile(4) over (order by 'Money Value as Sales' desc) 'RFM - M',
       ntile(4) over (order by 'Frequency' desc) 'RFM - F',
       ntile(4) over (order by Recency) 'RFM - R'
from rfm 
)
-- i will create a column that represents the total rfm value of each client and another column having a string breakdown of the value
select *,
('RFM - M') + ('RFM - F') + ('RFM - R') as rfm_value
      -- ('RFM - M'+'RFM - F'+'RFM - R') RFM_Value
from RFM_Calc 



