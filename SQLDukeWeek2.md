# Week 2 

#### INTRODUCTION

Note to self: Typical syntax follows this order 
```sql
SELECT item
FROM table
WHERE condition
GROUP BY variable 
HAVING condition
ORDER BY category ASC / DESC
```
Other notes:
- Only SELECT + FROM are actually required. Rest = optional
- DB will physically manage and plan the how aspect of retrieving it best (aka not your problem for now). Focus on extracting data first. 
- To tell db that data is missing, type NULL, not zero.

### Style Notes
1. CAPITALISE all commands aka first word
2. CAPITALISE other keywords like 'sum' or 'avg' too
2. End all queries with ; 
2. Start each command on a new line (easier to read)

### Optional but Good To Follow
The DUKE course uses the dialect, *MySQL*. However, MySQL is a nappy hipster that doesn't quite follow SQL convention. In fact, it's pretty far out. If you ever need to change to a different SQL dialect, you'll need these rules too. Hence, it might be a good idea to start making them a habit now.

1. Not all DBs are case insensitive. Try to write the EXACT name used in database, CaPiTal letters and all.
3. Names inside "inverted commas" are strictly case sensitive. Use the EXACT name used in the db too. 
4. Make indentations for new subqueries or new lines. You'll learn more about this later. 
2. Although MySQL accepts both single and double inverted commas, stick to single commas where possible. Most other DBs only accept single ticks. 

# First Look At Your Database
*Let's assume you're exploring a new DB, but have no diagrams about it. How would you explore and get to know it?*

To make something the default database for our queries, run this command:

```sql
USE dognitiondb
```

To show all tables in the database.
```sql
SHOW tables
```

