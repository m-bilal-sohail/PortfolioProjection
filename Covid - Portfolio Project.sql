create database PortfolioProject
use PortfolioProject

Select * From CovidDeaths$

Select * From CovidVaccinations$
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Order By 1,2


-- Total Cases vs Total Deaths
-- Likelihood of dying in the country
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths$
Where location LIKE '%Pakistan%'
Order By 1,2

--Total Cases VS Population

Select location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
From CovidDeaths$
Where location LIKE '%Pakistan%'
Order By 1,2


--Highest infection rate VS Country
Select location, population, MAX(total_cases)AS HighestInfection#, MAX(total_cases/population)*100 AS PopulationInfectionPercentage
From CovidDeaths$
Group By location, Population
order by PopulationInfectionPercentage DESC

--Highest DeathRate VS Country

Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From CovidDeaths$
Where continent IS NOT NULL
Group By location
order by TotalDeathCount DESC


--Highest DeathRate VS Continent

Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From CovidDeaths$
Where continent IS NULL
Group By location
order by TotalDeathCount DESC

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From CovidDeaths$
Where continent IS NOT NULL
Group By continent
order by TotalDeathCount DESC

--Highest DeathRate per population VS Continent 

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From CovidDeaths$
Where continent IS NOT NULL
Group By continent
order by TotalDeathCount DESC


-- GLOBAL NUMBER

Select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From CovidDeaths$
--Where location LIKE '%Pakistan%'
where continent is not null
--Group BY date--, total_cases,total_deaths
Order By 1,2


-- Total Vaccinated Population

Select D.continent,d.location, D.date, population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations))
		OVER (partition by D.location Order By D.location,D.date)
			as PeopleVaccinated
		--,PeopleVaccinated/population*100
From CovidDeaths$ D
JOIN CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
Where D.continent IS NOT NULL
Order BY 2,3

-- CTE

With PopulationVsVaccination (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
Select D.continent,d.location, D.date, population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations))
		OVER (partition by D.location Order By D.location,D.date)
			as PeopleVaccinated
		--,PeopleVaccinated/population*100
From CovidDeaths$ D
JOIN CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
Where D.continent IS NOT NULL
--Order BY 2,3
)

Select *, (PeopleVaccinated/population)*100
From PopulationVsVaccination


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent,d.location, D.date, population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations))
		OVER (partition by D.location Order By D.location,D.date)
			as PeopleVaccinated
		--,PeopleVaccinated/population*100
From CovidDeaths$ D
JOIN CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
--Where D.continent IS NOT NULL
--Order BY 2,3

Select *, (PeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Data Storage Views for Visualizations

create View PercentPopulationVaccinated AS
Select D.continent,d.location, D.date, population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations))
		OVER (partition by D.location Order By D.location,D.date)
			as PeopleVaccinated
		--,PeopleVaccinated/population*100
From CovidDeaths$ D
JOIN CovidVaccinations$ V
	ON D.location = V.location
	AND D.date = V.date
Where D.continent IS NOT NULL
--Order BY 2,3

Select * FROM PercentPopulationVaccinated