/***
	Create a table with Struct and Array data type
*/
CREATE TABLE x5-qualified-star-w.gogates_gk14c.BigQStructTable  (
  `id` INT64,
  `user_info` STRUCT<
    `name` STRING,
    `age` INT64,
	mobileNumbers ARRAY<STRING>
  >,
  `hobbies` ARRAY<STRING>,
  `scores` ARRAY<STRUCT<
    `subject` STRING,
    `value` FLOAT64
  >>
);

/****
	Inserts records into newly created table
**/


-- INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable 
-- VALUES
--   (1, STRUCT('John', 30,['123','3435']), ['reading', 'hiking'], [STRUCT('math', 95.5), STRUCT('science', 89.0)]),
--   (2, STRUCT('Jane', 25,['']), ['painting', 'traveling'], [STRUCT('english', 92.0), STRUCT('history', 85.5)]);

/****
	Once inserted - how to select the records?
*/
--Way1
	SELECT *
	FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ

--Way2
	SELECT BQ.id
	, BQ.user_info
	, BQ.hobbies
	, BQ.scores
	FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ

--Way3
SELECT BQ.id
, STRUCT(
    BQ.user_info.name
  , BQ.user_info.age
  , BQ.user_info.mobileNumbers
)AS UI
, BQ.hobbies
, ARRAY(
        SELECT STRUCT(
            Score.subject
           ,CAST(Score.value AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub
, STRUCT(
    '' AS name
  , CAST(NULL AS INT64) AS age
  , ARRAY(SELECT '') AS mobileNumbers
)AS UI2
, ARRAY( SELECT('')) as hobbies2
, ARRAY(
        SELECT STRUCT(
            '' AS subject
           ,CAST(NULL AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub2
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ

/***
	Since it's a structed data - we can't compare it using EXCEPT DISTINCT
	If we wanted to compare - we need to get the data into single row
	how do we do that?
**/

--Way1
SELECT BQ.id
, BQ.user_info.name
, BQ.user_info.age
, ARRAY_TO_STRING(BQ.user_info.mobileNumbers, ", ") AS mobileNumbers
, ARRAY_TO_STRING(BQ.hobbies, ", ") AS hobbies
, ARRAY_TO_STRING(ARRAY(SELECT (scores.subject) FROM UNNEST(scores) scores),", ") AS Sub
, ARRAY_TO_STRING(ARRAY(SELECT CAST(scores.value AS STRING) FROM UNNEST(scores) scores),", ") AS Val
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
GROUP BY BQ.id, BQ.user_info.name, BQ.user_info.age, BQ.user_info.mobileNumbers, BQ.hobbies
,BQ.scores

--OR 

--Way2
SELECT BQ.id
, BQ.user_info.name
, BQ.user_info.age
, ARRAY_TO_STRING(BQ.user_info.mobileNumbers, ", ") AS mobileNumbers
, ARRAY_TO_STRING(BQ.hobbies, ", ") AS hobbies
, ARRAY_TO_STRING(ARRAY(SELECT (scores.subject) FROM UNNEST(scores) scores),", ") AS Sub
, ARRAY_TO_STRING(ARRAY(SELECT CAST(scores.value AS STRING) FROM UNNEST(scores) scores),", ") AS Val
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
GROUP BY ALL

---Basically here, Struct data type can be compared easily
---as we can select the individual struct column 
---		however, if a column is defined as an array 
---		we need to get that indiviual column as array 
---		and then using array_to_string - need to convert it as shown above


/**
	Except Distinct
**/

--following query should return 0 records
SELECT BQ.id
, BQ.user_info.name
, BQ.user_info.age
, ARRAY_TO_STRING(BQ.user_info.mobileNumbers, ", ") AS mobileNumbers
, ARRAY_TO_STRING(BQ.hobbies, ", ") AS hobbies
, ARRAY_TO_STRING(ARRAY(SELECT (scores.subject) FROM UNNEST(scores) scores),", ") AS Sub
, ARRAY_TO_STRING(ARRAY(SELECT CAST(scores.value AS STRING) FROM UNNEST(scores) scores),", ") AS Val
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
GROUP BY ALL
EXCEPT DISTINCT
SELECT BQ.id
, BQ.user_info.name
, BQ.user_info.age
, ARRAY_TO_STRING(BQ.user_info.mobileNumbers, ", ") AS mobileNumbers
, ARRAY_TO_STRING(BQ.hobbies, ", ") AS hobbies
, ARRAY_TO_STRING(ARRAY(SELECT (scores.subject) FROM UNNEST(scores) scores),", ") AS Sub
, ARRAY_TO_STRING(ARRAY(SELECT CAST(scores.value AS STRING) FROM UNNEST(scores) scores),", ") AS Val
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
GROUP BY ALL

/****
	Inserting default values for Struct and Array datatype
*/

/**
	Create a new table for that with same struct
	just add 2 more columns having same structure
*/
CREATE TABLE x5-qualified-star-w.gogates_gk14c.BigQStructTable2 (
  `id` INT64,
  `user_info` STRUCT<
    `name` STRING,
    `age` INT64,
    mobileNumbers ARRAY<STRING>
  >,
  `hobbies` ARRAY<STRING>,
  `scores` ARRAY<STRUCT<
    `subject` STRING,
    `value` FLOAT64
    >
  >,
  `user_info2` STRUCT<
    `name` STRING,
    `age` INT64,
    mobileNumbers ARRAY<STRING>
  >,
  `hobbies2` ARRAY<STRING>,
  `scores2` ARRAY<STRUCT<
    `subject` STRING,
    `value` FLOAT64
    >
  >
);

/****
	Insert queries
	There are multiple ways
*/

--Way1
/***
	Last 3 columns - doesnt exists in table from which we are quering from
		UI2
		hobbies2
		scores2
	That's why - we had to define the data type for default values
	i.e. For Struct and Array we have defined STRUCT() or ARRAY(SELECT '')
	Also, for Int or Flot datatype - we have to specify CAST with corresponding datatype
*/
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.id
, BQ.user_info
, BQ.hobbies
, BQ.scores
, STRUCT(
    '' AS name
  , CAST(NULL AS INT64) AS age
  , ARRAY(SELECT '') AS mobileNumbers
)AS UI2
, ARRAY( SELECT('')) as hobbies2
, ARRAY(
        SELECT STRUCT(
            '' AS subject
           ,CAST(NULL AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS scores2
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ


--Way2
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.id
, STRUCT(
    BQ.user_info.name
  , BQ.user_info.age
  , BQ.user_info.mobileNumbers
)AS UI
, BQ.hobbies
, ARRAY(
        SELECT STRUCT(
            Score.subject
           ,CAST(Score.value AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub
, STRUCT(
    '' AS name
  , CAST(NULL AS INT64) AS age
  , ARRAY(SELECT '') AS mobileNumbers
)AS UI2
, ARRAY( SELECT('')) as hobbies2
, ARRAY(
        SELECT STRUCT(
            '' AS subject
           ,CAST(NULL AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub2
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ

--Way3
/***
	Now, Last 3 columns - "doest" exists in table from which we are quering from
		UI2
		hobbies2
		scores2
	Since these columns exists - it has it's datatypes as well created
	, so we don't need to mention these datatypes again 
	, and can simple use column names instead
*/
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.id
, BQ.user_info
, BQ.hobbies
, BQ.scores
, BQ.user_info2
, BQ.hobbies2
, BQ.scores2
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable2 BQ

OR

--Since the columns are same - just add *
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.*
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable2 BQ


--Way4
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.id
, STRUCT(
    BQ.user_info.name
  , BQ.user_info.age
  , BQ.user_info.mobileNumbers
)AS UI
, BQ.hobbies
, ARRAY(
        SELECT STRUCT(
            Score.subject
           ,CAST(Score.value AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub
, STRUCT(
    BQ.user_info2.name
  , BQ.user_info2.age
  , BQ.user_info2.mobileNumbers
)AS UI2
, BQ.hobbies2
, ARRAY(
        SELECT STRUCT(
            Score2.subject
           ,CAST(Score2.value AS FLOAT64) AS value
        )FROM UNNEST(scores2) Score2
 ) AS Sub
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable2 BQ


--Way5
INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable2
SELECT BQ.id
, STRUCT(
    BQ.user_info.name
  , BQ.user_info.age
  , BQ.user_info.mobileNumbers
)AS UI
, BQ.hobbies
, ARRAY(
        SELECT STRUCT(
            Score.subject
           ,CAST(Score.value AS FLOAT64) AS value
        )FROM UNNEST(scores) Score
 ) AS Sub
, STRUCT(
    BQ.user_info2.name
  , BQ.user_info2.age
  , BQ.user_info2.mobileNumbers
)AS UI2
, BQ.hobbies2
, ARRAY(
        SELECT STRUCT(
            Score2.subject
           ,Score2.value AS value-- you don't need to cast; but even cast will work
        )FROM UNNEST(scores2) Score2
 ) AS Sub
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable2 BQ

-----------------



SELECT BQ.id
, BQ.user_info.name
, BQ.user_info.age
, ARRAY_TO_STRING(BQ.user_info.mobileNumbers, ", ") AS mobileNumbers
, ARRAY_TO_STRING(BQ.hobbies, ", ") AS hobbies
, ARRAY_TO_STRING(ARRAY(SELECT (scores.subject) FROM UNNEST(scores) scores),", ") AS Sub
, ARRAY_TO_STRING(ARRAY(SELECT CAST(scores.value AS STRING) FROM UNNEST(scores) scores),", ") AS Val
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
GROUP BY BQ.id, BQ.user_info.name, BQ.user_info.age, BQ.user_info.mobileNumbers, BQ.hobbies
,BQ.scores


