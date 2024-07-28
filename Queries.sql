select * from df_orders;


-- Find TOP 10 highest revenue generating products

select product_id, sum(sale_price) as revenue
from df_orders
group by product_id
order by revenue desc
limit 10;

-- Find Top 5 highest selling products in each region

with cte as(
select  region, product_id, sum(sale_price) as revenue
from df_orders
group by region, product_id
)
select * from(
select * 
, row_number() over(partition by region order by revenue desc) as rn
from cte) A 
where rn <= 5

-- Find month over month growth comparision for 2022 and 2023 sales eg: feb 2022 vs feb 2023

with cte as (
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(sale_price) AS revenue
FROM df_orders
GROUP BY 
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
)
select month
, sum(case when year = 2022 then revenue else 0 end) as revenue_2022
, sum(case when year = 2023 then revenue else 0 end) as revenue_2023
from cte
group by month
order by month;

-- For each category which month had highest revenue

With cte as (
SELECT category,TO_CHAR(order_date, 'YYYY/MM') AS order_year_month, sum(sale_price) as revenue
FROM df_orders
group by category,order_year_month
order by category,order_year_month
)
select * from (
	select * , 
	row_number() over(partition by category order by revenue desc) as rn
	from cte
) A
Where rn = 1

-- Which category has the highest growth by profit in 2023 compare to 2022


with cte as (
SELECT sub_category,
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(sale_price) AS revenue
FROM df_orders
GROUP BY 
    EXTRACT(YEAR FROM order_date),sub_category
)
	, cte2 as (
select sub_category
, sum(case when year = 2022 then revenue else 0 end) as revenue_2022
, sum(case when year = 2023 then revenue else 0 end) as revenue_2023
from cte
group by sub_category)
select *, (revenue_2023 - revenue_2022)*100/revenue_2022 as Growth
from cte2
order by Growth desc
limit 1






