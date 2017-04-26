# Final Week - Dillard's Database Exercises

Date created: 25 April 2017

This is the COMPLETE answer key (including explanations where necessary) 
for Week 5 (final week) of the ["Managing Big Data wtih MySQL"](https://www.coursera.org/learn/analytics-mysql/home/week/5) 
course by Duke University.

I wrote this answer key as no official answers have been released online. 
These answers reflect my own work and are accurate to the best of my knowledge. 
I will update them if the professors ever release an "official" answer key. 

**These answers will come in handy during the final exam for the course, which 
requires one to make similar queries.**

Update: These answers are based on the older version of ``UA_Dillards`` dataset 
(not ``UA_Dillards1``, nor ``UA_Dillards_2016``). For example, this means I am using 
the table ``SKSTINFO`` and not ``SKSTINFO_FIX`` which is the newer version.

Meanwhile, let's start.

# Answers

To start, enter ``DATABASE ua_dillards``; into the Teradata SQL scratchpad.

### Question 1 

**How many distinct dates are there in the saledate column of the transaction
table for each month/year combination in the database?**

```sql
SELECT 
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num, 
  COUNT (DISTINCT EXTRACT (day FROM saledate)) AS days_in_month, 
  COUNT (EXTRACT (day FROM saledate)) AS num_transactions -- I'm curious abt num transactions per mth
FROM trnsact
GROUP BY month_num, year_num
ORDER BY year_num, month_num
```

Result

| MONTH_NUM | YEAR_NUM | DAYS_IN_MONTH | NUM_TRANSACTIONS |
| -- | -- | -- | -- |
| 8 | 2004 | 31 | 8292953
| 9 | 2004 | 30 | 8967415
| 10 | 2004 | 31 | 8412131
| 11 | 2004 | 29 | 7047319
| 12 | 2004 | 30 | 13383892
| 1 | 2005 | 31 | 8952311
| 2 | 2005 | 28 | 11352221
| 3 | 2005 | 30 | 8940444
| 4 | 2005 | 30 | 9082523
| 5 | 2005 | 31 | 7715779
| 6 | 2005 | 30 | 7922997
| 7 | 2005 | 31 | 11122770
| 8 | 2005 | 27 | 9724141

There appears to be an incomplete record of the month during August 2005 
(as it has only 27 days). 

*As the homework instructs, I will restrict all further analysis of August sales 
to only include those recorded in 2004, and not 2005.*

Next, it appears that Dillard's department has designated holidays from their 
calendar. None of the stores have data for ``25 November`` (Thanksgiving),
``25 December`` (Christmas), or ``27 March`` (their annual sale date). 

### Question 2

**Use a CASE statement within an aggregate function to determine which sku
had the greatest total sales during the combined summer months of June, July, 
and August.**

```sql
SELECT DISTINCT sku,
SUM (CASE WHEN EXTRACT(month FROM saledate)=6 AND stype='p' THEN amt END) AS rev_june,
SUM (CASE WHEN EXTRACT(month FROM saledate)=7 AND stype='p' THEN amt END) AS rev_july,
SUM (CASE WHEN EXTRACT(month FROM saledate)=8 AND stype='p' THEN amt END) AS rev_aug, -- !
(rev_aug + rev_june + rev_july) AS rev_total_summer
FROM trnsact
GROUP BY sku
ORDER BY rev_total_summer DESC
HAVING rev_total_summer > 0 -- exclude null values
```

There is a problem with this question statement. It suggests that:

> *'If your query is correct, you should find that sku #2783996 has the fifth greatest total sales
during the combined months of June, July, and August, with a total summer sales sum of
$897,807.01.'*

However, you will only get this value if you include values from **both** August 2004
and August 2005, which **Question 1 explicitly states not to do so**.

A more sensible answer, that includes *only one copy of each month per year*, would be: 

```sql
SELECT DISTINCT sku,
SUM (CASE WHEN EXTRACT(month FROM saledate)=6 AND stype='p' THEN amt END) AS rev_june,
SUM (CASE WHEN EXTRACT(month FROM saledate)=7 AND stype='p' THEN amt END) AS rev_july,
SUM (CASE WHEN EXTRACT(month FROM saledate)=8 AND stype='p' 
AND EXTRACT(year FROM saledate)=12 -- new line
THEN amt END) AS rev_aug,
(rev_aug + rev_june + rev_july) AS rev_total_summer
FROM trnsact
GROUP BY sku
ORDER BY rev_total_summer DESC
HAVING rev_total_summer > 0 -- exclude null values
```

This gives the answer:

| SKU ITEM CODE | REV_JUNE 2005 | REV_JULY 2005 | REV_AUG 2004 | REV_TOTAL_SUMMER
| -- | -- | -- | -- | -- | 
| 4108011 | 309511.88 | 379326.00 | 499821.00 | 1, 188, 658.88
| 3524026 | 269934.50 | 344833.00 | 458227.50 | 1, 072, 995.00
| 5528349 | 339349.00 | 325156.50 | 337221.00 | 1, 001, 726.50
| 3978011 | 197885.37 | 259279.60 | 308910.00 | 766, 074.97
| **2783996** | 190252.01 | 197414.50 | 313736.50 | **701, 403.01**

Additional background information on the most popular summer items: *(because I'm
curious lol)*

```sql
SELECT *
FROM SKUINFO
WHERE sku IN (4108011, 3524026, 5528349, 3978011, 2783996)
```

| SKU CODE | COLOUR | SIZE | PACKSIZE | BRAND | 
| -- | -- | -- | -- | -- | 
| 4108011 | DDML | DDML 4OZ | 6 | CLINIQUE
| 3524026 | DDML | PUMP 4.2 OZ |  6 | CLINIQUE
| 5528349 | 01-BLACK | 01-BLACK | 3 | LANCOME
| 3978011 | CLARIFY #2 | 13.5 OZ | 3 | CLINIQUE
| 2783996 |  01-BLACK | NO SIZE | 3 | LANCOME

### Exercise 3. 

**How many distinct dates are there in the saledate column of the transaction
table for each month/year/store combination in the database? Sort your results by the
number of days per combination in ascending order.**

```sql
SELECT 
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num,
  store,
  COUNT (DISTINCT saledate) AS num_dates
FROM trnsact
GROUP BY month_num, year_num, store
ORDER BY num_dates asc
```
Some stores appear to have missing or removed data (i.e., less than 30 days per month).

 | MONTH | YEAR | STORE ID | NUM_DATES | 
 | ----- | ---- | -------- | --------- | 
 | 7 | 2005 | 7604 | 1
 | 3 | 2005 | 8304 | 1
 | 9 | 2004 | 4402 | 1
 | 8 | 2004 | 9906 | 1
 | 8 | 2004 | 8304 | 1
 | 8 | 2004 | 7203 | 3
 | 3 | 2005 | 6402 | 11

We will note the missing data in case of in future calculations. Where possible, we 
will aim to exclude months that do not meet criteria when doing trend analysis.

### Exercise 4. 

**What is the average daily revenue for each store/month/year combination in
the database? Calculate this by dividing the total revenue for a group by the number of
sales days available in the transaction table for that group.**

*For all of the exercises that follow, unless otherwise specified, we will assess sales by summing
the total revenue for a given time period, and dividing by the total number of days that
contributed to that time period. This will give us “average daily revenue”.*
