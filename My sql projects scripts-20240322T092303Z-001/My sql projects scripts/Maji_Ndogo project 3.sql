# using the use function 2
USE md_water_services;
SELECT 
	CONCAT(
    LOWER(REPLACE(employee_name, ' ','.')), '@ndogowater.gov') AS new_email
FROM employee;

# setting and updating the existing table with the email column.
SET SQL_SAFE_UPDATES = 0;

UPDATE
	employee
SET 
email = CONCAT(
    LOWER(REPLACE(employee_name, ' ','.')), '@ndogowater.gov');

# Checking for the length of the phone_column and trimming out the unnecessary space then updating the whole table 
SELECT
	LENGTH(phone_number)
FROM employee;

SELECT 
TRIM(phone_number)
FROM employee;

UPDATE 
	employee
SET 
	phone_number = TRIM(phone_number);
SELECT *
FROM 
 employee;
 
 #counting how many employees that lives in each cities using the count function

SELECT DISTINCT town_name,
COUNT(assigned_employee_id) AS num_employees
FROM
	employee
GROUP BY town_name;
 
# looking at the number of records each employee collected
SELECT 
	assigned_employee_id,COUNT(*) AS number_of_visit
FROM 
	visits
GROUP BY 
	assigned_employee_id;

# checking for the top 3 employee with the highest visit 
SELECT 
	assigned_employee_id,
    employee_name,
    email,
    phone_number
FROM
	employee
WHERE assigned_employee_id IN ('1', '30', '34')
;
  
# retrieving the location table
SELECT
	*
FROM
	location;

# Query that counts the number of records per town
SELECT
	town_name,
    COUNT(location_type) AS records_per_town
FROM location
GROUP BY town_name;

# query that counts number of records per province
SELECT 
	province_name,
    COUNT(province_name) AS record_per_province
FROM 
	location
GROUP BY
	province_name;

# creating a result set to show the province_name, town_name and aggregate_per_town then order by DESC province_name
SELECT 
	province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
	 location
GROUP BY 
	province_name,
	town_name
ORDER BY 
	province_name DESC;

# Query for numbers of records for each location type
SELECT 
	location_type,
    COUNT(location_type) AS number_of_records
FROM
	location
GROUP BY location_type;

# getting the number of records for water source in percentages
SELECT 
(23740 / (15910 + 23740)) * 100 AS Pct_Rural,
(15910 / (15910 + 23740)) * 100 AS Pct_Urban;

# DIVING INTO THE SOURCES
# Retrieving the water_source table to see how structure the table 
SELECT 
	*
FROM 
	 water_source;

# how many people did we survey in total
SELECT 
	SUM(number_of_people_served) AS total_people_survey
FROM water_source;

SELECT 
	type_of_water_source,
    COUNT(number_of_people_served) AS total_people_served
FROM 
	water_source
GROUP BY 
	type_of_water_source
ORDER BY total_people_served DESC;

# how many wells, taps and rivers are there?
SELECT 
	type_of_water_source,
    COUNT(number_of_people_served) AS number_of_sources
FROM 
	water_source
GROUP BY 
	type_of_water_source;

# average people with a particular types of water source
SELECT 
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS avg_people_to_water_source
FROM 
	water_source
GROUP BY
	type_of_water_source
ORDER BY 
	avg_people_to_water_source;

# number of people getting water from each type of source
SELECT 
	type_of_water_source,
    SUM(number_of_people_served) AS Total_number_of_people
FROM 
	water_source
GROUP BY
	type_of_water_source
ORDER BY 
	Total_number_of_people DESC;

# number of people in percentages getting water from each type of source
SELECT 
	type_of_water_source,
	SUM(number_of_people_served) AS total_people_served,
	ROUND((SUM(number_of_people_served) / (SELECT SUM(number_of_people_served)
FROM water_source))*100,0) AS pct_served
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY
	total_people_served DESC;
    
# Start of a solution
# using window function to remove people with best source
SELECT 
	type_of_water_source,
    total_people_served,
    RANK() OVER (ORDER BY total_people_served DESC) AS rank_by_population
	FROM(
	SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served
FROM
	water_source
GROUP BY
	type_of_water_source
    ) AS Subquery
ORDER BY 
	total_people_served DESC;

