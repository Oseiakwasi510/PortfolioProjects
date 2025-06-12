select * from CovidD
Order by 3, 4

--select * from CovidVaccination
--Order by 3, 4

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM CovidD
ORDER BY 1, 2

--Total cases vs Total Deaths
--shows the percentage of the total cases who died
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidD
WHERE location LIKE '%states%'
ORDER BY 1, 2 desc


--Total cases vs Population
--shows the percentage population who got infected with Covid
SELECT  location, date, population, total_cases, (total_cases/population)*100 T_CasePercentage
FROM CovidD
WHERE location LIKE '%states%'
ORDER BY 1, 2 desc


--Looking at Countries with Highest Infection rate compared to Population
SELECT  location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentagePopulationInfected
FROM CovidD
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


--Countries with Highest Death Count per Population
SELECT  location, population, MAX(CAST(total_deaths as INT)) HighestDeathCount, MAX((total_deaths/population))*100 PercentagePopulationDied
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationDied desc

--OR
--COUNTRIES WITH HIGHEST DEATH COUNT PER LOCATION
SELECT  location, MAX(CAST(total_deaths as INT)) HighestDeathCount 
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT
--Highest Death Count per Continent
SELECT  continent, MAX(CAST(total_deaths as INT)) HighestDeathCount 
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
--Total cases recorded globally per date
SELECT date, SUM(total_cases) --total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY date
ORDER BY 1, 2 


--New total new death recorded globally per date
SELECT date, SUM(CAST(new_deaths AS INT))
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT date, SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths, 
			SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 NewDeathPercentage
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths, 
			SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 NewDeathPercentage
FROM CovidD
--WHERE location LIKE '%states%'
where continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2


--VACCINATION
SELECT *
FROM CovidVaccination

SELECT *
FROM CovidD dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date

--POPULATION VS VACCINATON
--Total number of people who got vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) over (partition by dea.location 
		Order By dea.location, dea.date) RollingPeopleVaccinated
FROM CovidD dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) over (partition by dea.location 
		Order By dea.location, dea.date) RollingPeopleVaccinated
FROM CovidD dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated 
(
continent varchar(255),
location varchar(255),
date date,
population int,
new_population int,
RollingPeopleVaccinated int
)


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) over (partition by dea.location 
		Order By dea.location, dea.date) RollingPeopleVaccinated
FROM CovidD dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from #PercentPopulationVaccinated


--VIEW
CREATE VIEW PercentagePopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) over (partition by dea.location 
		Order By dea.location, dea.date) RollingPeopleVaccinated
FROM CovidD dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *
FROM PercentagePopulationVaccinated