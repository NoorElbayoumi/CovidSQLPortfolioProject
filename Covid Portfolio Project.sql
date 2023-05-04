Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4



Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2



-- Total Cases VS Total Deaths
-- Shows the percentage of death if covid is contracted within your country
SELECT Location, date, total_cases,total_deaths, (convert(float,total_deaths)/ convert(float,total_cases)*100) as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



-- Total Cases vs Population
-- Shows the percentage of the population that were infected by COVID-19
SELECT Location, date, population, total_cases, (convert(float,total_cases)/ convert(float,population)*100) as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



-- Countries with the highest infection rate compared to the countries population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((convert(float,total_cases)/ convert(float,population)*100)) as HighestInfectionRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by HighestInfectionRate desc



-- Countries with the highest death count compared to their population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalDeathCount desc



-- Continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global total numbers
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 1,2



-- Global numbers by date
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1,2



-- Total population VS Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3



-- USE CTE
;WITH PopVsVac (Contintent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS 
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS TotalPercentageVaccinated
FROM PopVsVac;



-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS TotalPercentageVaccinated
FROM #PercentPopulationVaccinated



 -- Creating Views to store for a visualization

CREATE view PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

Select *
From PercentPopulationVaccinated

CREATE View TotalPopulationNumbers AS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 


CREATE View ContinentsHighestDeathCount AS
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent

CREATE View GlobalDeathByDate AS
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY date 

Select *
FROM GlobalDeathByDate

CREATE View DeathCountVsCountryPopulation AS
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population

Select *
From DeathCountVsCountryPopulation