#using rank function
SELECT 
	source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS number_of_people_served,
RANK() OVER(
PARTITION BY type_of_water_source 
ORDER BY SUM(number_of_people_served)
DESC) AS priority_rank
FROM
	water_source
GROUP BY
	source_id, type_of_water_source;

# using dense rank
SELECT 
	source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS number_of_people_served,
DENSE_RANK() OVER(
PARTITION BY type_of_water_source 
ORDER BY SUM(number_of_people_served)
DESC) AS priority_rank
FROM
	water_source
GROUP BY
	source_id, type_of_water_source;

# Using row number
SELECT 
	source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS number_of_people_served,
ROW_NUMBER() OVER(
PARTITION BY type_of_water_source 
ORDER BY SUM(number_of_people_served)
DESC) AS priority_rank
FROM
	water_source
GROUP BY
	source_id, type_of_water_source;
    
# Analysing queues
# looking at the information we have from the previous queries, we can use some DateTime function here to get some deeper insight into the queueing
# situation in Maji Ndogo, like which day of the week it was, and what time.
# How long did the survey take?
SELECT 
	DATEDIFF(MAX(Time_of_record), MIN(Time_of_record)) AS Survey_Duration_In_Days
FROM
	visits;
    
# What day of the week had the most visits?
SELECT
	DAYOFWEEK(Time_of_record) AS Day_of_Week,
    COUNT(*) AS Visits_Count
FROM 
	visits
GROUP BY
	Day_Of_Week
ORDER BY
	Visits_Count DESC
LIMIT 1;

# What is the average time spent in the-queue?
SELECT
	AVG(time_in_queue) AS Average_Time_in_Queue
 FROM 
	visits;


# Working on the united_nations database and querying the access to basic services table
	USE united_nations;
# Retrieving all the columns and data in the access to basic access_to_basic_services table
	SELECT 
		* 
	FROM
		access_to_basic_services
	LIMIT 5
	;
# Counting all the entries in the table access_to_basic_services
SELECT 
		COUNT(*) AS Total_entries
FROM
			access_to_basic_services;
# checking for the earliest and the latest date on the time period column.
SELECT 
		MAX(Time_period) AS Latest_year,
		MIN(Time_period) AS Earliest_year
FROM
		access_to_basic_services;

# What is the minimum, maximum, and average percentage
# of people that have access to managed drinking water services per region and sub_region?
SELECT 
		Region,
		Sub_region,
		MIN(Pct_managed_drinking_water_services) AS min_pct_managed_drinking_water_services,
		MAX(Pct_managed_drinking_water_services) AS max_pct_managed_drinking_water_services,
		AVG(Pct_managed_drinking_water_services) AS ave_pct_managed_drinking_water_services,
		COUNT(DISTINCT Country_name) AS Number_of_country,
		SUM(Est_gdp_in_billions) AS Total_gdp_for_countries
FROM
		access_to_basic_services
WHERE 
		Time_period = 2020
AND
		Pct_managed_drinking_water_services < 60
GROUP BY
		Region, Sub_region
HAVING
		Number_of_country < 4
ORDER BY 
		Total_gdp_for_countries DESC;

# What is the number of countries within each region and sub_region?
SELECT 
		Region,
		Sub_region,
		COUNT(DISTINCT Country_name) AS Number_of_country
FROM
		access_to_basic_services
GROUP BY
		Region, Sub_region;

# What is the total GDP for each region and sub_region?
SELECT 
		Region,
		Sub_region,
		SUM(Est_gdp_in_billions) AS Total_gdp_for_countries
FROM 
		united_nations.access_to_basic_services
GROUP BY
		 Region, Sub_region
ORDER BY 
		Total_gdp_for_countries DESC;

--working with cte and subquery
USE united_nations;
SELECT	
		Region,
		Country_name,
		Pct_managed_drinking_water_services,
		Pct_managed_sanitation_services,
		Est_gdp_in_billions,
	AVG(Est_gdp_in_billions) OVER(PARTITION BY Region) AS avg_gdp_region
FROM
		access_to_basic_services
WHERE
		Region = 'Sub-Saharan Africa'
    AND Time_period = 2020
    AND Pct_managed_drinking_water_services < 60
HAVING	
		Est_gdp_in_billions < avg_gdp_region;