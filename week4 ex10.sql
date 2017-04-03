/* ANSWER KEY: Week 3 Exercise 7 - Inner Joins 

This is the COMPLETE answer key (including explanations) for Week 3 of the DUKE UNIVERSITY "Managing Big Data wtih MySQL" course. 
Date created: 17 March 2017

*/

-- BOX 1: LOAD SERVER

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb



-- BOX 2, Qn 1
-- Expected: 11 rows

SELECT DISTINCT dimension
FROM dogs;



-- BOX 3, Qn 2
-- Expected: 100 rows

/* Note: This question is rather misleading. The question suggests that a subquery is required, but an inner join will do. 

It's also not obvious whether the question wants you to group by the dog's personality dimensions (as that was the main focus of the preamble), or to produce a report of EVERY dog in the database. As it turns out, they want the latter.

*/

SELECT 
    d.dog_guid AS dogID, 
    d.dimension AS dimension, 
    count(c.created_at) AS numtests
FROM dogs d, complete_tests c
WHERE d.dog_guid=c.dog_guid
GROUP BY dogID
ORDER BY numtests DESC
LIMIT 100; -- feel free to remove this line if you're curious
-- Expected output otherwise: 17986


-- BOX 4, Qn 3
-- Expected: 100 rows

SELECT 
    d.dog_guid AS dogID, 
    d.dimension AS dimension, 
    count(c.created_at) AS numtests
FROM dogs d
    INNER JOIN complete_tests c -- Or just JOIN
        ON d.dog_guid=c.dog_guid
GROUP BY dogID
ORDER BY numtests DESC
LIMIT 100;


-- BOX 5, Qn 4
-- Expected: 11 rows

SELECT 
    indiv_scores.personality, 
    AVG(indiv_scores.testcount)
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.dimension AS personality, 
        count(c.created_at) AS testcount
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.personality;



-- BOX 6, Qn 5

/* The question is not well-worded either. This question asks, "How many unique DogIDs are summarized in the Dognition dimensions labeled 'None' or ''? (You should retrieve values of 13,705 and 71)". However, it expects you to ONLY count unique Dog IDs that have ALSO completed tests. 

A better question would be, "How many unique DOG IDs who have completed at least one test, have Dognition dimensions labelled 'None' or '' ?"

*/

SELECT 
    indiv_scores.personality, 
    count(indiv_scores.dogID)
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.dimension AS personality
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE c.created_at IS NOT NULL
    GROUP BY dogID) 
    AS indiv_scores
WHERE indiv_scores.personality IS NULL 
    OR indiv_scores.personality='' 
GROUP BY indiv_scores.personality;



-- BOX 7, Qn 6
-- Expected (71 rows)

SELECT 
    indiv_scores.dogID,
    indiv_scores.breed,
    indiv_scores.weight,
    indiv_scores.exclude,
    indiv_scores.testcount,
    indiv_scores.Earliest,
    indiv_scores.Latest
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.breed AS breed,
        d.weight AS weight,
        d.exclude AS exclude,
        count(c.created_at) AS testcount,
        min(c.created_at) AS Earliest,
        max(c.created_at) AS Latest
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE c.created_at IS NOT NULL
        AND d.dimension = ''
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.dogID;

-- A shorter version would be: 

SELECT 
        d.dog_guid AS dogID, 
        d.breed AS breed,
        d.weight AS weight,
        d.exclude AS exclude,
        count(c.created_at) AS testcount,
        min(c.created_at) AS Earliest,
        max(c.created_at) AS Latest
FROM dogs d
    INNER JOIN complete_tests c 
        ON d.dog_guid=c.dog_guid
WHERE c.created_at IS NOT NULL
    AND d.dimension = ''
GROUP BY dogID;


-- BOX 8, Qn 7
-- Expected: 9 Rows (ace = 402, charmer = 626)

SELECT 
    indiv_scores.personality, 
    count(indiv_scores.dogID) AS NumDogs,
    AVG(indiv_scores.testcount) AS AvgScore
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.dimension AS personality, 
        count(c.created_at) AS testcount
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE d.dimension IS NOT NULL -- (2)
         AND d.dimension != '' -- (1)
         AND (d.exclude IS NULL OR d.exclude = 0) -- (3)
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.personality;


-- BOX 9

SELECT DISTINCT breed_group
FROM dogs



-- BOX 10, Qn 9
-- Expected: 8816 rows

SELECT 
    d.dog_guid AS 'Dog ID', 
    d.breed, d.weight, d.exclude, 
    MIN(c.created_at) AS 'Earliest Time',
    MAX(c.created_at) AS 'Latest Time',
    count(c.created_at) AS 'Num Tests Done'
FROM dogs d
    JOIN complete_tests c
        ON d.dog_guid = c.dog_guid
WHERE c.created_at IS NOT NULL 
AND d.breed_group IS NULL 
GROUP BY d.dog_guid



-- BOX 11, Qn 10
-- Expected: 9 rows (Herding = 1774)

