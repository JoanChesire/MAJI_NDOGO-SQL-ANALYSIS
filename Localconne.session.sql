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
visits,
WHERE
visit_count > 2;


