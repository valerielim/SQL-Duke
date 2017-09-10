# Final Week - Dillard's Database Exercises

Date created: 25 April 2017

Last updated: 9 Sept 2017

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

### Exercise 4a. 

**What is the average daily revenue for each store/month/year combination in
the database? Calculate this by dividing the total revenue for a group by the number of
sales days available in the transaction table for that group.**

We can solve this by modifying the solution from Qn 3 to include revenue data. 

```sql
SELECT 
  store, 
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num,
  COUNT (DISTINCT saledate) AS num_dates,
  SUM(amt) AS total_revenue,
  revenue/num_dates AS daily_revenue 
FROM trnsact
WHERE stype='p'
GROUP BY store, month_num, year_num
ORDER BY daily_revenue desc
```
> Dr Jana: If your query is correct, you should find that store #204 has an average daily revenue of
$16,303.65 in August of 2005.

```sql
-- Modified to check results
SELECT 
  store, 
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num,
  COUNT (DISTINCT saledate) AS num_dates,
  SUM(amt) AS total_revenue,
  total_revenue/num_dates AS daily_revenue 
FROM trnsact
WHERE stype='p' AND store=204 -- !
GROUP BY store, month_num, year_num
ORDER BY year_num desc, month_num desc -- ! 
```

Results 

 | STORE | MONTH_NUM | YEAR_NUM | NUM_DATES | TOTAL_REVENUE | DAILY_REVENUE | 
 | ----- | --------- | -------- | --------- | ------------- | ------------- |
 | 204 | 12 | 2004 | 30 | 651309.29 | 21710.31 |
 | 204 | 7 | 2005 | 31 | 520512.72 | 16790.73 |
 | 204 | 4 | 2005 | 30 | 503312.54 | 16777.08 |
 | 204 | 8 | 2005 | 27 | 440198.68 | 16303.65 |
 
Awesome! 

*For all of the exercises that follow, unless otherwise specified, we will assess sales by summing
the total revenue for a given time period, and dividing by the total number of days that
contributed to that time period. This will give us “average daily revenue”.*

### Question 4b. 

**Modify the query you wrote above to assess the average daily revenue for each store/month/year 
combination with a clause that removes all the data from August, 2005. Then, given the data we 
have available in our data set, I propose that we only examine store/month/year combinations that 
have at least 20 days of data within that month.**

```sql
SELECT 
  sub.store, 
  sub.year_num, 
  sub.month_num, 
  sub.num_dates, 
  sub.daily_revenue
FROM (
  SELECT 
  store, 
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num,
  COUNT (DISTINCT saledate) AS num_dates,
  SUM(amt) AS total_revenue,
  total_revenue/num_dates AS daily_revenue,
  (CASE 
  WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
  END) As can_use_anot
  FROM trnsact
  WHERE stype='p' AND can_use_anot='can'
  GROUP BY store, month_num, year_num
  ) AS sub
HAVING sub.num_dates >=20
GROUP BY sub.store, sub.year_num, sub.month_num, sub.num_dates, sub.daily_revenue
ORDER BY sub.num_dates ASC; 
```

> DR JANA: Save your final queries that remove “bad data” for use in subsequent exercises. From
now on (and in the graded quiz), when I ask for average daily revenue: (1) Only examine purchases 
(not returns). (2) Exclude all stores with less than 20 days of data. (3) Exclude all data from 
August, 2005. 

### Question 5. 

**What is the average daily revenue brought in by Dillard’s stores in areas of high, medium, or 
low levels of high school education? Define areas of “low” education as those that have high 
school graduation rates between 50-60%, areas of “medium” education as those that have high 
school graduation rates between 60.01-70%, and areas of “high” education as those that have 
high school graduation rates of above 70%.**

I'll start by counting the number of stores within each education level first.

```sql
SELECT
(CASE
WHEN msa_high>=50 AND msa_high<70 THEN 'low'
WHEN msa_high>=70 AND msa_high<80 THEN 'med'
WHEN msa_high>=80 THEN 'high'
END) AS education_levels,
COUNT (DISTINCT store) AS num_stores
FROM store_msa
GROUP BY education_levels
```

