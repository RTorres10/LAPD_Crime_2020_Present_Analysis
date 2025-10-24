USE crimedatadb;

-- Duplicates (Records with identical attributes but different Dr_No)
-- Possible duplicate crimes kept intentionally to preserve original dataset (further explanation in README file).

-- Replace any empty values with NULL in all columns
UPDATE Crime_Data_Staging 
SET Date_Rptd = NULLIF(Date_Rptd, ''), Date_OCC = NULLIF(Date_OCC, ''),
	Time_OCC = NULLIF(Time_OCC, ''), Area = NULLIF(Area, ''), Area_Name = NULLIF(Area_Name, ''),
    Rpt_Dist_No = NULLIF(Rpt_Dist_No, ''), Part_1_2 = NULLIF(Part_1_2, ''), 
    Crm_Cd = NULLIF(Crm_Cd, ''), Crm_Cd_Desc = NULLIF(Crm_Cd_Desc, ''), 
    Mocodes = NULLIF(Mocodes, ''), Vict_Age = NULLIF(Vict_Age, ''),
    Vict_Sex = NULLIF(Vict_Sex, ''), Vict_Descent = NULLIF(Vict_Descent, ''),
	Premis_CD = NULLIF(Premis_Cd, ''), Premis_Desc = NULLIF(Premis_Desc, ''),
    Weapon_Used_Cd = NULLIF(Weapon_Used_Cd, ''), Weapon_Desc = NULLIF(Weapon_Desc, ''),
    Status = NULLIF(Status, ''), Status_Desc = NULLIF(Status_Desc, ''),
	Crm_Cd_1 = NULLIF(Crm_Cd_1, ''), Crm_Cd_2 = NULLIF(Crm_Cd_2, ''),
    Crm_Cd_3 = NULLIF(Crm_Cd_3, ''), Crm_Cd_4 = NULLIF(Crm_Cd_4, ''),
    Location = NULLIF(Location, ''), Cross_Street = NULLIF(Cross_Street, ''),
    Lat = NULLIF(Lat, ''), Lon = NULLIF(Lon, '');
    
-- Change the column data types to the correct ones
ALTER TABLE Crime_Data_Staging
	MODIFY COLUMN Time_OCC INT,
    MODIFY COLUMN Area TINYINT,
    MODIFY COLUMN Rpt_Dist_No INT,
    MODIFY COLUMN Part_1_2 TINYINT,
    MODIFY COLUMN Crm_Cd INT,
    MODIFY COLUMN Vict_Age INT,
	MODIFY COLUMN Premis_CD INT,
    MODIFY COLUMN Weapon_Used_Cd INT,
    MODIFY COLUMN Crm_Cd_1 INT,
    MODIFY COLUMN Crm_Cd_2 INT,
    MODIFY COLUMN Crm_Cd_3 INT,
	MODIFY COLUMN Crm_Cd_4 INT,
    MODIFY COLUMN Lat DECIMAL(8, 5),
    MODIFY COLUMN Lon DECIMAL(8, 5);

-- Remove 2024–2025 rows since LAPD switched to a new reporting system in 2024.
-- The data for these years is incomplete and inconsistent when comparing the data from 2020-2023.
DELETE FROM Crime_Data_Staging
WHERE YEAR(STR_TO_DATE(Date_OCC, '%m/%d/%Y %r')) = 2024 OR YEAR(STR_TO_DATE(Date_OCC, '%m/%d/%Y %r')) = 2025;

-- Update the date time column to DATE datatype. Want it as integer so I can use it as a FK to Date_Dim
UPDATE Crime_Data_Staging
SET Date_Rptd = REPLACE(DATE(STR_TO_DATE(Date_Rptd, '%m/%d/%Y %r')), '-', ''),
	Date_OCC  = REPLACE(DATE(STR_TO_DATE(Date_OCC, '%m/%d/%Y %r')), '-', '');
    
ALTER TABLE Crime_Data_Staging 
	MODIFY COLUMN Date_Rptd BIGINT,
	MODIFY COLUMN Date_OCC BIGINT;
 
