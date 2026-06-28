Bonus Task 3 — Query Analysis
 
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



Execution plan: 
Nested Loop  (cost=27.38..63.94 rows=7 width=492) (actual time=0.345..0.352 rows=2 loops=1)
  ->  Nested Loop  (cost=27.23..62.50 rows=7 width=246) (actual time=0.317..0.321 rows=2 loops=1)
        ->  Index Scan using customers_pkey on customers c  (cost=0.14..8.16 rows=1 width=222) (actual time=0.038..0.038 rows=1 loops=1)
              Index Cond: (customer_id = 1)
        ->  Hash Join  (cost=27.09..54.27 rows=7 width=32) (actual time=0.098..0.101 rows=2 loops=1)
              Hash Cond: (oi.order_id = o.order_id)
              ->  Seq Scan on order_items oi  (cost=0.00..23.60 rows=1360 width=28) (actual time=0.018..0.019 rows=4 loops=1)
              ->  Hash  (cost=27.00..27.00 rows=7 width=8) (actual time=0.046..0.046 rows=1 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    ->  Seq Scan on orders o  (cost=0.00..27.00 rows=7 width=8) (actual time=0.039..0.040 rows=1 loops=1)
                          Filter: (customer_id = 1)
                          Rows Removed by Filter: 2
  ->  Index Scan using products_pkey on products p  (cost=0.15..0.20 rows=1 width=222) (actual time=0.010..0.010 rows=1 loops=2)
        Index Cond: (product_id = oi.product_id)
Planning Time: 4.859 ms
Execution Time: 0.768 ms

Short explanation of how PostgreSQL executes the query: 
Запит виконується за допомого Nested Loop, який поєднує всі чотири таблиці. Через Index Scan відбувається пошук клієнтапо індексу customer_pkey, це є ефективним для пошуку за конкретним значенням customer_id=1.  Для з'єднання order_items та orders PostgreSQL застосовувалось Hash Join з філтрацією по customer_id. Через Index Scan отримується назва продукту, а саме по індексу products_pkey. Мій запит виконався за  0.768 ms. 