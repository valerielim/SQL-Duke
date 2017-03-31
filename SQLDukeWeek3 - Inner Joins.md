# Week 3 - JOINS

- Joins are based on cartesian products
- (x, a) (x, b) (y, a) (y, b)
- JOIN works by retrieving data only where the cartesian products match

This document will cover **inner joins**. See next doc for **outer joins**. I'm splitting them into separate docs because I want to include more examples for each type and how to use them. 

# Overview

### Inner Joins

- Only items with exact matching primary keys from both tables will be put into a table
- NULL values can't be matched
- Order of which table joins to which table *does not matter*

### Left / Right Outer Join

- Here, ORDER of join matters.
- Example: LEFT outer join vs RIGHT outer join
- Left (or first) table will have ALL its rows included
- Even NULL values!
- Right (or second) table's items will only be included if they match the chosen key used in the left table
- Rows from the left table who don't have a matching ID in the right, will instead have a NULL value

Extra Notes

- Can switch to RIGHT OUTER JOIN to reverse order of tables (see example below)
- Basically same as reversing the positions of the join. So left and right don't really matter, order matters more.

### Full Outer Join

- ALL rows of both tables are included
- Any row that doesn't have a matching partner is given a NULL value.
- Rarely used (why would anyone want this? jkjk)
- Note: Not all db supper full outer joins, like MySQL. However, PostgreSQL does. Can test this out using the Teradata db! 

### Many to Many Relationships

- Recall example 2.3 of Week 1? While building the "fashion shop" relationship schema, there was a many-to-many relationship, with another table between two big entities as a linking/bridge table. 
- This table had only the foreign keys + primary keys of two tables in various combinations 
- **For many to many, left join 1 & 2 first, then left join the results again to 3.**

Caution: 
- Stick to left outer joins! Right/inner joins would mess up the data by deleting NULL values, since the right table is now the 'primary key'. (example below)
- Beware of duplicates too. Joining three tables a single duplicate (2 rows) across them results in 6 rows. This could quickly get out of hand in a big db. (example below)

### Notes to self before starting (!!!)

- Where possible, clean data before you start
- Try to be aware of table relationships, who has null data, subsets, duplicates etc
- When doing joins, count the number of unique IDs / keys in each table you are joining first. Helps to see which is larger or smaller. Also helps to get reasonable expectation of how the final product should look like. 
- On handling errors:
    - Be aware of duplicates and NULL values (sometimes they exist despite rules)
    - Null values can exist even in the primary key column when the database is young, and the company is desperate for data so they accept any data, even incomplete sets
    - **It is NOT your job to clean this up, or restructure their db -- Instead, just try to make as much business value of the items you have.**
- Start with small data and tables (<10 rows), see if they output what you are expecting
- Double check at beginning! Or you won't even know your results are incorrect

### Reminder: (Proper) Technical Terms

- Table = Relation
- Row = Tuple
- Column/Field = Attribute

# Worked Examples - INNER JOINS

Let's start with an inner join.

- SQL needs to be told which IDs overlap
- SQL needs to be told which is left/right

Example: INNER JOIN 2 TABLES
**Find the total number of reviews, and the average rating given, for EACH dog. Combine information from the Dogs table and the Reviews table:**
```sql
SELECT
    d.dog_guid AS DogID,
    d.user_guid AS UserID,
    AVG(r.rating) AS AvgRating,
    COUNT(r.rating) AS NumRatings
FROM dogs  d, reviews r -- alphabets are its short form
WHERE d.dog_guid=r.dog_guid
    AND d.user_guid=r.user_guid -- repeating this excludes any unmatched IDs
GROUP BY UserID, DogID
ORDER BY AvgRating DESC;
```
Example: INNER JOIN 2 TABLES , CONDITIONAL
**Extract the user_guid, dog_guid, breed, breed_type, and breed_group for all animals who completed the "Yawn Warm-up" game. Join on dog_guid only.**

```sql
SELECT
    c.user_guid,
    c.dog_guid,
    d.breed,
    d.breed_type,
    d.breed_group
FROM complete_tests c, dogs d
WHERE c.dog_guid=d.dog_guid
    AND test_name = "Yawn Warm-up" ;
```
Example: INNER JOIN 3 TABLES
**Join 3 tables to extract the user ID, user's state of residence, user's zip code, dog ID, breed, breed_type, and breed_group for all animals who completed the "Yawn Warm-up" game.**

```sql
SELECT
    d.user_guid AS UserID,
    d.dog_guid AS DogID,
    d.breed,
    d.breed_type,
    d.breed_group,
    u.state,
    u.zip
FROM dogs d, complete_tests c, users u -- inner join so order doesn't matter
WHERE d.dog_guid = c.dog_guid
    AND d.user_guid = u.user_guid
    AND c.test_name = "Yawn Warm-up";
```
Notes: Here, I avoided using c.user_guid to join the tables because user GUID under completed tests is null. I wouldn't have known this if I did not check the tables first. So, always test in small batches! And be prepared to deal with missing data.

Example: INNER JOIN 3 TABLES
**How would you extract the user ID, membership type, and dog ID of all the golden retrievers who completed at least 1 Dognition test (you should get 711 rows)?**
``` sql
SELECT DISTINCT
     u.user_guid,
     u.membership_type,
     d.dog_guid,
     d.breed
FROM complete_tests c, dogs d, users u
WHERE c.dog_guid = d.dog_guid 
     AND d.user_guid = u.user_guid
     AND d.breed = 'Golden Retriever';
```
Example: How many unique Golden Retrievers who live in North Carolina are there in the Dognition database (you should get 30)?

```sql
SELECT DISTINCT
    u.user_guid,
    d.dog_guid,
    d.breed
FROM dogs d, users u
WHERE d.user_guid = u.user_guid
  AND d.breed = 'Golden Retriever'
  AND u.state = 'NC';
```

### NOTE: USING TRADITIONAL SYNTAX

The above syntax is accepted with inner joins, but not with full/left/right outer joins. Instead, a the (traditional) syntax for that would look something like this (below). 

Why do we still have the traditional version when it is longer? Because: 

- With using = signs, WHERE can be saved for other conditions
- Unless otherwise specified, join is understood as INNER join
- If inner join, order doesnt matter
- If outer join, RIGHT joins LEFT in this order

Re-writing the first example using traditional syntax: 
```sql
SELECT 
    d.user_guid AS UserID,
    d.dog_guid AS DogID,
    d.breed,
    d.breed_type,
    d.breed_group
FROM dogs d JOIN complete_tests c -- look here 
  ON c.dog_guid=d.dog_guid -- look here
WHERE test_name='Yawn Warm-up';
```
For the next doc, outer joins will be done using traditional syntax. 

*To be honest, I'm not really sure why Duke university wanted to include the 
non-traditional method in their syllabus when it isn't widely used. I'm including 
it here because it's part of the course.*
