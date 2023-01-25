### 1. How many runners signed up for each 1 week period ? (i.e. week starts 2021-01-01)

There is some discrepancy between the data in the `runners table`, `customer_orders` and `runner_orders` tables.

Runners' registration dates are in January, 2021, orders were made and picked up by the runners in January, 2020.

To count the number of registrations, we need to extract the week and rank each week with the `rank` window function, so the first week of registration will have number 1.

````sql
SELECT
  number_of_week,
  number_of_registrations
FROM
  (
    SELECT
      'Week ' || RANK () OVER (
        ORDER BY
          date_trunc('week', registration_date)
      ) number_of_week,
      DATE_TRUNC('week', registration_date) AS week,
      COUNT(*) AS number_of_registrations
    FROM
      pizza_runner.runners
    GROUP BY
      week
  ) AS count_weeks
  ````

| number_of_week | number_of_registrations |
| -------------- | ----------------------- |
| Week 1         | 2                       |
| Week 2         | 1                       |
| Week 3         | 1                       |

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order ?

The `pickup_time` column in the `runner_orders` table has `varchar` type, and we need transform it to timestamp first. After that we can count the difference between order creation time and order pickup time and the average time in minutes for each runner to arrive at the Pizza Runner HQ to pickup the order.

````sql
SELECT
  runner_id,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') - c.order_time
      )
    )
  ) AS average_pickup_time_in_minutes
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  runner_id
ORDER BY
  runner_id
  ````
  
| runner_id | average_pickup_time_in_minutes |
| --------- | ------------------------------ |
| 1         | 15                             |
| 2         | 23                             |
| 3         | 10                             |

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

To answer this question, let's count for each order: number of ordered pizzas, time from placing order to pick up, and average time it took to prepare one pizza.

````sql
SELECT
  c.order_id,
  COUNT(c.order_id) AS items_in_order,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        pickup_time_new - c.order_time
      )
    )
  ) AS average_pickup_time_in_minutes,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        pickup_time_new - c.order_time
      )
    ) / COUNT(c.order_id)
  ) AS average_time_per_pizza_in_minutes
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c,
  LATERAL(
    SELECT
      TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') AS pickup_time_new
  ) pt
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  c.order_id
ORDER BY
  items_in_order DESC
  ````
  
| order_id | items_in_order | average_pickup_time_in_minutes | average_time_per_pizza_in_minutes |
| -------- | -------------- | ------------------------------ | --------------------------------- |
| 4        | 3              | 29                             | 10                                |
| 3        | 2              | 21                             | 10                                |
| 10       | 2              | 15                             | 8                                 |
| 7        | 1              | 10                             | 10                                |
| 8        | 1              | 20                             | 20                                |
| 5        | 1              | 10                             | 10                                |
| 2        | 1              | 10                             | 10                                |
| 1        | 1              | 10                             | 10                                |  
  
It takes 10 minutes in average to prepare one pizza (except order #8 - it took 20 minutes to prepare 1 pizza). The more pizzas in one order, the more time it takes to prepare the order.

### 4. What was the average distance travelled for each customer?

Assuming that each customer has the same address, we can suggest that there is a possible misspelling error in the distance cell for the customer with ID 102 (order #2 - 13.4km, order #8 - 23.4km). 
Data in the `distance` column has `varchar` type. To calculate the average distance we need to cast is as `numeric`. We can do it using `TO_NUMBER` function.

````sql
SELECT
  customer_id,
  ROUND(AVG(TO_NUMBER(distance, '99D9')), 1) AS average_distance_km
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  customer_id
ORDER BY
  customer_id
  ````
  
| customer_id | average_distance_km |
| ----------- | ------------------- |
| 101         | 20.0                |
| 102         | 16.7                |
| 103         | 23.4                |
| 104         | 10.0                |
| 105         | 25.0                |

### 5. What was the difference between the longest and shortest delivery times for all orders?

Checking the longest and the shortest delivery time first:

````sql
SELECT
  MIN(TO_NUMBER(duration, '99')) AS min_delivery_time_in_minutes,
  MAX(TO_NUMBER(duration, '99')) AS max_delivery_time_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
````

| min_delivery_time_in_minutes | max_delivery_time_in_minutes |
| ---------------------------- | ---------------------------- |
| 10                           | 40                           |

The shortest delivery time was 10 minutes, the longest delivery time was 40 minutes.

Now let's calculate the time difference:

````sql
SELECT
  MAX(TO_NUMBER(duration, '99')) - MIN(TO_NUMBER(duration, '99')) AS delivery_time_difference_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
  ````
  
| delivery_time_difference_in_minutes |
| ----------------------------------- |
| 30                                  |  

***The difference between the longest and the shortest delivery time is 30 minutes***

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

To calculate the average speed in km/h we need to divide distance to duration, and as the duration is in minutes, we need to divide the result to 60 to convert minutes to hours.
`distance` and `duration` columns have `varchar` data type, it needs to be converted to `numeric` to make calculations.

````sql
SELECT
  order_id,
  runner_id,
  ROUND(
    AVG(
      TO_NUMBER(distance, '99D9') /(TO_NUMBER(duration, '99') / 60)
    )
  ) AS runner_average_speed
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  order_id,
  runner_id
ORDER BY
  order_id
````

| order_id | runner_id | runner_average_speed |
| -------- | --------- | -------------------- |
| 1        | 1         | 38                   |
| 2        | 1         | 44                   |
| 3        | 1         | 40                   |
| 4        | 2         | 35                   |
| 5        | 3         | 40                   |
| 7        | 2         | 60                   |
| 8        | 2         | 94                   |
| 10       | 1         | 60                   |  

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT
  runner_id,
  ROUND(
    100 - (
      SUM(unsuccessful) / (SUM(unsuccessful) + SUM(successful))
    ) * 100
  ) AS successful_delivery_percent
FROM
  (
    SELECT
      runner_id,
      CASE
        WHEN pickup_time != 'null' THEN COUNT(*)
        ELSE 0
      END AS successful,
      CASE
        WHEN pickup_time = 'null' THEN COUNT(*)
        ELSE 0
      END AS unsuccessful
    FROM
      pizza_runner.runner_orders AS r
    GROUP BY
      runner_id,
      pickup_time
  ) AS count_rating
GROUP BY
  runner_id
ORDER BY
  runner_id
````

| runner_id | successful_delivery_percent |
| --------- | --------------------------- |
| 1         | 100                         |
| 2         | 75                          |
| 3         | 50                          |