-- Crm_Cd_Desc: Capitalize fist letter only & address other issues
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = CONCAT(UPPER(SUBSTRING(Crm_Cd_Desc, 1, 1)), LOWER(SUBSTRING(Crm_Cd_Desc, 2)));
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REGEXP_REPLACE(Crm_Cd_Desc, '\\s*-\\s*', ' - '))
WHERE Crm_Cd_Desc REGEXP '\\s*-\\s*';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REGEXP_REPLACE(Crm_Cd_Desc, ',\\s*', ', '))
WHERE Crm_Cd_Desc REGEXP ',\\s*';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ' / ', '/'))
WHERE Crm_Cd_Desc like '% / %';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ' (see 300 w.i.c.)', ''))
WHERE Crm_Cd_Desc like '%(see 300%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REGEXP_REPLACE(Crm_Cd_Desc, '\\(firearms [^)]*\\)', ''))
WHERE Crm_Cd_Desc REGEXP '\\(firearms [^)]*\\)';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc,' (dwoc)', ''))
WHERE Crm_Cd_Desc LIKE '%(dwoc)%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, '(inc mutual consent, penetration w/ frgn obj', ' (includes mutual consent, penetration w/ foreign objects)'))
WHERE Crm_Cd_Desc LIKE '%frgn obj%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, 'pers to anus oth', 'person to anus (other)'))
WHERE Crm_Cd_Desc LIKE '%pers to%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ', over $950.01', ' ($950.01 & over)'))
WHERE Crm_Cd_Desc LIKE '%, over%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(Replace(Crm_Cd_Desc, ', $950 & under', ' ($950 & under)'))
WHERE Crm_Cd_Desc LIKE '%, $950 &%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = CONCAT(Crm_Cd_Desc, ')')
WHERE Crm_Cd_Desc LIKE '% under';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ', crime against nature sexual asslt with anim', ''))
WHERE Crm_Cd_Desc LIKE '%beast%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ', grand', ' - grand'))
WHERE Crm_Cd_Desc like '%, grand%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ', petty', ' - petty'))
WHERE Crm_Cd_Desc like '%, petty%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, ', attempt', ' - attempt'))
WHERE Crm_Cd_Desc like '%, attempt%';
UPDATE Crime_Data_Staging
SET Crm_Cd_Desc = TRIM(REPLACE(Crm_Cd_Desc, 'excpt, guns, fowl, livestk, prod', ' except, guns, fowl, livestock, produce'))
WHERE Crm_Cd_Desc LIKE '%excpt%';

-- Vict_Age: Replace any age <= 0 with NULL
-- Ages recorded as 0 can be ambiguous as some may represent infants while others also indicate unknown values
-- Replace all 0s with NULL to avoid any false data since I don't know its true meaning
UPDATE Crime_Data_Staging
SET Vict_Age = NULL 
WHERE Vict_Age <= 0;

-- Vict_Sex: Replace Sex abbreviation with full meaning and replace any empty/unknown values with NULL
-- Actual meanings for victim sex and descent came from https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8/about_data
UPDATE Crime_Data_Staging
SET Vict_Sex = 
	case 
		when vict_sex = "M" THEN "Male" 
		when vict_sex = "F" THEN "Female"
		ELSE NULL -- Replace X (Unknown with NULL)
    END;

-- Vict_Descent: Replace descent abbreviation with full meaning and replaced empty/unkown values with NULL
-- Actual meanings found at https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8/about_data
UPDATE Crime_Data_Staging
SET Vict_Descent =
	CASE 
		WHEN Vict_Descent = 'A' THEN 'Other Asian'
        WHEN Vict_Descent = 'B' THEN 'Black'
        WHEN Vict_Descent = 'C' THEN 'Chinese'
        WHEN Vict_Descent = 'D' THEN 'Cambodian'
        WHEN Vict_Descent = 'F' THEN 'Filipino'
        WHEN Vict_Descent = 'G' THEN 'Guamanian'
        WHEN Vict_Descent = 'H' THEN 'Hispanic/Latin/Mexican'
        WHEN Vict_Descent = 'I' THEN 'American Indian/Alaskan Native'
        WHEN Vict_Descent = 'J' THEN 'Japanese'
        WHEN Vict_Descent = 'K' THEN 'Korean'
        WHEN Vict_Descent = 'L' THEN 'Laotian'
        WHEN Vict_Descent = 'O' THEN 'Other'
        WHEN Vict_Descent = 'P' THEN 'Pacific Islander'
        WHEN Vict_Descent = 'S' THEN 'Samoan'
        WHEN Vict_Descent = 'U' THEN 'Hawaiian'
        WHEN Vict_Descent = 'V' THEN 'Vietnamese'
        WHEN Vict_Descent = 'W' THEN 'White'
        WHEN Vict_Descent = 'Z' THEN 'Asian Indian'
        ELSE NULL
    END;

-- Premis_Desc: Capitalize the first letter only & address other issues
UPDATE Crime_Data_Staging
SET Premis_Desc = CONCAT(UPPER(SUBSTRING(premis_desc, 1, 1)), LOWER(SUBSTRING(premis_desc, 2)));
UPDATE Crime_Data_Staging
SET Premis_CD = NULL,
	Premis_Desc = NULL 
