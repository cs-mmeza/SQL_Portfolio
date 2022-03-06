/*
Covid-19 Data Exploration
-- Pandemic analysis focus on death rate, infections rate, and vaccionations rate in Mexico and the World

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Pandemic analysis focus on death rate, infections rate, and vaccionations rate in Mexico and the World

--Data preview ordered by location and date
SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Shows likelihood of dying if you contract covid in mexico
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Mexico%' 
and continent is not null 
order by 1,2

-- looking at the total cases vs the population
-- Shows what percentage of pupulation got Covid-19 in Mexico
Select location, date, total_cases, population, (total_cases/population)*100 as Infected
From PortfolioProject..CovidDeaths
Where location like '%Mexico%'
and continent is not null 
ORDER BY 1,2

-- Global Death Percent Rate
-- Looking at Countries with highiest infection rate compared to pupuplation
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC

--Showing Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Classifying by continent and every location and income
-- Showing the categories with the highest death counts
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location <> 'Upper middle income' AND location <> 'High income' 
AND location <> 'Low income' -- Filtering Socio-Economics from Locations
GROUP BY location
ORDER BY TotalDeathCount DESC

-- WORLDWIDE NUMBERS until 22 January 2022 

--Tableau Viz in Readme.md from this folder
SELECT date,  MAX(total_cases) AS CASES, MAX(total_deaths) AS DEATHS, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

-- SUM
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Group By date
ORDER BY 1,2

-- TOTAL DEATH RATE WORLDWIDE FROM 2020-01-23 TO 2022-01-22
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
-- Group By date
order by 1,2

-- Covid Vaccionations
-- Joining
-- Pupulation vs Vaccionations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE (Mexico)
-- 
DROP TABLE IF EXISTS #PercentPopulationVaccinated_M 
CREATE TABLE #PercentPopulationVaccinated_M
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated_M
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
and dea.location like '%Mexico%'

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfVaccinatedPeople
FROM #PercentPopulationVaccinated_M

-- TEMP TABLE (WorldWide Table)
-- 
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfVaccinatedPeople
FROM #PercentPopulationVaccinated

-- Creating View For Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

-- Creating View For Visualizations
CREATE VIEW PercentPopulationVaccinated_M AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccionations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
and dea.location like '%Mexico%'

SELECT *
FROM PercentPopulationVaccinated_M