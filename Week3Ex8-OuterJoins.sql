/* ANSWER KEY: Week 3 Exercise 7 - Inner Joins 

This is the COMPLETE answer key (including explanations) 
for Week 3 of the DUKE UNIVERSITY "Managing Big Data wtih MySQL" course. 

Date created: 16 March 2017
*/

-- BOX 1: LOAD SERVER

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb



-- BOX 2
-- Expected: 20845 rows

SELECT 
	d.user_guid AS UserID, 
	d.dog_guid AS DogID, 
	d.breed, 
	d.breed_type, 
	d.breed_group

FROM dogs d JOIN complete_tests c
  ON d.dog_guid=c.dog_guid 

AND test_name='Yawn Warm-up';




-- BOX 2
-- Expected: 932 rows

SELECT 
	r.dog_guid AS rDogID, 
	r.user_guid AS rUserID,
	d.dog_guid AS dDogID, 
	d.user_guid AS dUserID, 
	AVG(r.rating) AS AvgRating, 
	COUNT(r.rating) AS NumRatings
FROM dogs d RIGHT JOIN reviews r 
	ON r.dog_guid=d.dog_guid 
	AND r.user_guid=d.user_guid
WHERE r.dog_guid IS NOT NULL
GROUP BY r.dog_guid
HAVING NumRatings >= 10
ORDER BY AvgRating DESC



-- BOX 3
-- Expected: 894 rows

SELECT 
	r.dog_guid AS rDogID, 
	d.dog_guid AS dDogID, 
	r.user_guid AS rUserID, 
	d.user_guid AS dUserID, 
	AVG(r.rating) AS AvgRating, 
	COUNT(r.rating) AS NumRatings
FROM reviews r LEFT JOIN dogs d
	ON r.dog_guid=d.dog_guid 
	AND r.user_guid=d.user_guid
WHERE d.dog_guid IS NULL
GROUP BY r.dog_guid
HAVING NumRatings >= 10
ORDER BY AvgRating DESC;



-- BOX 4
-- Expected: 35050 rows

SELECT 
	d.dog_guid AS dDogID,
	COUNT(c.test_name) AS 'Tests Completed'
FROM dogs d LEFT JOIN complete_tests c
    ON d.dog_guid = c.dog_guid 
WHERE d.dog_guid IS NOT NULL
GROUP BY d.dog_guid
ORDER BY COUNT(c.dog_guid) ASC;



-- BOX 5
-- Expected: 17987 rows

SELECT 
	d.dog_guid AS dDogID,
	COUNT(c.test_name) AS 'Tests Completed'
FROM dogs d LEFT JOIN complete_tests c
    ON d.dog_guid = c.dog_guid 
WHERE d.dog_guid IS NOT NULL
GROUP BY c.dog_guid -- DIFFERENCE! 
ORDER BY COUNT(c.dog_guid) ASC;



-- BOX 6 QN 5
-- Expected: 1 row (17986)

SELECT count(distinct dog_guid)
FROM complete_tests;



-- BOX 7 QN 6
-- Expected: 952557 rows

SELECT 
	u.user_guid, 
	d.user_guid,
	d.dog_guid,
	d.breed,
	d.breed_type,
	d.breed_group
FROM users u LEFT JOIN dogs d
    ON u.user_guid = d.user_guid    



-- BOX 8 QN 7
-- Expected: 33193 rows

SELECT 
	u.user_guid AS uUserID,
	d.user_guid AS dUserID, 
	d.dog_guid AS dDogID,
	d.breed, 
	count(*) AS numrows
FROM users u LEFT JOIN dogs d
    ON u.user_guid = d.user_guid
GROUP BY u.user_guid
ORDER BY numrows DESC;



-- BOX 9 QN 8
-- Expected: 17 rows

SELECT count(user_guid)
from users
where user_guid = 'ce225842-7144-11e5-ba71-058fbc01cf0b'



-- BOX 10 QN 9
-- Expected: 26 rows

SELECT count(user_guid)
from dogs
where user_guid = 'ce225842-7144-11e5-ba71-058fbc01cf0b'


-- BOX 11 QN 10
-- Expected: 2226 rows

SELECT DISTINCT
	u.user_guid AS uUserID,
	d.user_guid AS dUserID
FROM users u LEFT JOIN dogs d
    ON u.user_guid = d.user_guid    
WHERE d.user_guid IS NULL



-- BOX 12 QN 11
-- Expected: 2226 rows

SELECT DISTINCT
u.user_guid AS uUserID,
d.user_guid AS dUserID

FROM dogs d RIGHT JOIN users u
    ON u.user_guid = d.user_guid
    
WHERE d.user_guid IS NULL



-- BOX 13 QN 12
-- Expected: 5833 rows
SELECT DISTINCT 
    sa.dog_guid AS 'Dog ID',
    d.dog_guid AS 'Should be NULL',
    COUNT(sa.dog_guid) AS Times
FROM site_activities sa LEFT JOIN dogs d
    ON sa.user_guid = d.user_guid 
WHERE d.dog_guid IS NULL 
    AND sa.dog_guid IS NOT NULL
GROUP BY sa.dog_guid
ORDER BY Times DESC;
