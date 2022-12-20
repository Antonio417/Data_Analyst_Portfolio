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

### 2. How many unique customer orders were made ?

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

### 3. How many successful orders were delivered by each runner ?
Orders can be cancelled and can be found as shown below
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

### 4. How many of each type of pizza was delivered ?

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

### 5. How many Vegetarian and Meatlovers were ordered by each customer ?
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

### 6. What was the maximum number of pizzas delivered in a single order ?

````sql
SELECT MAX(items) AS max_number_of_orders
FROM 
(
SELECT c.order_id, COUNT(c.order_id) AS items
FROM pizza_runner.customer_orders c
JOIN pizza_runner.runner_orders r
ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  c.order_id
    ) AS temp_table
  ````

| max_items_in_order |
| ------------------ |
| 3                  |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes ? 
````sql
SELECT
  customer_id,
  changes,
  COUNT(changes) AS number_of_changes
FROM
  (
    WITH ranked AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      customer_id,
      c.order_id,
      CASE
        WHEN exclusions ~ '^[0-9, ]+$'
        OR extras ~ '^[0-9, ]+$' THEN 'Have changes'
        ELSE 'No changes'
      END AS changes,
      rank
    FROM
      ranked AS c
      JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    WHERE
      pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      exclusions,
      extras,
      customer_id,
      c.order_id,
      rank
  ) AS changes
GROUP BY
  changes,
  customer_id
ORDER BY
  customer_id
  ````
| customer_id | changes      | number_of_pizzas |
| ----------- | ------------ | ---------------- |
| 101         | No changes   | 2                |
| 102         | No changes   | 3                |
| 103         | Have changes | 3                |
| 104         | Have changes | 2                |
| 104         | No changes   | 1                |
| 105         | Have changes | 1                |

### 8. How many pizzas were delivered that had both exclusions and extras ?
````sql
SELECT
  CASE
    WHEN exclusions ~ '^[0-9, ]+$'
    AND extras ~ '^[0-9, ]+$' THEN 'Have exclusions and extras'
  END AS exclusions_and_extras,
  COUNT(exclusions) AS number_of_pizzas
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  exclusions,
  extras
HAVING
  extras ~ '^[0-9, ]+$'
  AND exclusions ~ '^[0-9, ]+$'
  ````
| exclusions_and_extras      | number_of_pizzas |
| -------------------------- | ---------------- |
| Have exclusions and extras | 1                |

### 9. What was the total volume of pizzas ordered for each hour of the day?
Excluding cancelled orders:

````sql
SELECT hours, SUM(pizzas_ordered) AS pizzas_ordered
FROM
	(
      SELECT EXTRACT(hour FROM order_time) AS hours,
      COUNT(EXTRACT(hour FROM order_time)) AS pizzas_ordered
      FROM pizza_runner.customer_orders AS c
      JOIN pizza_runner.runner_orders AS r 
      ON c.order_id = r.order_id
      WHERE pickup_time != 'null'
            AND distance != 'null'
            AND duration != 'null'
      GROUP BY order_time
	) AS count_hours
GROUP BY hours
ORDER BY hours    
  ````
  
| hours | pizzas_ordered |
| ----- | -------------- |
| 13    | 3              |
| 18    | 3              |
| 19    | 1              |
| 21    | 2              |
| 23    | 3              |

### 10. What was the volume of orders for each day of the week ?
Excluding cancelled orders:
````sql
SELECT
  day_of_the_week,
  SUM(pizzas_ordered) AS pizzas_ordered
FROM
	(
	SELECT
		CASE WHEN EXTRACT(isodow FROM order_time) = 1 THEN 'Monday'
		WHEN EXTRACT(isodow FROM order_time) = 2 THEN 'Tuesday'
		WHEN EXTRACT(isodow FROM order_time) = 3 THEN 'Wednesday'
		WHEN EXTRACT(isodow FROM order_time) = 4 THEN 'Thursday'
		WHEN EXTRACT(isodow FROM order_time) = 5 THEN 'Friday'
		WHEN EXTRACT(isodow FROM order_time) = 6 THEN 'Saturday'
		WHEN EXTRACT(isodow FROM order_time) = 7 THEN 'Sunday'
		END AS day_of_the_week,
		COUNT(EXTRACT(isodow FROM order_time)) AS pizzas_ordered
    	FROM
		pizza_runner.customer_orders AS c
		JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    	WHERE
      		pickup_time != 'null'
      		AND distance != 'null'
      		AND duration != 'null'
    	GROUP BY order_time
	) AS count_dow
GROUP BY
  day_of_the_week
ORDER BY
  pizzas_ordered DESC
````
| day_of_the_week | pizzas_ordered |
| ----------- | -------------- |
| Saturday    | 5              |
| Wednesday  | 4              |
| Thursday    | 3              |