Unfortunately it's not a nice distribution: 

| EDUCATION_LEVEL | NUM_STORES |
| --------------- | ---------- | 
| LOW (>50%) | 324
| MED (>60%) | 5
| HIGH (>70%) | 4

It would be better if we could redistribute it like this: 

| EDUCATION_LEVEL | NUM_STORES |
| --------------- | ---------- | 
| LOW (>50%) | 213
| MED (>70%) | 111
| HIGH (>80%) | 9

But that's not what the question asked, so I'll leave it aside for now. 
Back to the question, let's merge them: 

```sql
SELECT 
	(CASE
	WHEN s.msa_high >= 50 and s.msa_high < 60 THEN 'low'
	WHEN s.msa_high >= 60 and s.msa_high < 70 THEN 'medium'
	WHEN s.msa_high >= 70 THEN 'high'
	END) AS education_levels,
	SUM(sub.total_revenue)/SUM(sub.num_dates) AS avg_daily_revenue
FROM store_msa s 
	JOIN (
		SELECT 
		store, 
		EXTRACT (year FROM saledate) AS year_num,
		EXTRACT (month FROM saledate) AS month_num, 
		SUM(amt) AS total_revenue, 
		COUNT (DISTINCT (saledate)) AS num_dates,
		(CASE 
		WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
		END) As can_use_anot
		FROM trnsact
		WHERE stype='p' AND can_use_anot='can'
		GROUP BY year_num, month_num, store
		HAVING num_dates >= 20 -- moving this back to within the subquery
		) AS sub
			ON s.store = sub.store
GROUP BY education_levels;

```

I'm not sure why line 21 ``HAVING num_dates >= 20`` only works when inside the 
subquery but not when requested from the outer query. It worked fine in the previous question. 
*I guess something about aggregate functions??*

> DR JANA: If you have executed this query correctly, you will find that the average daily revenue brought in
by Dillard’s stores in the low education group is a little more than $34,000, the average daily
revenue brought in by Dillard’s stores in the medium education group is a little more than
$25,000, and the average daily revenue brought in by Dillard’s stores in the high education group
is just under $21,000.

| EDUCATION_LEVEL | AVG_DAILY_REVENUE |
| --------------- | ----------------- |
| low | 34,159.76
| medium | 27,112.67
| high | 20,921.32

Hooray! Moving forward... 

*Whenever I ask you to calculate the average daily revenue for a group of stores in either 
these exercises or the quiz, do so by summing together all the revenue from all the entries 
in that group, and then dividing that summed total by the total number of sale days that 
contributed to the total. Do not compute averages of averages.* 

### Question 6. 

**Compare the average daily revenues of the stores with the highest median
msa_income and the lowest median msa_income. In what city and state were these stores,
and which store had a higher average daily revenue? Use ``msa_income`` to calculate.** 

```sql
SELECT 
s.city, 
s.state,
s.msa_income,
SUM(sub.total_revenue)/SUM(sub.num_dates) AS avg_daily_revenue
FROM store_msa s 
	JOIN (
		SELECT 
		store,
		EXTRACT (year FROM saledate) AS year_num,
		EXTRACT (month FROM saledate) AS month_num,  
		SUM(amt) AS total_revenue, 
		COUNT(DISTINCT saledate) AS num_dates, 
		(CASE 
			WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
			END) As can_use_anot
		FROM trnsact 
		WHERE stype='p' AND can_use_anot='can'
		GROUP BY year_num, month_num, store
		HAVING num_dates >= 20
		) AS sub 
			ON s.store = sub.store
WHERE s.msa_income IN (
	(SELECT MAX(msa_income) FROM store_msa),
	(SELECT MIN(msa_income) FROM store_msa))
GROUP BY s.city, s.state;
```

Overall pretty similar to Qn 5. 

