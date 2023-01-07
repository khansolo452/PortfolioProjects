Select *
From Covid..Coviddeaths
order by 3,4

--Select *
--From Covid..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Covid..Coviddeaths
order by 1,2


-- Looking at Total cases Vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases ) * 100 as deathpcnt
From Covid..Coviddeaths
Where location = 'United States' AND  total_cases > 50000
order by 1,2

-- Looking at Total cases VS Population
--shows what prcnt of pop got covid

Select location, Population, total_cases as HighestInfectioncount, (total_cases/Population ) * 100 as Percent_pop_infected
From Covid..Coviddeaths
Where location = 'United States' AND  total_cases > 50000
order by 1,2



-- Looking at Countries with highest infection rate compared to population 

Select location as Country, Population,max(total_cases) as HighestInfected, max((total_cases/Population )) * 100 as percent_pop_infected
From Covid..Coviddeaths
--Where location = 'United States' AND  total_cases > 50000
Group by location, Population
order by percent_pop_infected desc;


--- Showing Countries with Highest Death Count per Population

Select location as Country, max(cast(total_deaths as bigint)) as TotalDeaths
From Covid..Coviddeaths
--Where location = 'United States' AND  total_cases > 50000
Where continent is not null
Group by location
order by TotalDeaths desc;


--LET'S BREAK IT DOWN BY CONTINENT

Select location, max(cast(total_deaths as bigint)) as TotalDeaths
From Covid..Coviddeaths
--Where location = 'United States' AND  total_cases > 50000
Where continent is null and location NOT LIKE '%income' and location NOT LIKE 'International'
Group by  location
order by TotalDeaths desc;


-- GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From Covid..Coviddeaths
--Where location = 'United States' AND  total_cases > 50000
where continent is not null
--group by date
order by 1,2


--Looking at Total Population Vs. vaccinations
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From Covid..Coviddeaths dea
Join Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

With PopvsVac(continent,location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From Covid..Coviddeaths dea
Join Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100 as PcntRollingPop
From PopvsVac



--Temp Table

DROP Table if exists #PercentPopVac
Create table #PercentPopVac
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopVac
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From Covid..Coviddeaths dea
Join Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100 as PcntRollingPop
From #PercentPopVac


--Creating View to store data for Visualizations later

Create view PercentPopVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From Covid..Coviddeaths dea
Join Covid..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
