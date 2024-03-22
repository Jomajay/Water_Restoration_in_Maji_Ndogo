-- selecting the database and retrieving the auditor's report
USE md_water_services;
SELECT 
        *
FROM 
        auditor_report;

---checking for the difference in scores and if there are any patterns.
SELECT
        location_id,
        true_water_source_score
FROM 
        auditor_report;

--joining auditor_table, water_quaity and visits table use the id columns, true_water_source_score
SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score,
        visits.location_id AS visit_location,
        visits.record_id,
        subjective_quality_score
FROM 
        auditor_report
JOIN
        visits
ON auditor_report.location_id = visits.location_id
JOIN 
        water_quality
ON visits.record_id = water_quality.record_id;
--- dropping the location_id column and renaming other columns.
SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id, 
        subjective_quality_score AS employee_score
FROM 
        auditor_report
JOIN
        visits
ON auditor_report.location_id = visits.location_id
JOIN 
        water_quality
ON visits.record_id = water_quality.record_id
-- checking if the auditor_score and employee_score
SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id, 
        subjective_quality_score AS employee_score
FROM 
        auditor_report
JOIN
        visits
ON auditor_report.location_id = visits.location_id
JOIN 
        water_quality
ON visits.record_id = water_quality.record_id
WHERE true_water_source_score = subjective_quality_score;
----filtering out the visit_count with more than 1 visit
SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id, 
        subjective_quality_score AS employee_score
FROM 
        auditor_report
JOIN
        visits
ON auditor_report.location_id = visits.location_id
JOIN 
        water_quality
ON 
        visits.record_id = water_quality.record_id
WHERE  
        true_water_source_score = subjective_quality_score
    AND 
        visits.visit_count = 1;    
--- checking for those records that has, more than one visit counts.
SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id, 
        subjective_quality_score AS employee_score,
        auditor_report.type_of_water_source AS auditor_source,
        water_source.type_of_water_source AS survey_source
FROM 
        auditor_report
JOIN
        visits
ON auditor_report.location_id = visits.location_id
JOIN 
        water_quality
ON 
        visits.record_id = water_quality.record_id
JOIN 
        water_source
ON
        visits.source_id = water_source.source_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1;

---Once you're done, remove the columns and JOIN statement for water_sources again
--- with auditor_score.
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    auditor_report.type_of_water_source AS auditor_source
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1;

---Once you're done, remove the columns and JOIN statement for water_sources again
--- without auditor_score.
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1;

--assigning employee id to the 6% wrong visit_count to see who the employees are 
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1;

---assigning employee name to employee id
SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id,
    employee.employee_name
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1;

---creating a cte table for employee
WITH 
        Incorrect_record
    AS
    (SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id, 
        subjective_quality_score AS employee_score,
        visits.assigned_employee_id,
        employee.employee_name
FROM 
        auditor_report
JOIN
        visits
ON 
    auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON 
    visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1
    )
SELECT
        * 
FROM
        Incorrect_record;

---selecting distinct for the employee to count for the number of employee
WITH 
    Incorrect_records
            AS
        (SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id,
    employee.employee_name
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1)
SELECT 
        COUNT(DISTINCT employee_name)  AS number_of_employee
FROM 
        Incorrect_records;

---Using the distinct syntax to count for the number of employee so as to count for 
---each employee's mistakes
WITH 
    Incorrect_records
            AS
        (SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id,
    employee.employee_name
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1)
SELECT 
        employee_name,
        COUNT(employee_name)  AS number_of_mistakes
FROM 
        Incorrect_records
GROUP BY
        employee_name;
/*remaining our previous query as error_count and find the average of the error for
each employee and sorting to know the empolyee with the highest number of error.*/
WITH 
    Incorrect_records
            AS
        (SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id,
    employee.employee_name
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1)
SELECT 
        employee_name,
        COUNT(employee_name)  AS error_count
FROM 
        Incorrect_records
GROUP BY
        employee_name
