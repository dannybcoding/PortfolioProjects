

select *
from CovidDeaths

select *
from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%states%'
order by 1,2

-- look at Total cases vs population

select location, date, total_cases, population, 
	(total_cases/population)*100 as PercentContracted
from CovidDeaths
--Where location like '%states%'
order by 1,2

-- Look at countries with hightest infection rate compared to population

select location, population, 
	Max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentInfected
from CovidDeaths
group by location, population
order by PercentInfected desc

--Showing Countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--show Continent with hightest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location not in('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

--Global Numbers

select date, sum(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from CovidDeaths 
Where continent is not null
group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
and dea.continent is not null
order by 2,3


-- USE CTE

with popvsVac(Continent, Location, Date, Population, New_Vaccinations,
	RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
and dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percent_Vaccinated
from popvsVac


--TEMP TABLE
 
 drop table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--and dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	and dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated