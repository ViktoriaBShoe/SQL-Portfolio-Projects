Select *
From [Portfolio - COVID].dbo.CovidVaccinations
order by 3, 4

--Select *
--From [Portfolio - COVID].dbo.CovidDeaths
--order by 3, 4

-- Select Data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From [Portfolio - COVID].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at total cases vs. total deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio - COVID].dbo.CovidDeaths
WHERE location like '%States%'
AND continent is not null
ORDER BY 1, 2

-- Looking at the total cases vs. the population
-- Shows what percentage of population gor COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
ORDER BY 1, 2

-- Looking at countries with the highest infection rate compared to the population
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY population, location
ORDER BY 4 desc

-- Showing the countries with the highest death count per population
SELECT location, max(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count
SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers TOTAL
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs. vaccination
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
From [Portfolio - COVID].dbo.CovidDeaths as dea
Join [Portfolio - COVID].dbo.CovidVaccinations as vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
Order By 2, 3

-- Use CTE (Rolling Percent of People Vaccinated per counrty and date)

;With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio - COVID].dbo.CovidDeaths dea
Join [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Total Percent of People Vaccinated per counrty

;With PopvsVac (Location, Population, TotalPeopleVaccinated)
as
(
Select dea.location, dea.population, vac.total_vaccinations
From [Portfolio - COVID].dbo.CovidDeaths dea
Join [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
where dea.continent is not null
group by dea.location, dea.population, vac.total_vaccinations
--Order by 2, 3
)
Select *, (TotalPeopleVaccinated/Population)*100
From PopvsVac

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio - COVID].dbo.CovidDeaths dea
Join [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later vizualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
, dea.date) as RollingPeopleVaccinated
From [Portfolio - COVID].dbo.CovidDeaths dea
Join [Portfolio - COVID].dbo.CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2, 3

SELECT * FROM [dbo].[PercentPopulationVaccinated]

Create View TotalPopulationvsVacination as
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
From [Portfolio - COVID].dbo.CovidDeaths as dea
Join [Portfolio - COVID].dbo.CovidVaccinations as vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--Order By 2, 3

Create View GlobalNumbersTotal as
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null

Create View DeathsByContinents as
SELECT continent, max(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent

Create View HighestInfectionvsPopulation as
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases)/population*100 as PercentPopulationInfected
From [Portfolio - COVID].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY population, location