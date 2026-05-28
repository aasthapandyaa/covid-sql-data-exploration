SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4;

--SELECT*
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4;

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT Location , date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- lOOKING AT Total cases vs total deaths
-- shows likelihood of dying if you contact covid in your country
SELECT Location , date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2;

-- Looking at Total cases vs population
-- shows what percernatge of population got covid
SELECT Location , date, population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2;

-- looking at country with highest infection rate compared to population
SELECT Location ,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Group by Location , Population
ORDER BY PercentPopulationInfected desc;

-- showing country with highest death count per population
SELECT Location ,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group by Location 
ORDER BY TotalDeathCount desc;

-- lets break things down by location
SELECT location ,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is  null
Group by location
ORDER BY TotalDeathCount desc;


-- showing the continent with highest death count per population
SELECT continent ,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is  not null
Group by continent
ORDER BY TotalDeathCount desc;


-- Global NUMBERS
SELECT  date, SUM(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths , SUM(cast(New_deaths as int))/SUM
(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE  continent is not null
Group By date
ORDER BY 1,2;

SELECT   SUM(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths , SUM(cast(New_deaths as int))/SUM
(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE  continent is not null
--Group By date
ORDER BY 1,2;



-- looking at total population vs vaccinations
-- USE CTE
With PopvsVac(Continent,Location,Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order BY 2,3;
)
SELECT * ,(RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--Order BY 2,3;

SELECT * ,(RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISULAIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order BY 2,3;

SELECT *
FROM PercentPopulationVaccinated;