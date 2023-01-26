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

### 4. Generate an order item for each record in the `customers_orders` table in the format of one of the following:

- Meat Lovers

- Meat Lovers - Exclude Beef

- Meat Lovers - Extra Bacon

- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

First we add rank to each row to prevent grouping of duplicate rows in the order #4 and follow the original row order. We do that in a CTE using the `row_number` window function.

Next we join this CTE with the `pizza_toppings` table to get the ingredient names and the `pizza_names` table to get pizzas' names.

Then we convert comma separated values in `extras` and `exclusion` columns into rows using `string_to_array` and `unnest` functions.

Now we are ready for the final output. We need to convert extras and exclusions to strings - we will use `strting_agg` function to do that.
We also need to add words "- Exclude" or "- Extra" if a pizza has exclusion or extras - we can do that using `CASE` statement and `count` function.
And eventually we can concatenate these parts into one string using the `concat` function. 

````sql
SELECT
  order_id,
  CONCAT(
    pizza_name,
    ' ',
    CASE
      WHEN COUNT(exclusions) > 0 THEN '- Exclude '
      ELSE ''
    END,
    STRING_AGG(exclusions, ', '),
    CASE
      WHEN COUNT(extras) > 0 THEN ' - Extra '
      ELSE ''
    END,
    STRING_AGG(extras, ', ')
  ) AS pizza_name_exclusions_and_extras
FROM
  (
    WITH rank_added AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      rank,
      ra.order_id,
      pizza_name,
      CASE
        WHEN exclusions != 'null'
        AND topping_id IN (
          SELECT
            UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int [])
        ) THEN topping_name
      END AS exclusions,
      CASE
        WHEN extras != 'null'
        AND topping_id IN (
          SELECT
            unnest(string_to_array(extras, ',') :: int [])
        ) THEN topping_name
      END AS extras
    FROM
      pizza_runner.pizza_toppings AS t,
      rank_added as ra
      JOIN pizza_runner.pizza_names AS n ON ra.pizza_id = n.pizza_id
    GROUP BY
      rank,
      ra.order_id,
      pizza_name,
      exclusions,
      extras,
      topping_id,
      topping_name
  ) AS toppings_as_names
GROUP BY
  pizza_name,
  rank,
  order_id
ORDER BY
  rank
````

| order_id | pizza_name_exclusions_and_extras                                |
| -------- | --------------------------------------------------------------- |
| 1        | Meatlovers                                                      |
| 2        | Meatlovers                                                      |
| 3        | Meatlovers                                                      |
| 3        | Vegetarian                                                      |
| 4        | Meatlovers - Exclude Cheese                                     |
| 4        | Meatlovers - Exclude Cheese                                     |
| 4        | Vegetarian - Exclude Cheese                                     |
| 5        | Meatlovers  - Extra Bacon                                       |
| 6        | Vegetarian                                                      |
| 7        | Vegetarian  - Extra Bacon                                       |
| 8        | Meatlovers                                                      |
| 9        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | Meatlovers                                                      |
| 10       | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the `customer_orders` table and add a 2x in front of any relevant ingredients

For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

This query utilizes similar functions as the previous query. 

The query logic is: first we select all ingredients for each pizza type, exclude exclusions, add extras and count how many ingredients each pizza includes, then we select the ingredients that are greater than 0 and calculate the sum of them to add 2x when relevant, and then aggregate the results into one string.
To sort all the ingredients alphabetically we add the `ORDER BY` parameter to the `string_agg` function.

````sql
SELECT
  order_id,
  CONCAT(
    pizza_name,
    ': ',
    STRING_AGG(
      topping_name,
      ', '
      ORDER BY
        topping_name
    )
  ) AS all_ingredients
FROM
  (
    SELECT
      rank,
      order_id,
      pizza_name,
      CONCAT(
        CASE
          WHEN (SUM(count_toppings) + SUM(count_extra)) > 1 THEN (SUM(count_toppings) + SUM(count_extra)) || 'x'
        END,
        topping_name
      ) AS topping_name
    FROM
      (
        WITH rank_added AS (
          SELECT
            *,
            ROW_NUMBER() OVER () AS rank
          FROM
            pizza_runner.customer_orders
        )
        SELECT
          rank,
          ra.order_id,
          pizza_name,
          topping_name,
          CASE
            WHEN exclusions != 'null'
            AND t.topping_id IN (
              SELECT
                unnest(string_to_array(exclusions, ',') :: int [])
            ) THEN 0
            ELSE CASE
              WHEN t.topping_id IN (
                SELECT
                  UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
              ) THEN COUNT(topping_name)
              ELSE 0
            END
          END AS count_toppings,
          CASE
            WHEN extras != 'null'
            AND t.topping_id IN (
              SELECT
                unnest(string_to_array(extras, ',') :: int [])
            ) THEN count(topping_name)
            ELSE 0
          END AS count_extra
        FROM
          rank_added AS ra,
          pizza_runner.pizza_toppings AS t,
          pizza_runner.pizza_recipes AS r
          JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
        WHERE
          ra.pizza_id = n.pizza_id
        GROUP BY
          pizza_name,
          rank,
          ra.order_id,
          topping_name,
          toppings,
          exclusions,
          extras,
          t.topping_id
      ) tt
    WHERE
      count_toppings > 0
      OR count_extra > 0
    GROUP BY
      pizza_name,
      rank,
      order_id,
      topping_name
  ) cc
GROUP BY
  pizza_name,
  rank,
  order_id
ORDER BY
  rank
````

| order_id | all_ingredients                                                                     |
| -------- | ----------------------------------------------------------------------------------- |
| 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes       |
| 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9        | Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami       |
| 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10       | Meatlovers: 2xBacon, 2xCheese, Beef, Chicken, Pepperoni, Salami                     |
