### 1. What are the standard ingredients for each pizza ?

````sql
SELECT
  pizza_name,
  STRING_AGG(topping_name, ', ') AS toppings
FROM
  pizza_runner.pizza_toppings AS t,
  pizza_runner.pizza_recipes AS r
  JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
WHERE
  t.topping_id IN (
    SELECT
      UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
  )
GROUP BY
  1
ORDER BY
  1
````

| pizza_name | toppings                                                              |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

### 2. What was the most commonly added extra ?

````sql
SELECT
  extra_ingredient,
  number_of_pizzas
FROM
  (
    WITH extras_table AS (
      SELECT
        order_id,
        UNNEST(STRING_TO_ARRAY(extras, ',') :: int []) AS topping_id
      FROM
        pizza_runner.customer_orders AS c
      WHERE
        extras != 'null'
    )
    SELECT
      topping_name AS extra_ingredient,
      COUNT(topping_name) AS number_of_pizzas,
      RANK() OVER (
        ORDER BY
          COUNT(topping_name) DESC
      ) AS rank
    FROM
      extras_table AS et
      JOIN pizza_runner.pizza_toppings AS t ON et.topping_id = t.topping_id
    GROUP BY
      topping_name
  ) t
WHERE
  rank = 1
````

| extra_ingredient | number_of_pizzas |
| ---------------- | ---------------- |
| Bacon            | 4                |

### 3. What was the most common exclusion?

````sql
SELECT
  excluded_ingredient,
  number_of_pizzas
FROM
  (
    WITH exclusions_table AS (
      SELECT
        order_id,
        UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int []) AS topping_id
      FROM
        pizza_runner.customer_orders AS c
      WHERE
        exclusions != 'null'
    )
    SELECT
      topping_name AS excluded_ingredient,
      COUNT(topping_name) AS number_of_pizzas,
      RANK() OVER (
        ORDER BY
          COUNT(topping_name) DESC
      ) AS rank
    FROM
      exclusions_table AS et
      JOIN pizza_runner.pizza_toppings AS t ON et.topping_id = t.topping_id
    GROUP BY
      topping_name
  ) t
WHERE
  rank = 1
````

| excluded_ingredient | number_of_pizzas |
| ------------------- | ---------------- |
| Cheese              | 4                |
