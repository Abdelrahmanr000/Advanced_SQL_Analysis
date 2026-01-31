-- Calculate The Total Sales Per Month
-- And The Running Total Of Sales Over Time
with sales_over_months as (
select 
	datetrunc(month , order_date) as OrderDate ,
	sum(sales_amount) as TotalSales 
from
	FactSales
where
	datetrunc(month , order_date) is not null
group by
	datetrunc(month , order_date)
)

-- Main Query
select 
	* ,
	sum(TotalSales) over(order by OrderDate) as RunningTotal
from 
	sales_over_months
order by
	OrderDate;
