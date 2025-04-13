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
