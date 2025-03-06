-- Create view table and name forestation based on 3 tables.
CREATE VIEW forestation AS
SELECT
    fa.country_code AS CountryCode,
    fa.country_name AS CountryName,
    fa.year AS Year,
    fa.forest_area_sqkm AS ForestAreaSqKm,
    la.total_area_sq_mi AS TotalAreaSqMi,
    r.region AS Region,
    r.income_group AS IncomeGroup,
    ROUND((fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) * 100, 2) AS ForestAreaPercentage
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code;
GO  
SELECT * FROM forestation

-- Updating land_area table and converting total_area_sq_mi to total_area_sqkm.
ALTER TABLE land_area
ADD total_area_sqkm FLOAT;

UPDATE land_area 
SET total_area_sqkm = total_area_sq_mi * 2.59;

SELECT TOP 5 country_name, total_area_sq_mi, total_area_sqkm
FROM land_area;

-- PROJECT: GLOBAL FOREST COVERAGE

-- 1. Calculate Total Forest Area for 1990 and 2016, then Compute Loss and Loss Percentage
WITH Totals AS (
    SELECT 
        year,
        SUM(forest_area_sqkm) AS total_forest_area
    FROM forest_area
    WHERE year IN (1990, 2016)
	AND country_name = 'World'
    GROUP BY year
)
SELECT 
    CAST((SELECT total_forest_area FROM Totals WHERE year = 1990) AS DECIMAL(18,2)) AS total_forest_1990,
    CAST((SELECT total_forest_area FROM Totals WHERE year = 2016) AS DECIMAL(18,2)) AS total_forest_2016,
    CAST(((SELECT total_forest_area FROM Totals WHERE year = 1990) - 
          (SELECT total_forest_area FROM Totals WHERE year = 2016)) AS DECIMAL(18,2)) AS forest_loss,
    ROUND((( (SELECT total_forest_area FROM Totals WHERE year = 1990) - 
          (SELECT total_forest_area FROM Totals WHERE year = 2016)) * 100 / 
          (SELECT total_forest_area FROM Totals WHERE year = 1990)), 2) AS loss_percent;

