/* ANSWER KEY: Week 4 Exercise 12 - Practicing Business Queries

This is the COMPLETE answer key (including explanations) for Week 3 of the DUKE UNIVERSITY "Managing Big Data wtih MySQL" course. 
Date created: 18 March 2017

*/

-- BOX 1: LOAD SERVER

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb



-- Qn 1
-- Expected: 200 rows

SELECT created_at, dayofweek(created_at)
FROM complete_tests
LIMIT 50, 200;



-- Qn 2
-- Expected: 200 rows

SELECT created_at, 
CASE 
WHEN dayofweek(created_at)=1 THEN 'Sunday'
WHEN dayofweek(created_at)=2 THEN 'Monday'
WHEN dayofweek(created_at)=3 THEN 'Tuesday'
WHEN dayofweek(created_at)=4 THEN 'Wednesday'
WHEN dayofweek(created_at)=5 THEN 'Thursday'
WHEN dayofweek(created_at)=6 THEN 'Friday'
WHEN dayofweek(created_at)=7 THEN 'Saturday'
END AS Day
FROM complete_tests
LIMIT 50, 200;



-- Qn 3
-- Expected: 33,190 rows

SELECT
CASE 
WHEN dayofweek(created_at)=1 THEN 'Sunday'
WHEN dayofweek(created_at)=2 THEN 'Monday'
WHEN dayofweek(created_at)=3 THEN 'Tuesday'
WHEN dayofweek(created_at)=4 THEN 'Wednesday'
WHEN dayofweek(created_at)=5 THEN 'Thursday'
WHEN dayofweek(created_at)=6 THEN 'Friday'
WHEN dayofweek(created_at)=7 THEN 'Saturday'
END AS Day,
COUNT(created_at) AS 'Number of Tests'
FROM complete_tests
GROUP BY Day
ORDER BY COUNT(created_at) DESC;



-- Qn 4
-- Expected: 7 rows

SELECT
CASE 
WHEN dayofweek(c.created_at)=1 THEN 'Sunday'
WHEN dayofweek(c.created_at)=2 THEN 'Monday'
WHEN dayofweek(c.created_at)=3 THEN 'Tuesday'
WHEN dayofweek(c.created_at)=4 THEN 'Wednesday'
WHEN dayofweek(c.created_at)=5 THEN 'Thursday'
WHEN dayofweek(c.created_at)=6 THEN 'Friday'
WHEN dayofweek(c.created_at)=7 THEN 'Saturday'
END AS Day,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN dogs d
        ON c.dog_guid = d.dog_guid
WHERE (d.exclude = 0 OR d.exclude IS NULL)
GROUP BY Day
ORDER BY count(c.created_at) DESC;



-- Qn 5
-- Expected: 950,331 rows

SELECT d.dog_guid
FROM dogs d
    JOIN users u
        ON d.user_guid = u.user_guid;



-- Qn 6
-- Expected 35,048 rows

SELECT DISTINCT d.dog_guid
FROM dogs d
    JOIN users u
        ON d.user_guid = u.user_guid;



-- Qn 7
-- Expected: 34,121 Rows 

SELECT DISTINCT d.dog_guid
FROM dogs d
    JOIN users u
        ON d.user_guid = u.user_guid
WHERE (d.exclude = 0 OR d.exclude IS NULL)
    AND (u.exclude = 0 OR u.exclude IS NULL);



-- BOX 8
-- Expected: 7 rows

