Use zomato;

show tables;

select * from users;
select * from orders;
select * from menu;
select * from food;
select * from restaurants;

# 1. Find customers who have never ordered

select * from users
where user_id not in (select user_id from orders);

select u.* 
from users u
left join orders o
on u.user_id = o.user_id 
where o.user_id is NULL ;
-----------------------------------------------------------------------------------------------------------
# 2. Average Price/dish

select m.f_id,
		f.f_name as Dish , 
        round(avg(price),2) as Avg_Price
from menu m
join food f
on m.f_id = f.f_id 
group by m.f_id ,f.f_name
order by m.f_id ;
-----------------------------------------------------------------------------------------------------------
# 3. Find the top restaurant in terms of the number of orders for a given month

select o.r_id,
		r.r_name as Restaurant, 
        count(*) as order_qty 
from orders o
join restaurants r 
on o.r_id = r.r_id 
where monthname(date) = "june" 
group by o.r_id , r.r_name
order by order_qty desc
limit 1;
-----------------------------------------------------------------------------------------------------------
# 4. restaurants with monthly sales greater than $ 500 

select r.r_id ,
		r.r_name as Restaurants, 
		sum(amount) as Monthly_sales  
from orders o
join restaurants r
on o.r_id = r.r_id
where monthname(date) = "june" 
group by r.r_id,r.r_name 
having Monthly_sales >= 500 ;
-----------------------------------------------------------------------------------------------------------
# 5. Show all orders with order details for a particular customer in a particular date range

select o.order_id,
		r.r_name as restaurants, 
		f.f_name as Food_Name
from orders o
join order_details od
on od.order_id = o.order_id
JOIN restaurants r ON o.r_id = r.r_id
join food f on od. f_id = f.f_id
where o.user_id like (select user_id from users where name = "Ankit")
and (date > "2022-06-10" and date < "2022-07-10");

-----------------------------------------------------------------------------------------------------------
# 6. Find restaurants with max repeated customers 

select r.r_name ,count(*) as loyal_customer
from (
		select  r_id ,user_id , count(*) as Visits
		from orders
		group by user_id , r_id
		having Visits > 1 
		order by r_id ) t 
JOIN restaurants r ON r.r_id = t.r_id
group by r.r_name
order by loyal_customer Desc
limit 1 ; 

WITH VISITER AS (select  r_id ,user_id , count(*) as Visits
		from orders
		group by user_id , r_id
		having Visits > 1 
		order by r_id)
SELECT r.r_name ,count(*) as Loyal_customer
FROM VISITER v
JOIN restaurants r ON r.r_id = v.r_id
group by r.r_name
order by Loyal_customer desc
limit 1 ;

-----------------------------------------------------------------------------------------------------------
#7. Month over month revenue growth for total restaurants 

WITH Total_sales as (
		select monthname(date) as months ,sum(amount) as Revenue
		from orders
		group by months , MONTH(date)
        ORDER BY MONTH(date)),
	Differnce as (select months ,revenue,
					lag(Revenue, 1)over(order by revenue ) as prev
				from Total_sales )
select months , 
		concat((((revenue - prev)/prev)*100),"%") as "%growth"
from Differnce ;
-----------------------------------------------------------------------------------------------------------
# 8. Customer name and its favorite food

With temp as (
	 select o.user_id ,od.f_id ,count(*) as Frequency
	 from orders o
	 join order_details as od
	 on o.order_id = od.order_id
	 group by o.user_id,od.f_id )
select t1.* , u.name ,f.f_name
from temp t1
join users u on u.user_id = t1.user_id 
join food f on t1.f_id = f.f_id 
where t1.Frequency  = (select max(Frequency) from temp t2
						where t1. user_id = t2.user_id)
order by u.user_id;
-----------------------------------------------------------------------------------------------------------
# 9. Find the most loyal customers for all restaurant

SELECT o.r_id, o.user_id, COUNT(*) AS visit, u.name, r.r_name
FROM orders o 
JOIN users u ON o.user_id = u.user_id 
JOIN restaurants r ON o.r_id = r.r_id
GROUP BY o.r_id, o.user_id, u.name, r.r_name
HAVING COUNT(*) > 1
ORDER BY o.r_id;

-----------------------------------------------------------------------------------------------------------
# 10.  Month over month revenue growth of a restaurant 

WITH Month_Rev as ( 
				select r_id ,monthname(date) as months ,sum(amount) as Revenue 
				from orders
				group by r_id , months,month(date)
				order by  r_id ,month(date) ),
		Diff as (SELECT r_id, months, 
						Revenue, 
						LAG(Revenue, 1) OVER (PARTITION BY r_id ORDER BY r_id) AS prev
				FROM Month_Rev ) 
SELECT r.r_name, 
		d.r_id, 
        d.months, 
        d.Revenue, 
        d.prev, ((d.Revenue - d.prev) / d.prev) * 100 AS "%diff"
FROM  diff d
JOIN restaurants r
ON r.r_id = d.r_id ;




