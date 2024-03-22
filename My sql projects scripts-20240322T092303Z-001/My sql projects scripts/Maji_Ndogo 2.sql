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
USE united_nations;
SELECT 
		Region,
		Sub_region,
		SUM(Est_gdp_in_billions) AS Total_gdp_for_countries
FROM 
		access_to_basic_services
GROUP BY
		 Region, Sub_region
ORDER BY 
		Total_gdp_for_countries DESC;

SELECT 
		Sub_region,
		Land_area,
		Country_name,
		ROUND(Land_area / SUM(Land_area) OVER(PARTITION BY Sub_region) *100,4) 
		AS pct_sub_region_land_use
FROM 
		access_to_basic_services
WHERE 
		Time_period = 2020
	AND Land_area IS NOT NULL
ORDER BY pct_sub_region_land_use;

SELECT
		Sub_region,
		Country_name,
		Time_period,
		Pct_managed_drinking_water_services,
		Pct_managed_sanitation_services,
		Est_gdp_in_billions,
		Est_population_in_millions,
	ROUND(AVG(Est_population_in_millions) OVER (PARTITION BY Sub_region),4) 
	AS Running_average_pop
FROM 
		access_to_basic_services
WHERE
		Est_gdp_in_billions IS NOT NULL;

SELECT
    	Country_name,
    	Time_period,
    	Pct_managed_drinking_water_services,
	RANK() OVER(PARTITION BY Time_period 
	ORDER BY Pct_managed_drinking_water_services ASC)
	AS Water_rank
FROM
    	united_nations.Access_to_Basic_Services;


SELECT
		Country_name,
		Time_period,
		Pct_managed_drinking_water_services,
	LAG(Pct_managed_drinking_water_services) OVER (PARTITION BY Country_name
	ORDER BY Time_period ASC) AS Prev_year_pct_managed_drinking_water_services,
	Pct_managed_drinking_water_services - LAG(Pct_managed_drinking_water_services) 
	OVER (PARTITION BY Country_name
	ORDER BY Time_period ASC) 
	AS ARC_pct_managed_drinking_water_services
FROM
		 united_nations.Access_to_Basic_Services;


/*working with data type conversion using different sql function cast(), 
Convert(), coalesce(), nullif(), isnull(), ifnull()*/
SHOW
    COLUMNS
FROM
    united_nations.Access_to_Basic_Services;
-- coverting the precision in the est_population_in_millions from 11,6 to 6,2
USE united_nations;
SELECT DISTINCT
		 Country_name,
    	Time_period,
    	Est_population_in_millions,
	CAST(Est_population_in_millions AS Decimal (6,2)) 
	AS Est_population_in_millions_2dp
FROM 
		access_to_basic_services;

-- using strings function 
SELECT
		Distinct Country_name,
	RTRIM(LEFT(Country_name, Position('(' IN Country_name)-1)) AS New_extract,
	LENGTH(RTRIM(LEFT(Country_name, Position('(' IN Country_name)-1)))
	AS New_extract_Length
FROM
		united_nations.Access_to_Basic_Services
WHERE
		Country_name LIKE '%(%)%';
----creating customs id from the specified column present in the table
SELECT
		DISTINCT Country_name,
		Time_period,
		Est_population_in_millions,
	CONCAT(
		SUBSTRING(IFNULL(UPPER(Country_name), 'UNKNOWN'),1,4),
		SUBSTRING(IFNULL(Time_period, 'UNKNOWN'),1,4),
		SUBSTRING(IFNULL(Est_population_in_millions, 'UNKNOWN'),-7)
	)
		AS Country_ID
FROM
		united_nations.Access_to_Basic_Services
	ORDER BY Country_ID DESC;

USE united_nations;
SHOW
	columns
FROM 
	access_to_basic_services;

/* categorizing african countries into there respective groups and checking
for there average, minimum and maximum pct_managed_drinking_water_services*/

