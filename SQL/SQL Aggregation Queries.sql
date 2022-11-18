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