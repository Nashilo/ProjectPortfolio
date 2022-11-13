CREATE DATABASE PortfolioProject;

ALTER TABLE dbo.owid-covid-data$ RENAME TO CovidVaccinnations$;

--SELECT *
--FROM PortfolioProject..dbo.CovidDeaths$
--where continent is not null
--ORDER BY 3,4

SELECT *FROM [PortfolioProject].[dbo].[CovidVaccinations$]
ORDER BY 3,4;

--Select Data to be used
SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Total Cases vs Total Deaths
--Shows liklihood of dying if you contract the covid in your area
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%Namibia%'
ORDER BY 1,2

--Total Cases vs Population
SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Africa%'
ORDER BY 1,2

--Region with highest Infection Rate compared to population
SELECT location, population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
GROUP BY location, population
ORDER BY PopulationInfectionRate desc

CREATE VIEW InfectionRateperPopulation as 
SELECT location, population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
GROUP BY location, population


--For continent
SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
WHERE continent is not null
GROUP BY continent, population
ORDER BY PopulationInfectionRate desc

CREATE VIEW InfectionRateperContinent as
SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionRate
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
WHERE continent is not null
GROUP BY continent, population

--Breaking things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc


CREATE VIEW DeathsPerContinent as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is null
GROUP BY continent


--Showing the Countries with the highest death count per populution

-- Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

CREATE VIEW DeathperPopulation as 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
where continent is not null
GROUP BY location



--Breaking Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Joining the two tables
SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' 
ORDER BY 1,2,3

--CAST

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.location = 'Namibia' 
WHERE dea.continent is not null
ORDER BY 1,2,3

--CONVERT

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' and vac.new_vaccinations is not null
--WHERE dea.continent is not null
ORDER BY 1,2,3



SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' and vac.new_vaccinations is not null
--WHERE dea.continent is not null
ORDER BY 1,2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' and vac.new_vaccinations is not null
--WHERE dea.continent is not null
--ORDER BY 1,2,3
)

SELECT*,(RollingPeopleVaccinated/population)*100 as RPVvspop
FROM PopvsVac



-- Temp Table

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
 Continent varchar(255),
 location varchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeoplevaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' and vac.new_vaccinations is not null
--WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT*,(RollingPeopleVaccinated/population)*100 as RPVvspop
FROM #PercentagePopulationVaccinated



--Create view to store data for visualisations

CREATE VIEW PercentagePopulationVaccinated as
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Namibia' and vac.new_vaccinations is not null
--WHERE dea.continent is not null
--ORDER BY 1,2,3

DROP VIEW if exists TCasesvsTDeathNam

CREATE VIEW TCasesvsTDeathNam as
--Shows liklihood of dying if you contract the covid in your area
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%Namibia%'

CREATE VIEW TCasesvsTDeathGlo as
--Shows liklihood of dying if you contract the covid in your area
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Namibia%'

CREATE VIEW TCasesvsTPop as
SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%Africa%'
--ORDER BY 1,2

