use dw;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE SHIPPERS
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_shipper(id_sh, company, last_update)
	select s.id, s.company, now() 
    from northwind.shippers s;

insert into dim_shipper (id, id_sh, company, last_update) VALUES (-1, -1, 'Unknown', '1975-01-01 00:00:00');
    

select * from dw.dim_shipper;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE SUPPLIER
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_supplier(id_su, company, last_update)
	select s.id, s.company, now() 
    from northwind.suppliers s;

insert into dim_supplier (id, id_su, company, last_update) VALUES (-1, -1, 'Unknown', '1975-01-01 00:00:00');

select * from dw.dim_supplier;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE EMPLOYEE
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_employee(id_e, name, company, last_update)
	select e.id, concat(e.first_name, " ", e.last_name), e.company, now()
    from northwind.employees e;

insert into dim_employee (id, id_e, name, company, last_update) VALUES (-1, -1, 'Unknown', 'Unknown' ,'1975-01-01 00:00:00');
    
select * from dw.dim_employee;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE PRODUCT
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_product(id_p, standard_cost, category_name, last_update)
	select p.id, p.standard_cost, p.category, now()
    from northwind.products p;
    
select * from dw.dim_product;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE LOCAL
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_local(city, state, country, last_update)
	select distinct c.city, c.state_province, c.country_region, now()
    from northwind.customers c;
    
select * from dw.dim_local;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE DIMENSAO DE TIME
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

insert into dw.dim_time(date,day,month,year, week, quarter, weekday, last_update)
	select distinct o.order_date, day(o.order_date), month(o.order_date), year(o.order_date), week(o.order_date), quarter(o.order_date), weekday(o.order_date), now() 
	from northwind.orders o;

select * from dw.dim_time;


-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- POVOAMENTO DA TABELA DE FACTOS DE VENDAS
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    
    
delimiter $$
create function total_price( order_id int )
returns decimal(19,4)
deterministic
begin
    declare total decimal(19,4);

	set total = (select sum(od.unit_price) from northwind.order_details od where od.order_id = order_id);
	
    return total;
end $$
delimiter ;

delimiter $$
create function get_supplier( order_details_id int )
returns int
deterministic
begin
    declare res int;
    declare interm int;
    declare res2 int;

	set interm = (select od.purchase_order_id from northwind.order_details od where od.id = order_details_id);
	set res = coalesce(interm,-1);
    
    if res = -1 then
		return res;
	else
		set res2 = (select po.supplier_id from northwind.purchase_orders po where po.id = res);
	end if;
    return res2;
end $$
delimiter ;

delimiter $$
create function get_shipper( orders_id int )
returns int
deterministic
begin
    declare res int;
    declare interm int;

	set interm = (select shipper_id from northwind.orders where id = orders_id);
	set res = coalesce(interm,-1);
    
    return res;
end $$
delimiter ;

delimiter $$
create function get_employee( orders_id int )
returns int
deterministic
begin
    declare res int;
    declare interm int;

    set interm = (select employee_id from northwind.orders where id = orders_id);
    set res = coalesce(interm,-1);
    
    return res;
end $$
delimiter ;

delimiter $$
create function get_preparation_time( orders_id int )
returns int
deterministic
begin
    declare res int;
    declare interm int;

	set interm = datediff((select shipped_date from northwind.orders where id = orders_id), (select order_date from northwind.orders where id = orders_id));
	set res = coalesce(interm,-1);
    
    return res;
end $$
delimiter ;


insert into dw.fact_vendas
	(order_id,
    total_price,
    quantity,
    order_date,
    preparation_time,
    client_local,
    supplier,
    shipper,
    employee,
    product,
    last_update
    )
    select
    od.order_id,
    total_price(od.order_id),
	od.quantity,
	t.id,
    get_preparation_time(ord.id),
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
	e.id_e = get_employee(ord.id) and
    od.product_id = p.id_p;
    
select * from dw.fact_vendas;

