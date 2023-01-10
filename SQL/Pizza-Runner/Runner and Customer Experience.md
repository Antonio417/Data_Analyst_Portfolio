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

