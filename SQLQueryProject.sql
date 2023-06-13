SELECT *
  FROM [Portfolio Project].[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4
--SELECT *
--  FROM [Portfolio Project].[dbo].[CovidVaccinations]
--  order by 3,4
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].[dbo].[CovidDeaths]
 order by 1,2

 -- shows likelihood of dying if you contract covid in Russia
SELECT location, date, total_cases, total_deaths, (total_deaths / CAST(total_cases AS numeric))*100 as DeathsPercetage
FROM [Portfolio Project].[dbo].[CovidDeaths]
WHERE location ='Russia'
where continent is not null
 order by 1,2

--looking at total cases vs population
-- shows what percaetage of population got covid
SELECT location, date, population, total_cases, (CAST(total_cases AS numeric)/ population)*100 as PercetPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
--WHERE location ='Russia'
 where continent is not null
 order by 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCountr, max(CAST(total_cases AS numeric)/ population)*100 as PercetPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
--WHERE location ='Russia'
 where continent is not null
group by location, population
 order by PercetPopulationInfected desc

--showing counties with highest death count per population

SELECT location, max(cast(total_deaths as numeric)) as TotalDeathsCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
--WHERE location ='Russia'
where continent is not null
group by location 
order by TotalDeathsCount desc

--- let's break things down by continent


-- showing continent with the highest death count per population
SELECT continent, max(cast(total_deaths as  decimal)) as TotalDeathsCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
--WHERE location ='Russia'
where continent is not null
group by continent 
order by TotalDeathsCount desc

-- GLOBAL NUMBERS

SELECT date, 
       SUM(cast(new_cases as decimal)) as total_cases, 
	   SUM(cast(new_deaths as decimal))as total_deaths, 
	   (SUM(cast(new_deaths as decimal))/NULLIF(SUM(CAST(new_cases AS decimal)), 0))*100 as DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
--WHERE location ='Russia'
where continent is not null
Group by date
order by 1,2
 

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(decimal(10,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, 
   dea.Date) as RollingPeopleVaccinated, 
   ---(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].[dbo].[CovidDeaths] dea
Join [Portfolio Project].[dbo].[CovidVaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- use cte

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(decimal(10,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
   ---(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].[dbo].[CovidDeaths] dea
Join [Portfolio Project].[dbo].[CovidVaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)
From PopvsVac


--Temp table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(decimal(10,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
   ---(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].[dbo].[CovidDeaths] dea
Join [Portfolio Project].[dbo].[CovidVaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated


---Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(convert(decimal(10,2), vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
   ---(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project].[dbo].[CovidDeaths] dea
Join [Portfolio Project].[dbo].[CovidVaccinations] vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated