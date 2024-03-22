---creating a new table by using columns from visits, water source and location table
SELECT
        location.location_id,
        province_name,
        town_name,
        visits.visit_count,
        type_of_water_source,
        number_of_people_served
FROM
        location
JOIN
        visits
    ON
        visits.location_id = location.location_id
JOIN    
        water_source
    ON 
        visits.source_id = water_source.source_id
---filtering location_id AkHa00103 to check for visit_count > 1
WHERE visits.location_id = 'AkHa00103';
--- query to return single visits for every visit_count.
SELECT
        location.location_id,
        province_name,
        town_name,
        visits.visit_count,
        type_of_water_source,
        number_of_people_served
FROM
        location
JOIN
        visits
    ON
        visits.location_id = location.location_id
JOIN    
        water_source
    ON 
        visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;
/* now since we've verified that our tables are joined correctly, we can now remove the
location_id and visit count column */
SELECT
        province_name,
        town_name,
        type_of_water_source,
        number_of_people_served
FROM
        location
JOIN
        visits
    ON
        visits.location_id = location.location_id
JOIN    
        water_source
    ON 
        visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;
--adding the location type column and time in queue to our existing table.
SELECT
        location_type,
        time_in_queue,
        province_name,
        town_name,
        type_of_water_source,
        number_of_people_served
FROM
        location
JOIN
        visits
    ON
        visits.location_id = location.location_id
JOIN    
        water_source
    ON 
        visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;
---adding the result column on our water pollution table and join water  pollution to our previous
---query using left join and inner join
SELECT
        province_name,
        town_name,
        type_of_water_source,
        number_of_people_served,
        location_type,
        time_in_queue,
        well_pollution.results
FROM
        visits
LEFT JOIN
        well_pollution
    ON
        visits.source_id = well_pollution.source_id
   INNER JOIN
location
    ON location.location_id = visits.location_id
INNER JOIN
        water_source
    ON 
        water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;
--This view assembles data from different tables into one to simplify analysis by creating view
CREATE VIEW combined_analysis_table AS
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

---- retrieve data in our combined_analysis_table
SELECT 
        *
FROM
        combined_analysis_table;
----getting the percentage for each water source
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;
---retriving the cte table we created
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT 
        *
FROM 
        province_totals;
---aggregating different water source by province
WITH town_totals AS (-- This CTE calculates the population of each town--
--- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN --Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

---Due to the complexity of the last query we can create a temporary table which will help us to 
---access the result of the query by access the table using the syntax 'CREATE TEMPORARY TABLE'
CREATE TEMPORARY TABLE total_aggregate_water_access
WITH town_totals AS (-- This CTE calculates the population of each town--
--- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN --Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;
---Test running the temporary table created by retrieving all the data in it using the wildcard
SELECT 
        *
FROM
total_aggregate_water_access;
---checking for the which town has the highest ratio of people who have taps, 
---but have no running water
SELECT
        province_name,
        town_name,
        ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home)*100,0)
    AS pct_broken_taps
FROM
        total_aggregate_water_access
ORDER BY pct_broken_taps DESC;

-- creatind a project table called project list to showcase where our teams want to work on
CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON 
                UPDATE CASCADE, 
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);

SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' 
        AND well_pollution.results IS NOT NULL AND well_pollution.results !='Clean'));
    
    ----QUERY to fill in Improvement Column for Contaminated biological and chemical
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    visits.time_in_queue,
 CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        ELSE NULL
    END AS Improvement
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' 
        AND well_pollution.results IS NOT NULL AND well_pollution.results !='Clean'));

---QUERY to Add Drill well to the Improvements column for all river sources
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    visits.time_in_queue,
 CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
		WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        ELSE NULL
    END AS 
		Improvement
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' 
        AND well_pollution.results IS NOT NULL AND well_pollution.results !='Clean'));
----QUERY to Add a case statement to our query updating broken taps to Diagnose local infrastructure. 
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    visits.time_in_queue,
  CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
		WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'tap_in_home_broken'THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS 
		Improvement

FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' 
        AND well_pollution.results IS NOT NULL AND well_pollution.results !='Clean'));
----QUERY to update the Improvement column for shared_taps with long queue times
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    visits.time_in_queue,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN 
            CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
		WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        ELSE NULL
    END AS 
		Improvement
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' 
        AND well_pollution.results IS NOT NULL AND well_pollution.results !='Clean'));
---QUERY to Populate the Project_progress table with the results of your query
INSERT INTO Project_progress (
    source_id,
    Address,
    Town,
    Province,
    Source_type,
    Improvement
)
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN 
            CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
        ELSE NULL
    END
FROM
    water_source
LEFT JOIN
    well_pollution 
    ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits 
    ON water_source.source_id = visits.source_id
INNER JOIN
    location 
    ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' AND well_pollution.results 
        IS NOT NULL AND well_pollution.results != 'Clean')
        OR water_source.type_of_water_source IN ('river', 'tap_in_home_broken')
    );
---Final query
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    visits.time_in_queue,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
		WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN 
            CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
		WHEN water_source.type_of_water_source = 'tap_in_home_broken'THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS 
		Improvement
FROM
    water_source
LEFT JOIN
    well_pollution 
    ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits 
    ON water_source.source_id = visits.source_id
INNER JOIN
    location 
    ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
        OR (water_source.type_of_water_source = 'well' AND well_pollution.results 
        IS NOT NULL AND well_pollution.results != 'Clean')
        OR water_source.type_of_water_source IN ('river', 'tap_in_home_broken'));



SELECT
project_progress.Project_id, 
project_progress.Town, 
project_progress.Province, 
project_progress.Source_type, 
project_progress.Improvement,
Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;