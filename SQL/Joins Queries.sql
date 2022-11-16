/* Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for the Midwest region. Your final table should include three columns: the region name, 
the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to account name. */
SELECT r.name region, s.name sales_reps, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest'
ORDER BY a.name;

/* Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a first name starting with S and in the Midwest region.
 Your final table should include three columns: the region name, the sales rep name, and the account name.
  Sort the accounts alphabetically (A-Z) according to account name. */
SELECT r.name region, s.name sales_reps, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE s.name LIKE 'S%' AND r.name = 'Midwest'
ORDER BY a.name;

/* Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a last name starting with K and in the Midwest region.
 Your final table should include three columns: the region name, the sales rep name, and the account name. 
 Sort the accounts alphabetically (A-Z) according to account name. */
SELECT r.name region, s.name sales_reps, a.name accounts
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE s.name LIKE '% K%' AND r.name = 'Midwest'
ORDER BY a.name;

/* Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
However, you should only provide the results if the standard order quantity exceeds 100. 
Your final table should have 3 columns: region name, account name, and unit price */
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) Unit_Price
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
WHERE o.standard_qty > 100;

/* Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
However, you should only provide the results if the standard order quantity exceeds 100. 
Your final table should have 3 columns: region name, account name, and unit price. 
Sort for the smallest unit price first */
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) Unit_Price
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY Unit_Price;

/* Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
However, you should only provide the results if the standard order quantity exceeds 100. 
Your final table should have 3 columns: region name, account name, and unit price. 
Sort for the largest unit price first */
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) Unit_Price
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY Unit_Price DESC;

/* What are the different channels used by account id 1001?
Your final table should have only 2 columns: account name and the different channels. 
You can try SELECT DISTINCT to narrow down the results to only the unique values. */
SELECT DISTINCT a.name account, w.channel channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';
ORDER BY a.name;

/* Find all the orders that occurred in 2015. 
Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd */
SELECT o.occurred_at, a.name account, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at;
