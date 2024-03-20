select * 
from PortfolioProject.dbo.CovidDeaths$
order by 3,4

select * 
from PortfolioProject.dbo.CovidVaccinations$
order by 3,4

select * 
from PortfolioProject.dbo.CovidVaccinations$
where continent is not null
order by 3,4

---- select data that we are going to be using 
 
 select Location, date, total_cases, new_cases, total_deaths, population 
 from PortfolioProject.dbo.CovidDeaths$
 order by 1,2

 --- Loking at toatl Cases vs total Deaths

  select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject.dbo.CovidDeaths$
 order by 1,2

 ---Shows the likelihood of daying if you contract covid in your country

 select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject.dbo.CovidDeaths$
  where location like '%Algeria%'
 order by 1,2

 ---- Looking at total cases vs population 

 --- shows what percentage of population got covid 

 select Location, date, population,total_cases,  (total_cases/population)*100 as PercentPopulationInfected 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
 order by 1,2

 --- looking for Contries with Highest Infection Rate to population 

  select Location, Population, max (total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
  group by Location, Population 
 order by PercentPopulationInfected desc 

 -- showing Contries with Highest Death Count per Population 

  select Location, Max(cast (total_deaths as int )) as TotalDeathCount 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
  where continent is not null
  group by Location 
 order by TotalDeathCount desc 

 -- let's Break Things Down By Continent 

 select continent, Max(cast (total_deaths as int )) as TotalDeathCount 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
  where continent is not null
  group by continent 
 order by TotalDeathCount desc 

  select location, Max(cast (total_deaths as int )) as TotalDeathCount 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
  where continent is not null
  group by location 
 order by TotalDeathCount desc 

 ---- showing the contients with the hightest death count per population 

  select continent, Max(cast (total_deaths as int )) as TotalDeathCount 
  from PortfolioProject.dbo.CovidDeaths$
  --where location like '%Algeria%'
  where continent is not null
  group by continent 
 order by TotalDeathCount desc 

 --- Global Numbers 

 select  sum(new_cases) as total_cases, sum (cast (new_deaths as int)) as total_deaths,sum (cast (new_deaths as int))/sum(new_cases) *100 as DeathsPercentage 
  from PortfolioProject.dbo.CovidDeaths$
 -- where location like '%Algeria%'
 where continent is not null
 --group by date 
 order by 1,2


 --------------------------------------------------------
 select * 
from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date

--- looking for total population vs vaccinations
 select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
 from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

 select dea.continent, dea.location, dea.date,dea.population ,vac.new_vaccinations,
 sum(cast (vac.new_vaccinations as  int )) over (Partition by dea.location order by dea.location, 
 dea.date ) as RollingPeopleVaccinated  --- or sum( convert ( int, vac.new_vaccinations ))
 --, (RollingPeopleVaccinated/population)*100 can't use column that we just created 
 from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- use CTE

 with PopvsVac (continent , location ,date , population,new_vaccinations ,RollingPeopleVaccinated)
 as 
 (
 select dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
 sum(cast (vac.new_vaccinations as  int )) over (Partition by dea.location order by dea.location, 
 dea.date ) as RollingPeopleVaccinated  --- or sum( convert ( int, vac.new_vaccinations ))
 --, (RollingPeopleVaccinated/population)*100 can't use column that we just created 
 from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/ population)*100 
from PopvsVac 
 
 --- use temp_table -------------------------------------------------------------------------------------------------------------
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 contient nvarchar(225),
 Location nvarchar(255),
 Date dateTime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentPopulationVaccinated

  select dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
 sum(cast (vac.new_vaccinations as  int )) over (Partition by dea.location order by dea.location, 
 dea.date ) as RollingPeopleVaccinated  --- or sum( convert ( int, vac.new_vaccinations ))
 --, (RollingPeopleVaccinated/population)*100 can't use column that we just created 
 from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/ population)*100 
from #PercentPopulationVaccinated

--- creating view to store data for later visualizations 

create View PercentPopulationVaccinated as 
  select dea.continent, dea.location,  dea.date,dea.population, vac.new_vaccinations,
 sum(cast (vac.new_vaccinations as  int )) over (Partition by dea.location order by dea.location, 
 dea.date ) as RollingPeopleVaccinated  --- or sum( convert ( int, vac.new_vaccinations ))
 --, (RollingPeopleVaccinated/population)*100 can't use column that we just created 
 from PortfolioProject.dbo.CovidVaccinations$ as vac
join 
PortfolioProject.dbo.CovidDeaths$ as dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
