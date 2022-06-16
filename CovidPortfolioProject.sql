select * from PortfolioProject..CovidDeaths
order by 3,4


--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date, total_cases, new_cases, total_deaths, population  from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows probabilty of death if you get infected by Covid
select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

select location,date, total_cases,population, (total_cases/population)*100 as InfectionPercentage from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Looking at countries with highest infection rate compared to populaton

select location,Max(total_cases) as  HighestInfectionCount,population, max((total_cases/population))*100 as InfectionPercentage from PortfolioProject..CovidDeaths
--where location like 'India'
Group by location, population
order by InfectionPercentage desc


-- Showing countries with Highest Death Count per Population


select location,Max(CAST(total_deaths as int)) as  TotalDeathCount from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT



--Showing the continents with highest death count per population


select continent,Max(CAST(total_deaths as int)) as  TotalDeathCount from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,  Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated / Population) * 100
from PopvsVac


--Temp TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated

--creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3