| CITY | STATE | AVG_DAILY_REVENUE | 
| ---- | ----- | ----------------- |
| SPANISH FORT | AL |  17884.08
| MCALLEN | TX | 56601.99

### Exercise 7: 

**What is the brand of the sku with the greatest standard deviation in sprice?
Only examine skus that have been part of over 100 transactions.**

```sql
SELECT 
DISTINCT (t.SKU) AS item,
s.brand AS brand,
STDDEV_SAMP(t.sprice) AS dev_price,
COUNT(DISTINCT(t.SEQ||t.STORE||t.REGISTER||t.TRANNUM||t.SALEDATE)) AS distinct_transactions
FROM TRNSACT t
	JOIN SKUINFO s
		ON t.sku=s.sku
WHERE t.stype='p'
HAVING distinct_transactions>100
GROUP BY item, brand
ORDER BY dev_price DESC
```

I'm not sure which of these columns are unique so I put them all in together: ``SEQ``, ``STORE``, 
``REGISTER``, ``TRANNUM``, ``SALEDATE``.

| ITEM | BRAND | STYLE | COLOR | SIZE | DEV_PRICE | 
| ---- | ----- | ----- | ----- | ---- | --------- | 
| 2762683 | HART SCH | 403154133510 | BLACK | 42REG | 175.8106 | 
| 5453849 | POLO FAS | 9HA 726680 | FA02 | L | 169.4284 |
| 5623849 | POLO FAS | 9HA 726680 | FA02 | M | 164.4187 |

### Exercise 8: 

**Examine all the transactions for the sku with the greatest standard deviation in
sprice, but only consider skus that are part of more than 100 transactions. Do you think the 
retail price was set too high, or just right? **

```sql
SELECT 
distinct(s.sku) AS items, 
s.brand,
AVG(t.sprice) AS avg_price,
STDDEV_SAMP(t.sprice) AS variation_price, 
avg(t.orgprice)-avg(t.sprice) AS sale_price_diff,
COUNT(distinct(t.trannum)) AS distinct_transactions
FROM skuinfo s 
JOIN trnsact t
ON s.sku=t.sku
WHERE stype='p'
GROUP BY items, s.brand
HAVING distinct_transactions > 100
ORDER BY variation_price DESC;
```

Not perfect, but consider how items with the highest ``variation (std dev) prices`` 
are not quite those with the greatest ``sales price differences``. This may suggest that some 
stores are simply pricing items higher/lower across the band, rather than offering massively 
discounted sale prices (vs original prices) to clear their stock. This might simply reflect their 
``msa_income`` differences around each store.

So... Was the retail price just right? Can't say for sure, but it's definitely not too high.

### Exercise 9

**What was the average daily revenue Dillard’s brought in during each month of
the year?**

```sql
SELECT 
(CASE
WHEN sub.month_num=1 THEN 'Jan'
WHEN sub.month_num=2 THEN 'Feb'
WHEN sub.month_num=3 THEN 'Mar'
WHEN sub.month_num=4 THEN 'Apr'
WHEN sub.month_num=5 THEN 'May'
WHEN sub.month_num=6 THEN 'Jun'
WHEN sub.month_num=7 THEN 'Jul'
WHEN sub.month_num=8 THEN 'Aug'
WHEN sub.month_num=9 THEN 'Sep'
WHEN sub.month_num=10 THEN 'Oct'
WHEN sub.month_num=11 THEN 'Nov'
WHEN sub.month_num=12 THEN 'Dec'
END) as month_name,
SUM(num_dates) AS num_days_in_month,
SUM(total_revenue)/SUM(num_dates) AS avg_monthly_revenue
FROM (
	SELECT 
	EXTRACT (month FROM saledate) AS month_num, 
	EXTRACT (year FROM saledate) AS year_num,
	COUNT (DISTINCT saledate) AS num_dates,
	SUM(amt) AS total_revenue,
	(CASE 
	WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
	END) As can_use_anot
	FROM trnsact
	WHERE stype='p' AND can_use_anot='can'
	GROUP BY month_num, year_num
	HAVING num_dates>=20
	) AS sub
GROUP BY month_name
ORDER BY avg_monthly_revenue DESC; 
```

