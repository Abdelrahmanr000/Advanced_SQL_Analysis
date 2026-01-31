select
	year(order_date) as OrderYear ,
	month(order_date) as OrderMonth ,
	sum(sales_amount) as Total_Sales ,
	count(Distinct customer_key) as Total_Customers ,
	sum(quantity) as Total_Quantity
from
	FactSales
where
	order_date is not null
group by
	year(order_date) , month(order_date)
order by
	year(order_date) , month(order_date);