SELECT 
	CASE
		WHEN Country_name IN ('Angola', 'Botswana', 'Comoros', 'Democratic Republic of Congo', 
								'Eswatini', 'Lesotho', 'Madagascar', 'Malawi', 'Mauritius', 
								'Mozambique','Namibia', 'Seychelles', 'South Africa', 
								'United Republic Tanzania', 'Zambia', 'Zimbabwe')	
			THEN 'SADC'


		WHEN Country_name IN ('Algeria', 'Libya', 'Mauritania', 'Morocco', 
								'Tunisia')
			THEN 'UMA'


		WHEN Country_name IN ('Benin', 'Burkina Faso', 'Cabo Verde', 'Cote d’Ivoire', 
								'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 
								'Liberia', 'Mali', 'Niger', 'Nigeria', 'Senegal', 
								'Sierra Leone', 'Togo')
			THEN 'ECOWAS'					


		ELSE 'Not Classified'
		END AS Regional_economic_community,
		MAX(Pct_managed_drinking_water_services),
		MIN(Pct_managed_drinking_water_services),
		AVG(Pct_managed_drinking_water_services)
FROM 
		united_nations.access_to_basic_services
WHERE Region LIKE '%Africa%'
GROUP BY CASE
		WHEN Country_name IN ('Angola', 'Botswana', 'Comoros', 'Democratic Republic of Congo', 
								'Eswatini', 'Lesotho', 'Madagascar', 'Malawi', 'Mauritius', 
								'Mozambique','Namibia', 'Seychelles', 'South Africa', 
								'United Republic Tanzania', 'Zambia', 'Zimbabwe')	
			THEN 'SADC'


		WHEN Country_name IN ('Algeria', 'Libya', 'Mauritania', 'Morocco', 
								'Tunisia')
			THEN 'UMA'


		WHEN Country_name IN ('Benin', 'Burkina Faso', 'Cabo Verde', 'Cote d’Ivoire', 
								'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 
								'Liberia', 'Mali', 'Niger', 'Nigeria', 'Senegal', 
								'Sierra Leone', 'Togo')
			THEN 'ECOWAS'					


		ELSE 'Not Classified'
		END;
--- using nested if / multiple if condition statement 
SELECT 
	   Region,
       Pct_unemployment,
       IF( (Region = "Central and Southern Asia") AND (Pct_unemployment IS NULL), 19.59,
	    	IF( (Region = "Eastern and South-Eastern Asia") AND (Pct_unemployment IS NULL), 22.64,
				IF( (Region = "Europe and Northern America") AND (Pct_unemployment IS NULL), 24.43,
					IF( (Region = "Latin America and the Caribbean") AND (Pct_unemployment IS NULL), 24.23,
						IF( (Region = "Northern Africa and Western Asia") AND (Pct_unemployment IS NULL), 17.84,
							IF( (Region = "Oceania") AND (Pct_unemployment IS NULL), 4.98,
								IF( (Region = "Sub-Saharan Africa") AND (Pct_unemployment IS NULL), 33.65,	
									Pct_unemployment
								)
							)
						)
					)
				)
			)
	   )												
         AS New_pct_unemployment
FROM 
		united_nations.Access_to_Basic_Services;

/*the idea now is to create a sub table from the general table in our database called access to basic services
so as to reduce data redundancy and for us to have a proper view of the table in other to have proper insight
from the table in our database and we will join the tables all together by modelling them i.e creating
various relationships*/

--- creating a new table into our database from the existing table called geographical_location
CREATE TABLE united_nations.Geographical_Location (
			Country_name VARCHAR(37) PRIMARY KEY,
			Region VARCHAR(45),
			Sub_region VARCHAR(40),
			Land_area NUMERIC(10,2)
);
INSERT INTO united_nations.Geographical_Location (
	Country_name, Region, Sub_region, Land_area
)
SELECT
		Country_name,
		Region,
		Sub_region,
		AVG(Land_area) AS Country_area
FROM
		united_nations.access_to_basic_services
GROUP BY 
		Country_name,
		Region,
		Sub_region;

DROP TABLE united_nations.Geographic_Location;
SELECT *
FROM united_nations.Geographical_Location;

---creating another table called Basic services from the general table called access to basic services
CREATE TABLE united_nations.Basic_Services (
		Country_name VARCHAR(37), 
		Time_period INTEGER, 
		Pct_managed_drinking_water_services NUMERIC(5,2), 
		Pct_managed_sanitation_services NUMERIC(5,2),
		PRIMARY KEY (Country_name, Time_period),
		FOREIGN KEY (Country_name) REFERENCES Geographical_Location(Country_name)
);

