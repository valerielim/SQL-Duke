/* ANSWER KEY: Week 3 Exercise 9 - Subqueries & Derived Tables

This is the COMPLETE answer key (including explanations) 
for Week 3 of the DUKE UNIVERSITY "Managing Big Data wtih MySQL" course. 

Date created: 17 March 2017
*/

-- BOX 1: LOAD SERVER

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb



-- BOX 2
-- Expected: 1 row (9934)

SELECT AVG(TIMESTAMPDIFF(minute,start_time,end_time))
FROM exam_answers 
WHERE TIMESTAMPDIFF(minute,start_time,end_time) > 0
AND test_name = 'Yawn Warm-Up';




-- BOX 3
-- Expected: 11059 rows

SELECT * 
FROM exam_answers
WHERE TIMESTAMPDIFF(minute,start_time,end_time) >
    (
    SELECT AVG(TIMESTAMPDIFF(minute,start_time,end_time))
    FROM exam_answers 
    WHERE TIMESTAMPDIFF(minute,start_time,end_time) > 0
    AND test_name = 'Yawn Warm-Up'
    );


-- BOX 4
-- Expected: 1 rows (163022)

SELECT count(*)
FROM exam_answers
WHERE subcategory_name IN ("Puzzles", "Numerosity", "Bark Game");



-- BOX 5
-- Expected: 1 rows (7961)

SELECT count(distinct dog_guid)
FROM dogs
WHERE breed_group NOT IN ("Working", "Sporting", "Herding")



-- BOX 6
-- Expected: 2226 rows

SELECT DISTINCT u.user_guid
FROM users u
WHERE NOT EXISTS
    (SELECT d.user_guid
    FROM dogs d
    WHERE u.user_guid = d.user_guid);



-- BOX 7
-- Expected: 33193 rows

SELECT 
	clean.user_guid AS uUserID, 
	d.user_guid AS dUserID, 
	count(*) AS numrows
FROM 
    (SELECT DISTINCT u.user_guid 
    FROM users u) 
    AS clean
LEFT JOIN dogs d
   ON clean.user_guid=d.user_guid
GROUP BY clean.user_guid
ORDER BY numrows DESC



-- BOX 8
-- Expected: Note the type of error message

SELECT 
	u.user_guid AS uUserID, 
	d.user_guid AS dUserID, 
	count(*) AS numrows

FROM 
    (SELECT DISTINCT u.user_guid 
    FROM users u) 
    AS DistinctUUsersID 

LEFT JOIN dogs d
   ON DistinctUUsersID.user_guid=d.user_guid

GROUP BY DistinctUUsersID.user_guid
ORDER BY numrows DESC



-- BOX 9 QN 6
-- Expected: 10254 rows

SELECT distinct
	d.dog_guid,
	d.breed_group,
	u.state,
	u.zip
FROM dogs d, users u
WHERE d.user_guid = u.user_guid 
    AND breed_group IN ('Working', 'Sporting', 'Herding')



-- BOX 10
-- Expected: 10254 rows

SELECT distinct
	d.dog_guid,
	d.breed_group,
	u.state,
	u.zip
FROM dogs d JOIN users u
    ON d.user_guid = u.user_guid 
WHERE breed_group IN ('Working', 'Sporting', 'Herding')



-- BOX 11 Qn 8
-- Expected: 2 rows

SELECT d.user_guid
FROM dogs d
WHERE NOT EXISTS
    (SELECT DISTINCT u.user_guid
    FROM users u
    WHERE d.user_guid = u.user_guid);



-- BOX 12
-- Expected: 1 rows (1819)

SELECT 
    DistinctUUsersID.user_guid AS uUserID, 
    d.user_guid AS dUserID, 
    count(*) AS numrows
FROM (SELECT DISTINCT u.user_guid 
     FROM users u
     WHERE user_guid = 'ce7b75bc-7144-11e5-ba71-058fbc01cf0b') 
     AS DistinctUUsersID 
LEFT JOIN dogs d
  ON DistinctUUsersID.user_guid=d.user_guid
GROUP BY DistinctUUsersID.user_guid
ORDER BY numrows DESC;



-- BOX 13
-- Expected: 30968 rows

SELECT DISTINCT d.user_guid
FROM d.dogs



-- BOX 14 QN 11
-- Expected: 1 rows

SELECT 
    APPLES.user_guid AS uUserID, 
    ORANGES.user_guid AS dUserID, 
    count(*) AS numrows
FROM 
	(SELECT DISTINCT u.user_guid 
    FROM users u
    WHERE user_guid = 'ce7b75bc-7144-11e5-ba71-058fbc01cf0b') 
    AS APPLES
	LEFT JOIN 
	    (SELECT DISTINCT d.user_guid
	    FROM dogs d) 
	    AS ORANGES
	    	ON APPLES.user_guid=ORANGES.user_guid
GROUP BY APPLES.user_guid
ORDER BY numrows DESC;



-- BOX 15 QN 12
-- Expected: 100 rows

SELECT 
    APPLES.user_guid AS uUserID, 
    ORANGES.user_guid AS dUserID, 
    count(*) AS numrows
FROM 
	(SELECT DISTINCT u.user_guid 
    FROM users u
    LIMIT 100) 
    AS APPLES
	LEFT JOIN 
	    (SELECT DISTINCT d.user_guid
	    FROM dogs d) 
	    AS ORANGES
    		ON APPLES.user_guid=ORANGES.user_guid
GROUP BY APPLES.user_guid
ORDER BY numrows DESC;



-- BOX 16 QN 13
-- Expected: 5 rows (shih tzu, 190, 1819)

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
ORDER BY numrows DESC;