WHERE Premis_Desc LIKE '%Retired%'; -- Premis_cd was retired (not being used anymore, set Crm_ID 803, 805 to NULL)
UPDATE Crime_Data_Staging
SET Premis_Desc = TRIM(REPLACE(Premis_Desc, '*', ''))
WHERE Premis_Desc LIKE '%*%'; 
UPDATE Crime_Data_Staging
SET Premis_Desc = TRIM(REGEXP_REPLACE(Premis_Desc, '\\(.*\\)', ''))
WHERE Premis_Desc REGEXP '\\(.*\\)'; 
UPDATE Crime_Data_Staging
SET Premis_Desc = TRIM(REGEXP_REPLACE(Premis_Desc, '\\(.*', ''))
WHERE Premis_Desc REGEXP '\\(.*'; 
UPDATE Crime_Data_Staging
SET Premis_Desc = TRIM(REGEXP_REPLACE(Premis_Desc, 'mta', 'MTA')) -- Fix further capitilization in PBI
WHERE Premis_Desc LIKE '%mta%';

-- Weapon_Desc: Capitalize first letter only & address other issues
UPDATE Crime_Data_Staging
SET Weapon_Desc = CONCAT(UPPER(SUBSTRING(Weapon_Desc, 1, 1)), LOWER(SUBSTRING(Weapon_Desc, 2)));
UPDATE Crime_Data_Staging
SET Weapon_Desc = TRIM(REPLACE(Weapon_Desc, '/uzi/ak47/etc', ' (uzi/ak-47/etc)'))
WHERE Weapon_Desc LIKE '%47%';
UPDATE Crime_Data_Staging
SET Weapon_Desc = TRIM(REPLACE(Weapon_Desc, 'semiautomatic', 'semi-automatic'))
WHERE Weapon_Desc LIKE '%semiautomatic%';
UPDATE Crime_Data_Staging
SET Weapon_Desc = TRIM(REPLACE(Weapon_Desc, 'Unk ', 'Unknown '))
WHERE Weapon_Desc LIKE '%Unk %';
UPDATE Crime_Data_Staging
SET Weapon_Desc = TRIM(REPLACE(Weapon_Desc, '6inches', '6 inches'))
WHERE Weapon_Desc LIKE '%6inches%';

-- Status_Desc: Replace any value marked as 'UNK' to NULL & Juv -> Juvenile
UPDATE Crime_Data_Staging
SET Status_Desc = 
	CASE 
		WHEN Status_Desc = 'UNK' THEN NULL 
        WHEN Status_Desc REGEXP 'Juv' THEN REGEXP_REPLACE(Status_Desc, 'Juv', 'Juvenile')
        Else Status_Desc
	END;

-- Crm_Cd_1-4: Fix order of Crm_Cd columns as some are in the incorrect order (severe codes in the front (crm_cd_1) and crimes less severe towards end (crm_cd_2-4))
-- Create Crime_Dim table using Crm_Cd column as well as Part_1_2 column in order to know every crimes severity so we can properly order (part 1 -> most severe / part 2 -> less severe)
-- As the columns are being reordered, crm_cd column is suppose to be identical to crm_cd_1 (crm_cd_1 must be the most severe as well as match crm_cd)
CREATE TABLE Crime_Dim (
	Crm_ID INT PRIMARY KEY,
    Crm_Desc VARCHAR(300),
    Crm_Category VARCHAR(80),
    Part_1_2 INT
);
INSERT INTO Crime_Dim(Crm_ID, Crm_Desc, Crm_Category, Part_1_2)
SELECT DISTINCT 
	Crm_cd, 
    Crm_Cd_Desc, 
    CASE 
		WHEN Crm_Cd IN (110, 113) THEN "Homocide"
        WHEN Crm_Cd IN (121, 122, 815, 820, 821) THEN "Rape"
        WHEN Crm_Cd IN (210, 220) THEN "Robery"
        WHEN Crm_Cd IN (230, 231, 235, 236, 250, 251, 761, 926) THEN "Aggravated Assault"
        WHEN Crm_Cd IN (435, 436, 437, 622, 623, 624, 625, 626, 627, 647, 763, 928, 930) THEN "Simple Assault"
        WHEN Crm_Cd IN (310, 320) THEN "Burglary"
        WHEN Crm_Cd IN (510, 520, 433, 430, 431, 433) THEN "Motor Vehicle Theft (GTA)"
        WHEN Crm_Cd IN (330, 331, 410, 420, 421) THEN "Burglary (Theft from Vehicle)"
        WHEN Crm_Cd IN (350, 351, 352, 353, 450, 451, 452, 453) THEN "Personal Theft"
        WHEN Crm_Cd IN (341, 343, 345, 440, 441, 442, 443, 444, 445, 470, 471, 472, 473, 474, 475, 480, 485, 487, 491) THEN "Other Theft"
        ELSE NULL
	END AS Crm_Category,
    Part_1_2
