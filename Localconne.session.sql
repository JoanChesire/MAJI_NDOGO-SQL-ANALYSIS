USE md_water_services;
-- initial query to run is SHOW TABLES. This will give you a list of all the tables in the database
SHOW
TABLES;

-- use location so we can use that killer query, SELECT * but remember to limit it and tell it which table we are looking at.
SELECT
*
FROM location
LIMIT 5;

-- let's look at the visits table.
SELECT
*
FROM visits
LIMIT 5;

-- location_id looks like the primary key  
-- look at the water_source table to see what a 'source' is. Normally "_id" columns are related to another table.


SELECT
*
FROM water_source
LIMIT 5;

SELECT DISTINCT
type_of_water_source
FROM
water_source;

-- Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. How would it feel to queue 8 hours for water?

SELECT 
*
FROM
visits
WHERE 
time_in_queue>500;

SELECT
*
FROM 
water_source
WHERE source_id
IN(
  'AkRu05234224',
  'HaZa21742224',
  'AkLu01628224',
  'SoRu36096224',
  'SoRu37635224',
  'SoRu38776224'
);

-- 4. Assess the quality of water sources

-- The data has assigned a score to each source from 1, being terrible, to 10 for a good, clean water source in a home.
-- The surveyors only made multiple visits to shared taps and did not revisit other types of water sources. 
-- So there should be no records of second visits to locations where there are good water sources, like taps in homes

--  query to find records where the subject_quality_score is 10 -- only looking for home taps -- and where the source was visited a second time

SELECT
*
FROM
water_quality
WHERE
subjective_quality_score = 10 AND visit_count = 2;

-- Investigate pollution issues:

-- We recorded contamination/pollution data for all of the well sources

SELECT
*
FROM
well_pollution;

-- Some of the wells are contaminated with biological contaminants, while others are polluted with an excess of heavy metals and other pollutants. Based on the results, each well was classified as: 

-- Clean, Contaminated: Biological or Contaminated: Chemical. It is important to know this because wells that are polluted with bio- or other contaminants are not safe to drink.
--  It looks like they recorded the source_id of each test, so we can link it to a source, at someplace in Maji Ndogo.

-- The well pollution table, the descriptions are notes taken by scientists as text, so it will be challenging to process it.
-- The biological column is in units of CFU/mL, so it measures how much contamination is in the water. 0 is clean, and anything more than 0.01 is contaminated.
-- Let's check the integrity of the data

-- query that checks if the results is Clean but the biological column is > 0.01

SELECT
* 
FROM
well_pollution

SELECT
*
FROM
well_pollution
WHERE
results ='Clean' AND
biological >0.01;

-- It seems like we have some inconsistencies in how the well statuses are recorded
-- The mistake stems from n the description field for determining the cleanliness of the water.

-- In some cases, if the description field begins with the word “Clean”, the results have been classified as “Clean” in the results column, even thogh the biological column is > 0.01.

--  let's look at the descriptions. We need to identify the records that mistakenly have the word Clean in the description.

SELECT
*
FROM
well_pollution
WHERE
description LIKE 'Clean_%' AND biological>0.01;

-- The query has 38 wrong descriptions

-- The results show two different descriptions that we need to fix:
-- 1.Records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli
-- 2.Records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia

-- Case 1a: Update descriptions that mistakenly mention
-- `Clean Bacteria: E. coli` to `Bacteria: E. coli`

UPDATE
well_pollution
SET
description ='Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';