SELECT 
    indiv_scores.doggroup AS 'Breed Group', 
    count(indiv_scores.dogID) AS 'Num of Dogs',
    AVG(indiv_scores.testcount) AS 'Their Avg Score'
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.breed_group AS doggroup, 
        count(c.created_at) AS testcount
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE d.breed_group IS NOT NULL -- remove
         AND d.breed_group != '' -- remove
         AND (d.exclude IS NULL OR d.exclude = 0) -- (specified by qn)
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.doggroup;

/* *HOUND* breed groups, NOT *toy* breed groups, complete the least tests. Hound groups = 564. Toy groups = 1041.

*/

-- BOX 12, Qn 11
-- Expected: 4 rows

SELECT 
    indiv_scores.doggroup AS 'Breed Group', 
    count(indiv_scores.dogID) AS 'Num of Dogs',
    AVG(indiv_scores.testcount) AS 'Their Avg Score'
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.breed_group AS doggroup, 
        count(c.created_at) AS testcount
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE d.breed_group IN ('Sporting', 'Hound', 'Herding', 'Working')
         AND (d.exclude IS NULL OR d.exclude = 0) -- (specified by qn)
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.doggroup;



-- BOX 13, Qn 12
-- Expected: 4 rows (pure breed = 8865)

SELECT DISTINCT breed_type
FROM dogs



-- BOX 14, Qn 13
-- Expected: 4 rows

SELECT 
    d.breed_type AS 'Breed Type',
    COUNT(DISTINCT d.dog_guid) AS 'Num of dogs',
    COUNT(c.created_at) AS 'Num of tests',
    COUNT(c.created_at)/COUNT(DISTINCT d.dog_guid) AS 'Tests Done per Dog' -- bonus to make relationship clearer
FROM dogs d
    JOIN complete_tests c
        ON d.dog_guid = c.dog_guid
WHERE (d.exclude IS NULL OR d.exclude = '0')
     AND d.breed_type IS NOT NULL 
     AND c.created_at IS NOT NULL
GROUP BY d.breed_type



-- BOX 15, Qn 14
-- Expected: 50 rows

SELECT 
    DISTINCT d.dog_guid AS 'DogID',
    d.breed_type AS 'Breed Type', 
    count(c.created_at) AS 'Completed tests',
    CASE 
    WHEN d.breed_type = 'Pure Breed' THEN "Pure Breed"
    ELSE "Not_Pure_Breed"
    END AS Label
FROM dogs d 
    JOIN complete_tests c
        ON d.dog_guid = c.dog_guid
GROUP BY d.dog_guid 
LIMIT 50; 




-- BOX 16, Qn 15
-- Expected: 2 rows (Not Pure Breed = 8336 IDs)

SELECT 
    cleaned.Label,
    count(distinct cleaned.DogID),
    AVG(cleaned.testcount)
FROM 
    (SELECT 
        DISTINCT d.dog_guid AS DogID,
        d.breed_type AS BreedType, 
        count(c.created_at) AS testcount,
        CASE 
        WHEN d.breed_type = 'Pure Breed' THEN 'Pure Breed'
        ELSE 'Not_Pure_Breed'
        END AS Label
    FROM dogs d 
        JOIN complete_tests c
            ON d.dog_guid = c.dog_guid
    WHERE c.created_at IS NOT NULL
        AND d.breed_type IS NOT NULL 
        AND (d.exclude IS NULL OR d.exclude = '0')
    GROUP BY d.dog_guid)
    AS cleaned
GROUP BY cleaned.Label




-- BOX 17, Qn 16
-- Expected: 8816 rows

-- BOX 18, Qn 17
-- Expected: 9 rows (ace = 5.4896, charmer = 5.1919)

SELECT 
    indiv_scores.personality, 
    count(indiv_scores.dogID) AS NumDogs,
    AVG(indiv_scores.testcount) AS AvgScore,
    STDDEV(indiv_scores.testcount) AS StdDevScore
FROM
    (SELECT 
        d.dog_guid AS dogID, 
        d.dimension AS personality, 
        count(c.created_at) AS testcount
    FROM dogs d
        INNER JOIN complete_tests c 
            ON d.dog_guid=c.dog_guid
    WHERE d.dimension IS NOT NULL -- (2)
         AND d.dimension != '' -- (1)
         AND (d.exclude IS NULL OR d.exclude = 0) -- (3)
    GROUP BY dogID) 
    AS indiv_scores
GROUP BY indiv_scores.personality;



-- BOX 19, Qn 18
-- Expected: 9 rows (cross breed std dv = 13849)

SELECT 
DISTINCT d.breed_type,
AVG(TIMESTAMPDIFF(minute, e.start_time, e.end_time)) AS AvgTime,
STDDEV(TIMESTAMPDIFF(minute, e.start_time, e.end_time)) AS StdDevTime
FROM dogs d 
    JOIN exam_answers e 
        ON d.dog_guid = e.dog_guid
GROUP BY d.breed_type

-- END --