# Week 2 - Dillard's Database Exercises

Date created: 14 March 2017

This is the COMPLETE answer key (including explanations where necessary) 
for Week 2 of **"Managing Big Data wtih MySQL"** course by Duke University: 
'Queries to Extract Data from Single Tables'. 

I wrote this answer key as no official answers have been released online. 
These answers reflect my own work and are accurate to the best of my knowledge. 
I will update them if the professors ever release an "official" answer key. 

**Update**: These answers are based on the original UA_Dillards dataset (not UA_Dillards1, 
nor UA_Dillards_2016). This means I am using the table ``SKSTINFO`` and not 
``SKSTINFO_FIX`` which is the newer version.

Meanwhile, let's start.

# Answers

To start, enter ``DATABASE ua_dillards;`` into the Teradata SQL scratchpad.

### Exercise 1

**Use HELP and SHOW to confirm the relational schema provided to us for the
Dillard’s dataset shows the correct column names and primary keys for each table.**

```sql
HELP TABLE strinfo
HELP TABLE skstinfo
HELP TABLE skuinfo
HELP TABLE trnsact
HELP TABLE deptinfo
HELP TABLE store_msa
``` 

Note: *The course's notes contain an error.* It suggests:

> "To get information about a single column in a table, you could write:
>
> HELP COLUMN [name of column goes here; don’t include the
brackets when executing the query]"

This is incorrect. You need to specify **which table** the column is from too, 
as some column names are common to more than one table. The syntax correct should be 
``HELP COLUMN tablename.columnname``. Thus, to find out more information 
about a single column, you should do this:

```sql
HELP COLUMN skstinfo.sku
HELP COLUMN skuinfo.sku
HELP COLUMN trnsact.sku
...
etc
```

Lastly, to confirm which is the primary key of each table, do this:
``SHOW TABLE [tablename here -- but don’t include the
brackets when executing the query];``. When applied, it looks like this:

```sql
SHOW TABLE strinfo
SHOW TABLE skstinfo
SHOW TABLE skuinfo
SHOW TABLE trnsact
SHOW TABLE deptinfo
SHOW TABLE store_msa
``` 

### Exercise 2

**Look at examples of data from each of the tables. Pay particular attention to
the ``skuinfo`` table.**

Things to note: 
- There are two types of transactions: purchases (P) and returns (R). We will need to 
make sure we specify which type we are interested in when running queries using the 
transaction table.
- There are a lot of strange values in the “color”, “style”, and “size” fields of 
the skuinfo table. The information recorded in these columns is not always related to 
the column title (for example there are entries like "BMK/TOUR K” and “ALOE COMBO” in 
the color field, even though those entries do not represent colors).
- The department descriptions (``deptdesc`` from ``DEPTINFO``) seem to represent brand 
names. However, if you look at entries in the skuinfo table from only one department, 
you will see that many brands are in the same department. 

### Exercise 3

**Examine lists of distinct values in each of the tables.**

Okay... 

### Exercise 4

**Examine instances of transaction table where “amt” is different than “sprice”.
What did you learn about how the values in “amt”, “quantity”, and “sprice” 
relate to one another?**

To query all rows where ``amt``(total transaction amount) is different from 
``sprice``(sale price):

```sql
SELECT * 
FROM trnsact
WHERE amt <> sprice;
```

We see 7 rows appear. What the rows have in common is that they are all return 
transactions (``R``), and have an ``INTERID`` of 000000000. The items, which were originally 
$20-$80 each, are now $0.10 to $1.00 each. 

### Exercise 5

Even though the Dillard’s dataset had primary keys declared and there were not 
many NULL values, there are still many bizarre entries that likely reflect entry errors.
To see some examples of these likely errors, examine:

**(a) Rows in the trsnact table that have “0” in their orgprice column (how could the original
price be 0?)**

```sql
SELECT *
FROM trnsact
WHERE orgprice = '0';
```
*Notes: There should be 1425811 rows where the original price = $0.00, or approx 1.18% 
of all rows in the ``TRNSACT`` table. There appears to be nothing in common between these items.*

