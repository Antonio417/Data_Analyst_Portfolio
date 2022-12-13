--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Antonio Fernando Christophorus
--Date: 13/12/2022 
--Tool used: PostgreSQL v13

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

--2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT(order_date)) visit_count
FROM dannys_diner.sales s
GROUP BY s.customer_id;

--3. What was the first item from the menu purchased by each customer?
WITH ordered_sales AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM dannys_diner.sales AS s
   JOIN dannys_diner.menu AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.product_id) AS number_of_sales
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name 
ORDER BY number_of_sales DESC
LIMIT 1;

--5. Which item was the most popular for each customer?
WITH temp_table AS
(
   SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
   FROM dannys_diner.menu AS m
   JOIN dannys_diner.sales AS s
      ON m.product_id = s.product_id
   GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM temp_table
WHERE rank = 1;

--6. Which item was purchased first by the customer after they became a member?
WITH new_member AS
(
  SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
  	 DENSE_RANK() OVER(PARTITION BY s.customer_id 
                       ORDER BY s.order_date) AS rank
  	 FROM dannys_diner.sales s
  	 JOIN dannys_diner.members m
  	 	ON s.customer_id = m.customer_id
  	 WHERE s.order_date >= m.join_date
)
     
 SELECT new_member.customer_id, new_member.order_date, menu.product_name
 FROM new_member
 JOIN dannys_diner.menu AS menu
 ON new_member.product_id = menu.product_id
 WHERE rank = 1
 ORDER BY new_member.customer_id;

--7. Which item was purchased just before the customer became a member?
WITH new_member AS
(
  SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
  	 DENSE_RANK() OVER(PARTITION BY s.customer_id 
                       ORDER BY s.order_date DESC) AS rank
  	 FROM dannys_diner.sales s
  	 JOIN dannys_diner.members m
  	 	ON s.customer_id = m.customer_id
  	 WHERE s.order_date < m.join_date
)
     
 SELECT new_member.customer_id, new_member.order_date, menu.product_name
 FROM new_member
 JOIN dannys_diner.menu AS menu
 ON new_member.product_id = menu.product_id
 WHERE rank = 1
 ORDER BY new_member.customer_id;


--8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(DISTINCT s.product_id) item_count, SUM(m.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members as members
ON s.customer_id = members.customer_id
WHERE s.order_date < members.join_date
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
-- how many points would each customer have?
WITH points AS
(
   SELECT *, 
      CASE
         WHEN product_name = 'sushi' THEN price * 20
         ELSE price * 10
      END AS points
   FROM dannys_diner.menu
)

SELECT s.customer_id, SUM(p.points) AS total_points
FROM points p
JOIN dannys_diner.sales AS s
   ON p.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY customer_id;

--10. In the first week after a customer joins the program (including their join date)
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have 
-- at the end of January?

WITH count_points AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      SUM(point) AS point
    FROM
      dannys_diner.sales AS s
      JOIN (
        SELECT
          product_id,
          product_name,
          CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
          END AS point
        FROM
          dannys_diner.menu AS m
      ) AS p ON s.product_id = p.product_id
      JOIN dannys_diner.members AS mm ON s.customer_id = mm.customer_id
    GROUP BY
      s.customer_id,
      order_date,
      join_date,
      product_name,
      point
  )
SELECT
  customer_id,
  SUM(
    CASE
      WHEN order_date >= join_date
      AND order_date < join_date + (7 * INTERVAL '1 day')
      AND product_name != 'sushi' THEN point * 2
      ELSE point
    END
  ) AS new_points
FROM
  count_points
WHERE
  DATE_PART('month', order_date) = 1
GROUP BY
  1
ORDER BY
  1

