Select  location, date, new_cases, total_cases, total_deaths, population
From PortfolioProject..['coviddeaths']
Order by 1,2


-- Looking at percentage of total cases vs total deaths in the UK
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeaths
From PortfolioProject..['coviddeaths']
Where location = 'United Kingdom'
Order by 1,2


-- Total cases vs Total population
Select location, date, total_cases, total_deaths, (total_cases/population)*100 as CasesPerPop
From PortfolioProject..['coviddeaths']
Where location = 'United Kingdom'
Order by 1,2


-- Highest Infection Rates compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['coviddeaths']
Group by location, population
Order by PercentPopulationInfected desc



--Total deaths by country, total_deaths cast as int due to the data type of nvarchar(255)
select location, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..['coviddeaths']
where continent is not null
Group by location
Order by TotalDeaths desc


--Total deaths by continent
select continent, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..['coviddeaths']
where continent is not null
Group by continent
Order by TotalDeaths desc


--Joining Covid Deaths and vaccinations
Select *
From PortfolioProject..['coviddeaths'] as dea
Join PortfolioProject..vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	

--Rolling vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated, 
From PortfolioProject..['coviddeaths'] as dea
Join PortfolioProject..vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 1,2,3


--Rolling Percentage of Population Vaccinated with CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated 
From PortfolioProject..['coviddeaths'] as dea
Join PortfolioProject..vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select*, (RollingPeopleVaccinated/Population)*100 as PercentVac
From PopvsVac



--Rolling Percentage of Population Vaccinated with Temp table

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatoins numeric,
RollingPeopleVaccinated numeric,
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated 
From PortfolioProject..['coviddeaths'] as dea
Join PortfolioProject..vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select*, (RollingPeopleVaccinated/Population)*100 as PercentVac
From PercentPopulationVaccinated


--Creating a view of PercentPopulaitonVaccinated

Create View PercentPopulaitonVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as 
RollingPeopleVaccinated 
From PortfolioProject..['coviddeaths'] as dea
Join PortfolioProject..vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

