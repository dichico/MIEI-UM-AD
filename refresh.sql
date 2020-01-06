-- Refresh da tabela dim_supplier
insert into dw.dim_supplier
    (id_su,company)
select northwind.suppliers.id, northwind.suppliers.company
from northwind.suppliers
    left join dw.dim_supplier on northwind.suppliers.id = dw.dim_supplier.id_su and
        northwind.suppliers.company = dw.dim_supplier.company
where dw.dim_supplier.id is null;

-- Refresh da tabela dim_shipper
insert into dw.dim_shipper
    (id_sh,company)
select northwind.shippers.id, northwind.shippers.company
from northwind.shippers
    left join dw.dim_shipper on northwind.shippers.id = dw.dim_shipper.id_sh and
        northwind.shippers.company = dw.dim_shipper.company
where dw.dim_shipper.id is null;

-- Refresh da tabela dim_employee
insert into dw.dim_employee
    (id_e,company,name)
select northwind.employees.id, northwind.employees.company, concat(northwind.employees.first_name," ",northwind.employees.last_name)
from northwind.employees
    left join dw.dim_employee on northwind.employees.id = dw.dim_employee.id_e and
        northwind.employees.company = dw.dim_employee.company AND
        concat(northwind.employees.first_name," ",northwind.employees.last_name) = dw.dim_employee.name
where dw.dim_employee.id is null;

-- Refresh da tabela dim_product
insert into dw.dim_product
    (id_p,standard_cost,category_name)
select northwind.products.id, northwind.products.standard_cost, northwind.products.category
from northwind.products
    left join dw.dim_product on northwind.products.id = dw.dim_product.id_p and
        northwind.products.standard_cost = dw.dim_product.standard_cost AND
        northwind.products.category = dw.dim_product.category_name
where dw.dim_product.id is null;

-- Refresh da tabela dim_local
insert into dw.dim_local
    (city,state,country)
select distinct northwind.customers.city, northwind.customers.state_province, northwind.customers.country_region
from northwind.customers
    left join dw.dim_local on northwind.customers.city = dw.dim_local.city and
        northwind.customers.state_province = dw.dim_local.state AND
        northwind.customers.country_region = dw.dim_local.country
where dw.dim_local.id is null;

-- Refresh da tabela dim_time
insert into dw.dim_time
    (date,day,month,year,week,quarter,weekday)
select distinct northwind.orders.order_date, day(northwind.orders.order_date), month(northwind.orders.order_date), year(northwind.orders.order_date), week(northwind.orders.order_date), quarter(northwind.orders.order_date), weekday(northwind.orders.order_date)
from northwind.orders
    left join dw.dim_time on northwind.orders.order_date = dw.dim_time.date and
        day(northwind.orders.order_date) = dw.dim_time.day AND
        month(northwind.orders.order_date) = dw.dim_time.month AND
        year(northwind.orders.order_date) = dw.dim_time.year AND
        week(northwind.orders.order_date) = dw.dim_time.week AND
        quarter(northwind.orders.order_date) = dw.dim_time.quarter AND
        weekday(northwind.orders.order_date) = dw.dim_time.weekday
where dw.dim_time.id is null;

-- Refresh da tabela fact_vendas - not working

insert into dw.fact_vendas
    (order_id,total_price,quantity,order_date,preparation_time,client_local,supplier,shipper,employee,product)
select northwind.order_details.order_id, total_price(northwind.order_details.order_id), northwind.order_details.quantity, t.id, datediff(ord.shipped_date, ord.order_date),
    l.id,
    s.id,
    shi.id,
    e.id,
    p.id
from (select
        od.order_id,
        total_price(order_id),
        od.quantity,
        t.id,
        datediff(ord.shipped_date, ord.order_date),
        l.id,
        s.id,
        shi.id,
        e.id,
        p.id,
        now()
    from
        northwind.order_details od,
        northwind.orders ord,
        dw.dim_time t,
        dw.dim_local l,
        northwind.customers c,
        dw.dim_shipper shi,
        dw.dim_employee e,
        dw.dim_product p,
        dw.dim_supplier s
    where
    od.order_id = ord.id and
        ord.order_date = t.date and
        ord.customer_id = c.id and
        c.city = l.city and
        c.state_province = l.state and
        c.country_region = l.country and
        s.id_su = get_supplier(od.id) and
        shi.id_sh = get_shipper(ord.id) and
        ord.employee_id = e.id_e and
        od.product_id = p.id_p) AS nw_total
    left join dw.fact_vendas on nw_total.order_id = dw.fact_vendas.order_id and
        nw_total.total_price = dw.fact_vendas.total_price AND
        nw_total.quantity = dw.fact_vendas.quantity AND
        nw_total.order_date = dw.fact_vendas.order_date AND
        nw_total.preparation_time = dw.fact_vendas.preparation_time
where dw.fact_vendas.id is null;