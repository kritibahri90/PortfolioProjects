SELECT * FROM dbo.covid_deaths
order by 3,4;


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM dbo.covid_deaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.covid_deaths
where continent is not null
--where location like 'canada'
order by 1,2


----Looking at Total Cases  Vs Population
----Shows what percentage of people got Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPercentage
FROM dbo.covid_deaths
where continent is not null
--where location like 'canada'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as InfectedPopulationPercentage
FROM dbo.covid_deaths
--where location like 'canada'
where continent is not null
GROUP BY location, population
order by InfectedPopulationPercentage DESC

--Showing countries with highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.covid_deaths
where continent is null
--where location like 'canada'
GROUP BY location
order by TotalDeathCount DESC


--Continents with highest death rate
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.covid_deaths
where continent is not null
--where location like 'canada'
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
FROM dbo.covid_deaths
where continent is not  null
--where location like 'canada'
GROUP BY date
order by 1,2

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
FROM dbo.covid_deaths
where continent is not  null
--where location like 'canada'
--GROUP BY date
order by 1,2



--Total Population Vs Vaccination

With PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)as
(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated

FROM dbo.covid_deaths as d
Join dbo.covid_vaccinations as v
  on d.date=v.date
  and d.location=v.location
where d.continent is not  null
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopVsVac



--TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric )


Insert into #PercentagePopulationVaccinated

SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated

FROM dbo.covid_deaths as d
Join dbo.covid_vaccinations as v
  on d.date=v.date
  and d.location=v.location
where d.continent is not  null


SELECT * ,(RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

--Creating view to store data for later visualization

Create view PercentagePopulationVaccinated as
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
 sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated

FROM dbo.covid_deaths as d
Join dbo.covid_vaccinations as v
  on d.date=v.date
  and d.location=v.location
where d.continent is not  null



SELECT *
FROM PrecentagePopulationVaccinated
