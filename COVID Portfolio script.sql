-- Selecting Data I am going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio - COVID].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Total cases vs. total deaths
-- Shows the COVID death percentage per country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio - COVID].dbo.CovidDeaths
WHERE location like '%States%'
AND continent is not null
ORDER BY 1, 2

-- Total cases vs. the population
-- Shows the COVID infection percentage per country and date

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
ORDER BY 1, 2

-- Countries with the highest infection rate compared to the population
-- Shows the total number of COVID cases and percentage of populated infected by country
	
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY population, location, date
ORDER BY PercentPopulationInfected desc

-- Countries with the highest death count
	
SELECT location, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

	
-- GROUPING RESULTS BY CONTINENTS

	
-- Continents with the highest death count
	
SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Summary of Global Numbers TOTAL
	
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--Rolling Percent of People Vaccinated per counrty and date 
--JOIN Table
	
SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM [Portfolio - COVID].dbo.CovidDeaths as dea
JOIN [Portfolio - COVID].dbo.CovidVaccinations as vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Total Percent of People Vaccinated per counrty 
--CTE

;WITH PopvsVac (Location, Population, TotalPeopleVaccinated)
as
(
SELECT dea.location, dea.population, vac.total_vaccinations
FROM [Portfolio - COVID].dbo.CovidDeaths dea
JOIN [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
WHERE dea.continent is not null
GROUP BY dea.location, dea.population, vac.total_vaccinations
--Order by 2, 3
)
SELECT *, (TotalPeopleVaccinated/Population)*100
FROM PopvsVac

--Rolling Percent of people vaccinated by location and date
--TEMP table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
FROM [Portfolio - COVID].dbo.CovidDeaths dea
JOIN [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--Order by 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later vizualizations

-- View #1

Create View GlobalNumbersTotal as
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null

--View #2
	
Create View DeathsByContinent as
SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
	
--View 3
	
Create View HighestInfectionvsPopulation as
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY population, location, date

--View 4
	
Create View PercentPopulationInfected as
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
FROM [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY population, location, date
