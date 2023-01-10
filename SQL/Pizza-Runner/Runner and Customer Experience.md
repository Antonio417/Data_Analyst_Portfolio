### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

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

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

The `pickup_time` column in the `runner_orders` table has `varchar` type, and we need transfrom it to timestamp first. After that we can count the difference between order creation time and order pickup time and the average time in minutes for each runner to arrive at the Pizza Runner HQ to pickup the order.

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
