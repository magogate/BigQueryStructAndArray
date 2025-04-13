# BigQueryStructAndArray
How Big Query Struct and Array data types works - how to select, insert and aggregate data when we use these data types in table

## Need
Main purpose of this exercise is to find out following things 
1. How exactly STRUCT and ARRAY data types works in BQ
2. How to use SELECT query on STRUCT & ARRAY data type
3. How to insert default values when table has STRUCT & ARRAY data types
4. How to insert data into another table - when table in SELECT has same data type
5. How to compare 2 tables which has STRUCT & ARRAY data types using EXCEPT DISTINCT 

### 1. How exactly STRUCT & ARRAY data types works in BQ?
#### Step1 - Let's create a table having STRUCT & ARRAY

```
/***
	Create a table with Struct and Array data type
*/
CREATE TABLE x5-qualified-star-w.gogates_gk14c.BigQStructTable  (
  `id` INT64,
  `user_info` STRUCT<
    `name` STRING,
    `age` INT64,
    `mobileNumbers` ARRAY<STRING>
  >,
  `hobbies` ARRAY<STRING>,
  `scores` ARRAY<STRUCT<
    `subject` STRING,
    `value` FLOAT64
  >>
);
```
As you can see here,
1. user_info has STRUCT data type - which intern again has mobileNumbers with ARRAY data type. i.e. STRUCT holding ARRAY
2. hobbies has ARRAY data type
3. scores has ARRAY data type - which again holds STRUCT data type. i.e. Array of STRUCT

Once you create a table - it will looks like below:

![image](https://github.com/user-attachments/assets/a9852061-67d1-4b1a-b28c-6825a267cf9f)

As you can see in image - since user_info is defined as STRUCT - at table level it appeas as a RECORD whereas mobileNumbers inside that is defined as ARRAY - hence, it appears as REPEATED.
Also, hobbies & scores data types are defined as ARRAY - so they appear as REPEATED mode - but only score has type as RECORD since it's defined as STRUCT

Let's insert some records to newly created table
```
 INSERT INTO x5-qualified-star-w.gogates_gk14c.BigQStructTable 
 VALUES
   (1, STRUCT('Mandar', 30,['123','3435']), ['reading', 'hiking'], [STRUCT('math', 95.5), STRUCT('science', 89.0)]),
   (2, STRUCT('Devendra', 25,['']), ['painting', 'traveling'], [STRUCT('english', 92.0), STRUCT('history', 85.5)]);
```

### 2.How to use SELECT query on STRUCT & ARRAY data type
##### Option 1 - Select all cols using *
```
SELECT *
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
```
##### Option 2 - Select all cols by mentioning them specifically
```
SELECT BQ.id
, BQ.user_info
, BQ.hobbies
, BQ.scores
FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
```
##### Option 3 - Select all cols by mentioning their data types i.e. ARRAY or STRUCT specifically
```
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
 FROM x5-qualified-star-w.gogates_gk14c.BigQStructTable BQ
```
We need this way - just in case if we need to modify the existing values in SELECT statement itself.

### 3.How to compare 2 tables which has STRUCT & ARRAY data types using EXCEPT DISTINCT
#### How to compare 2 tables having STRUCT or ARRAY data types?
if you try following - it will error out

![image](https://github.com/user-attachments/assets/cdb50ca5-1742-4c3f-a902-5a7dcea789c9)

This is because - you can simply compare tables having STRUCT data types using EXCEPT DISTINCT

Reason being, data in such tables appeas as STRUCT or OBJECT (something similar to JSON file) - as below

![image](https://github.com/user-attachments/assets/764cfc19-1793-47b5-8817-aadb7d4d59cb)

EXCEPT DISTINCT will work if the data appars as a SINGLE record - not STRUCT or OBJECT.

##### Converting STRUCT or ARRAY data types into a SINGLE record.
So basically, we need to aggregate those records to bring them into single row; and we can do that using following query
```
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
```
OR

```
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
```

Here, as you can see, if columns are defined as STRUCT - it will be easy; just mention STRUCT columns in select as well as at GROUP BY; 
however, if column is of ARRAY type - then in-order to bring them into single row - we need to use ARRAY_TO_STRING function 

![image](https://github.com/user-attachments/assets/f2865b5b-469c-4f37-85ea-c98bd93f7b5e)

As you can see in above image, there are 2 records - and in 2nd record - there are 2 numbers - due to which they are appearing at different levels - hence we can't use EXCEPT DISTINCT here. however, using ARRAY_TO_STRING we can bring them into single record.

![image](https://github.com/user-attachments/assets/0c296081-690b-4c5b-83e2-2fd68d42e6ba)

Next 2 columns - scores.subject & scores.value are little different. They are STRUCT which is inside ARRAY i.e. STRUCT will get repeated as it's defined as an ARRAY.

![image](https://github.com/user-attachments/assets/4ad2bcdc-6b18-4cee-912c-e7ea22b60687)

In order to bring them into single row - we need to select them individually and then again apply ARRAY_TO_STRING

![image](https://github.com/user-attachments/assets/ab5e32aa-a648-46c2-b662-40c8722dcf99)

Now, all records are at same level - let's try to use EXCEPT DISTINCT now

![image](https://github.com/user-attachments/assets/e4d4e54c-6593-43f7-a7f1-9c9cf449fe40)

### 4.How to insert default values when table has STRUCT & ARRAY data types






