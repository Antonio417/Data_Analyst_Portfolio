### 1. How many pizzas were ordered?

````sql
SELECT COUNT(pizza_id) AS number_of_pizza_ordered
FROM pizza_runner.customer_orders;
````

**Answer:**

| number_of_pizza_ordered |
| ----------------------- |
| 14                      |

- Total of 14 pizzas were ordered.

#### 2. How many unique customer orders were made?

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

#### 3. How many successful orders were delivered by each runner?
Orders can be cancelled. Cancelled orders can be found as shown below
SELECT
  *
FROM
  pizza_runner.runner_orders
WHERE
  length(cancellation) > 0
