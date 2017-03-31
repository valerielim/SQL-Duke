# Week 3
Continuing all functions learnt in week 2, we will learn the final 3 this week. Notes for this week will emphasize applications of functions more than explanations. Week 3 also includes notes on Inner Joins & Outer Joins (see next markdown file). 

# COUNT, SUM
Count is well, count. 
```sql
SELECT COUNT(breed)
FROM dogs;

SELECT COUNT(DISTINCT breed)
FROM dogs;

SELECT COUNT(DISTINCT user_guid)
FROM complete_tests
WHERE created_at > __

SELECT state, zip, COUNT(DISTINCT user_guid)
FROM users
WHERE country = "US"
GROUP BY state, zip
HAVING COUNT(DISTINCT user_guid) > 5
ORDER BY state ASC;
```
Note: When a column is included in a count function, null values are ignored in that count. But when an asterisk is included in a count function, nulls are included in the count.

Next, SUM finds the total of all rows matching a given criteria. It only works for numerical values though, not for strings, and not for date-time types. 
```sql
SELECT SUM(IS NULL(exclude)
FROM dogs;
Result: 34, 025
```
Note: SUM is different from Count. Sum takes only 'is null = 0', while count includes rows where null= 1 too.
```
SELECT COUNT(IS NULL(exclude)
FROM dogs;
Result: 35,035
```

# AVERAGE, MIN, MAX
AVG, MIN, MAX are mathematical operators that work with numerical data. They can be used together or used separately. The minimum and maximum amounts also work on dates -- via picking the earliest or latest date. It's pretty basic so just read the examples to learn their syntax. 

```sql
SELECT test_name,
AVG (rating) AS AVG_rating,
MIN (rating) AS MIN_rating,
MAX (rating) AS MAX_rating
FROM reviews
WHERE test_name = "Eye Contact Game";

SELECT AVG (TIMESTAMPDIFF (minutes, start_time, end_time)) AS Duration,
test_name AS Test
FROM exam_answers;

SELECT AVG (TIMESTAMPDIFF (hour, start_time, end_time)) AS Avg_duration,
MIN (TIMESTAMPDIFF (hour, start_time, end_time)) AS min_time,
MAX (TIMESTAMPDIFF (hour, start_time, end_time)) AS max_time,
test_name AS Test
FROM exam_answers
WHERE timestampdiff(minute, start_time, end_time)>0;
```
# GROUP BY

GROUP BY aggregates all data for other columns based on the column selected to be grouped by. For instance, this groups the data by MONTH:
```SQL
SELECT test_name, MONTH(created_at) AS Month, COUNT(created_at) AS Num_Completed
FROM complete_tests
GROUP BY Month;
```
Note: Although this correctly groups data by month, **this example gives an incorrect test_name answer**. This is because there is only 1 row allocated for each Month, but more than one type of test done per month. In this situation, MySQL will populate it with a randomly chosen Test done in that month, while other DB may throw an error, but both are incorrect. Overall, there is no way to present an aggregated and non-aggregate dataset in the same table. 

**Solution**: We can either group by all non-aggregated variables too (B), or further aggregate ALL variables (A). 

(A) This gives the number of test types and tests completed per month.
```SQL
SELECT COUNT(test_name), MONTH(created_at) AS Month, 
COUNT(created_at) AS Num_Completed
FROM complete_tests
GROUP BY Month; 
```
(B) This gives number of tests completed per test type AND month.
```sql
SELECT test_name, MONTH(created_at) AS Month, COUNT(created_at) AS Num_Completed
FROM complete_tests
GROUP BY Month, test_name; 
```
Note: Not all databases accept aliases (eg. MONTH(created_at) stored as Month). If they don't just retype the formula in the GROUP BY line.

# HAVING
The HAVING command is similar to WHERE, in that it adds another layer of specificity to your query. However, the difference is that *HAVING applies to aggregate data* while WHERE applies to single-column data. 

**Example using WHERE:** Print test name, month it is completed it, and number of tests done that month -- for Nov & Dec ONLY.
```sql
SELECT test_name, 
    MONTH(created_at) AS Month_Name, 
    COUNT(created_at) AS Num_Completed_Tests
FROM complete_tests
WHERE MONTH(created_at)=11 OR MONTH(created_at)=12
GROUP BY test_name, Month_Name
ORDER BY Num_Completed_Tests DESC;
```
**Example using HAVING:** Print test name, month it is completed it, and number of tests done that month -- for all months, WITH at least 20 tests done that month.
```sql
SELECT test_name,
    MONTH(created_at) AS Month,
    COUNT(created_at) AS Num_Completed_Tests
FROM complete_tests
WHERE MONTH(created_at)=11 OR MONTH(created_at)=12
GROUP BY 1, 2
HAVING COUNT(created_at)>=20
ORDER BY 3 DESC;
```
#### More Examples
Prints the average time taken by a user for each test in minutes. Excludes data of users who took more than 6000 hours, or less than 0 seconds per test, for that test.
```sql
SELECT test_name,
    AVG( TIMESTAMP DIFF( minute, start_time, end_time)) AS 'Time (Min)',
    subcategory_name
FROM exam_answers
WHERE TIMESTAMP DIFF(minute, start_time, end_time)<6000
    AND TIMESTAMP DIFF((second, start_time, end_time)>0
GROUP BY test_name;
```
Print the sum of users in each combination of state & zip -- where there is at least 5 users in that combination. Order in ascending by state, and in descending by number of users.
```sql
SELECT state, zip,
    COUNT(DISTINCT user_guid) AS UserID
FROM users
WHERE state != ""
    AND state IS NOT NULL
    AND zip IS NOT NULL
    AND zip != ""
GROUP BY state, zip
HAVING UserID >= 5
ORDER BY state ASC, UserID DESC;
```
Revise the query your wrote in Question 2 so that it (1) excludes the NULL and empty string entries in the breed_group field, and (2) excludes any groups that don't have at least 1,000 distinct Dog_Guids in them.
```sql
SELECT count(dog_guid) AS num_dogs, gender, breed_group
FROM dogs
WHERE breed_group IS NOT NULL AND breed_group != ''
GROUP BY 3
HAVING COUNT(breed_group>1000)
ORDER BY 1 DESC;
```
# Conclusion
These functions sum up the last of all basic commands. Last week, you learnt SELECT, FROM, WHERE, ORDER BY. This week, you learnt HAVING, GROUP BY, as well as OPERATORS, SUM, AVG, DISTINCT, COUNT. This lets you add a greater layer of specificity to your query. 

*See notes in next section for inner and outer joins.*
