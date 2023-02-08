
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--likelyhood of dying if you contract covid in your country
---Show what percentage of the population has go Covid 

Select Location, date, population, total_cases, (total_deaths/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--Showing countries with Highest Deathh Count per population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent

--showing the continents with the highest Death per popilation


Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
--Group by date
order by 1,2


--Looking at the Total Population vs Vaccinations

--USE CTE

with PopvsVac (continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated', 'U') IS NOT NULL
BEGIN
    DROP TABLE #PercentPopulationVaccinated;
END;

CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated;



--Creating View to store data later for visualisation

DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO

CREATE VIEW PercentPopulationVaccinated
AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated


