/* ANSWER KEY: Week 3 Exercise 7 - Inner Joins 

This is the COMPLETE answer key (including explanations) for Week 3 of the DUKE UNIVERSITY "Managing Big Data wtih MySQL" course. 


Date created: 15 March 2017


*/

-- BOX 1: LOAD SERVER

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb



-- BOX 2
-- Note: This should throw an error. This is to demonstrate what the error looks like. 

SELECT 
	dog_guid AS DogID, 
	user_guid AS UserID, 
	AVG(rating) AS AvgRating, 
	COUNT(rating) AS NumRatings, 
	breed, breed_group, breed_type
FROM dogs, reviews
GROUP BY user_guid, dog_guid, breed, breed_group, breed_type
HAVING NumRatings >= 10
ORDER BY AvgRating DESC
LIMIT 200;



-- BOX 3
-- Expected: 38 rows

%%sql
SELECT 
	d.dog_guid AS DogID, 
	d.user_guid AS UserID, 
	AVG(r.rating) AS AvgRating, 
	COUNT(r.rating) AS NumRatings, 
	d.breed, 
	d.breed_group, 
	d.breed_type
FROM dogs d, reviews r
WHERE d.dog_guid=r.dog_guid 
	AND d.user_guid=r.user_guid
GROUP BY DogID, d.breed, d.breed_group, d.breed_type
HAVING NumRatings >= 10
ORDER BY AvgRating DESC
LIMIT 200;



-- BOX 4
-- Expected 389 rows

/* IMPORTANT NOTE

There is some discrepancy between what the questions asks, and what it actually wants. As the student mentors have admitted, this question could be better worded. Most of us (including me) got 395 rows the first time. This is the explanation of what went wrong, and how to fix it:

Doing exactly as the question instructs, which is to run the query from BOX 3 without the HAVING and LIMIT clause, most people got 395 rows as their answer. However, the question tells us to expect 389 rows instead. 

What do these answers represent? 

	395 rows is the number of unique DOG IDs common to both the dogs and reviews table.

	389 rows is the number of unique USER IDs common to both the dogs and reviews table. 

Although we are technically right in following the assignment's exact instructions, the instructions themselves were misleading. 

The original purpose of this question was to explore if users who gave a high average surprise rating for their dogs performance were users who tend to have more than one dog of the same breed. Hence, the question should have prompted us to compare on the basis of USERS instead of DOG IDs, but the instructors forgot to tell us we could modify it. 

The correct query to get 389 rows should be:
*/

%%sql
SELECT DISTINCT 
    r.user_guid AS UserID, 
    AVG(r.rating) AS AvgRating, 
    COUNT(r.rating) AS NumRatings
FROM dogs d, reviews r
WHERE d.dog_guid=r.dog_guid 
    AND d.user_guid=r.user_guid
GROUP BY UserID
ORDER BY AvgRating DESC;

/*
Note: The reason for this discrepancy (users vs dogs) is because some users have more than one dog. 
*/



-- BOX 5 QN 1
-- Expected: 5991 (1 row)

%%sql
SELECT COUNT(DISTINCT dog_guid)
FROM reviews



-- BOX 6 QN 2
-- Expected: 5586 (1 row)

%%sql
SELECT COUNT(DISTINCT user_guid)
FROM reviews



-- BOX 7 QN 3
-- Expected: 30967 (1 row)

%%sql
SELECT COUNT(DISTINCT user_guid)
FROM dogs



-- BOX 8 QN 4
-- Expected: 35050 (1 row)

%%sql
SELECT COUNT(DISTINCT dog_guid)
FROM dogs



-- BOX 9
-- Expected: 5589 (1 row)

%%sql
SELECT COUNT(DISTINCT d.user_guid)
  FROM dogs d,
       reviews r 
 WHERE d.user_guid=r.user_guid;

 OR 

-- Expected: 389 (1 row)

%%sql
SELECT COUNT(DISTINCT d.user_guid)
  FROM dogs d,
       reviews r 
 WHERE d.dog_guid=r.dog_guid;



-- BOX 10 QN 5
-- Expected: 20845 rows

%%sql
SELECT 
	c.user_guid, 
	c.dog_guid,
	d.breed,
	d.breed_type,
	d.breed_group
FROM complete_tests c, dogs d
WHERE c.dog_guid=d.dog_guid
	AND test_name = "Yawn Warm-up";



-- BOX 11 QN 6
-- Expected: 711 rows

%%sql
SELECT DISTINCT 
	u.user_guid,
	u.membership_type,
	d.dog_guid, 
	d.breed
FROM complete_tests c, dogs d, users u
WHERE c.dog_guid = d.dog_guid 
    AND d.user_guid = u.user_guid 
    AND d.breed = 'Golden Retriever';



-- BOX 12 QN 7
-- Expected: 30 rows
%%sql
SELECT DISTINCT
    d.dog_guid, 
    d.breed
FROM dogs d, users u
WHERE d.user_guid = u.user_guid
    AND d.breed = "Golden Retriever"
    AND u.state = 'NC';



-- BOX 12 QN 8
-- Expected: 5 rows (first row should be 1, 2900)

%%sql
SELECT
	u.membership_type AS 'Membership Type',
	COUNT(DISTINCT r.user_guid) AS 'Total Reviews'
FROM users u, reviews r
WHERE r.user_guid = u.user_guid
    AND r.rating IS NOT NULL
GROUP BY u.membership_type 
ORDER BY COUNT(r.user_guid) DESC; 



-- BOX 13 QN 9
-- Expected: 5 rows (first row should be 1, 2900)

%%sql
SELECT
	u.membership_type AS 'Membership Type',
	COUNT(DISTINCT r.user_guid) AS 'Total Reviews'
FROM users u, reviews r
WHERE r.user_guid = u.user_guid
    AND r.rating IS NOT NULL
GROUP BY u.membership_type 
ORDER BY COUNT(r.user_guid) DESC; 



-- BOX 14 QN 10
-- Expected: 3 rows (breeds should be mixed, golden retriever, and golden retriever-labrador mix)

%%sql
SELECT
d.breed,
COUNT(sa.script_detail_id)
FROM dogs d, site_activities sa
WHERE d.dog_guid = sa.dog_guid 
    AND sa.script_detail_id IS NOT NULL
GROUP BY d.breed
ORDER BY COUNT(sa.script_detail_id) DESC
LIMIT 3;