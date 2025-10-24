CREATE DATABASE IF NOT EXISTS CrimeDatadb;
USE CrimeDatadb;

-- Create table to hold raw data
CREATE TABLE Crime_Data (
    Dr_No BIGINT PRIMARY KEY,
    Date_Rptd VARCHAR(30), 
    Date_OCC VARCHAR(30),
    Time_OCC VARCHAR(10), -- INT
    Area VARCHAR(10), -- TINYINT
    Area_Name VARCHAR(100),
    Rpt_Dist_No VARCHAR(10), -- INT
    Part_1_2 CHAR(2),-- TINYINT
    Crm_Cd VARCHAR(10), -- INT
    Crm_Cd_Desc VARCHAR(300),
    Mocodes VARCHAR(300),
    Vict_Age CHAR(3), -- INT
    Vict_Sex VARCHAR(15),
    Vict_Descent VARCHAR(100),
    Premis_Cd VARCHAR(20), -- INT
    Premis_Desc VARCHAR(300),
    Weapon_Used_Cd VARCHAR(100), -- INT
    Weapon_Desc VARCHAR(300),
    Status CHAR(2),
    Status_Desc VARCHAR(100),
    Crm_Cd_1 VARCHAR(50), -- INT 
    Crm_Cd_2 VARCHAR(50), -- INT
    Crm_Cd_3 VARCHAR(50), -- INT 
    Crm_Cd_4 VARCHAR(50), -- INT 
    Location VARCHAR(300),  
    Cross_Street VARCHAR(300),
    Lat VARCHAR(20), -- DECIMAL
    Lon VARCHAR(20) -- DECIMAL
);

-- Import data into Crime_Data table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Crime_Data_from_2020_to_Present.csv'
INTO TABLE Crime_Data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Create staging table and trim any trailing whitespace
CREATE TABLE Crime_Data_Staging AS
SELECT 
	Dr_No,
    TRIM(Date_Rptd) AS Date_Rptd,
    TRIM(Date_OCC) AS Date_OCC, 
    TRIM(Time_OCC) AS Time_OCC, 
    TRIM(Area) AS Area,
    TRIM(Area_Name) AS Area_Name,
    TRIM(Rpt_Dist_No) AS Rpt_Dist_No,
    TRIM(Part_1_2) AS Part_1_2,
    TRIM(Crm_Cd) AS Crm_Cd,
    TRIM(Crm_Cd_Desc) AS Crm_Cd_Desc,
    TRIM(Mocodes) AS Mocodes,
    TRIM(Vict_Age) AS Vict_Age,
    TRIM(Vict_Sex) AS Vict_Sex,
    TRIM(Vict_Descent) AS Vict_Descent,
    TRIM(Premis_Cd) AS Premis_Cd,
    TRIM(Premis_Desc) AS Premis_Desc,
    TRIM(Weapon_Used_Cd) AS Weapon_Used_Cd, 
    TRIM(Weapon_Desc) AS Weapon_Desc,
    TRIM(Status) AS Status,
    TRIM(Status_Desc) AS Status_Desc,
    TRIM(Crm_Cd_1) AS Crm_Cd_1, 
    TRIM(Crm_Cd_2) AS Crm_Cd_2,
    TRIM(Crm_Cd_3) AS Crm_Cd_3, 
    TRIM(Crm_Cd_4) AS  Crm_Cd_4,
    TRIM(Location) AS Location,
    TRIM(Cross_Street) AS Cross_Street,
    TRIM(Lat) AS Lat,
    TRIM(Lon) AS Lon
FROM Crime_Data;