--Data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From COVID_PROJECT..CovidDeaths
Where Continent is not null
order by 1,2


--Looking at total cases vs total Deaths
--It shows the liklihood of dying if you contract in your country


Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as Death_percentage
From COVID_PROJECT..CovidDeaths
Where location LIKE '%State%'
and Continent is not null
order by 1,2


--Looking at the Total cases vs Population
--Shows what percentage of population got COVID


Select location, date, population, total_cases, (total_cases/population)*100 as Population_wise_COVID_percentage
From COVID_PROJECT..CovidDeaths
Where location LIKE '%Bangla%' and Continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population


Select location, population, MAX(total_cases) as Highest_infection_count, MAX(total_cases/population)*100 as Percent_of_population_infected
From COVID_PROJECT..CovidDeaths
Group by Location, population
order by Percent_of_population_infected desc


--Showing the countries with the highest death count per population


Select location, population, MAX (CAST (total_deaths as int)) as Highest_death_count, MAX(total_deaths/population)*100 as Percent_of_population_dead
From COVID_PROJECT..CovidDeaths
Where Continent is not null
Group by location, Population
order by Highest_death_count desc


--Let's break things down by continent


Select continent, MAX (CAST (total_deaths as int)) as Total_death_count, MAX(total_deaths/population)*100 as Percent_of_population_dead
From COVID_PROJECT..CovidDeaths
Where Continent is not null
Group by continent
order by Total_death_count desc

--Let's break things down by Location

Select location, MAX (CAST (total_deaths as int)) as Total_death_count
From COVID_PROJECT..CovidDeaths
Where Continent is null
Group by location
order by Total_death_count desc


--Showing the continent with the highest death count population


Select continent, MAX (CAST (total_deaths as int)) as Total_death_count, MAX(total_deaths/population)*100 as Percent_of_population_dead
From COVID_PROJECT..CovidDeaths
Where Continent is not null
Group by continent
order by Total_death_count desc


--Global Numbers


Select SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From COVID_PROJECT..CovidDeaths
Where Continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as ROllingpeoplevaccinated
from COVID_PROJECT..CovidDeaths dea
JOIN COVID_PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
Order by 2,3


--USE CTE


with PopvsVac (continent, location, date, population, New_vaccinations, ROllingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations as int)) OVER (partition by 
dea.location order by dea.location, dea.date) as Rolling_People_vaccinated
-- (ROllingpeoplevaccinated/population)*100
from COVID_PROJECT..CovidDeaths dea
JOIN COVID_PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
)
Select *, (ROllingpeoplevaccinated/population)*100
from PopvsVac



--Temp Table


Drop table if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccination Numeric,
Rollingpeoplevaccinated Numeric
)

INSERT INTO #Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations as int)) OVER (partition by 
dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- (ROllingpeoplevaccinated/population)*100
from COVID_PROJECT..CovidDeaths dea
JOIN COVID_PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null

Select *, (ROllingpeoplevaccinated/population)*100
from #Percentpopulationvaccinated;



--VIEW to store data for later visualization


Create view Percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(vac.new_vaccinations as int)) OVER (partition by 
dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- (ROllingpeoplevaccinated/population)*100
from COVID_PROJECT..CovidDeaths dea
JOIN COVID_PROJECT..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--Order by 2,3;

	
Select *
From Percent_population_vaccinated;
 

