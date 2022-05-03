
/* Covid19 Data Exploration

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%Africa' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidProject..CovidDeaths
-- WHERE location LIKE '%Africa'
ORDER BY 1,2

-- Countries with Highest Covid Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS Highest_Infection__Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM CovidProject..CovidDeaths
-- WHERE location LIKE '%Africa'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100
	AS Death_Percentage
FROM CovidProject..CovidDeaths
-- WHERE location LIKE '%Africa'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Percentage of Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPopulationVaccinated
FROM CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPopulationVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPopulationVaccinated
	--, (RollingPopulationVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPopulationVaccinated/Population)*100
FROM PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopulationVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPopulationVaccinated
	--, (RollingPopulationVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPopulationVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualizations

CREATE VIEW 
	PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPopulationVaccinated
	--, (RollingPopulationVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


