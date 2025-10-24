USE crimedatadb;

-- Create Fact and Dim Tables (Crime_Dim created in Crime_Data_Clean file)
CREATE TABLE Date_Dim (
	Date_ID INT PRIMARY KEY,
    Actual_Date Date,
    Year INT,
    Quarter INT,
    Month INT,
    Month_Name VARCHAR(20), 
    Day INT,
    Day_Name VARCHAR(20), 
    Week_Day TINYINT
);

CREATE TABLE Time_Dim(
	Time_ID INT PRIMARY KEY,
    Actual_Time TIME,
    Hour INT, 
    Minute INT,
    Time_12hr VARCHAR(20),
    Hour_12hr_Label VARCHAR(10),
    Hour_12hr INT,
    12hr_Label CHAR(2),
    Part_Of_Day VARCHAR(100)
);

CREATE TABLE Area_Dim (
	Area_ID TINYINT PRIMARY KEY,
	Area_Name VARCHAR(100)
);

CREATE TABLE Location_Dim (
	Location_ID INT AUTO_INCREMENT PRIMARY KEY,
	Location VARCHAR(300), 
    Cross_Street VARCHAR(300),
    Area_ID TINYINT,
    City VARCHAR(20),
    State VARCHAR(20),
    Rpt_Dist_No INT,
    Lat DECIMAL(8, 5),
    Lon DECIMAL(8, 5),
    FOREIGN KEY (Area_ID) REFERENCES Area_Dim(Area_ID)
);

CREATE TABLE Mocodes_Dim (
	Mocode_ID INT PRIMARY KEY,
    Mocode_Desc VARCHAR(300)
);

CREATE TABLE Premis_Dim (
	Premis_ID INT PRIMARY KEY,
    Premis_Desc VARCHAR(300)
);

CREATE TABLE Weapon_Dim (
	Weapon_ID INT PRIMARY KEY,
    Weapon_Desc VARCHAR(300)
);

CREATE TABLE Status_Dim (
	Status_ID CHAR(2) PRIMARY KEY,
    Status_Desc VARCHAR(100)
);

CREATE TABLE Victim_Dim (
	Vict_ID INT AUTO_INCREMENT PRIMARY KEY,
	Vict_Age INT,
    Vict_Sex VARCHAR(15),
    Vict_Descent VARCHAR(100)
);