-- 2.  Global forest percentage in 1990 & 2016 and Regions with the highest & lowest forest percentage in 1990 & 2016
-- 2.1 Global forest percentage in 1990
SELECT fa.country_name, 
       ROUND(SUM(fa.forest_area_sqkm) * 100 / SUM(la.total_area_sqkm), 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
WHERE fa.year = 1990
AND fa.country_name = 'World'
GROUP BY fa.country_name;

-- 2.2 The region with the highest percentage in 1990
SELECT TOP 1 r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code
WHERE fa.year = 1990
GROUP BY r.region
ORDER BY pct_forest_area DESC;

-- 2.3 The region with the lowest percentage in 1990
SELECT TOP 1 r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code
WHERE fa.year = 1990
GROUP BY r.region
ORDER BY pct_forest_area ASC;

-- 2.4 Global forest percentage in 2016
SELECT fa.country_name, 
       ROUND(SUM(fa.forest_area_sqkm) * 100 / SUM(la.total_area_sqkm), 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
WHERE fa.year = 2016
AND fa.country_name = 'World'
GROUP BY fa.country_name;

-- 2.5 The region with the highest percentage in 2016
SELECT TOP 1 r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code
WHERE fa.year = 2016
GROUP BY r.region
ORDER BY pct_forest_area DESC;

-- 2.6 The region with the lowest percentage in 2016
SELECT TOP 1 r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS pct_forest_area
FROM forest_area fa
JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r ON fa.country_code = r.country_code
WHERE fa.year = 2016
GROUP BY r.region
ORDER BY pct_forest_area ASC;

-- 2.7 Percent Forest Area by Region, 1990 & 2016
WITH Forest_PCT_1990 AS (
	SELECT r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS forest_pct_1990
	FROM forest_area fa
	JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
	JOIN regions r ON fa.country_code = r.country_code
	WHERE fa.year = 1990
	GROUP BY r.region
	),
Forest_PCT_2016 AS (
	SELECT r.region, 
       ROUND((SUM(fa.forest_area_sqkm) / SUM(la.total_area_sqkm)) * 100, 2) AS forest_pct_2016
	FROM forest_area fa
	JOIN land_area la ON fa.country_code = la.country_code AND fa.year = la.year
	JOIN regions r ON fa.country_code = r.country_code
	WHERE fa.year = 2016
	GROUP BY r.region
	)
SELECT f1990.region, f1990.forest_pct_1990, f2016.forest_pct_2016
FROM Forest_PCT_1990 f1990
JOIN Forest_PCT_2016 f2016
ON f1990.region = f2016.region;

-- 3. Country - Level Detail
--3.1 Countries with the Largest Change in Forest Area in SqKM (1990-2016)
SELECT TOP 5 WITH TIES 
    f1.country_code AS CountryCode, 
    f1.country_name AS CountryName, 
    r.region,
    ROUND((f1.forest_area_sqkm - f0.forest_area_sqkm), 2) AS [Change in Forest Area in SqKm]
FROM forest_area AS f1
JOIN forest_area AS f0 
    ON f1.country_code = f0.country_code 
    AND f1.year = 2016 
    AND f0.year = 1990
JOIN regions r 
    ON f1.country_code = r.country_code
WHERE f1.country_code != 'WLD'
AND f1.forest_area_sqkm != 0 
AND f0.forest_area_sqkm != 0
ORDER BY [Change in Forest Area in SqKm] DESC;

-- 3.2 Countries with the Most Increased Percentage in Forest Area (1990-2016)
SELECT TOP 5 WITH TIES 
    f1.country_code AS CountryCode, 
    f1.country_name AS CountryName, 
    r.region,
    ROUND(((f1.forest_area_sqkm - f0.forest_area_sqkm) / f0.forest_area_sqkm) * 100, 2) AS [PCT change in Forest Area]
FROM forest_area AS f1
JOIN forest_area AS f0 
    ON f1.country_code = f0.country_code 
    AND f1.year = 2016 
    AND f0.year = 1990
JOIN regions r 
    ON f1.country_code = r.country_code
WHERE f0.country_code != 'WLD'
AND f1.forest_area_sqkm > 0 
AND f0.forest_area_sqkm > 0
ORDER BY [PCT change in Forest Area] DESC;

-- 3.3 Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016
SELECT TOP 5 WITH TIES 
    f1.country_code AS CountryCode, 
    f1.country_name AS CountryName, 
    r.region,
    ROUND((f1.forest_area_sqkm - f0.forest_area_sqkm), 2) AS [Change in Forest Area in SqKm]
FROM forest_area AS f1
JOIN forest_area AS f0 
    ON f1.country_code = f0.country_code 
    AND f1.year = 2016 
    AND f0.year = 1990
JOIN regions r 
    ON f1.country_code = r.country_code
WHERE f1.country_code != 'WLD'
AND f1.forest_area_sqkm != 0 
AND f0.forest_area_sqkm != 0
ORDER BY [Change in Forest Area in SqKm] ASC;

-- 3.4 Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016
SELECT TOP 5 WITH TIES 
    f1.country_code AS CountryCode, 
    f1.country_name AS CountryName, 
    r.region,
    ROUND(((f1.forest_area_sqkm - f0.forest_area_sqkm) / f0.forest_area_sqkm) * 100, 2) AS [PCT change in Forest Area]
FROM forest_area AS f1
JOIN forest_area AS f0 
    ON f1.country_code = f0.country_code 
    AND f1.year = 2016 
    AND f0.year = 1990
JOIN regions r 
    ON f1.country_code = r.country_code
WHERE f0.country_code != 'WLD'
AND f1.forest_area_sqkm > 0 
AND f0.forest_area_sqkm > 0
ORDER BY [PCT change in Forest Area] ASC;

--4. Rank Forest Area by Income Group in 2016
WITH IncomeForest AS (
    SELECT 
        r.income_group,
		r.country_code,
        fa.country_name,
		fa.forest_area_sqkm
    FROM forest_area fa
    JOIN regions r ON fa.country_code = r.country_code
    WHERE fa.year = 2016 
	AND fa.country_name <> 'World'
	AND fa.forest_area_sqkm <> 0
)
SELECT 
    income_group,
    country_name,
    forest_area_sqkm,
    RANK() OVER (PARTITION BY income_group ORDER BY forest_area_sqkm DESC) AS forest_rank
FROM IncomeForest
ORDER BY income_group, forest_rank;












