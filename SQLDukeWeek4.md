# Week 4 - Subqueries

Subqueries, which are also sometimes called inner queries or nested queries, are queries that are embedded within the context of another query. They are useful for complex queries, and also for testing smaller parts of the queries to ensure they give you what you want first before assembling the whole thing. Some basic rules are:

- ORDER BY phrases cannot be used in subqueries (although ORDER BY phrases can still be used in outer queries that contain subqueries)
- Subqueries in SELECT or WHERE statements can output no more than 1 row. Otherwise, subqueries in SELECT or WHERE clauses that return more than one row must be used in combination with operators that are explicitly designed to handle multiple values, such as the IN operator.

Lastly, when they are used in FROM clauses, they create what are called **derived tables**. This comes into play later when you want to optimse your query to run faster. Having smaller derived tables helps the query be answered quicker because the db does not need to hold such a large derived table in memory. But for now, focus on writing the damn thing right first. 

### #1: SUBQUERIES FOR ON-THE-FLY CALCULATIONS

Example: Find all details about users whose average time taken per test is greater than the average time taken by the community.
```sql
SELECT *,
TIMESTAMPDIFF(minute,start_time,end_time) AS AvgDuration
FROM exam_answers
WHERE TIMESTAMPDIFF(minute,start_time,end_time) >
      (SELECT AVG(TIMESTAMPDIFF(minute,start_time,end_time))
      FROM exam_answers
      WHERE TIMESTAMPDIFF(minute,start_time,end_time)>0);
```

Example: Find all details about users whose average time taken for the "yawn warm up" game is greater than the average time taken by the community.
```sql
SELECT *,
    avg(TIMESTAMPDIFF(minute,start_time,end_time)) AS Avg_Duration
FROM exam_answers
WHERE TIMESTAMPDIFF(minute,start_time,end_time) >
      (SELECT AVG(TIMESTAMPDIFF(minute,start_time,end_time))
      FROM exam_answers
      WHERE TIMESTAMPDIFF(minute,start_time,end_time)>0
      AND test_name = 'Yawn Warm-Up');
```
### #2: SUBQUERIES FOR TESTING MEMBERSHIP
Subqueries can be used to test membership for items in one group against another, through calling the test group in the subquery. We can use EXIST / NOT EXIST for this command specifically. Somerules: 

- EXISTS and NOT EXISTS can ONLY be used in subqueries
- IT is similar to IN and NOT IN functions, but those can be used in all queries
- Cannot be preceded by a column name or any other expression
- Returns TRUE/FALSE logical statements
- Since the only concern for the subquery is whether it is TRUE/FALSE, can use SELECT * in subquery

Example: Retrieve a list of all the users in the users table who were also in the dogs table using the EXIST function.
```sql
SELECT DISTINCT u.user_guid AS uUserID
FROM users u
WHERE EXISTS 
    (SELECT *
    FROM dogs d
    WHERE u.user_guid =d.user_guid);
```
Example: Find the stores that exist in one or more cities.
```sql
SELECT DISTINCT store_type
FROM stores
WHERE EXISTS (
     SELECT *
     FROM cities_stores
     WHERE cities_stores.store_type = stores.store_type);
```
### #3: SUBQUERIES FOR LOGIC WITH DERIVED TABLES
Subqueries can be more elegant than joins, especially when it allows us to select/ exclude more efficiently than a lengthy join command. In addition, we can fix the problem of duplicates immediately instead of having to patch this using a GROUP BY clause after. 

##### Rules for subqueries

- We are required to give an alias to any derived table we create in subqueries within FROM statements.
- We need to use this alias every time we want to execute a function that uses the derived table.
- Third, aliases used within subqueries CAN refer to tables OUTSIDE of the subqueries. However, outer queries cannot refer to aliases created within subqueries unless those aliases are explicitly part of the subquery output.
- If using LIMIT with derived tables, put the limit in the LEFT derived table. If you put it in the outermost query, the db will still have to hold huge inner derived tables in memory which will make your query slow.

Example: We want a list of each dog a user in the users table owns, with its accompanying breed information whenever possible. 
```sql
SELECT
    clean.user_guid AS uUserID,
    d.user_guid AS dUserID,
    count(*) AS NumDogs
FROM 
    (SELECT DISTINCT u.user_guid
    FROM users u)
    AS clean
LEFT JOIN dogs d
    ON clean.user_guid=d.user_guid
GROUP BY clean.user_guid
ORDER BY NumDogs DESC
```
The query we just wrote extracts the distinct user_guids from the users table first, and then left joins that reduced subset of user_guids on the dogs table. As mentioned at the beginning of the lesson, since the subquery is in the FROM statement, it actually creates a temporary table, called a derived table, that is then incorporated into the rest of the query.

Example: Write a query to retrieve a full list of all the DogIDs a user in the users table owns. Add dog breed and dog weight to the columns that will be included in the final output of your query. In addition, use a HAVING clause to include only UserIDs who would have more than 10 rows in the output of the left join.
```sql
SELECT 
    APPLES.user_guid AS uUserID,
    d.user_guid AS dUserID,
    d.breed,
    d.weight,
    count(*) AS numrows
FROM
    (SELECT DISTINCT u.user_guid
    FROM users u)
    AS APPLES
LEFT JOIN dogs d
    ON APPLES.user_guid=d.user_guid
GROUP BY APPLES.user_guid
HAVING numrows > 10
ORDER BY numrows DESC
```