CREATE TABLE united_nations.Basic_Services (
  Country_name VARCHAR(37),
  Time_period INTEGER,
  Pct_managed_drinking_water_services NUMERIC(5,2),
  Pct_managed_sanitation_services NUMERIC(5,2),
  PRIMARY KEY (Country_name, Time_period),
  FOREIGN KEY (Country_name) REFERENCES Geographical_Location (Country_name)
);
INSERT INTO united_nations.Basic_Services (Country_name, Time_period, Pct_managed_drinking_water_services,
  		Pct_managed_sanitation_services)
SELECT
		Country_name,
  		Time_period,
  		Pct_managed_drinking_water_services,
  		Pct_managed_sanitation_services
FROM
		united_nations.access_to_basic_services;
--- creating another table called economic indicator from access_to_basic_services
CREATE TABLE united_nations.Economic_indicator (
		Country_name VARCHAR(37),
  		Time_period INTEGER,
  		Est_gdp_in_billions NUMERIC(8,2),
 		Est_population_in_millions NUMERIC(11,6),
  		Pct_unemployment NUMERIC(5,2),
  		PRIMARY KEY (Country_name, Time_period),
  		FOREIGN KEY (Country_name) REFERENCES Geographical_Location (Country_name)
);	
INSERT INTO united_nations.Economic_indicator(Country_name, Time_period, Est_gdp_in_billions,
 		Est_population_in_millions, Pct_unemployment)
SELECT
		Country_name,
		Time_period,
		Est_gdp_in_billions,
		Est_population_in_millions,
		Pct_unemployment
FROM
		united_nations.access_to_basic_services;

---using the left join operator to create back the table we divided 
SELECT
        *
FROM 
        united_nations.Geographical_Location AS geo
LEFT JOIN
        united_nations.Economic_indicator AS eco 
ON geo.Country_name = eco.Country_name
LEFT JOIN
        united_nations.Basic_Services AS bsv
ON geo.Country_name = bsv.Country_name
AND eco.Time_period = bsv.Time_period;

-- using the join operator to fix in null value in the economic indicator table
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 19.59) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Central and Southern Asia' 

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 22.64) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Eastern and South-Eastern Asia'

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 24.43) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE 'Europe and Northern America'

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 24.23) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Latin America and the Caribbean'

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 17.84) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Northern Africa and Western Asia'

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 4.98) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Oceania'

UNION
SELECT 
        loc.Country_name,
        eco.Time_period,
        IFNULL(eco.Pct_unemployment, 33.65) AS percentage_unemployment
FROM united_nations.Geographical_Location AS loc  
LEFT JOIN united_nations.Economic_indicator AS eco
ON loc.Country_name = eco.Country_name
WHERE REGION LIKE '%Sub-Saharan Africa';

--- Working with subqueries
USE united_nations;
SELECT
        Country_name,
        ROUND(Land_area / 
                        (SELECT
                                SUM(Land_area)
                        FROM Geographical_Location
                        WHERE (Sub_region = g.Sub_region) * 100))
                    AS Pct_Land_area
FROM 
        Geographical_Location AS g;                           
---performing subqueries on join operator
SELECT
        geoloc.Country_name,
        geoloc.Land_area,
        geoloc.Sub_region,
    ROUND(geoloc.Land_area / Land_per_region.TotalLandArea)* 100 
    AS Pct_Regional_Landuse
FROM 
        Geographical_Location AS geoloc
JOIN
        (
            SELECT
                Sub_region,
                SUM(Land_area) AS TotalLandArea
        FROM 
                Geographical_Location
        GROUP BY Sub_region
        )
            AS Land_per_region
ON
    geoloc.Sub_region = Land_per_region.Sub_region;
---performing subqueries on from keyword
USE united_nations;
SELECT
        Country_name,
        AVG(Est_gdp_in_billions) AS Avg_GDP,
        AVG(Est_population_in_millions) AS Avg_Population
FROM
    (
        SELECT
                Country_name,
                Est_gdp_in_billions,
                Est_population_in_millions
        FROM
                Economic_Indicator
        WHERE Time_period = 2020 
            AND Pct_unemployment > 5
    ) 
        AS Filtered_Countries
GROUP BY
    Country_name;

                                                                                                                                                                                                                                                                                  
