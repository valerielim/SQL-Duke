# Week 3 - Dillard's Database Exercises

Date created: 17 March 2017

This is the COMPLETE answer key (including explanations where necessary) 
for Week 2 of "Managing Big Data wtih MySQL" course by Duke University: 
'Queries to Extract Data from Single Tables'.

I wrote this answer key as no official answers have been released online. 
These answers reflect my own work and are accurate to the best of my knowledge. 
I will update them if the professors ever release an "official" answer key.

Update: These answers are based on the original UA_Dillards dataset 
(not UA_Dillards1, nor UA_Dillards_2016). For example, this means I am using 
the table ``SKSTINFO`` and not ``SKSTINFO_FIX`` which is the newer version.

Meanwhile, let's start.

# Answers

To start, enter ``DATABASE ua_dillards``; into the Teradata SQL scratchpad.

### Question 1 

**(a) Use COUNT and DISTINCT to determine how many distinct skus there are in 
pairs of the skuinfo, skstinfo, and trnsact tables. Which skus are common to 
pairs of tables, or unique to specific tables?**

```sql
SELECT COUNT(DISTINCT a.sku)
FROM skuinfo a
	JOIN skstinfo b
		ON a.sku = b.sku;
    
SELECT COUNT(DISTINCT a.sku)
FROM skuinfo a
	JOIN trnsact b
		ON a.sku = b.sku;
    
SELECT COUNT(DISTINCT a.sku)
FROM skstinfo a
	JOIN trnsact b
		ON a.sku = b.sku;
```

Results

| Combi | Pair 1 | Pair 2 | Distinct SKU |
| ----- | ------ | ------ | ------------ |
| 1 | skuinfo | skstinfo | 760212 |
| 2 | skuinfo | trnsact  | 714499 |
| 3 | skstinfo | trnsact | 542513 |

To test which ``SKU``s are in which tables:

```sql
SELECT a.sku, b.sku
FROM skuinfo a
	LEFT JOIN skstinfo b
		ON a.sku = b.sku
WHERE b.sku IS NULL;

SELECT a.sku, b.sku
FROM skuinfo a
	LEFT JOIN trnsact b
		ON a.sku = b.sku
WHERE b.sku IS NULL;

```
* All items in ``SKSTINFO`` are listed in ``SKUINFO``, but not vice versa
* All items in ``TRNSACT`` are listed in ``SKSTINFO``, but not vice versa

**(b) Use COUNT to determine how many instances there are of each sku associated 
with each store in the skstinfo table and the trnsact table?**

```sql
SELECT sku, store, COUNT(sku)
FROM skstinfo
GROUP BY sku, store;
```
Seems like there's only 1x sku-store combo in the ``SKSTINFO`` table.
```sql
SELECT sku, store, COUNT(sku)
FROM trnsact
GROUP BY sku, store;
```
Seems like there's multiple instances of each sku-store combos in the ``TRNSACT`` table.

*Notes from lecture: You should see there are multiple instances of every 
sku/store combination in the ``trnsact`` table, but only one instance of every 
sku/store combination in the ``skstinfo`` table. Therefore you could join the 
``trnsact`` and ``skstinfo`` tables, but you would need to join them on both of the 
following conditions: ``trnsact.sku= skstinfo.sku`` AND ``trnsact.store= skstinfo.store``.* 

### Exercise 2

**(a) Use COUNT and DISTINCT to determine how many distinct stores there are in the
strinfo, store_msa, skstinfo, and trnsact tables.**

```sql
SELECT COUNT(DISTINCT store)
FROM strinfo;

SELECT COUNT(DISTINCT store)
FROM skstinfo;

SELECT COUNT(DISTINCT store)
FROM store_msa;

SELECT COUNT(DISTINCT store)
FROM trnsact;
```

|Table Name | Unique Stores |
| --------- | ------------- |
| STRINFO | 453
| SKSTINFO | 357
| STORE_MSA | 333
| TRNSACT | 332

**(b) Which stores are common to all four tables, or unique to specific tables?**

Since we know that ALL stores can be found in the ``STRINFO`` table, we can left join 
the three other tables to it. 

```sql
SELECT a.store, b.store, c.store, d.store
FROM strinfo a 
  LEFT JOIN skstinfo b 
    ON a.store = b.store
  LEFT JOIN trnsact c 
    ON a.store = c.store
  LEFT JOIN store_msa d
    ON c.store = d.store
```

