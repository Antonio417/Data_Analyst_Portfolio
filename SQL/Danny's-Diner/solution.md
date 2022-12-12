# 🍣 Case Study #1 - Danny's Diner
## Solution

***

### 1. What is the total amount each customer spent at the restaurant ?

````sql
SELECT s.customer_id, SUM(price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id
````

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant ?

````sql
SELECT s.customer_id, COUNT(DISTINCT(order_date)) visit_count
FROM dannys_diner.sales s
GROUP BY s.customer_id;
````

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT m.product_name, COUNT(s.product_id) AS number_of_sales
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name 
ORDER BY number_of_sales DESC
LIMIT 1
````

#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |

- Most purchased item on the menu is ramen which is 8 times.

### 5. Which item was the most popular for each customer?

````sql
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
````

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C loves ramen.
- Customer B loves all foods in the menu equally.
### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````
#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Customer A's first order as a member is curry.
- Customer B's first order as a member is sushi.

### 7. Which item was purchased just before the customer became a member?

````sql
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

````

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- Whereas for Customer B, it's sushi. That must have been a real good sushi!

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT s.customer_id, COUNT(DISTINCT s.product_id), SUM(m.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members as members
ON s.customer_id = members.customer_id
WHERE s.order_date < members.join_date
GROUP BY s.customer_id;
````

#### Answer:
| customer_id | unique_menu_item | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

- Customer A spent $25 on 2 items.
- Customer B spent $40 on 2 items.
