Select * 
from projectsql.coviddata
where continent is not null
order by 1,2

--select the data columns needed

Select location,date,total_cases,new_cases,total_deaths,population
From projectsql.coviddata 
order by 1,2

--comparing total cases with total death

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From projectsql.coviddata
order by 1,2

--comparison in india

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From projectsql.coviddata 
Where location like '%india%'
order by 1,2

 --comparison of total cases vs population
 --shows the percentage of population infected with corono-19 virus
 
Select location, date, total_cases,population,(total_cases/population)*100 as InfectedPopulationPercentage
From projectsql.coviddata 
order by 1,2

--checking country with highest infection rate
Select location,population, MAX( total_cases) as HighestinfectedCount,MAX((total_cases/population))*100 as InfectedPopulationPercentage
From projectsql.coviddata 
Group by location,population
order by InfectedPopulationPercentage desc

--countries with max death cases
Select location, MAX(CAST(total_deaths as UNSIGNED )) as TotalDeathCount
From projectsql.coviddata 
where continent is not null
Group by location
order by TotalDeathCount desc


--Global Numbers
Select date , SUM(new_cases),SUM(new_deaths),SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From projectsql.coviddata 
where continent is not null
Group by date
Order by 1,2

--Joing two CSV files Covid death and Covid Vaccination rate file

Select *
From projectsql.coviddata dea
Join projectsql.covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   
--Looking Total population vs vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From projectsql.coviddata dea
Join projectsql.covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--Temp Table

Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RolligPeopleVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From projectsql.coviddata dea
Join projectsql.covidvaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null

Select * ,(RollingPeopleVaccinated/population)* 100
From #PercentagePeopleVaccinated