### Exercise 3

It turns out there are many skus in the trnsact table that are not in the skstinfo 
table. As a consequence, we will not be able to complete many desirable analyses of 
Dillard’s profit, as opposed to revenue, because we do not have the cost information 
for all the skus in the transact table (recall that profit = revenue - cost).

**Examine some of the rows in the trnsact table that are not in the skstinfo table;
can you find any common features that could explain why the cost information is missing?**

```sql
SELECT * 
FROM trnsact a 
  LEFT JOIN skstinfo b
    ON a.sku=b.sku AND a.store = b.store
WHERE b.sku IS NULL 
```
This returns a table with all columns, of rows of items which are in ``TRNSACT`` but 
**not in** ``SKSTINFO``. Honestly, I can't see much difference just eyeballing it. 
There are 52,338,840 rows, or 43.3% of 120 billion rows that are missing. 

To check how many of them are *unique*:

```sql
SELECT distinct a.sku, a.store
FROM trnsact a 
  LEFT JOIN skstinfo b
    ON a.sku=b.sku AND a.store = b.store
WHERE b.sku IS NULL 
GROUP BY a.sku, a.store;
```

That leaves exactly 17,816,793 sku-store combinations found in the transactions table
that are not listed in the master ``skstinfo`` table. I still can't tell what's 
unique about the missing values, so let's see what's the next question and 
come back to this later. 

### Exercise 4

**Although we can’t complete all the analyses we’d like to on Dillard’s profit, 
we can look at general trends. What is Dillard’s average profit per day?**

Assumptions: 

1. With **over 40% of the necessary data missing** (see Qn 3), whatever data we 
have left is accurate and worth calculating -.-"
2. For each transaction recorded (row), only 1 type of item is purchased at a time. 
In other words, that:

> Total amount paid per transaction = number of items x price of each item. 

This is important because if each transaction contains numerous items of different prices, 
we will lack necessary information about unique compositions of each transaction to make 
this query. 

Back to the question, 

> Profit = revenue - cost 

This can be written as 

``PROFIT = trnsact.amt - (trnsact.quantity * skstinfo.cost)``

Further, since we want to know the **average** profit, we can find the 
number of days by diving the profit by ``count(distinct saledate)``. 

Overall, we can build the rest of the query around it like so:

```sql
SELECT SUM(a.amt - a.quantity*b.cost)/COUNT(DISTINCT a.saledate) -- avg profit
FROM trnsact a
  LEFT JOIN SKSTINFO b
    ON a.sku = b.sku AND a.store = b.store
WHERE a.stype = 'P'; -- purchases only
```
This returns an average profit of ``$1,527,903.46`` per day. Let's check this 
against what the question expects - that the average profit for Register 640
should be ``$10,779.20``.

```sql
SELECT SUM(a.amt - a.quantity*b.cost)/COUNT(DISTINCT a.saledate)
FROM trnsact a
  LEFT JOIN SKSTINFO b
    ON a.sku = b.sku AND a.store = b.store
WHERE a.stype = 'P'
  AND register = '640';
```
The answer is correct. 

### Exercise 5

**On what day was the total value (in $) of returned goods the greatest?**

```sql 
SELECT saledate, sum(amt)  -- I didnt limit this cos I'm kaypoh 
FROM trnsact
WHERE stype = 'R'
GROUP BY saledate 
ORDER BY sum(amt) DESC;
```

To select only the day with the *greatest* value, ``select limit 1``. 

| Sale date | Total value of returned goods |
| --------- | ----------------------------- |
| **04/12/27** | **$3,030,259.76**
| 04/12/26 | $2,665,283.86
| 04/12/28 | $2,332,544.44
| 04/12/29 | $1,983,898.91
| 04/12/30 | $1,884,052.85
| 04/12/31 | $1,631,004.76
| 05/01/08 | $1,438,745.35
| 05/02/26 | $1,403,971.89
| 05/01/03 | $1,357,311.82
| 05/01/02 | $1,270,440.95

**On what day was the total number of individual returned items the greatest?**

```sql 
SELECT saledate, sum(quantity) 
FROM trnsact
WHERE stype = 'R'
GROUP BY saledate 
ORDER BY sum(quantity) DESC;
```