CREATE TABLE Crime_Data_Fact (
	Dr_No BIGINT PRIMARY KEY,
	Date_Rptd_ID INT,
	Date_OCC_ID INT, 
	Time_OCC_ID INT,
    Location_ID INT,
    Vict_ID INT NULL,
    Premis_ID INT NULL,
    Weapon_ID INT NULL,
    Status_ID CHAR(2) NULL,
    FOREIGN KEY (Date_Rptd_ID) REFERENCES Date_Dim(Date_ID),
    FOREIGN KEY (Date_OCC_ID) REFERENCES Date_Dim(Date_ID),
    FOREIGN KEY (Time_OCC_ID) REFERENCES Time_Dim(Time_ID),
    FOREIGN KEY (Vict_ID) REFERENCES Victim_Dim(Vict_ID),
    FOREIGN KEY (Premis_ID) REFERENCES Premis_Dim(Premis_ID),
    FOREIGN KEY (Weapon_ID) REFERENCES Weapon_Dim(Weapon_ID),
    FOREIGN KEY (Status_ID) REFERENCES Status_Dim(Status_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location_Dim(Location_ID)
);

CREATE TABLE Mocodes_Bridge(
	Dr_No BIGINT,
    Mocode_ID INT,
    PRIMARY KEY(Dr_No, Mocode_ID),
    FOREIGN KEY (Mocode_ID) REFERENCES Mocodes_Dim(Mocode_ID),
    FOREIGN KEY (Dr_No) REFERENCES Crime_Data_Fact(Dr_No)
);

CREATE TABLE Crime_Bridge(
	Dr_No BIGINT,
    Source_Column VARCHAR(20),
    Crm_ID INT,
    PRIMARY KEY(Dr_No, Crm_ID),
    FOREIGN KEY (Dr_No) REFERENCES Crime_Data_Fact(Dr_No),
    FOREIGN KEY (Crm_ID) REFERENCES Crime_Dim(Crm_ID)
);

-- Create procedures to insert into CrimeDataFact and MocodeBridge tables
DELIMITER $$
CREATE PROCEDURE InsertCrimeDataFact(IN ran1 BIGINT, IN ran2 BIGINT)
BEGIN 
    INSERT INTO Crime_Data_Fact(Dr_No, Date_Rptd_ID, Date_OCC_ID, Time_OCC_ID, Vict_ID, Premis_ID, Weapon_ID, Status_ID, Location_ID)
	SELECT 
		cds.Dr_No, 
		cds.Date_Rptd, 
		cds.Date_OCC, 
		cds.Time_OCC, 
		vd.Vict_ID, 
		cds.Premis_Cd, 
		cds.Weapon_Used_Cd, 
		cds.Status,
		ld.Location_ID
	FROM Crime_Data_Staging AS cds 
	LEFT JOIN Victim_Dim AS vd -- Since I generated my own primary key for Victim and Location Dim which cannot be found in the staging table, I need to join both tables in order to include the key in fact 
		ON cds.Vict_Age <=> vd.Vict_Age -- Use NULL_safe equality operator since the values we are joining on have a chance of being NULL
	   AND cds.Vict_Sex <=> vd.Vict_Sex 
	   AND cds.Vict_Descent <=> vd.Vict_Descent
	LEFT JOIN Location_Dim AS ld -- Same goes for Location_Dim ^
		ON cds.Location <=> ld.Location 
	   AND cds.Cross_Street <=> ld.Cross_Street
	   AND cds.Area <=> ld.Area_ID
	   AND cds.Rpt_Dist_No <=> ld.Rpt_Dist_No
	   AND cds.Lat <=> ld.Lat
	   AND cds.Lon <=> ld.Lon
	WHERE Dr_No BETWEEN ran1 AND ran2;
END$$
DELIMITER ; 

DELIMITER $$
CREATE PROCEDURE InsertMocodesBridge(IN ran1 BIGINT, IN ran2 BIGINT)
BEGIN 
    INSERT INTO Mocodes_Bridge (DR_NO, Mocode_ID) 
	WITH RECURSIVE Mocode_Split AS ( -- use recursive cte to split all values in each column to its seperate row
		SELECT 
			DR_NO,
			CAST(TRIM(SUBSTRING_INDEX(Mocodes, ' ', 1)) AS UNSIGNED) AS Mocode, -- extract first mocode
			TRIM(SUBSTRING(Mocodes, LENGTH(SUBSTRING_INDEX(Mocodes, ' ', 1)) + 2)) AS rest -- save the rest that hasnt been split to rest
		FROM  Crime_Data_Staging
		WHERE Mocodes IS NOT NULL AND Mocodes != '' AND Dr_No BETWEEN ran1 AND ran2 -- Only for Dr_No in specifide range from procedure parameters
		UNION ALL
		SELECT 
			DR_NO,
			CAST(TRIM(SUBSTRING_INDEX(rest, ' ', 1)) AS UNSIGNED) AS Mocode, -- repeat process until there are no more mocodes
			TRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ' ', 1)) + 2)) AS rest
		FROM Mocode_Split
		WHERE rest != ''
	)
	SELECT DR_NO, CAST(Mocode AS UNSIGNED) AS Mocode
	FROM Mocode_Split;
END$$
DELIMITER ; 

-- Date_Dim: Use recursive CTE to populate table with dates from 2020-01-01 to 2025-12-31
-- Have to do to year 2025 (even though we excluded the crimes that happened in that year) because some crimes were reported in this year but occured in a previous year
SET SESSION cte_max_recursion_depth = 3000;
INSERT INTO Date_Dim(Date_ID, Actual_Date, Year, Quarter, Month, Month_Name, Day, Day_Name, Week_Day)
WITH RECURSIVE Date_CTE AS (
    SELECT DATE('2020-01-01') AS newDate
    UNION ALL
    SELECT DATE_ADD(newDate, INTERVAL 1 DAY)
    FROM Date_CTE
    WHERE newDate < '2025-12-31'
)
SELECT
    CAST(DATE_FORMAT(newDate, '%Y%m%d') AS UNSIGNED) AS Date_ID,
    newDate AS Actual_Date,
    YEAR(newDate) AS Year,
    QUARTER(newDate) AS Quarter,
    MONTH(newDate) AS Month,
    MONTHNAME(newDate) AS Month_Name,
    DAY(newDate) AS Day,
    DAYNAME(newDate) AS Day_Name,
    (WEEKDAY(newDate) + 1) AS Week_Day