| MONTH_NUM | DAYS_IN_MONTH | AVG_MONTHLY_REVENUE |
| --------- | ------------- | ------------------- |
| Dec | 30 | 11333356.01
| Feb | 28 | 7363752.69
| Jul | 31 | 7271088.69
| Apr | 30 | 6949616.95
| Mar | 30 | 6736315.39
| May | 31 | 6666962.59
| Jun | 30 | 6524845.42
| Nov | 29 | 6296913.50
| Oct | 31 | 6106357.90
| Jan | 31 | 5836833.31
| Aug | 31 | 5616841.37
| Sep | 30 | 5596588.02

> DR JANA: you should find that December consistently has the best sales, September consistently
has the worst or close to the worst sales, and July has very good sales, although less than December.

### Question 10

**Which department, in which city and state of what store, had the greatest percentage increase in 
average daily sales revenue from November to December? Note: Use percentage change.**

Hints from the notes:

1. Need to join 4 tables
1. Use two CASE statements within an aggregate function to sum all revenue Nov and Dec
1 .Use two CASE statements within an aggregate function to count the number of sale
days that contributed to the revenue in November and December, separately
1. Use these 4 fields to calculate the ``average daily revenue`` for November and December. You can then calculate the
change in these values using the following % change formula: *(X-Y)/Y)*100. 
1. Don’t forget to exclude “bad data” and to exclude ``return`` transactions. 

First I'd try to find just the percentage increase in revenue from November to December, for each ``store``. I will 
join the extra details like ``dept`` and stuff later.

```sql
SELECT 
sub.store,
SUM(CASE WHEN sub.month_num=11 THEN sub.amt END) AS Nov_revenue,
SUM(CASE WHEN sub.month_num=12 THEN sub.amt END) AS Dec_revenue,
COUNT(DISTINCT CASE WHEN sub.month_num=11 THEN sub.saledate END) AS Nov_days,
COUNT(DISTINCT CASE WHEN sub.month_num=12 THEN sub.saledate END) AS Dec_days,
Nov_revenue/Nov_days AS Nov_daily_rev, 
Dec_revenue/Dec_days AS Dec_daily_rev,
((Dec_daily_rev-Nov_daily_rev)/Nov_daily_rev)*100 AS percent_increase
FROM (
  SELECT 
  store,
  amt,
  saledate,
  EXTRACT (month FROM saledate) AS month_num, 
  EXTRACT (year FROM saledate) AS year_num,
  (CASE WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' END) As can_use_anot
  FROM trnsact
  WHERE stype='p' AND can_use_anot='can'
  ) AS sub
GROUP BY sub.store
HAVING Nov_days>=20 AND Dec_days>=20
ORDER BY percent_increase DESC;
```

| STORE | NOV_REV | DEC_REV | NOV_DAYS | DEC_DAYS | NOV_DAILY_REV | DEC_DAILY_REV | PERCENT_INC |
| ----- | ------- | ------- | -------- | -------- | ------------- | ------------- | ----------- |
| 3809 | 210139.08 | 486314.01 | 29 | 30 | 7246.18 | 16210.47 | 124.00
| 303 | 175003.74 | 399975.83 | 29 | 30 | 6034.61 | 13332.53 | 121.00
| 7003 | 169776.27 | 380024.73 | 29 | 30 | 5854.35 | 12667.49 | 116.00

Seems okay. Let's add the others in. 

