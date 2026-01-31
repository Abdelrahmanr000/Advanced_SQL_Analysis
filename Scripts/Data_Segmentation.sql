/*Segment Products Into Cost Ranges And 
  Count How Many Products Fall Into Each Segment */
with products_cost as (
select
	product_key ,
	product_name ,
	cost , 
	case when cost < 100 then 'Below 100'
		 when cost between 100 and 500 then '100-500'
		 when cost between 500 and 1000 then '500-1000'
		 else 'Above 1000'
	end as CostSegments
from
	DimProducts
)

-- Main Query 
select 
	CostSegments ,
	count(product_key) as ProductsCount
from
	products_cost
group by
	CostSegments
order by
	count(product_key) desc;