FROM Date_CTE;

-- Time_Dim: Use recursive CTE to populate table with time from 00:00 - 23:59. 
INSERT INTO Time_Dim(Time_ID, Actual_Time, Hour, Minute, Time_12hr, Hour_12hr_Label, Hour_12hr, 12hr_Label, Part_Of_Day)
WITH RECURSIVE Time_CTE AS (
	SELECT 0 AS h, 0 AS m
    UNION ALL 
    SELECT h, m + 1 FROM Time_CTE WHERE m < 59 -- get every minute for every hour
    UNION ALL 
    SELECT h + 1, 0 FROM Time_CTE WHERE h < 23 AND m = 59 -- once minute hits 59, reset to zero and increment hour by one and go back to minute step ^
)
SELECT
	h * 100 + m AS Time_ID,
	CAST(CONCAT(LPAD(h, 2, '0'), ':', LPAD(m, 2, '0')) AS TIME) AS Actual_Time,
    h AS Hour,
    m AS Minute, 
    TIME_FORMAT(CAST(CONCAT(LPAD(h, 2, '0'), ':', LPAD(m, 2, '0')) AS TIME), '%h:%i %p') AS Time_12hr,
    TIME_FORMAT(CAST(CONCAT(LPAD(h, 2, '0'), ':', LPAD(m, 2, '0')) AS TIME), '%l %p') AS Hour_12hr_Label,
    CAST(TIME_FORMAT(CAST(CONCAT(LPAD(h, 2, '0'), ':', LPAD(m, 2, '0')) AS TIME), '%h') AS UNSIGNED) AS Hour_12hr,
    CAST(TIME_FORMAT(CAST(CONCAT(LPAD(h, 2, '0'), ':', LPAD(m, 2, '0')) AS TIME), '%p') AS CHAR) AS 12hr_Label,
    CASE 
		WHEN h BETWEEN 5 AND 11 THEN 'Morning'    
		WHEN h BETWEEN 12 AND 16 THEN 'Afternoon'    
		WHEN h BETWEEN 17 AND 20 THEN 'Evening'      
		WHEN h BETWEEN 21 AND 23 THEN 'Night'        
		WHEN h BETWEEN 0 AND 4 THEN 'Night' 
	END AS Part_Of_Day
FROM Time_CTE;

-- Mocodes_Dim: Insert the list of mocodes with their coresponding description from Mocodes.csv
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Mocodes.csv'
INTO TABLE Mocodes_Dim
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

INSERT INTO Mocodes_Dim(Mocode_ID, Mocode_Desc)  -- Insert Mocodes that are found in some of the crimes but are not inlcuded in Mocodes_Dim (NULL as the description)
WITH RECURSIVE Mocode_Split AS (  -- Unpivot mocodes using recursion
    SELECT 
        DR_NO,
        CAST(TRIM(SUBSTRING_INDEX(Mocodes, ' ', 1)) AS UNSIGNED) AS Mocode,
        TRIM(SUBSTRING(Mocodes, LENGTH(SUBSTRING_INDEX(Mocodes, ' ', 1)) + 2)) AS rest
    FROM Crime_Data_Staging
    WHERE Mocodes IS NOT NULL AND Mocodes != ''
    UNION ALL
    SELECT 
        DR_NO,
        CAST(TRIM(SUBSTRING_INDEX(rest, ' ', 1)) AS UNSIGNED) AS Mocode,
        TRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ' ', 1)) + 2)) AS rest
    FROM Mocode_Split
    WHERE rest != ''
)
SELECT DISTINCT Mocode, NULL
FROM Mocode_Split
WHERE Mocode NOT IN (SELECT Mocode_ID FROM Mocodes_Dim);

-- Area_Dim
INSERT INTO Area_Dim(Area_ID, Area_Name)
SELECT DISTINCT Area, Area_Name
FROM Crime_Data_Staging
WHERE NOT (Area IS NULL AND Area_Name IS NULL);