# OPERATIONS: IF

Can segment queries conditionally using IF, especially if the situation has clear true/false conditions. IF can also be nested into loops. Note on syntax for using : IF 

``` 
IF ( variable = "result", value if true, value if false)
```
Example: Count the number of users in America, and outside America. Output 2 columns with the groups America, Not in America, and the count for each. Exclude all null values.

```sql
SELECT
    IF(cleanedset.country = 'US','In America','Not in America') AS Location,
    COUNT(cleanedset.country) AS 'Number of Users'
FROM
    (SELECT DISTINCT user_guid, country
    FROM users
    WHERE user_guid IS NOT NULL
    AND country IS NOT NULL)
    AS cleanedset
GROUP BY Location;
```
Example: Sort users by early users and late users. Print the total number of users in each group. Early users = those who signed up before 1 June 2014.
```sql
SELECT 
    IF(cleaned_users.first_account<'2014-06-01','early_user','late_user') AS user_type,
    COUNT(cleaned_users.first_account)
FROM 
    (SELECT user_guid,
    MIN(created_at) AS first_account
    FROM users
    GROUP BY user_guid)
    AS cleaned_users
GROUP BY user_type;
```

#### Nested Loop Example
Print all users and their country status.
```sql
SELECT
      IF(cleaned_users.country='US','In US',
           IF(cleaned_users.country='N/A','Not Applicable','Outside US'))
                AS US_user,
    count(cleaned_users.user_guid)
FROM
  (SELECT DISTINCT user_guid, country
  FROM users
  WHERE country IS NOT NULL)
  AS cleaned_users
GROUP BY US_user;
````
Example: For each dog, output its dog ID, breed_type, number of completed tests, and use an IF statement to include an extra column that reads "Pure_Breed" whenever breed_type equals 'Pure Breed" and "Not_Pure_Breed" whenever breed_type equals anything else.
```sql
SELECT DISTINCT
    d.dog_guid AS 'Dog ID',
    IF(d.breed_type="Pure Breed", 'Pure Breed', 'Not Pure Breed') AS 'Breed Type',
    count(c.created_at) AS 'Num Tests Done'
FROM dogs d
     LEFT JOIN complete_tests c
          ON d.dog_guid = c.dog_guid
WHERE d.dog_guid IS NOT NULL
GROUP BY d.dog_guid
ORDER BY count(c.created_at) DESC
LIMIT 50;
```
However, you can see this is not very efficient as the number of conditions increases. For those, it is better to use CASE. 

# OPERATORS: CASE 

Syntax for CASE:
```
SELECT 
apples, 
oranges, 
    CASE 
    WHEN ..... (condition) THEN .... (label) 
    WHEN ..... (condition) THEN .... (label)
    END -- ps: no commas needed within
FROM database 
```
Example: Print cases of users based on their country locations.
```sql
SELECT
    CASE
    WHEN cleaned_users.country="US" THEN "In US"
    WHEN cleaned_users.country="N/A" THEN "Not Applicable"
    ELSE "Outside US"
    END AS US_user,
    count(cleaned_users.user_guid)
FROM
    (SELECT DISTINCT user_guid, country
    FROM users
    WHERE country IS NOT NULL)
    AS cleaned_users
GROUP BY US_user
ORDER BY count(cleaned_users.user_guid);
```
Example: Write a query to present the range of dog's weight in groups, and the number of dogs in each weight group. 
```sql
SELECT
    DISTINCT dog_guid,
    breed,
    weight,
    CASE
    WHEN weight<=0 THEN "very small"
    WHEN weight>10 AND weight<=30 THEN "small"
    WHEN weight>30 AND weight<=50 THEN "medium"
    WHEN weight>50 AND weight<=85 THEN "large"
    WHEN weight>85 THEN "very large"
    END AS Category
FROM dogs
WHERE weight > 0
LIMIT 200;
```
Example: Binary tree question. Find the parent root, inner and leaf nodes.
```sql
SELECT N,
CASE
     WHEN P IS NULL THEN "Root" -- capitsalisation matters inside commas
     WHEN N IN (SELECT P, FROM BST) THEN "Inner"
     ELSE "Leaf"
     END                                                  
FROM BST
ORDER BY N;
```
# OPERATORS: NOT, AND, OR

These operators can be used to make true/false logic statements. They are evaluated in that order: Not, And, Or. This means that any NOT statements will be evaluated first, followed by AND, then OR.

> CASE WHEN "condition 1" OR "condition 2" AND "condition 3"...

will lead to different results than this expression:

> CASE WHEN "condition 3" AND "condition 1" OR "condition 2"...

or this expression:

> CASE WHEN ("condition 1" OR "condition 2") AND "condition 3"...

In the first case you will get rows that meet condition 2 and 3, or condition 1. In the second case you will get rows that meet condition 1 and 3, or condition 2. In the third case, you will get rows that meet condition 1 or 2, and condition 3.

