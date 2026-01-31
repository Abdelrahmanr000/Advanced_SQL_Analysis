/*

	===========================================================================================
	Product Report
	===========================================================================================
	Purpose:
		- This Report Consolidates Key Product Metrics And Behavior

	Highlights:
		- Gathers Essential Feilds Such As ProductName , Category , SubCategory and Cost
		- Segments Products by Revenue To Identify High-Prformance , Mid-Range , Low-Performance
		- Aggregates Customer-Level Metrics:
			- Total Orders
			- Total Sales
			- Total Quantity
			- Total Customers (Unique)	
			- Lifespan (In Months)
		- Calculates KPIs:
			- Recency (Months Since Last Order)
			- Average Order Revenue (AOR)
			- Average Monthly Revenue

*/
create view Product_Report as
with products_report as (
select
	p.product_key ,
	p.product_name , 
	p.category ,
	p.subcategory ,
	p.cost ,
	f.order_number ,
	f.customer_key ,
	f.order_date ,
	f.quantity ,
	f.sales_amount
from
	FactSales as f
left join 
	DimProducts as p
on
	p.product_key = f.product_key
where 
	f.order_date is not null
)
, product_aggregations as (
select
	product_key ,
	product_name , 
	category ,
	subcategory ,
	sum(cost) as TotalCost ,
	count(distinct order_number) as TotalOrders ,
	sum(sales_amount) as TotalSales ,
	sum(quantity) as TotalQuantity ,
	count(distinct customer_key) as TotalCustomers ,
	max(order_date) as LastOrderDate ,
	datediff(month , min(order_date) , max(order_date)) as lifespan
from
	products_report
group by
	product_key ,
	product_name , 
	category ,
	subcategory
)

select
	* ,
	case when TotalSales < 100000 then 'Low-Performance'
		 when TotalSales between 100000 and 150000 then 'Mid-Range'
		 else 'High-Performance'
	end as ProductSegments ,
	datediff(month , LastOrderDate , getdate()) as recency ,
	case when TotalOrders = 0 then 0
		 else TotalSales / TotalOrders
	end as AverageOrderValue ,
	case when LifeSpan = 0 then 0
		 else TotalSales / LifeSpan
	end as AverageMonthlySpend
from
	product_aggregations;