```sql
SELECT -- outer query to drop all necessary columns from inner query
clean.store,
clean.dept,
clean.deptdesc,
clean.city,
clean.state,
clean.percent_increase
FROM (
	SELECT 
	sub.store,
	d.dept, 
	d.deptdesc,
	str.city,
	str.state,
	SUM(CASE WHEN sub.month_num=11 THEN sub.amt END) AS Nov_revenue,
	SUM(CASE WHEN sub.month_num=12 THEN sub.amt END) AS Dec_revenue,
	COUNT(DISTINCT CASE WHEN sub.month_num=11 THEN sub.saledate END) AS Nov_days,
	COUNT(DISTINCT CASE WHEN sub.month_num=12 THEN sub.saledate END) AS Dec_days,    
	Nov_revenue/Nov_days AS Nov_daily_rev, 
	Dec_revenue/Dec_days AS Dec_daily_rev,
	((Dec_daily_rev-Nov_daily_rev)/Nov_daily_rev)*100 AS percent_increase
	FROM (
		SELECT 
 		sku.dept, -- NEW: include this here bc you need to group-by departments at most granular lvl
    t.store,
		t.amt,
		t.saledate,
		EXTRACT (month FROM t.saledate) AS month_num, 
		EXTRACT (year FROM t.saledate) AS year_num,
		(CASE WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' END) As can_use_anot
		FROM trnsact t
			INNER JOIN skuinfo sku 
				ON t.sku=sku.sku 
		WHERE stype='p' AND can_use_anot='can' -- only query purchases, from legal dates
		) AS sub 
		INNER JOIN strinfo str
			ON str.store = sub.store -- to select city and state
		INNER JOIN deptinfo d 
			ON d.dept = sub.dept -- to select department description
	GROUP BY sub.store, d.dept, d.deptdesc, str.city, str.state
	HAVING Nov_days>=20 AND Dec_days>=20 
	) AS clean
GROUP BY 1,2,3,4,5,6
ORDER BY clean.percent_increase DESC

```
| STORE | DEPT | DEPT_DESC | CITY | STATE | PERCENTAGE_INCREASE | 
| ---- | ----- | -------- | ------ | ----- | -------------- | 
| 3403 | 7205 | LOUIS VL | SALINA | KS | 596.00
| 9806 | 6402 | FREDERI | MABELVALE | AR | 476.00
| 404 | 2107 | MAI | PINE BLUFF | AR | 442.00

### Question 11

**What is the city and state of the store that had the greatest decrease in
average daily revenue from August to September?**

This is easy, just adapt the query from Qn 10 and remove unnecessary tables.

```sql
SELECT 
sub.store, 
str.city, -- left join store_info table for these two
str.state,
SUM(CASE WHEN sub.month_num=8 THEN sub.amt END) AS Aug_revenue, 
SUM(CASE WHEN sub.month_num=9 THEN sub.amt END) AS Sep_revenue,
COUNT(DISTINCT CASE WHEN sub.month_num=8 THEN sub.saledate END) AS Aug_days,
COUNT(DISTINCT CASE WHEN sub.month_num=9 THEN sub.saledate END) AS Sep_days,    
Aug_revenue/Aug_days AS Aug_daily_rev, 
Sep_revenue/Sep_days AS Sep_daily_rev,
(Sep_daily_rev-Aug_daily_rev) AS rev_difference
	FROM ( -- clean inner query for legal dates and purchases only
		SELECT 
		store,
		amt,
		saledate,
		EXTRACT (month FROM saledate) AS month_num, 
		EXTRACT (year FROM saledate) AS year_num,
		(CASE WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' END) As can_use_anot
		FROM trnsact 
		WHERE stype='p' AND can_use_anot='can'
		) AS sub
	INNER JOIN strinfo str -- to extract store's city, state
		ON str.store = sub.store
GROUP BY sub.store, str.city, str.state
HAVING Aug_days>=20 AND Sep_days>=20 -- only keep stores with more than 20 dates per month
ORDER BY rev_difference ASC
```
| STORE | CITY | STATE | REV_DIFFERENCE |
| ----- | ---- | ---- | ------------- |
| 4003 | WEST DES MOINES | IA | -6479.60
| 9103 | LOUISVILLE | KY | -5233.12
| 2707 | MCALLEN | TX | -5109.47

### Question 12

**Determine the month of maximum total revenue for each store. Count the
number of stores whose month of maximum total revenue was in each of the twelve
months.**

