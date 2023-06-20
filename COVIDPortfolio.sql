

Select *
From PortfolioProject. .CovidDeaths
WHERE continent is not NULL
Order by 3,4


--Select *
--From PortfolioProject. .CovidVaccinations
--Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject. .CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract COVID in your country

Select location, date, total_cases , total_deaths, (total_deaths/total_cases)* 100.0 AS DeathPercentage
From PortfolioProject. .CovidDeaths
Where location like '%states%'
and continent is not NULL
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select location, date, population, total_cases , (total_cases/population)* 100.0 AS PercentePopulationInfected
From PortfolioProject. .CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Countries with highest Infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, (Max(total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
GROUP by location, population
Order by PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
WHERE continent is not NULL
GROUP by location
Order by TotalDeathCount desc

-- BY Continent
-- Showing continents with the highest death count per population


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
WHERE continent is NULL
GROUP by location
Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
GROUP by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject. .CovidDeaths
Where continent is NOT NULL
Order by 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (/population)
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
Order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaaccinated
Create Table #PercentPopulationVaaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
ORder by 2,3

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaaccinated
Order by 2,3



-- Creating View to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL


SELECT *
FROM PercentPeopleVaccinated