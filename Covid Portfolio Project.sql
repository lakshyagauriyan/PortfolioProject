Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the Likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
order by 1,2

--Looking as Total Cases vs Population

Select location, date, total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
order by 1,2

--Looking at Countries with highest Infection Rate vs  Population

Select location, Max(total_cases) as HighestInfectionCount, population, 
Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100) AS InfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location,population
order by Infectedpercentage Desc


--Showing the Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
order by TotalDeathCount Desc


--Showing the Continent with Highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount Desc

--Global Numbers

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE


With PopVsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, convert(bigint,dea.population), convert(bigint,vac.new_vaccinations)
, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/nullif(Population,0))*100
From PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, convert(bigint,dea.population), convert(bigint,vac.new_vaccinations)
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Nullif(Population,0))*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