FROM Crime_Data_Staging
WHERE NOT (Crm_cd IS NULL AND Crm_Cd_Desc IS NULL AND Part_1_2 IS NULL);

INSERT INTO Crime_Dim(Crm_ID, Crm_Desc, Part_1_2) -- Insert the crime codes that did not have a description & part but appear in one of the 1-4 crm_cd columns (fill with NULLS for desc. & part).
SELECT codes, NULL, NULL
FROM (
    SELECT distinct crm_cd_1 AS codes FROM crime_data_staging
    UNION
    SELECT distinct crm_cd_2 FROM crime_data_staging
    UNION
    SELECT distinct crm_cd_3 FROM crime_data_staging
    UNION
    SELECT distinct crm_cd_4 FROM crime_data_staging
) AS combined
WHERE codes NOT IN (SELECT distinct crm_cd FROM crime_data_staging);

UPDATE Crime_Dim
SET Part_1_2 = 1 
Where crm_id = 430 or crm_id = 431 ; -- corresponding part number found in UCR-COMPSTAT062618.pdf at https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8/about_data

WITH OrderedCrimes AS ( -- Unpivot current crm_cd_1-4 columns so it is easier to reorder using windows function
Select 
	cb.Dr_No, 
	cb.Source_Column AS Old_Source,
    cb.Crm_ID, 
    cd.Part_1_2, 
    cs.Crm_Cd,
    ROW_NUMBER() OVER(
		PARTITION BY cb.Dr_No 
        ORDER BY 
			CASE 
				WHEN cb.Crm_ID = cs.Crm_cd THEN 0
                WHEN cb.Crm_ID != cs.Crm_cd AND cd.Part_1_2 = 1 THEN 1
                WHEN cd.Part_1_2 = 2 THEN 2
                ELSE 3 
			END
		) as Row_Order
From (select Dr_No, 'Crm_Cd_1' as Source_Column, Crm_Cd_1 as Crm_ID from Crime_Data_Staging -- Unpivot
	where Crm_Cd_1 is not null 
	UNION ALL 
	select Dr_No, 'Crm_Cd_2' as Source_Column, Crm_Cd_2 from Crime_Data_Staging
	where Crm_Cd_2 is not null 
	UNION ALL 
	select Dr_No, 'Crm_Cd_3' as Source_Column, Crm_Cd_3 from Crime_Data_Staging
	where Crm_Cd_3 is not null
	UNION ALL 
	select Dr_No, 'Crm_Cd_4' as Source_Column, Crm_Cd_4 from Crime_Data_Staging
	where Crm_Cd_4 is not null) as cb 
JOIN Crime_Dim as cd
	ON cb.Crm_ID = cd.Crm_ID
JOIN Crime_Data_Staging cs
	ON cb.Dr_No = cs.Dr_No
),
Pivoted AS ( -- Pivot the properly ordered columns back (New Crm_cd_1-4)
    SELECT 
        Dr_No,
        MAX(CASE WHEN Row_Order = 1 THEN Crm_ID END) AS Crm_Cd_1, -- MAX used since group by needs an aggregate function
        MAX(CASE WHEN Row_Order = 2 THEN Crm_ID END) AS Crm_Cd_2,
        MAX(CASE WHEN Row_Order = 3 THEN Crm_ID END) AS Crm_Cd_3,
        MAX(CASE WHEN Row_Order = 4 THEN Crm_ID END) AS Crm_Cd_4
    FROM OrderedCrimes
    GROUP BY Dr_No
)
UPDATE Crime_Data_Staging AS cs -- Update Crime_Data_Staging table by replacing the old values with the new properly ordered ones
JOIN Pivoted AS p
    ON cs.Dr_No = p.Dr_No
SET 
	cs.Crm_cd_1 = p.Crm_Cd_1,
    cs.Crm_cd_2 = p.Crm_Cd_2,
    cs.Crm_cd_3 = p.Crm_Cd_3,
    cs.Crm_cd_4 = p.Crm_Cd_4;

-- Location: Remove any extra spaces (Fix capatilization in Power BI(PQ) since there is no INITCAP function in mysql)
UPDATE Crime_Data_Staging
SET Location = TRIM(REGEXP_REPLACE(Location, ' +', ' '));

-- Cross_Street: Remove any extra spaces (Fix capatilization in Power BI(PQ) since there is no INITCAP function in mysql)
UPDATE Crime_Data_Staging
SET Cross_Street = TRIM(REGEXP_REPLACE(Cross_Street, ' +', ' '));

-- Lat: Replace with Null when equal to 0
UPDATE Crime_Data_Staging
SET Lat = NULL
WHERE Lat = 0;

-- Lon: Replace with Null when equal to 0
UPDATE Crime_Data_Staging
SET  Lon = NULL
WHERE Lon = 0;