-- Location_Dim
INSERT INTO Location_Dim(Location, Cross_Street, Area_ID, City, State, Rpt_Dist_No, Lat, Lon)
SELECT DISTINCT Location, Cross_Street, Area, 'Los Angeles' AS City, 'California' AS State, Rpt_Dist_No, Lat, Lon
FROM Crime_Data_Staging
WHERE NOT (Location IS NULL AND Cross_Street IS NULL AND AREA IS NULL AND Rpt_Dist_No IS NULL AND Lat IS NULL AND Lon IS NULL);

-- Crime_Dim
-- Inserted in Crime_Data_Clean File

-- Premis_Dim
INSERT INTO Premis_Dim(Premis_ID, Premis_Desc)
SELECT DISTINCT Premis_Cd, Premis_Desc
FROM Crime_Data_Staging
WHERE NOT (Premis_Cd IS NULL AND Premis_Desc IS NULL);

-- Weapon_Dim
INSERT INTO Weapon_Dim(Weapon_ID, Weapon_Desc)
SELECT DISTINCT Weapon_Used_Cd, Weapon_Desc
FROM Crime_Data_Staging
WHERE NOT (Weapon_Used_Cd IS NULL AND Weapon_Desc IS NULL);

-- Status_Dim
INSERT INTO Status_Dim(Status_ID, Status_Desc)
SELECT DISTINCT Status, Status_Desc
FROM Crime_Data_Staging
WHERE NOT (Status IS NULL AND Status_Desc IS NULL);

-- Victim_Dim
INSERT INTO Victim_Dim(Vict_age, Vict_Sex, Vict_Descent)
SELECT DISTINCT Vict_age, Vict_Sex, Vict_Descent
FROM Crime_Data_Staging
WHERE NOT (Vict_age IS NULL AND Vict_Sex IS NULL AND Vict_Descent IS NULL); 

-- Crime_Data_Fact: Seperated the data into three batches to be able to insert it into fact table
-- Created indexes for dim tables to help speed up the joining process
-- Call procedure to insert the data using the desired range for Dr_No
CREATE INDEX Victim_Idx ON Victim_Dim (Vict_Age, Vict_Sex, Vict_Descent);
CREATE INDEX Location_Idx ON Location_Dim (Location, Cross_Street, Area_ID, Rpt_Dist_No, Lat, Lon);
CALL InsertCrimeDataFact(0, 230000000);
CALL InsertCrimeDataFact(230000001, 240000000);
CALL InsertCrimeDataFact(240000001, 260000000);

-- Mocodes_Bridge: Use recursive CTE to split the list of mocodes for each Dr_No into their own seperate row (in mocodes 
-- Since majority of the records have multiple mocodes this means that the size of the data would greatly increase (From 1M -> ~3M). 
-- Therefore, I seperated the data into four batches using the range of Dr_No and inserted them a batch at a time. 
CALL InsertMocodesBridge(0, 210000000);
CALL InsertMocodesBridge(210000001, 220000000);
CALL InsertMocodesBridge(220000001, 230000000);
CALL InsertMocodesBridge(230000001, 260000000);

-- Crime_Bridge
-- Unpivot and insert to bridge table (Crm_Cds are in correct order now)
INSERT INTO Crime_Bridge 
(SELECT Dr_No, 'Crm_Cd_1' AS Source_Column, Crm_Cd_1 AS Crm_ID FROM Crime_Data_Staging
WHERE Crm_Cd_1 IS NOT NULL 
UNION ALL 
SELECT Dr_No, 'Crm_Cd_2' AS Source_Column, Crm_Cd_2 FROM Crime_Data_Staging
WHERE Crm_Cd_2 IS NOT NULL 
UNION ALL 
SELECT Dr_No, 'Crm_Cd_3' AS Source_Column, Crm_Cd_3 FROM Crime_Data_Staging
WHERE Crm_Cd_3 IS NOT NULL
UNION ALL 
SELECT Dr_No, 'Crm_Cd_4' AS Source_Column, Crm_Cd_4 FROM Crime_Data_Staging
WHERE Crm_Cd_4 IS NOT NULL);