ORDER BY error_count DESC;
/*---creating view to create a new table on our database called Incorrect record.
CREATE VIEW
        Wrong_record
    AS
        (WITH 
    Incorrect_records
            AS
        (SELECT
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score AS auditor_score,
    visits.record_id, 
    subjective_quality_score AS employee_score,
    visits.assigned_employee_id,
    employee.employee_name
FROM 
    auditor_report
JOIN
    visits
ON auditor_report.location_id = visits.location_id
JOIN 
    water_quality
ON visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id 
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
    AND visits.visit_count = 1)
SELECT 
        employee_name,
        COUNT(employee_name)  AS error_count
FROM 
        Incorrect_records
GROUP BY
        employee_name
);

--- retrieving the new table incomplete records
SELECT 
        *
FROM
        Wrong_record;
---Calculating for the average error_count for the employee
SELECT
        employee_name,
        AVG(error_count)  AS avg_error_count_per_empl
FROM
        Wrong_record
GROUP BY employee_name;

SELECT
        employee_name,
        error_count
FROM
        Wrong_record
WHERE
        error_count > (
    SELECT
            
            AVG(error_count)  AS avg_error_count_per_empl
    FROM
            Wrong_record
);*/
---dropping the two views we created
DROP VIEW Wrong_record;
DROP VIEW Incorrect_record;
--creating a new view called incorrect_record
CREATE VIEW 
        Incorrect_records AS (
SELECT
        auditor_report.location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score,
        auditor_report.statements AS statements
FROM
        auditor_report
JOIN
        visits
ON 
        auditor_report.location_id = visits.location_id
JOIN
        water_quality AS wq
ON 
        visits.record_id = wq.record_id
JOIN
        employee
ON 
        employee.assigned_employee_id = visits.assigned_employee_id
WHERE
        visits.visit_count =1
AND 
        auditor_report.true_water_source_score != wq.subjective_quality_score);
---retrieving the data in the incorrect_records
SELECT
        *
FROM
        md_water_services.Incorrect_records;

WITH 
        error_count 
    AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
FROM
        Incorrect_records
GROUP BY
        employee_name)
-- Query
SELECT * FROM error_count;

--average mistake count
WITH 
        error_count 
    AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
FROM
        Incorrect_records
GROUP BY
        employee_name)
SELECT
        AVG(number_of_mistakes)
FROM 
        error_count;
-- checking for the employee that has more than the average number of mistake
M

/*creating suspect list for employee whose number of mistakes are greater that the 
average number od mistakes using CTE*/
WITH 
	suspect_list AS (WITH error_count AS (
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY 
	employee_name)
SELECT
	employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (
							SELECT
							AVG(number_of_mistakes)
							FROM 
							error_count))
SELECT
	employee_name 
FROM 
	suspect_list;
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
        record_id,
        employee_name,
        statements
FROM
        incorrect_records
WHERE
        employee_name IN ('Bello Azibo', 'Zuriel Matembo', 'Malachi Mavuso', 
        'Lalitha Kaburi' 
        
);

--subqueries to filter the suspect list 
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different */
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location_id,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);
---filtering out records with cash in the statement
SELECT  
        employee_name,
        statements
FROM
        incorrect_records
WHERE
        employee_name IN ('Bello Azibo', 'Zuriel Matembo', 'Malachi Mavuso', 
        'Lalitha Kaburi') 
AND statements LIKE '%cash%'        
;


----mcq questions
SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    Empl_Table.employee_name,
    auditorRep.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS employee_score
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id;


suspect_list AS (
    SELECT ec1.employee_name, ec1.number_of_mistakes
    FROM error_count AS ec1
    WHERE ec1.number_of_mistakes >= (
        SELECT AVG(ec2.number_of_mistakes)
        FROM error_count AS ec2
        WHERE ec2.employee_name = ec1.employee_name));


SELECT
auditorRep.location_id,
visitsTbl.record_id,
auditorRep.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS employee_score,
wq.subjective_quality_score - auditorRep.true_water_source_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
WHERE (wq.subjective_quality_score - auditorRep.true_water_source_score) > 9;