--  Case 1b: Update the descriptions that mistakenly mention
-- `Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia

UPDATE
well_pollution
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description ='Clean Bacteria: Giardia Lamblia';

UPDATE
well_pollution
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';

-- Test the changes on a copy of the table first.

-- This method is especially useful for creating backup tables or subsets without the need for a separate CREATE TABLE and INSERT INTO statement

CREATE TABLE
md_water_services.well_pollution_copy
AS(
  SELECT
  *
  FROM
  md_water_services.well_pollution
);


UPDATE
well_pollution_copy
SET
description ='Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description ='Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';

--  Check if our errors are fixed using a SELECT query on the well_pollution_copy table:

SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR(results = "Clean"AND biological >0.01);

-- There is No data
--  Drop the table 

DROP TABLE
md_water_services.well_pollution_copy

-- Clustering data to unveil Maji Ndogo's water crisis

-- Cleaning our Data
-- We add email addresses  in the format first_name.last_name@ndogowater.gov
-- The procedure for adding email is as stipulated below 
-- selecting the employee_name column
-- replacing the space with a full stop
-- make it lowercase
-- and stitch it all together

-- #1. Check the employee_name

SELECT
*
FROM
employee LIMIT 5;

-- #2. Remove the space between the first and last names using REPLACE()
-- #3 .use LOWER() with the result we just got 
-- #4. CONCAT() to add the rest of the email address
SELECT
CONCAT(
LOWER(REPLACE(employee_name,' ','.')),'@ndogowater.gov'
)
FROM
employee;

-- UPDATE the email column this time with the email addresses

UPDATE
employee
SET email=CONCAT(
LOWER(REPLACE(employee_name,' ','.')),'@ndogowater.gov'
)

-- Confirm that the email has been set
SELECT
*
FROM
employee LIMIT 5;


-- Often when databases are created and updated, or information is collected from different sources, errors creep in.
-- The phone numbers in the phone_number column, the values are stored as strings.
-- The phone numbers should be 12 characters long, consisting of the plus sign, area code (99)

SELECT
LENGTH(phone_number)
FROM
employee;

-- The phone number has a trailing space at the end .
-- USE TRIM(column) to remove any leading or trailing spaces and then update

UPDATE employee
SET phone_number = RTRIM(phone_number);

SELECT
LENGTH(phone_number)
FROM
employee;

-- We used the RTRIM to remove trailing spaces the updated it thus the length of the phone number column is now 12

-- Honouring the workers .
-- Use the employee table to count how many of our employees live in each town. 

SELECT 
town_name,
COUNT(employee_name)AS num_employees
FROM
employee
GROUP BY town_name;

-- top 3 field surveyors are to be honoured
-- use the COUNT() to count the number of visits and GROUP BY assigned_employee_id then order be the number _of _visits creating in descending order to get the highest.


SELECT
assigned_employee_id,
COUNT(visit_count) AS number_of_visits
FROM
visits
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;

-- Analysing Locations
-- Looking at the location table, let’s focus on the province_name, town_name and location_type to understand where the water sources are in Maji Ndogo.

-- Count the number of records per town

SELECT
town_name,
COUNT(*) AS records_per_town
FROM
location
GROUP BY town_name 
ORDER BY records_per_town DESC;

-- Count of records_per_province

SELECT
province_name,
COUNT(*) AS records_per_province
FROM
location
GROUP BY province_name
ORDER BY records_per_province DESC;

-- From this table it is clear that most of the water sources in the survey are situated in small rural communities.

SELECT
province_name,
town_name,
COUNT(*) AS  records_per_town
FROM 
location
GROUP BY province_name,town_name
ORDER BY province_name ASC, records_per_town DESC;

-- number of records for each location type

SELECT
location_type,
COUNT(*) AS num_sources
FROM
location
GROUP BY location_type
ORDER BY num_sources;

-- We can see that there are more rural sources than urban
-- We will use percentages to make it more relatable

SELECT
23740/(15910 + 23740)*100


-- Insights From the above area 
--   1.Our entire country was properly canvassed, and our dataset represents the situation on the ground.
--   2. 60% of our water sources are in rural communities across Maji Ndogo.

-- Diving into the sources
SELECT
* 
FROM 
water_source;

-- The tabel shows we have access to different water source types and the number of people using each source
-- The table will answer the following
-- 1.  How many people did we survey in total?

SELECT
SUM(number_of_people_served) AS total_num_served
FROM
water_source;

-- #276,628,140 people are served

-- 2. How many wells, taps and rivers are there?

SELECT
type_of_water_source,
COUNT(type_of_water_source)AS number_of_sources
FROM
water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- The number of wells stand out at 17,383. 
-- The results obtained will be useful to  understand how much all of these repairs will cost.

-- 3.  How many people share particular types of water sources on average?
SELECT
type_of_water_source,
Round(AVG(number_of_people_served),0 )AS ave_people_per_source
FROM
water_source
GROUP BY type_of_water_source
ORDER BY ave_people_per_source DESC;


-- These results are telling us that 644 people share a tap_in_home on average
-- The surveyors combined the data of many households together and added this as a single tap record, but each household actually has its own tap
-- In addition to this, there is an average of 6 people living in a home. So 6 people actually share 1 tap (not 644).

-- Calculating the average number of people served by a single instance of each water source type helps us understand the typical capacity or load on a single water source.

-- Calculate the total number of people served by each type of water source in total.

SELECT
  type_of_water_source,
  SUM(number_of_people_served) AS population_served
FROM
  water_source
GROUP BY
  type_of_water_source
ORDER BY population_served DESC;

-- To make it a bit simpler to interpret, let's use percentages
-- Total number of people served #276,628,140 

SELECT
type_of_water_source,
(CAST(SUM(number_of_people_served)AS FLOAT)/276628140.0 * 100) AS percentage_people_per_source
FROM
water_source
GROUP BY type_of_water_source
ORDER BY percentage_people_per_source;