SELECT
CASE 
WHEN dayofweek(c.created_at)=1 THEN 'Sunday'
WHEN dayofweek(c.created_at)=2 THEN 'Monday'
WHEN dayofweek(c.created_at)=3 THEN 'Tuesday'
WHEN dayofweek(c.created_at)=4 THEN 'Wednesday'
WHEN dayofweek(c.created_at)=5 THEN 'Thursday'
WHEN dayofweek(c.created_at)=6 THEN 'Friday'
WHEN dayofweek(c.created_at)=7 THEN 'Saturday'
END AS Day,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN (
        SELECT DISTINCT d.dog_guid
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS cleandogs
            ON c.dog_guid = cleandogs.dog_guid 
GROUP BY Day
ORDER BY count(c.created_at) DESC;



-- Qn 9
-- Expected: 21 rows

SELECT
CASE 
WHEN dayofweek(c.created_at)=1 THEN 'Sunday'
WHEN dayofweek(c.created_at)=2 THEN 'Monday'
WHEN dayofweek(c.created_at)=3 THEN 'Tuesday'
WHEN dayofweek(c.created_at)=4 THEN 'Wednesday'
WHEN dayofweek(c.created_at)=5 THEN 'Thursday'
WHEN dayofweek(c.created_at)=6 THEN 'Friday'
WHEN dayofweek(c.created_at)=7 THEN 'Saturday'
END AS Day,
YEAR(c.created_at) AS Year,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN (
        SELECT DISTINCT d.dog_guid
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS cleandogs
            ON c.dog_guid = cleandogs.dog_guid 
GROUP BY Day, Year
ORDER BY Year ASC, count(c.created_at) DESC;



-- Qn 10
-- Expected: 21 rows (Sunday - 5860)

SELECT
CASE 
WHEN dayofweek(c.created_at)=1 THEN 'Sunday'
WHEN dayofweek(c.created_at)=2 THEN 'Monday'
WHEN dayofweek(c.created_at)=3 THEN 'Tuesday'
WHEN dayofweek(c.created_at)=4 THEN 'Wednesday'
WHEN dayofweek(c.created_at)=5 THEN 'Thursday'
WHEN dayofweek(c.created_at)=6 THEN 'Friday'
WHEN dayofweek(c.created_at)=7 THEN 'Saturday'
END AS Day,
YEAR(c.created_at) AS Year,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN (
        SELECT DISTINCT d.dog_guid,
        u.country,
        u.state
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS cleandogs
            ON c.dog_guid = cleandogs.dog_guid 
WHERE cleandogs.country = 'US' AND cleandogs.state NOT IN ('HI', 'AK')
GROUP BY Day, Year
ORDER BY Year ASC, count(c.created_at) DESC;

-- Qn 11
-- Expected: 100 rows

SELECT created_at, 
DATE_SUB(created_at, INTERVAL 6 HOUR) AS NewTime
FROM complete_tests
LIMIT 100;



-- Qn 12
-- Expected: 21 rows 

SELECT
CASE 
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=1 THEN 'Sunday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=2 THEN 'Monday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=3 THEN 'Tuesday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=4 THEN 'Wednesday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=5 THEN 'Thursday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=6 THEN 'Friday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=7 THEN 'Saturday'
END AS Day,
YEAR(c.created_at) AS Year,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN (
        SELECT DISTINCT d.dog_guid,
        u.country,
        u.state
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS cleandogs
            ON c.dog_guid = cleandogs.dog_guid 
WHERE cleandogs.country = 'US' AND cleandogs.state NOT IN ('HI', 'AK')
GROUP BY Day, Year
ORDER BY Year ASC, count(c.created_at) DESC;



-- Qn 13
-- Expected: 21 rows

SELECT
CASE 
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=1 THEN 'Sunday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=2 THEN 'Monday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=3 THEN 'Tuesday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=4 THEN 'Wednesday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=5 THEN 'Thursday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=6 THEN 'Friday'
WHEN dayofweek(DATE_SUB(c.created_at, INTERVAL 6 HOUR))=7 THEN 'Saturday'
END AS Day,
YEAR(c.created_at) AS Year,
COUNT(c.created_at) AS 'Number of Tests'
FROM complete_tests c
    JOIN (
        SELECT DISTINCT d.dog_guid,
        u.country,
        u.state
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS cleandogs
            ON c.dog_guid = cleandogs.dog_guid 
WHERE cleandogs.country = 'US' AND cleandogs.state NOT IN ('HI', 'AK')
GROUP BY Day, Year
ORDER BY Year ASC, FIELD(Day, 'Monday', 'Tuesday', 
                         'Wednesday', 'Thursday', 'Friday', 
                         'Saturday', 'Sunday'), count(c.created_at) DESC;



-- Qn 14
-- Expected: 5 rows

SELECT
clean.state AS 'State',
COUNT(DISTINCT clean.user_guid) AS 'Number of Users'
FROM complete_tests c 
    JOIN (
        SELECT DISTINCT d.user_guid,
        u.state,
        u.country
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        AND u.country = 'US'
        ) 
        AS clean
GROUP BY 'State'
ORDER BY 'Number of Users' DESC
LIMIT 5;



-- Qn 15
-- Expected: 10 rows

SELECT
clean.country AS 'Country',
clean.state AS 'State',
COUNT(DISTINCT clean.user_guid) AS 'Number of Users'
FROM complete_tests c 
    JOIN (
        SELECT DISTINCT d.user_guid,
        u.state,
        u.country
        FROM dogs d
            JOIN users u
                ON d.user_guid = u.user_guid
        WHERE (d.exclude = 0 OR d.exclude IS NULL)
        AND (u.exclude = 0 OR u.exclude IS NULL)
        ) 
        AS clean
        ON c.dog_guid = clean.dog_guid
GROUP BY 'Country', 'State'
ORDER BY 'Number of Users' DESC;

-- END --
