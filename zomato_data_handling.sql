drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1, '2008-11-11'),
(3,'2017-10-09');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-02-20'),
(2,'2015-05-15'),
(3,'2014-11-21');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-09-20',2),
(3,'2012-08-19',1),
(2,'2020-02-07',3),
(1,'2019-03-19',2),
(1,'2018-09-18',3),
(3,'2016-02-06',2),
(1,'2016-09-21',1),
(1,'2016-02-16',3),
(2,'2017-04-09',1),
(1,'2017-11-03',2),
(1,'2016-11-03',1),
(3,'2016-10-11',1),
(3,'2017-07-12',2),
(3,'2016-12-16',2),
(2,'2017-11-27',2),
(2,'2020-10-01',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- -- -----------------------------------------------------------------------------------
-- -- 1. what is the total amount each customer spend on zomato?

select sales.userid , sum(product.price) from sales
inner join product on product.product_id = sales.product_id
group by sales.userid;



-- -- -----------------------------------------------------------------------------------
-- -- 2. how many days each customer visited zomato?

select userid, count(distinct created_date) as days_visited from sales group by userid;


-- -- -----------------------------------------------------------------------------------
-- -- 3. what was the first product purchased by each customer?
select *from (select  *,rank() over (partition by userid order by created_date) as rnk from sales) a where rnk = 1;


-- -- -----------------------------------------------------------------------------------
-- -- 4. which is the most purchased item on menu and how many times it was purchased by all the customers?
select userid,count(product_id) from sales where product_id = (select count(product_id) as count  from sales group by product_id order by count desc limit 1)
group by userid ;

-- -- -----------------------------------------------------------------------------------
-- -- 5. which item was most popular for each customer?
select *from 
(select *,rank() over (partition by userid order by cnt desc) as rnk from
(select userid , product_id, count(product_id) as cnt    from sales group by userid,product_id) a) b
where rnk = 1 ; 


-- -- -----------------------------------------------------------------------------------
-- -- 7. which item was purchased first by a customer after they became a member?
select *from
(select c.*, rank() over (partition by userid order by created_date ) rnk from
(select sales.userid , sales.created_date , sales.product_id , goldusers_signup.gold_signup_date from sales
inner join goldusers_signup on sales.userid = goldusers_signup.userid and created_date>=gold_signup_date) as c) d where rnk = 1;


-- -- -----------------------------------------------------------------------------------
-- 8. which item was purchased first by a customer just before they became a member?

select *from
(select c.*, rank() over (partition by userid order by created_date desc ) rnk from
(select sales.userid , sales.created_date , sales.product_id , goldusers_signup.gold_signup_date from sales
inner join goldusers_signup on sales.userid = goldusers_signup.userid and created_date<gold_signup_date) as c) d where rnk = 1;


-- -- -----------------------------------------------------------------------------------
-- 9. what is the total order and amount spend by each customer before they bocame a member?
select userid, count(created_date), sum(price) from
(select a.*, product.price from
(select sales.userid , sales.created_date , sales.product_id , goldusers_signup.gold_signup_date from sales
inner join goldusers_signup on sales.userid = goldusers_signup.userid and created_date<gold_signup_date) a
inner join product on product.product_id = a.product_id) b
group by userid;

-- -- -----------------------------------------------------------------------------------
-- 10. rank all the transactions of the customers

select *, rank() over (partition by userid order by created_date ) as rnk from sales;
