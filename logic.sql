--1.
create or replace  function calculate_order_total(p_order_id int)
    returns  numeric(10,2) language sql
    stable as $$ select coalesce(sum(quantity*price), 0)
                 from order_items where order_id=p_order_id;
$$;
--2.
create or replace  procedure create_order(p_customer_id int)
    language  plpgsql
as $$
begin if not exists
    (
        select 1 from customers where customer_id=p_customer_id
    ) then raise exception 'Customer with this id % does not exist.', p_customer_id;
end if;
insert into orders (customer_id, order_date, total_amount)
values (p_customer_id, current_timestamp, 0);
end;
$$;
--3.
create or replace  procedure add_product_to_order(p_order_id int,
                                                  p_product_id int, p_quantity int)
    language  plpgsql
as $$
declare
    v_price numeric(10,2);
    v_stock int;
begin if p_quantity<=0 then raise exception  'Quantity has to be greater than zero!';
end if;
select price, stock_quantity into v_price, v_stock from products where product_id=p_product_id
    for update;
if not  FOUND then
    raise exception 'Product with this id % does not exist.', p_product_id;
end if;
if v_stock<p_quantity then raise  exception
    'There is not enough stock for product %. Avaliable: %  and requested: % .',
    p_product_id, v_stock, p_quantity; end if;
insert into order_items (order_id, product_id, quantity, price)
values (p_order_id, p_product_id,p_quantity,v_price);
update products set stock_quantity=stock_quantity-p_quantity
where product_id=p_product_id;
end;
$$;
--4.
create or replace  function trg_recalculate_order_total()
    returns trigger
    language  plpgsql
as $$
declare
    v_order_id int;
begin
    if tg_op='DELETE' then v_order_id:=OLD.order_id;
    else v_order_id:=NEW.order_id;
    end if;
    update orders set total_amount=calculate_order_total(v_order_id)
    where order_id=v_order_id;
    return  null;
end;
$$;
drop trigger if exists trg_order_items_total on order_items;
create trigger  trg_order_items_total after insert or update  or delete on order_items
    for each row execute function trg_recalculate_order_total();
--5.
create or replace  function trg_log_new_order()
    returns trigger
    language  plpgsql
as $$
begin
    insert into order_log(order_id, customer_id, action, log_date)
    values (NEW.order_id, NEW.customer_id, 'ORDER_CREATED', current_timestamp);
    return  null;
end;
$$;
drop trigger if exists trg_orders_audit on orders;
create trigger trg_orders_audit
    after insert on orders
    for each row
execute function trg_log_new_order();