**Then determine the month of maximum average daily revenue. Count the
number of stores whose month of maximum average daily revenue was in each of the
twelve months. How do they compare?**

I'm guessing the assignment wants us to see which month has the most number of stores 
hitting their maximum total revenue in, and also their highest average daily revenue in. 

If the numbers don't match, it might suggest hidden trends, outliers or missing data within the set. 

Things to do:
1. Calculate the average daily revenue for each store, for each month (for each year, but
there will only be one year associated with each month)
1. Order the rows within a store according to average daily revenue from high to low
1. Assign a rank to each of the ordered rows
1. Retrieve all of the rows that have the rank you want
1. Count all of your retrieved rows 

> DR JANA: You can assign ranks using the ``ROW_NUMBER`` or ``RANK()`` function. 
 Make sure you “partition” by store in your ``ROW_NUMBER`` clause. Lastly when you have 
 confirmed that the output is reasonable, introduce a ``QUALIFY`` clause 
 (described in the references above) into your query in order to restrict the output to 
 rows that represent the month with the minimum average daily revenue for each store.

Starting with task (1) and (2), I'll calculate the average daily revenue for each ``store``, by ``month``.
We can do this by recycling the query from Qn 9. 

```sql
SELECT 
(CASE
WHEN sub.month_num=1 THEN 'Jan'
WHEN sub.month_num=2 THEN 'Feb'
WHEN sub.month_num=3 THEN 'Mar'
WHEN sub.month_num=4 THEN 'Apr'
WHEN sub.month_num=5 THEN 'May'
WHEN sub.month_num=6 THEN 'Jun'
WHEN sub.month_num=7 THEN 'Jul'
WHEN sub.month_num=8 THEN 'Aug'
WHEN sub.month_num=9 THEN 'Sep'
WHEN sub.month_num=10 THEN 'Oct'
WHEN sub.month_num=11 THEN 'Nov'
WHEN sub.month_num=12 THEN 'Dec'
END) as month_name,
sub.store,
SUM(sub.total_revenue)/SUM(sub.num_dates) AS avg_daily_revenue
FROM (
	SELECT 
	store,
	EXTRACT (month FROM saledate) AS month_num, 
	EXTRACT (year FROM saledate) AS year_num,
	COUNT (DISTINCT saledate) AS num_dates,
	SUM(amt) AS total_revenue,
	(CASE 
	WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
	END) As can_use_anot
	FROM trnsact
	WHERE stype='p' AND can_use_anot='can'
	GROUP BY month_num, year_num
	HAVING num_dates>=20
	) AS sub
GROUP BY month_name, sub.store
ORDER BY avg_daily_revenue DESC; 
```

(3) Let's add the bit for ``RANK()`` and ``PARTITION``: (a snippet)

```sql
SELECT 
(CASE
WHEN sub.month_num=1 THEN 'Jan'
	...
WHEN sub.month_num=12 THEN 'Dec'
END) as month_name,
sub.store,
SUM(sub.total_revenue) AS sum_monthly_revenue, -- TOTAL monthly rev
SUM(sub.total_revenue)/SUM(sub.num_dates) AS avg_daily_revenue, -- AVERAGE rev within month
ROW_NUMBER() OVER (PARTITION BY sub.store ORDER BY avg_daily_revenue DESC ) AS Row_sum_rev, --! 
ROW_NUMBER() OVER (PARTITION BY sub.store ORDER BY sum_monthly_revenue DESC ) AS Row_avg_rev --!
FROM (
	...
	) AS sub
GROUP BY month_name, sub.store
ORDER BY avg_daily_revenue DESC; 
```

(4)+(5) Finally, let's retrieve all rows with top ranking month, to see which month performed best. 

