
#1.Data type of all columns in the "customers" table.
SELECT
column_name,
data_type
FROM
`alert-outlet-348511.target.INFORMATION_SCHEMA.COLUMNS`
WHERE
table_name = 'customers';

#2.Get the time range between which the orders were placed.
SELECT
MIN(order_purchase_timestamp) AS earliest_order_time,
MAX(order_purchase_timestamp) AS latest_order_time
FROM
alert-outlet-348511.target.orders


#3. Count the Cities & States of customers who ordered during the given period.
SELECT
count(distinct customer_city) as cnt_city,
count(distinct customer_state) as cnt_state,
FROM
alert-outlet-348511.target.orders o
join alert-outlet-348511.target.customers c on o.customer_id = c.customer_id


#In-depth Exploration:
#4.Is there a growing trend in the no. of orders placed over the past years?
SELECT
EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
COUNT(*) AS total_orders
FROM
alert-outlet-348511.target.orders o
GROUP BY
year
ORDER BY
year;

#5.Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
SELECT
EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2016) AS orders_2021,
COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2017) AS orders_2022,
COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2018) AS orders_2023,
FROM
alert-outlet-348511.target.orders
GROUP BY
order_month
ORDER BY
order_month;


#6.During what time of the day, do the Brazilian customers mostly place their orders?
(Dawn, Morning, Afternoon or Night)
SELECT
CASE
 WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
 WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
 WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
 WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
 ELSE 'Unknown'
END AS time_of_day,
COUNT(*) AS total_orders
FROM
alert-outlet-348511.target.orders
GROUP BY
time_of_day
ORDER BY
total_orders DESC;

#Evolution of E-commerce orders in the Brazil region:
#7.Get the month on month no. of orders placed in each state.
SELECT
EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
customer_state,
COUNT(*) AS total_orders
FROM
`alert-outlet-348511.target.orders` o
left join alert-outlet-348511.target.customers c on c.customer_id = o.customer_id
GROUP BY
order_month, customer_state
ORDER BY
order_month, total_orders DESC;

#8.How are the customers distributed across all the states?
SELECT
customer_state,
COUNT(*) AS cnt_customers
FROM
alert-outlet-348511.target.customers
GROUP BY
1
ORDER BY
2 desc


#Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
#9.Get the % increase in the cost of orders from year 2017 to 2018 (include months
between Jan to Aug only).You can use the "payment_value" column in the payments
table to get the cost of orders.
WITH payment_summary AS (
SELECT
 EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
 ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM
 `alert-outlet-348511.target.orders` AS o
JOIN
 `alert-outlet-348511.target.payments` AS p
USING (order_id)
WHERE
 EXTRACT(YEAR FROM order_purchase_timestamp) IN (2017, 2018)
 AND EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8
GROUP BY
 year
),
year_values AS (
SELECT
 MAX(CASE WHEN year = 2017 THEN total_payment_value END) AS value_2017,
 MAX(CASE WHEN year = 2018 THEN total_payment_value END) AS value_2018
FROM
 payment_summary
)
SELECT
value_2017,
value_2018,
ROUND(((value_2018 - value_2017) / value_2017) * 100, 2) AS percent_increase
FROM
year_values;

#10.Calculate the Total & Average value of order price for each state.
#11.Calculate the Total & Average value of order freight for each state.
SELECT c.customer_state,round(sum(oi.price))as total_price,
round(avg(oi.price))as avg_price,
round(sum(oi.freight_value))as total_freight_value,
round(avg(oi.freight_value))as avg_freight_value
FROM `alert-outlet-348511.target.order_items` oi join
alert-outlet-348511.target.orders o on oi.order_id=o.order_id
join alert-outlet-348511.target.customers c on c.customer_id= o.customer_id
group by 1

#Analysis based on sales, freight and delivery time.
#12. Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
#Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
SELECT
order_id,
customer_id,
TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, day) AS
time_to_delivery,
TIMESTAMP_DIFF(order_estimated_delivery_date, order_delivered_customer_date, day) AS
diff_estimated_delivery
FROM
alert-outlet-348511.target.orders



#13.Find out the top 5 states with the highest & lowest average freight value.
with afv as (
SELECT c.customer_state,
round(avg(oi.freight_value))as avg_freight_value
FROM `alert-outlet-348511.target.order_items` oi join
alert-outlet-348511.target.orders o on oi.order_id=o.order_id
join alert-outlet-348511.target.customers c on c.customer_id= o.customer_id
group by 1)
-- top5 states
select customer_state, avg_freight_value from afv order by avg_freight_value desc
limit 5

-- least 5 states
select customer_state, avg_freight_value from afv order by avg_freight_value limit 5


#14.Find out the top 5 states with the highest & lowest average delivery time.
with delivery_time as
(SELECT c.customer_state,
avg(TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, day)) AS
avg_time_to_delivery,
from
alert-outlet-348511.target.orders o
join alert-outlet-348511.target.customers c on c.customer_id= o.customer_id
where order_status='delivered'
group by 1
)
select * from delivery_time order by avg_time_to_delivery desc limit 5


—lowest delivery time
select * from delivery_time order by avg_time_to_delivery limit 5

#15.Find out the top 5 states where the order delivery is really fast as compared to the
estimated date of delivery.
SELECT
 customer_state,
 ROUND(AVG(estimated_delivery_time - actual_delivery_time), 2) AS
delivery_time_difference
FROM (
 SELECT
 o.order_id,
 c.customer_state,
 TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, day) AS
actual_delivery_time,
 TIMESTAMP_DIFF(order_estimated_delivery_date, order_purchase_timestamp, day) AS
estimated_delivery_time
 FROM
 `alert-outlet-348511.target.orders` o
 JOIN
 `alert-outlet-348511.target.customers` c
 USING
 (customer_id)
 WHERE
 order_status = "delivered") t1
GROUP BY
 customer_state
ORDER BY
 delivery_time_difference DESC
LIMIT 5;


#16.states with late delivery compared to estimated date
SELECT
 customer_state,
 ROUND(AVG(estimated_delivery_time - actual_delivery_time), 2) AS
delivery_time_difference
FROM (
 SELECT
 o.order_id,
 c.customer_state,
 TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, day) AS
actual_delivery_time,
 TIMESTAMP_DIFF(order_estimated_delivery_date, order_purchase_timestamp, day) AS
estimated_delivery_time
 FROM
 `alert-outlet-348511.target.orders` o
 JOIN
 `alert-outlet-348511.target.customers` c
 USING
 (customer_id)
 WHERE
 order_status = "delivered") t1
GROUP BY
 customer_state
ORDER BY
 Delivery_time_difference
LIMIT 5;

#Analysis based on the payments:
#17. Find the month on month no. of orders placed using different payment
types.
SELECT
 month,
 payment_type,
 COUNT(*) AS total_orders
FROM (
 SELECT
 p.order_id,
 p.payment_type,
 FORMAT_DATE('%b %Y', DATE(ORDER_PURCHASE_TIMESTAMP)) AS month
 FROM
 `alert-outlet-348511.target.payments` p
 JOIN
 `alert-outlet-348511.target.orders` o
 on p.order_id= o.order_id
) t1
GROUP BY
1,2


#18. Find the no. of orders placed on the basis of the payment installments that
have been paid.
SELECT
 payment_installments,
 COUNT(*) AS total_orders
FROM
 `alert-outlet-348511.target.payments`
GROUP BY
 payment_installments;