| Sale date | Total num of returned goods |
| --------- | ----------------------------- |
| **04/12/27** | **82512** |
|04/12/26|71710
|04/12/28|64265
|05/02/26|62462
|04/12/29|55356
|05/02/25|54597
|04/12/30|53171
|05/02/24|49199
|05/07/30|46436
|05/08/27|45704

Well, at least it appears that there is some correlation between the two results. 

### Exercise 6

**What is the maximum price paid for an item in our database? What is the minimum price
paid for an item in our database?**

I'm not sure whether the tables are reliable, so I am going to check all possible values 
from ``skstinfo.retail``, ``trnsact.orgprice`` and ``trnsact.sprice``. 

```sql
SELECT max(orgprice)
FROM trnsact
WHERE stype = 'P';

SELECT min(orgprice)
FROM trnsact
WHERE stype = 'P';

SELECT max(sprice)
FROM trnsact
WHERE stype = 'P';

SELECT min(sprice)
FROM trnsact
WHERE stype = 'P';

SELECT max(retail)
FROM skstinfo;

SELECT min(retail)
FROM skstinfo;
```

| Source | Max price | Min price |
| ----------- | -----| --------- |
| skst.retail | 6017.00 | 0.00 |
| trnsact.orgprice | 6017.00 | 0.00 |
| trnsact.sprice | 6017.00 | 0.00 |

It's nice that they are consistent. Being careful pays off. It appears safe to conclude that 
the **maximum price** for any item is ``$6017.00`` and the **minimum price** is ``$0.00``.

### Exercise 7

**How many departments have more than 100 brands associated with them, and what are their
descriptions?**

```sql
SELECT DISTINCT a.dept, b.deptdesc, count(distinct a.brand) 
FROM skuinfo a
  LEFT JOIN deptinfo b
    ON  a.dept=b.dept 
GROUP BY a.dept, b.deptdesc
HAVING count(distinct a.brand) > 100;
```

There are **three** departments iwth more than 100 brands associated, and these are their 
descriptions: 

| Department ID | Description | Num brands |
| ----------- | -----| --------- |
|4407 | ENVIRON | 389
| 7104 | CARTERS | 109
| 5203 | COLEHAAN | 118

### Exercise 8

**Write a query that retrieves the department descriptions of each of the skus in the skstinfo
table.**

```sql
SELECT a.sku, c.deptdesc
FROM skstinfo a 
  LEFT JOIN skuinfo b 
    ON a.sku = b.sku 
  LEFT JOIN deptinfo c
    ON b.dept = c.dept
SAMPLE 100; -- remove this during exam
```
The department description for ``SKU5020024`` is ``LESLIE``.

### Exercise 9

**What department (with department description), brand, style, and color had the greatest total
value of returned items?**

### Exercise 10

**In what state and zip code is the store that had the greatest total revenue during the time
period monitored in our dataset?**

*Note: There is an error in the notes. The question asks for state and **city** instead of **zip**. 
The assignment statement provided (below) suggests that you should know the city too.*

> "If you have written your query correctly, you will find that the department with the 
10th highest total revenue is in Hurst, TX."

```sql
SELECT b.state, b.city, SUM(a.amt) -- no need to include sum(a.amt), but this is good for checking.
FROM strinfo b
  LEFT JOIN trnsact a
    ON a.store = b.store
WHERE stype = 'P'
GROUP BY b.state, b.zip
ORDER BY SUM(a.amt) DESC;
```

| State | ZIP | City | Total Revenue |
| ----- | --- | ---- | ------------------ |
| LA | 70002 | METAIRIE |$24,171,426.58
|AR |72205 |LITTLE ROCK |$22,792,579.65
|TX |78501 |MCALLEN |$22,331,884.55
|TX |75225 |DALLAS |$22,063,797.73
|KY |40207 |LOUISVILLE| $20,114,154.20
|TX |77056 |HOUSTON| $19,040,376.84
|KS |66214 |OVERLAND PARK |$18,642,976.76
|OK |73118 |OKLAHOMA CITY |$18,458,644.39
|TX |78216 |SAN ANTONIO |$18,455,775.63
| **TX** | **76053** | **HURST** | **$17,740,181.20**

The answer is correct. The store with the 10th highest revenue is 
``Hurst City`` with ``$17,740,181.20``. 
