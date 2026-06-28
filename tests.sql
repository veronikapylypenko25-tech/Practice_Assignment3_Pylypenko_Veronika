truncate table order_log, order_items, orders, products, customers
restart identity cascade ;
insert into customers(full_name, email, balance) values
                                                     ('Veronika Pylypenko', 'nika.pylyp@gmail.com', 400.00),
                                                     ('Sonya Shevchenko', 'sonya.schevch@gmail.com', 250.00),                                              ('Lina Smith', 'lina.smith@gmail.com', 300.00);
select * from customers;
insert into products(product_name, price, stock_quantity) values
                                                              ('Keyboard', 70.00, 40),
                                                              ('Monitor', 300.00, 50),
                                                              ('Mouse', 30.00, 100),
                                                              ('Laptop', 3000.00, 10);
select *from products;
call create_order(1);
call create_order(2);
call create_order(3);
select * from  orders;
call add_product_to_order(1, 1, 1);
call add_product_to_order(1, 2, 2);
call add_product_to_order(2, 3, 1);
call add_product_to_order(2, 4, 3);
select order_id,total_amount from orders;
select product_id,product_name, stock_quantity from products;
select * from order_log;

explain analyze
select c.full_name,
       o.order_id,
       p.product_name,
       oi.quantity,
       oi.price,
       oi.quantity * oi.price as item_total
from customers c
join orders o on c.customer_id = o.customer_id
join public.order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where c.customer_id=1;

