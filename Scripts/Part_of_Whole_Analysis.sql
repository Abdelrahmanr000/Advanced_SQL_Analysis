-- Which Categories Contribute The Most To Overall Sales?
with categories_sales as (
select
	p.category ,
	sum(f.sales_amount) as TotalSalesPerCategory 
from
	FactSales as f
left join 
	DimProducts as p
on
	f.product_key = p.product_key
group by 
	category
)

-- Main Query
select 
	* ,
	sum(TotalSalesPerCategory) over() as TotalSales ,
	concat(round((cast(TotalSalesPerCategory as float) / sum(TotalSalesPerCategory) over()) * 100 , 2) , '%') as CategoryContributionPercent
from
	categories_sales
order by 
	CategoryContributionPercent desc;