Show all columns in a table.
```sql
SHOW columns FROM [table name, without brackets]
OR:
DESCRIBE [table name, without brackets]
```
Note: In the output, the SHOW/DESCRIBE command will reveal whether NULL values can be stored in that field in the table. The "Key" column of the output also provides the following information about each field of data in the table being described (see [here](https://dev.mysql.com/doc/refman/5.6/en/show-columns.html "SQL documentation") for more information).

##### Hints

- PRI - the column is a PRIMARY KEY or is one of the columns in a multiple-column PRIMARY KEY.
- UNI - the column is the first column of a UNIQUE index.
- MUL - the column is the first column of a nonunique index in which multiple occurrences of a given value are permitted within the column.
- Empty - the column either is not indexed or is indexed only as a secondary column in a multiple-column, nonunique index.

*Note: The "Default" field of the output indicates the default value that is assigned to the field. The "Extra" field contains any additional information that is available about a given field in that table. For now, you won't die yet if you don't understand this.*

To show all data (types) in a column.

```sql
SELECT [column name, without brackets]
FROM [table name, without brackets];
```

If you have multiple databases loaded:
```sql
SHOW columns FROM [table name] FROM [database name]
SHOW columns FROM databasename.tablename
```
# MySQL Variable Types

In a MySQL database, there are three (3) main data types: text, numbers and dates/times.  When you design your database, it is important that you select the appropriate type, since this determines why type of data you can store in that column.  Using the most appropriate type can also increase the database's overall performance.

### Text Types

| Name | Description |
| ------ | -------- | 
| CHAR( ) | A fixed section from 0 to 255 characters long.|
| VARCHAR( ) | A variable section from 0 to 255 characters long. |
| TINYTEXT | A string with a maximum length of 255 characters. |
| TEXT | A string with a maximum length of 65535 characters.|
| BLOB | A string with a maximum length of 65535 characters.|
| MEDIUMTEXT | A string with a maximum length of 16777215 characters. |
| MEDIUMBLOB | A string with a maximum length of 16777215 characters.|
| LONGTEXT| A string with a maximum length of 4294967295 characters.|
| LONGBLOB| A string with a maximum length of 4294967295 characters.|

The ( ) brackets allow you to specify the maximum  number of characters that can be used in the column. Meanwhile, BLOB stands for Binary Large OBject, and can be used to store non-text information that is encoded into text. *How cute is that?!*

### Number Types

| Name | Description | Length
| --- | ---- | ---- |
| TINYINT ( ) | -128 to 127 normal | 0 to 255 UNSIGNED
| SMALLINT( ) | -32768 to 32767 normal | 0 to 65535 UNSIGNED
| MEDIUMINT( ) | -8388608 to 8388607 normal | 0 to 16777215 UNSIGNED
| INT( ) | -2147483648 to 2147483647 normal | 0 to 4294967295 UNSIGNED
| BIGINT( ) | -9223372036854775808 to 9223372036854775807 normal | 0 to 18446744073709551615 UNSIGNED
| FLOAT | A small number with a floating decimal point.
| DOUBLE( , ) | A large number with a floating decimal point.
| DECIMAL( , ) | A DOUBLE stored as a string, allowing for a fixed decimal point.

By default, the integer types will allow a range between a negative number and a positive number, as indicated in the table above.

You can use the UNSIGNED commend, which will instead only allow positive numbers, which start at 0 and count up.

#### Useful Num Commands
| Command | Description |
| --- | ---- |
| AVG( ) | Finds the average of all rows of the variable 
| SUM( ) | Finds the sum of all rows of the variable 
| FLOOR( ) | Rounds a floating decimal down to nearest integer
| CEIL( ) | Rounds a floating decimal up to nearest integer
| FLOAT(num, x) | Rounds a floating var to x decimal places eg. (height, 2)
|%| Modulus |
| Var % 2 = 0 | Used in conjunction with 'WHERE' command, to return all rows where 'var' is even numbered
| Var % 2 != 0 | Used in conjunction with 'WHERE' command, to return all rows where 'var' is even numbered

# SELECT, FROM
**SELECT** is used anytime you want to retrieve data from a table. In order to retrieve that data, you always have to provide at least two pieces of information:

>(1) WHAT you want to select, and
(2) FROM where you want to select it.

Example of most basic select:
```sql
SELECT breed
FROM dogs;
```
SELECT statements can also be used to make new derivations of individual columns using "+" for addition, "-" for subtraction, "*" for multiplication, or "/" for division. For example, if you wanted the median inter-test intervals in hours instead of minutes or days, you could query:
```sql
SELECT median_iti_minutes/60, median_iti_minutes
FROM dogs
```
# LIMIT / OFFSET

LIMIT is used to restrict the number of queries outputted.
OFFSET will offset that number of X entries (starting with 1).
##### Examples
Select only 10 rows of data
```sql
SELECT breed
FROM dogs 
LIMIT 10;
```
Select 10 rows of data, but AFTER the first 5 rows. 
```sql
SELECT breed
FROM dogs 
LIMIT 5, 10;

SELECT breed
FROM dogs 
OFFSET 5
LIMIT 10;
```

# WHERE + BETWEEN, AND, OR

We can use the WHERE statement to specify our queries, like this example below. We can add BETWEEN, AND, OR operators in conjunction with variables to make them more specific, like this:
```SQL
SELECT dog_guid, weight
FROM dogs
WHERE weight BETWEEN 10 AND 50;

SELECT dog_guid, dog_fixed, dna_tested
FROM dogs
WHERE dog_fixed=1 OR dna_tested=1;

SELECT dog_guid, dog_fixed, dna_tested
FROM dogs
WHERE dog_fixed=1 AND dna_tested!=1;

SELECT dog_guid
FROM dogs
WHERE YEAR(created_at) > 2015 -- you will learn more about dates later
```
##### Using WHERE + Strings
Strings need to be surrounded by quotation marks in SQL. MySQL accepts both double and single quotation marks, but some database systems only accept single quotation marks, so it might be a good idea to start that habit right now. Note that whenever a string contains an SQL keyword, the string must be enclosed in backticks instead of quotation marks.

>'the marks that surrounds this phrase are single quotation marks'
"the marks that surrounds this phrase are double quotation marks"
` the marks that surround this phrase are backticks ``

```SQL
SELECT dog_guid, weight
FROM dogs
WHERE breed = 'Golden Retriever';
```
### Date/Time Types
In the previous section, we saw one example of using date-time to specify a query further. Let's learn more about them now. We can use the WHERE statement to interact with datetime data. Time-related data is a little more complicated to work with than other types of data, because it must have a very specific format. Examples of datetime types: 

```sql 
DATE: YYYY-MM-DD
DATETIME: YYYY-MM-DD HH:MM:SS
TIMESTAMP: YYYYMMDDHHMMSS
TIME: HH:MM:SS
YEAR: YYYY
```
Date/Time fields will only accept a valid date or time. A time stamp stored in one row of data might look like this:
```sql
2013-02-07 02:50:52
```
Using the same date-time format in combination with WHERE, we can select specific rows of data that fit the date criteria. For example, we can specify a range of dates we'd like to retrieve data from:

```sql
SELECT dog_guid, created_at
FROM complete_tests
WHERE created_at >= '2014-01-01' AND created_at <= '2015-01-01'
```
However, instead of typing out full specifications of date ranges every time, there are other functions that interact well with date too. For instance: 
```sql
SELECT dog_guid, updated_at
FROM reviews
WHERE YEAR(created_at) = 2014 -- selects entried created in 2014
```
In that vein, two of similar commands are **Day** and **month** which also lets you extract all rows created around a specified day or month. 
```sql
SELECT dog_guid, created_at
FROM complete_tests
WHERE DAY(created_at) > 15 -- day of month: 0 to 31

SELECT dog_guid, created_at
FROM complete_tests
WHERE MONTH(created_at) = 12 -- month of year: Dec
```
**Dayname** is a function that will select data from only a single day of the week. This example selects all IDs created on Tuesday:  
```sql
SELECT dog_guid, created_at
FROM complete_tests
WHERE DAYNAME(created_at) = "Tuesday" -- dayname here
```
You have to use a different set of functions than you would use for regular numerical data to add or subtract time from any values in these datetime formats. You would use the **TIMESTAMPDIFF** or **DATEDIFF** function.
```sql
SELECT user_guid, TIMESTAMPDIFF(MINUTE, start_time, end_time)
FROM exam_answers
WHERE TIMESTAMPDIFF(MINUTE, start_time, end_time) < 0;

SELECT user_guid, TIMESTAMPDIFF(HOUR, start_time, end_time)
FROM exam_answers
WHERE TIMESTAMPDIFF(HOUR, start_time, end_time) > 1;

SELECT user_guid, TIMESTAMPDIFF(SECOND, start_time, end_time)
FROM exam_answers
WHERE TIMESTAMPDIFF(SECOND, start_time, end_time) > 60;
```
# SUBSETS: IN, LIKE
The IN operator allows you to specify multiple values in a WHERE clause. Each of these values must be separated by a comma from the other values, and the entire list of values should be enclosed in parentheses.
```sql
SELECT dog_guid, breed
FROM dogs
WHERE breed IN ('retriever', 'poodle');

SELECT * -- this means select all columns
FROM users
WHERE state NOT IN ('NC','NY');
```
The **LIKE** operator allows you to specify a pattern that the textual data you query has to match. For example, if you wanted to look at all the data from breeds whose names started with "s", you could query:
```
SELECT dog_guid, breed
FROM dogs
WHERE breed LIKE ("s%");
```
In this syntax, the percent sign indicates a wild card. Wild cards represent unlimited numbers of missing letters. This is how the placement of the percent sign would affect the results of the query:

1. WHERE breed LIKE ("s%") = the breed must start with "s", but can have any number of letters after the "s"
2. WHERE breed LIKE ("%s") = the breed must end with "s", but can have any number of letters before the "s"
3. WHERE breed LIKE ("%s%") = the breed must contain an "s" somewhere in its name, but can have any number of letters before or after the "s"

# IS, IS NOT, NULL
To select only the rows that have NON-NULL data you could query:
```sql
SELECT user_guid
FROM users
WHERE free_start_user IS NOT NULL;
```
To select only the rows that only have null data so that you can examine if these rows share something else in common, you could query:
```sql
SELECT user_guid
FROM users
WHERE free_start_user IS NULL;
```
You will see that ISNULL is a logical function that returns a 1 for every row that has a NULL value in the specified column, and a 0 for everything else. We can get the total number of NULL values in any column. Here's what that query would look like:
```sql
SELECT SUM(ISNULL(breed)) -- counts dogs with breed = NULL
FROM dogs
```
More complicated example: Printing number of unique DOG IDs for each breed and gender, where there is at least 1000 dogs in each breed group. Note the useful NULL function.
```sql
SELECT COUNT(dog_guid) AS num_dogs, gender, breed_group
FROM dogs
WHERE breed_group IS NOT NULL AND breed_group <> ''
GROUP BY breed_group
HAVING COUNT(breed_group>1000)
ORDER BY COUNT(dog_guid) DESC;

Can you guess what the other functions mean? If you can't, we'll learn about them next so don't stress about it. 
```
# AS / REPLACE / REMOVE

If you wanted to **rename** the name of the time stamp field of the completed_tests table from "created_at" to "time_stamp" in your output, you could take advantage of the **AS** clause and execute the following query:
```sql
SELECT dog_guid, created_at AS time_stamp
FROM complete_tests;
```
Note that if you use an alias that includes a space, the full alias MUST be surrounded in **quotation marks**:
```sql
SELECT dog_guid, created_at AS 'time stamp'
FROM complete_tests;
```
You could also make an alias for a table, and just about everything:
```sql
SELECT dog_guid, created_at AS 'time stamp'
FROM complete_tests AS tests

SELECT user_guid, (median_ITI_minutes * 60) AS 'Median Sec'
FROM dogs;
```
It is possible to replace unwanted stuff too, or remove them. For example, you can **delete** the first character off every word with the **TRIM** function:
```sql
SELECT breed, TRIM(LEADING '-' FROM breed) AS breed_fixed
FROM dogs;
```
Or, you could **replace** them instead with blanks, or any other item. The syntax for **REPLACE( )** is 

```sql
[variable, replace FOR, replace WITH]

SELECT breed, REPLACE (breed, '-', '' ) AS breed_fixed
FROM dogs;
```
One last way to edit output is to simply **WRITE** your own stuff using **CONCAT**. The syntax for concat is to lump everything together, separated by commas, like this: ['STRING 1', 'STRING 2' ... ]
```sql
SELECT breed,
CONCAT ("This dog is a", breed , 'dog.' ) AS new_statement
FROM dogs
ORDER BY breed_fixed
```
# DISTINCT, COUNT, ORDER BY

When the DISTINCT clause is used with multiple columns in a SELECT statement, the combination of all the columns together is used to determine the uniqueness of a row in a result set. Note that by "every type", it also includes type NULL too. 
```sql
SELECT DISTINCT breed
FROM dogs;       -- distinct dog breeds

SELECT DISTINCT state, city
FROM users;      -- distinct combo of state AND city
```
If you wanted the breeds of dogs in the dog table sorted in alphabetical order, you could query this using the **ORDER BY** function:
```sql
SELECT DISTINCT breed
FROM dogs
ORDER BY breed ASC;
```
To sort the output in descending order as well:
```sql
SELECT DISTINCT breed
FROM dogs
ORDER BY breed DESC;
```
Note: Using ORDER BY, when not applied to alphabetical data, gives the numerically ascending order by default.
```sql
SELECT DISTINCT user_guid, state, membership_type
FROM users
WHERE country="US" AND state IS NOT NULL AND membership_type IS NOT NULL
ORDER BY state ASC, membership_type ASC
```
##### Important Note:

COUNT and DISTINCT cannot be used together, like this:
```sql
SELECT count (apples), distinct pears
FROM fruit
```
Because count = only 1 row output (the sum of that variable), while pears = many pear types. However, it can be used this way, because this will produce the number of distinct apple types, *grouped by* each country, so that each unique country will only have 1 number attached to it. 
```sql
SELECT COUNT (DISTINCT apples), country
FROM fruit
GROUP BY country; -- we will learn group by next
```
Lastly, remember that DISTINCT removes NULL, but COUNT does not remove NULL. So, it is good practice to put IS NOT NULL or =! "" as much as possible when using COUNT. 

# How to Export your Query Results to a Text File
You can tell MySQL to put the results of a query into a variable, and then use Python code to format the data in the variable as a CSV file (comma separated value file, a .CSV file) that can be downloaded. When you use this strategy, all of the results of a query will be saved into the variable, not just the first 1000 rows as displayed in Jupyter.

To tell MySQL to put the results of a query into a variable, use the following syntax:
```sql
variable_name_of_your_choice = %sql [your full query goes here, but don't include square brackets];

breed_list = %sql SELECT DISTINCT breed FROM dogs ORDER BY breed;
num_dogs = %sql SELECT COUNT(DISTINCT dog_guid) FROM dogs;
```
Once your variable is created, using the above command tell Jupyter to format the variable as a csv file using the following syntax:
```sql
variable_name.csv('the_output_name_you_want.csv')
breed_list.csv('breed_list.csv')
num_dogs.csv('unrelated.csv')
```
