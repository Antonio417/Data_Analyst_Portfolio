/* Which account (by name) placed the earliest order ? */
SELECT accounts.name AS accounts_name, orders.occurred_at AS time_of_order
FROM orders 
JOIN accounts
ON accounts.id = orders.account_id
ORDER BY occurred_at DESC
LIMIT 1;


/* Find the total sales in usd for each account. */
 SELECT a.name AS company_name,
SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;


/* Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event ? */
SELECT a.name AS name,
w.occurred_at AS date,
w.channel AS channel
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;


/*Find the total number of times each type of channel from the web_events was used.*/
SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel;

 
/* Who was the primary contact associated with the earliest web_event ? */
SELECT a.primary_poc primary_contact,
w.occurred_at date
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;


/* What was the smallest order placed by each account in terms of total usd. */
 SELECT a.name, MIN(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY MIN(o.total_amt_usd);

 
/* Find the number of sales reps in each region. */
SELECT r.name region, COUNT(s.name) number_of_sales_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY number_of_sales_reps

/* For each account, determine the average amount of each type of paper they purchased across their orders. */
SELECT a.name, 
AVG(o.standard_qty) avg_standard,
AVG(o.gloss_qty) avg_gloss,
AVG(o.poster_qty) avg_poster
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

/* For each account, determine the average amount spent per order on each paper type. */
SELECT a.name, AVG(o.standard_amt_usd) avg_standard,
AVG(o.gloss_amt_usd) avg_gloss,
AVG(o.poster_amt_usd) avg_poster
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

/* Determine the number of times a particular channel was used in the web_events table for each sales rep. */
SELECT s.name, w.channel, COUNT(*) num_events
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;

/* Determine the number of times a particular channel was used in the web_events table for each region. */
SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC

/* How many of the sales reps have more than 5 accounts that they manage ? */
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

/* How many accounts have more than 20 orders ? */
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
HAVING COUNT(*) > 20
ORDER BY num_orders;

/* Which account has the most orders ? */
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
ORDER BY num_orders DESC
LIMIT 1;

/* Which accounts spent more than 30,000 usd total across all orders ? */
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

/* Which accounts spent less than 1,000 usd total across all orders ? */
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

/* Which account has spent the most with us ? */
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
ORDER BY total_spent DESC
LIMIT 1;

/* Which account has spent the least with us ? */
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name 
ORDER BY total_spent 
LIMIT 1;

/* Which accounts used facebook as a channel to contact customers more than 6 times ? */
SELECT a.id, a.name, w.channel, COUNT(*) num_channels_used
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING w.channel = 'facebook' AND COUNT(*) > 6
ORDER BY num_channels_used;

/* Which account used facebook most as a channel ? */
SELECT a.id, a.name, w.channel, COUNT(*) num_channels_used
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING w.channel = 'facebook' 
ORDER BY num_channels_used DESC
LIMIT 1;

/* Which channel was most frequently used by most accounts ? */
SELECT a.id, a.name, w.channel, COUNT(*) num_channels_used
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY num_channels_used DESC
LIMIT 10;

/* Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. */
SELECT DATE_PART('year', occurred_at) ord_year,  SUM(total_amt_usd) total_spent
FROM orders
GROUP BY ord_year
ORDER BY total_spent;

/* Which month did Parch & Posey have the greatest sales in terms of total dollars? 
Are all months evenly represented by the dataset? */
SELECT DATE_PART('month', occurred_at) ord_month,
SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY ord_month
ORDER BY total_spent DESC
LIMIT 1;

/* Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
Are all years evenly represented by the dataset? */
SELECT DATE_PART('year', occurred_at) ord_year,
COUNT(*) total_qty
FROM orders
GROUP BY ord_year
ORDER BY total_qty DESC;

/* Which month did Parch & Posey have the greatest sales in terms of total number of orders?
 Are all months evenly represented by the dataset? */
SELECT DATE_PART('month', occurred_at) ord_month,
COUNT(*) total_qty
FROM orders
GROUP BY ord_month
ORDER BY total_qty DESC;

/* In which month of which year did Walmart spend the most on gloss paper in terms of dollars? */
SELECT DATE_TRUNC('month', o.occurred_at) ord_month,
SUM(o.gloss_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY ord_month
ORDER BY total_spent DESC
LIMIT 1;

/* Write a query to display for each order, the account ID, total amount of the order, 
and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or 
smaller than $3000. */
SELECT account_id, total_amt_usd,
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS order_level
FROM orders;

/* Write a query to display the number of orders in each of three categories, 
based on the total number of items in each order. 
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'. */
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
ELSE 'Less than 1000' END AS order_category,
COUNT(*) AS order_count
FROM orders
GROUP BY 1;

/* We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
Provide a table that includes the level associated with each account. */
SELECT a.name, SUM(o.total_amt_usd) as total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Middle'
ELSE 'Low' END AS lifetime_value
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sales DESC;

/* We would now like to perform a similar calculation to the first, 
but we want to obtain the total amount spent by customers only in 2016 and 2017. */
SELECT a.name, SUM(o.total_amt_usd) as total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top'
WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Middle'
ELSE 'Low' END AS lifetime_value
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE o.occurred_at > '2015-12-31' 
GROUP BY a.name
ORDER BY total_sales DESC;

/* We would like to identify top performing sales reps, 
which are sales reps associated with more than 200 orders. */
SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
     ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY num_ords DESC;

/* The previous didn't account for the middle, nor the dollar amount associated with the sales. 
Management decides they want to see these characteristics represented as well. Create a table with the sales rep name,
the total number of orders, total sales across all orders, and a column with top, middle, 
or low depending on this criteria.  */
SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent, 
CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY total_spent DESC;

