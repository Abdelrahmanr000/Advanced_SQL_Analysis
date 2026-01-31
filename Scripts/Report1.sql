/*

	Group Customers Into Three Segments Based On Their Spending Behavior:
	- VIP: At Least 12 Months of History and Spending More Than $5000
	- Regular: At Least 12 Months of History but Spending $5000 or Less
	- New: Lifespan Less Than 12 Months

	Find Total Numbers of Customers by Each Group

*/
with customers_details as (
select
	c.customer_key ,
	sum(f.sales_amount) as TotalSpending ,
	min(f.order_date) as FirstOrder ,
	max(f.order_date) as LastOrder ,
	datediff(month , min(f.order_date) , max(f.order_date)) as LifeSpan
from
	FactSales as f
left join
	DimCustomers as c
on
	c.customer_key = f.customer_key
group by
	c.customer_key
)

-- Main Query
select
	CustomerCategory ,
	count(customer_key) as TotalCustomers 
from (
		select
			customer_key ,
			case when LifeSpan >= 12 and TotalSpending > 5000 then 'VIP'
				 when LifeSpan >= 12 and TotalSpending <= 5000 then 'Regular'
				 else 'New'
			end as CustomerCategory 
		from customers_details
	  ) t
group by
	CustomerCategory
order by
	TotalCustomers;