```sql
SELECT 
clean.month_name AS month_n, 
COUNT(CASE WHEN clean.Row_sum_rev =1 THEN clean.store END) AS Total_monthly_rev_count, -- count number of rank 1s per month
COUNT(CASE WHEN clean.Row_avg_rev =1 THEN clean.store END) AS Average_daily_rev_count -- count number of rank 1s per month
FROM (
	SELECT 
	(CASE
	WHEN sub.month_num=1 THEN 'Jan'
	WHEN sub.month_num=2 THEN 'Feb'
	WHEN sub.month_num=3 THEN 'Mar'
	WHEN sub.month_num=4 THEN 'Apr'
	WHEN sub.month_num=5 THEN 'May'
	WHEN sub.month_num=6 THEN 'Jun'
	WHEN sub.month_num=7 THEN 'Jul'
	WHEN sub.month_num=8 THEN 'Aug'
	WHEN sub.month_num=9 THEN 'Sep'
	WHEN sub.month_num=10 THEN 'Oct'
	WHEN sub.month_num=11 THEN 'Nov'
	WHEN sub.month_num=12 THEN 'Dec'
	END) as month_name,
	sub.store,
	SUM(sub.total_revenue) AS sum_monthly_revenue,
	SUM(sub.total_revenue)/SUM(sub.num_dates) AS avg_daily_revenue,
	ROW_NUMBER() OVER (PARTITION BY sub.store ORDER BY avg_daily_revenue DESC ) AS Row_sum_rev,
	ROW_NUMBER() OVER (PARTITION BY sub.store ORDER BY sum_monthly_revenue DESC ) AS Row_avg_rev
	FROM (
		SELECT 
		store,
		EXTRACT (month FROM saledate) AS month_num, 
		EXTRACT (year FROM saledate) AS year_num,
		COUNT (DISTINCT saledate) AS num_dates,
		SUM(amt) AS total_revenue,
		(CASE 
		WHEN (year_num=2005 AND month_num=8) THEN 'cannot' ELSE 'can' 
		END) As can_use_anot
		FROM trnsact
		WHERE stype='p' AND can_use_anot='can'
		GROUP BY month_num, year_num, store
		HAVING num_dates>=20
		) AS sub
	GROUP BY month_name, sub.store
	) AS clean
GROUP BY Month_n
ORDER BY Total_monthly_rev_count DESC
```

> DR JANA: If you write your queries correctly, you will find that 8 stores have the greatest 
total sales in April, while only 4 stores have the greatest average daily revenue in April.

| MONTH | TOTAL_MONTHLY | AVG_DAILY |
| ----- | ------------- | --------- | 
| Dec | 317 | 321
| Mar | 4 | 3
| Jul | 3 | 3

While the output fits with our expectations of the data (ie. that ``Dec`` should be the most popular month), 
but it doesn't match Dr Jana's hint. 

AFter reading the forum, I realised that official assignment seems to give the wrong hint (quite a significant mistake!). 
We will get the expected result if we write our queries to find the ``LOWEST`` total sales as ranked by month instead 
of the ``HIGHEST`` total sales, like so:

```sql
SELECT 
clean.month_name AS month_n, 
COUNT(CASE WHEN clean.Row_sum_rev =1 THEN clean.store END) AS Total_monthly_rev_count, -- change 1 to 12
COUNT(CASE WHEN clean.Row_avg_rev =1 THEN clean.store END) AS Average_daily_rev_count -- change 1 to 12
FROM (
... 
```

| MONTH | LOW_TOTAL_MONTH | LOW_AVG_DAILY |
| ----- | --------------- | ------------- |
| Aug | 120 | 77
| Jan | 73 | 54
| Sep | 72 | 108
| ... | ... | ...
| Apr | 4 | 8
| ... | ... | ...
| Dec | 0 | 0

# End

*Thoughts on this course:*
*Notes were messy and with quite a few significant mistakes, like that last one we saw. But overall it was a*
*good introduction to SQL and I appreciate the resources to let us try and play it out.* 

Key takeaways:

* Computational thinking: Learning how to split large, complex problems into smaller sets that can be reassembled later 
* Rigorous testing and checking of trend inconsistencies using month, year-aggregations, or standard deviations
* Dealing with outliers and missing data by setting predefined criterias in subqueries
* Overall syntax nuances between dialects for MySQL, Teradata
* Perseverance for long queries lol
