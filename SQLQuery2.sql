-- ACCIDENTS DATA
SELECT *
FROM [dbo].[accidents]

-- combining date and adding it as a new column
ALTER TABLE
    [dbo].[accidents]
ADD DATE AS
		CONVERT(DATE, 
					CAST([YEAR] AS VARCHAR(4))+'-'+
					CAST([MONTH] AS VARCHAR(2))+'-'+
					CAST([Day] AS VARCHAR(2)))

-- selecting the ACCIDENTS data to use
SELECT STATENAME, ST_CASE, DATE, MONTH, MONTHNAME, DAYNAME, DAY_WEEK, DAY_WEEKNAME, HOUR, FATALS
FROM [dbo].[accidents]

-- looking for the states with the most accidents - the most dangerous states for driving
-- percent of accidents per state
-- adding the population table per state
SELECT acc.STATENAME, COUNT(acc.ST_CASE) NUM_OF_ACCIDENTS, pop.RESIDENT_POPULATION, (COUNT(acc.ST_CASE)/pop.RESIDENT_POPULATION)*100 ACCIDENT_POPULATION_RATIO
FROM [dbo].[accidents] acc
FULL OUTER JOIN [dbo].[state_population] pop
		ON acc.STATENAME = pop.STATE
GROUP BY acc.STATENAME, pop.RESIDENT_POPULATION
ORDER BY ACCIDENT_POPULATION_RATIO DESC

-- looking for the states with the deadliest car accidents
-- percent of fatals vs. accidents per state
SELECT STATENAME, COUNT(ST_CASE) NUM_OF_ACCIDENTS, SUM (FATALS) TOTAL_FATALS, (SUM (FATALS)/COUNT(ST_CASE))*100 DEATH_PERCENTAGE 
FROM [dbo].[accidents]
GROUP BY STATENAME
ORDER BY DEATH_PERCENTAGE DESC


-- total accidents and fatals per month
SELECT MONTH, MONTHNAME, COUNT(ST_CASE) AS NUM_OF_ACCIDENTS, SUM (FATALS) TOTAL_FATALS
FROM [dbo].[accidents]
GROUP BY MONTHNAME, MONTH
ORDER BY MONTH

-- total accidents and fatals per day of week
SELECT DAY_WEEKNAME, COUNT(ST_CASE) AS NUM_OF_ACCIDENTS
FROM [dbo].[accidents]
GROUP BY DAY_WEEKNAME
ORDER BY DAY_WEEKNAME


-- total accidents and fatals per hour
SELECT HOUR, COUNT(ST_CASE) AS NUM_OF_ACCIDENTS
FROM [dbo].[accidents]
WHERE HOUR BETWEEN 0 AND 23
GROUP BY HOUR
ORDER BY HOUR

-- total accidents and fatals per state and date
SELECT DATE, STATENAME, COUNT(ST_CASE) AS NUM_OF_ACCIDENTS, SUM (FATALS) TOTAL_FATALS
FROM [dbo].[accidents]
GROUP BY STATENAME, DATE
ORDER BY DATE, STATENAME

-- rolling accidents per state and date
SELECT DATE, STATENAME, COUNT(ST_CASE) NUM_OF_ACCIDENTS, SUM(COUNT(ST_CASE)) OVER (PARTITION BY STATENAME ORDER BY DATE) AS ROLLING_ACCIDENTS
FROM [dbo].[accidents]
WHERE STATENAME IS NOT NULL
GROUP BY DATE, STATENAME
ORDER BY STATENAME, DATE

-----

--IMPAIRMENT DATA
SELECT DRIMPAIRNAME, COUNT(DRIMPAIRNAME) AS COUNT_IMPAIRMENT
FROM [dbo].[drimpair]
WHERE DRIMPAIRNAME NOT IN ('Not Reported', 'Reported as Unknown if Impaired')
GROUP BY DRIMPAIRNAME


------

-- DRIVERS DATA

-- Looking for cars that wreck the most
SELECT TOP 15 VPICMAKENAME AS CAR_MAKE, COUNT (VPICMAKENAME) AS CRASH_COUNT
FROM [dbo].[person]
GROUP BY VPICMAKENAME
ORDER BY 2 DESC

-- Age of drivers that wreck the most
SELECT * FROM [dbo].[person]
SELECT age, COUNT(AGE) AS COUNT 
FROM [dbo].[person] 
GROUP BY AGE 
ORDER BY 1 DESC

-- grouping by age categories
SELECT COUNT (*) AS PEOPLE_COUNT, *
FROM
(
SELECT
	CASE
		WHEN AGE <18 THEN 'UNDER 18'
		WHEN AGE BETWEEN 18 AND 24 THEN '18-24'
		WHEN AGE BETWEEN 25 AND 34 THEN '25-34'
		WHEN AGE BETWEEN 35 AND 44 THEN '35-44'
		WHEN AGE BETWEEN 45 AND 54 THEN '45-54'
		WHEN AGE BETWEEN 55 AND 64 THEN '55-64'
		WHEN AGE BETWEEN 65 AND 74 THEN '65-74'
		WHEN AGE BETWEEN 75 AND 84 THEN '75-84'
		WHEN AGE BETWEEN 85 AND 94 THEN '85-94'
	END AS AGE_RANGE
	FROM [dbo].[person]
) a
WHERE AGE_RANGE IS NOT NULL
GROUP BY AGE_RANGE
ORDER BY AGE_RANGE
