### 1. How many pizzas were ordered ?

````sql
SELECT COUNT(pizza_id) AS number_of_pizza_ordered
FROM pizza_runner.customer_orders;
````

**Answer:**

| number_of_pizza_ordered |
| ----------------------- |
| 14                      |

- Total of 14 pizzas were ordered.

#### 2. How many unique customer orders were made ?

````sql
SELECT
  customer_id,
  COUNT(DISTINCT order_id) AS unique_customer_orders
FROM
  pizza_runner.customer_orders
GROUP BY
  customer_id
  ````
  
| customer_id | unique_customer_orders |
| ----------- | ---------------------- |
| 101         | 3                      |
| 102         | 2                      |
| 103         | 2                      |
| 104         | 2                      |
| 105         | 1                      |

#### 3. How many successful orders were delivered by each runner ?
Orders can be cancelled. Cancelled orders can be found as shown below
````sql
SELECT
  *
FROM
  pizza_runner.runner_orders
WHERE
  length(cancellation) > 0
  ````


| order_id | runner_id | pickup_time         | distance | duration  | cancellation            |
| -------- | --------- | ------------------- | -------- | --------- | ----------------------- |
| 6        | 3         | null                | null     | null      | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins    | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute | null                    |
| 9        | 2         | null                | null     | null      | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes | null                    |

#### 4. How many of each type of pizza was delivered ?

Join the `pizza_names` table to get pizza names, and join the `runner_orders` table to exclude cancelled orders.

````sql
SELECT pizza_name, COUNT(pizza_name)
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY pizza_name
  ````

| pizza_name | number_of_pizzas_delivered |
| ---------- | -------------------------- |
| Meatlovers | 9                          |
| Vegetarian | 3                          |

#### 5. How many Vegetarian and Meatlovers were ordered by each customer ?
Calculate the number of ordered pizzas and exclude cancelled orders. Join two tables: pizza_names and runner_orders to exclude cancelled orders.
````sql
SELECT customer_id, pizza_name, COUNT(pizza_name) AS number_of_pizzas_delivered
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY customer_id, pizza_name
ORDER BY customer_id
  ````
  
| customer_id | pizza_name | number_of_pizzas_delivered |
| ----------- | ---------- | -------------------------- |
| 101         | Meatlovers | 2                          |
| 102         | Meatlovers | 2                          |
| 102         | Vegetarian | 1                          |
| 103         | Meatlovers | 2                          |
| 103         | Vegetarian | 1                          |
| 104         | Meatlovers | 3                          |
| 105         | Vegetarian | 1                          |


