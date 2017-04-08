# Teradata Cheatsheet

This document is a compilation of differences between MySQL and the SQL 
dialect Teradata uses with regards to major commands. It was made with 
reference to course notes from Duke University's "Managing Big Data with 
MySQL" course. 

This document assumes that one is already familiar with 
some SQL or MySQL as it mainly serves to point out the differences between them.

Date created: 18 March 2017

### Set Database

To select the database, enter ``DATABASE [name];`` into the SQL scratchpad. 

### Explore Database

To display tables and columns in database

```sql
HELP TABLE [name]

HELP COLUMN [name]
```
*Note: Don't include the brackets when executing the query.*

### Primary Keys

To confirm which are the primary keys of a table

```sql
SHOW table [name];
```
*Note: Don't include the brackets when executing the query.*

### Restricting Query Output 

Teradata uses TOP instead of LIMIT to restrict output. 
To select the first 10 rows:

```sql
SELECT TOP 10 student_IDs 
FROM class_info;
```

To select 10 random rows instead:

```sql
SELECT student_IDs 
FROM class_info
SAMPLE 10;
```

To select 10% of all rows instead: 

```sql
SELECT student_IDs 
FROM class_info
SAMPLE .10;
```
*Note: The last two commands will return different selection of rows each time.*

### Aggregation & Group By

Any non-aggregate column in the ``SELECT`` list or ``HAVING`` list of a query with 
a ``GROUP BY`` clause must also listed in the ``GROUP BY`` clause. Unlike MySQL, 
Teradata will not pick a random selection to populate a field that cannot be aggregated. 

This will not run:
```sql
SELECT shopname, clothes_ID, cost
FROM shop
GROUP BY shopname  
```
However, this will run:
```sql
SELECT shopname, clothes_ID, avg(cost) -- find average to aggregate this column
FROM shop
GROUP BY shopname, clothes_ID -- group by non-aggregates
```
### Operators

Both Teradata and Mysql accept the symbols ``<>`` for *not equals to*, but 
Teradata does not accept ``!=``. 

### String selection

Teradata only accepts **single quotation marks**. 

### Date Time Format

Teradata will output data in the format ``YY-MM-DD``. However, it expects date 
format to be entered in ``YYYY-MM-DD``. 

``TIMESTAMPDIFF(hour/minute/second, var1, var2)`` 
which calculates the difference between 2 variables in the specified format.

``DAYOFWEEK(datevar)``, where the day of the week will be returned as an 
integer from 1 - 7 where 1 = Sunday, 2 = Monday, etc. 

### IF ELSE 

Teradata does *not* accept ``IF`` functions. However, we can replace this with ``CASE``.

