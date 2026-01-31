/* Analyze The Yearly Performance of Products by Comparing Their Sales To both
	Average Sales Performance of The Product And Their Previous Year's Sales */

with yearly_product_sales as (
select 
	year(f.order_date) as OrderYear ,
	p.product_name ,
	sum(f.sales_amount) as CurrentSales
from 
	DimProducts as p
left join
	FactSales as f
on
	p.product_key = f.product_key
where
	f.order_date is not null
group by
	year(f.order_date) , p.product_name
)

-- Main Query
select 
	* ,
	avg(CurrentSales) over(partition by product_name) as AvgSales ,
	CurrentSales - avg(CurrentSales) over(partition by product_name) as DiffAvg ,
	case when CurrentSales - avg(CurrentSales) over(partition by product_name) > 0 then 'Above Average'
		 when CurrentSales - avg(CurrentSales) over(partition by product_name) < 0 then 'Below Average'
		 else 'Avg'
	end as AvgChange ,
	lag(CurrentSales) over(partition by product_name order by OrderYear) as PreviousYearSales ,
	CurrentSales - lag(CurrentSales) over(partition by product_name order by OrderYear) as DiffPreviousYear ,
	case when CurrentSales - lag(CurrentSales) over(partition by product_name order by OrderYear) > 0 then 'Increase'
		 when CurrentSales - lag(CurrentSales) over(partition by product_name order by OrderYear) < 0 then 'Decrease'
		 else 'No Change'
	end as PreviousYearChange
from 
	yearly_product_sales;
