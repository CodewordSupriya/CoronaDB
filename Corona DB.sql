select top 100 * from CoronaDB..CovidVaccinations;

select Location, Date, total_cases, new_cases, total_deaths, population 
from CoronaDB..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

select Location, Date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
from CoronaDB..CovidDeaths
where location like '%states%'
order by 1,2

-- countries with highest infection rate
select location, population, max(total_cases) HighestInfectionCount, MAX((Total_cases/population)*100) as PerecentInfection
from CoronaDB..CovidDeaths 
Group by location, population
order by PerecentInfection desc


--Showing highest death count per polulation
select location, population, max(cast(total_deaths as int)) HighestDeathCount, MAX((cast(total_deaths as int)/population)*100) as PerecentDeaths
from CoronaDB..CovidDeaths 
where continent is not null
Group by location, population
order by PerecentDeaths desc

--Lets breakdown data by continent

select continent, sum(population),max(cast(total_deaths as int)) HighestDeathCount, MAX((cast(total_deaths as int)/population)*100) as PerecentDeaths
from CoronaDB..CovidDeaths 
where continent is not null
Group by continent
order by PerecentDeaths desc

select location, sum(population),max(cast(total_deaths as int)) HighestDeathCount, MAX((cast(total_deaths as int)/population)*100) as PerecentDeaths
from CoronaDB..CovidDeaths 
where continent is null
Group by location
order by PerecentDeaths desc

--Global Numbers
select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from CoronaDB..CovidDeaths
where continent is not null

--looking at total polpulation vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CoronaDB..CovidDeaths dea
join CoronaDB..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null
 order by 2,3


 select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location)
from CoronaDB..CovidDeaths dea
join CoronaDB..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null
 order by 2,3


 --use CTE

 with PopvsVac ( Continet, Location, date, Population, New_vacciantions, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
from CoronaDB..CovidDeaths dea
join CoronaDB..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date= vac.date
 where dea.continent is not null
 )
 select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac