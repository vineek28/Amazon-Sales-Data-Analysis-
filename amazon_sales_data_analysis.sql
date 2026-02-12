-- Amazon Project - Advanced SQL


-- category TABLE
CREATE TABLE category
(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(20)
);


-- customers TABLE
CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    state VARCHAR(20),
    address VARCHAR(5) DEFAULT ('xxxx')
);


-- sellers TABLE
CREATE TABLE sellers
(
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(25),
    origin VARCHAR(5)
);
-- error in charercter chaing the length of orgin 
alter table sellers
alter column origin type varchar(20);

-- products table
CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price FLOAT,
    cogs FLOAT,
    category_id INT,  -- FK
    CONSTRAINT product_fk_category
        FOREIGN KEY (category_id)
        REFERENCES category(category_id)
);


-- orders table
CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,  -- FK
    seller_id INT,    -- FK
    order_status VARCHAR(15),
    CONSTRAINT orders_fk_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT orders_fk_sellers
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);


-- order_items table
CREATE TABLE order_items
(
    order_item_id INT PRIMARY KEY,
    order_id INT,    -- FK
    product_id INT,  -- FK
    quantity INT,
    price_per_unit FLOAT,
    CONSTRAINT order_items_fk_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT order_items_fk_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- payment TABLE
CREATE TABLE payments
(
    payment_id INT PRIMARY KEY,
    order_id INT,  -- FK
    payment_date DATE,
    payment_status VARCHAR(20),
    CONSTRAINT payments_fk_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- shippings TABLE
CREATE TABLE shippings
(
    shipping_id INT PRIMARY KEY,
    order_id INT,  -- FK
    shipping_date DATE,
    return_date DATE,
    shipping_providers VARCHAR(15),
    delivery_status VARCHAR(15),
    CONSTRAINT shippings_fk_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

--inventory table 
CREATE TABLE inventory
(
    inventory_id INT PRIMARY KEY,
    product_id INT,      -- FK
    stock INT,
    warehouse_id INT,
    last_stock_date DATE,
    CONSTRAINT inventory_fk_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);



-- end of schema 

-- Start of Basic Exploitory Data Analysis Per Table (EDA) 
--category 
select * from category;

--customers
select * from customers;
select distinct state, count(state) from customers
group by state
order by count(state) desc;

--inventory 
select * from inventory;
select distinct warehouse_id from inventory;

--order_items
select * from order_items;
select * from order_items 
order by price_per_unit desc;

--orders 
select * from orders;
select distinct order_status from orders;
select order_status, count(order_status)
from orders 
group by order_status;

--payments 
select * from payments;
select order_id, count(order_id)
from payments
group by order_id
order by order_id desc;

select payment_status,count(payment_status)
from payments
group by payment_status;

--products
select * from products;

--sellers 
select * from sellers;
select origin, count(origin)
from sellers 
group by origin; 

--shipping 
select * from shippings;
select distinct delivery_status from shippings;
select distinct shipping_providers from shippings;
select shipping_providers, count(delivery_status), delivery_status
from shippings
group by shipping_providers, delivery_status;

-- Start of Relationship checks between tables and validate business rules 
--1. are there any orders placed without cusotmer id in the order table - note the tables can be coonected through customer_id
select o.order_id, o.order_status, o.customer_id
from orders o 
left join customers c on (o.customer_id = c.customer_id) 
group by (o.customer_id, o.order_id)
having(o.customer_id is null)

--2. customer with the most orders 
select c.first_name, c.last_name,o.customer_id, count(o.customer_id) as max_orders
from orders o 
left join customers c on (o.customer_id = c.customer_id) 
group by (c.first_name, c.last_name, o.customer_id)
order by count(o.customer_id) desc;

--3. orders with no payments these 2 are connected via order_id
-- my understanding: the payments that have failed only have orders that are cancelled. all orders have a corresponding payments feild. 
select distinct payment_status from payments;
select distinct order_status from orders;
select o.order_id, o.order_status, p.payment_id, p.payment_status 
from payments p 
left join orders o on (o.order_id = p.order_id)
where payment_status = 'Payment Failed';

--my understdaning - every order that is completed has a valid succesfull payment//
select o.order_id, o.order_status, p.payment_id, p.payment_status 
from payments p 
left join orders o on (o.order_id = p.order_id)
where (payment_status = 'Payment Failed' and order_status = 'Completed');

select o.order_id, o.order_status, p.payment_id, p.payment_status 
from payments p 
left join orders o on (o.order_id = p.order_id)
where (payment_status = 'Payment Successed');

--4. grouping products based on categories and ranking them in order 
select count(p.category_id), c.category_name, dense_rank() over (order by count(p.category_id) desc) from category c
left join products p on (p.category_id = c.category_id)
group by (c.category_name)
order by count(p.category_id) desc;

--5. shipping exisits but order is missing 
select s.shipping_id, s.order_id
from shippings s
left join orders o on o.order_id = s.order_id
where o.order_id is null;

--6. orders with no order items
select o.order_id
from orders o
left join order_items oi on oi.order_id = o.order_id
where oi.order_id is null;


--business problems 
/*
1. Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.
*/

alter table order_items
add column total_sales float

update order_items 
set total_sales = quantity * price_per_unit;


select 
  oi.product_id,
  p.product_name,
  sum(oi.total_sales) as total_sale,
  count(o.order_id) as total_orders
from orders o
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
group by 1, 2
group by 3 DESC
limit 10;

/*
2. Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.
*/
select p.category_id, c.category_name, sum(oi.total_sales) as total_sale from
products p
join order_items oi on (oi.product_id = p.product_id) 
left join category c on (c.category_id = p.category_id)
group by 1,2
order by 3 desc;

/*
3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.
*/
--formula: total_revenue/total_order 
--first we have to select the approrpiate tables: order_items, orders, customers 
select concat(c.first_name, ' ', c.last_name) as full_name, 
c.customer_id, sum(oi.total_sales)/count(o.order_id) as aov, count(o.order_id) as total_orders
from orders o
join customers c on (c.customer_id = o.customer_id)
join order_items oi on (oi.order_id = o.order_id)
group by 1,2
having count(o.order_id)>5
order by 3 desc;

/*
4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!
*/

-- the data set has a max date of july 2024. so takng values from 2023 july to 2024 july.
select max(order_date) from orders o;
select * from order_items;

select order_year, order_month, total_sale,lag(total_sale) over(order by order_year, order_month) from 
(
select extract (year from order_date) as order_year, extract(month from order_date) as order_month, 
sum(total_sales) as total_sale
from order_items oi
join orders o on (o.order_id = oi.order_id)
where (o.order_date >= '2023-07-01' and o.order_date <= '2024-07-31')
group by (1,2)
order by 1,2
) as t1 ;

/*
5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.
*/


select * from 
customers c 
left join orders o on (c.customer_id = o.customer_id)
where o.customer_id is null;

/*
6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.
*/

with ranking_table
as 

(
SELECT 
	c.state,
	cat.category_name,
	SUM(oi.total_sales) as total_sale,
	RANK() OVER(PARTITION BY c.state ORDER BY SUM(oi.total_sales) ASC) as rank
FROM orders as o
JOIN 
customers as c
ON o.customer_id = c.customer_id
JOIN
order_items as oi
ON o.order_id = oi. order_id
JOIN 
products as p
ON oi.product_id = p.product_id
JOIN
category as cat
ON cat.category_id = p.category_id
GROUP BY 1, 2
)
SELECT 
*
FROM ranking_table
WHERE rank = 1


/*
7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.
*/


select  c.customer_id, concat(first_name, ' ',last_name) as full_name, sum(total_sales) as cltv, 
dense_rank() over(order by sum(total_sales) desc)
from customers c 
join orders o on (c.customer_id = o.customer_id)
join order_items oi on (o.order_id  = oi.order_id)
group by 1,2
order by 3 desc;


/*
8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.
*/

select i.product_id, i.warehouse_id, i.last_stock_date, p.product_name, i.stock
from inventory i
left join products p on (i.product_id = p.product_id)
where i.stock < 10
order by i.stock desc;

/*
9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
*/


select c.customer_id, o.order_id, s.shipping_providers, s.delivery_status,s.shipping_date - o.order_date days_from_order_to_shipment
from orders o 
join customers c on (o.customer_id = c.customer_id)
join shippings s on (o.order_id = s.order_id)
where(s.shipping_date - o.order_date > 3)
order by s.shipping_date - o.order_date desc;

/*
10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).
*/

select payment_status,count(*) payment_status, 
count(*)::numeric / (SELECT COUNT(*) FROM payments)::numeric * 100 as percentage from orders o --important concept
join payments p on (o.order_id = p.order_id
group by payment_status;

/*
11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.
*/

select * from sellers;
select * from orders;
select * from order_items;

with top_5_sellers as
(select s.seller_id, s.seller_name, sum(oi.total_sales)
from sellers s
join orders o on (o.seller_id = s.seller_id)
join order_items oi on (o.order_id = oi.order_id)
group by 1, 2
order by sum(oi.total_sales) desc
limit 5),
seller_reports as
(
select o.seller_id, o.order_status, count(o.order_status) as total_orders
from sellers s
join orders o on (o.seller_id = s.seller_id)
join top_5_sellers ts on (ts.seller_id = o.seller_id)
where (o.order_status = 'Completed' or o.order_status = 'Cancelled')
group by 1,2
)

SELECT seller_id,
sum(case when order_status = 'Completed' then total_orders else 0 end) as completed_orders,
sum(case when order_status = 'Cancelled' then total_orders else 0 end) as cancelled_orders,
sum(total_orders) as sum_total,
sum(case when order_status = 'Completed' then total_orders else 0 end)::numeric/sum(total_orders) :: numeric * 100 as total_order_complete_percentage
FROM seller_reports
group by seller_id
order by 1;

/*
12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/

select * from products;
select * from order_items;

--profit = (total_sales - cogs*quatity) 


select p.product_id, p.product_name, sum(o.total_sales - p.cogs * o.quantity) as profit, 
sum(o.total_sales - p.cogs * o.quantity)/ sum(o.total_sales) * 100 as profit_margin, 
dense_rank() over(order by sum(o.total_sales - p.cogs * o.quantity)/ sum(o.total_sales) * 100 desc )
from products p 
join order_items o on (p.product_id = o.product_id)
group by 1,2;


/*
13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.
*/

-- p-o-oi
select p.product_id, product_name, count(*) as total_items_quantity, 
sum(case when o.order_status = 'Returned' then 1 else 0 end) as return_count, 
sum(case when o.order_status = 'Returned' then 1 else 0 end)::numeric / count(*):: numeric * 100 as return_percentage
from products p 
join order_items oi on (oi.product_id = p.product_id) 
join orders o on (o.order_id = oi.order_id)
group by 1, 2
order by 5 desc limit 10;

/* 
14. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.
*/






