/*

	===========================================================================================
	Customer Report
	===========================================================================================
	Purpose:
		- This Report Consolidates Key Customer Metrics And Behavior

	Highlights:
		- Gathers Essential Feilds Such As Names , Ages , Transactional Details
		- Segments Customers Into Categories (VIP , Regular , New) And Age Groups
		- Aggregates Customer-Level Metrics:
			- Total Orders
			- Total Sales
			- Total Quantity
			- total Products
			- Lifespan (In Months)
		- Calculates KPIs:
			- Recency (Months Since Last Order)
			- Average Order Value
			- Average Monthly Spend

*/
create view Customer_Report as 
with customers_report as (
select 
	c.customer_key ,
	c.customer_number ,
	concat(c.first_name , ' ' , c.last_name) as CustomerName ,
	c.country ,
	c.birthdate ,
	datediff(year , c.birthdate , getdate()) as CustomerAge ,
	f.order_number ,
	f.order_date ,
	f.sales_amount ,
	f.quantity ,
	f.product_key
from 
	FactSales as f
left join
	DimCustomers as c
on 
	c.customer_key = f.customer_key
where
	f.order_date is not null and c.birthdate is not null
)
, customer_aggregations as (
select 
	customer_key ,
	customer_number ,
	CustomerName ,
	CustomerAge ,
	country ,
	count(distinct order_number) as TotalOrders ,
	sum(sales_amount) as TotalSpending ,
	sum(quantity) as TotalQuantity , 
	count(distinct product_key) as TotalProducts ,
	max(order_date) as LastOrderDate ,
	datediff(month , min(order_date) , max(order_date)) as LifeSpan
from
	customers_report
group by
	customer_key ,
	customer_number ,
	CustomerName ,
	CustomerAge ,
	country
)

select 
	* ,
	case when LifeSpan >= 12 and TotalSpending > 5000 then 'VIP'
		 when LifeSpan >= 12 and TotalSpending <= 5000 then 'Regular'
		 else 'New'
	end as CustomerCategory ,
	case when CustomerAge < 20 then 'Under 20'
		 when CustomerAge between 20 and 29 then '20-29'
		 when CustomerAge between 30 and 39 then '30-39'
		 when CustomerAge between 40 and 49 then '40-49'
		 else 'Above 50'
	end as AgeGroup ,
	datediff(month , LastOrderDate , getdate()) as recency ,
	case when TotalOrders = 0 then 0
		 else TotalSpending / TotalOrders
	end as AverageOrderValue ,
	case when LifeSpan = 0 then 0
		 else TotalSpending / LifeSpan
	end as AverageMonthlySpend
from
	customer_aggregations;