**(b) Rows in the skstinfo table where both the cost and retail price are listed as 0.00**

```sql
SELECT *
FROM skstinfo
WHERE cost = '0'
  AND retail = '0';
```

*Notes: There should be 350340 rows where both the cost and retail price = $0.00, or 
approx 0.89% of all rows in the ``SKSTINFO`` table. There appears to be nothing in common 
between these items.*

**(c) Rows in the skstinfo table where the cost is greater than the retail price (although
occasionally retailers will sell an item at a loss for strategic reasons, it is very 
unlikely that a manufacturer would provide a suggested retail price that is lower than 
the cost of the item).**

```sql
SELECT *
FROM skstinfo
WHERE cost > retail 
  AND retail > '0'; -- to exclude erroneous values
```

*Notes: There should be 7535205 rows where cost price is greater than retail price. 
This forms approx 19.2% of all rows in the ``SKSTINFO`` table.*

### Exercise 6

**Write your own queries that retrieve multiple columns in a precise order from
a table, and that restrict the rows retrieved from those columns using “BETWEEN”, “IN”,
and references to text strings. Try at least one query that uses dates to restrict the rows
you retrieve.**

Okay...

```sql 
SELECT count(store)
FROM strinfo
WHERE state = 'NY';
```
Seems like New York has only 2 stores. Actually, let's explore how many stores there are 
in each state, and see who has the most. 

```sql
SELECT STATE, COUNT(STORE)
FROM strinfo
GROUP BY STATE
ORDER BY COUNT(STORE) DESC;
```

|State | Stores |
| ---- | ----- |
| TX | 79 
| FL | 48
| AR | 27
| AZ | 26
| OH | 25

Okay, let's try to find the earliest and latest sale date in this dataset.

```sql
SELECT distinct saledate
FROM trnsact
ORDER BY saledate ASC;

SELECT distinct saledate
FROM trnsact
ORDER BY saledate DESC; -- I'm lazy to scroll. 
```
Earliest date: ``04/08/01``. Latest date: ``05/08/27``. Seems like we have 389 dates in 
record. 

Let's mess around further, and see which dates have the highest number of transactions. 
I bet that the total number of transactions will peak on 24 Dec (aka right before christmas). 
Let's check: 
```sql
SELECT saledate, count(saledate)
FROM trnsact
GROUP BY saledate
ORDER BY count(saledate) DESC;
```
HOLY CRAP. I am so wrong. Here are the top 10 dates with the highest transactions:

| No. | Date | Transactions |
| ---- | ---- | ---- | 
| 1 | 05/02/26 | 1198813
| 2 | 05/02/25 | 947451
| 3 |05/02/24 | 888352
| 4 | 05/07/30 | 875042
| 5 |  05/02/23 | 855037
| 6 |05/08/27 | 771760
| 7 | 04/10/02 | 758200
| 8 | 04/12/18* | 744268
| 9 | 04/11/26 | 690396
| 10 | 04/12/23* | 675139

Seems like christmas doesn't even come close. WTf? Let's find out what happened
on ``05/02/26``.

According to Google, it seems like they had the [mother of all sales](https://sgbonline.com/dillards-february-comps-increase-5-percent/ "DillardsReport"). 

Well that must be some epic sales. Because judging by the number of transactions, it 
appears that people spent **1.75x** more on 25th and 26th Feb, than the 2 days leading up 
to Christmas (23rd, 24th Dec. *I excluded 25th Dec because Dillards was not open on Christmas Eve*). 
 
![alt text](https://cdn.meme.am/instances/400x/64773524.jpg)

I don't understand, America. How do you spend more for yourself *in a single day*
than for all your friends and cousins combined?

Anyway, that's all the questions for this exercise. *I've spent an hour on this already and it's 
3am here. :(* 

One final note from the assignment: while **date formats** will be output as:

``YY-MM-DD'``

During queries, **date** strings should be entered as:

``YYYY-MM-DD'.``

*Thanks for reading, hope this was useful to you. I had fun writing this!*


