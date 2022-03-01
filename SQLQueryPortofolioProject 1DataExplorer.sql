
Select *
From PortfolioProject.dbo.Coviddeath
where continent is not null
order by 3,4


--Select *
--From PortfolioProject.dbo.Covidvaccinations
--order by 3,4

--Select Data that we are going to be using

--Looking at Total Cases vs Total Deaths 
--Shows likehood of dying you contract covid in your country

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.Coviddeath
Where location like '%state%'
--where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
order by 1,2

---Looking at countries with Highest Infection Rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
Group by Location, population 
order by PercentPopulationInfected desc

--Showing at countries with Highest Death Rate per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
Group by Location 
order by TotalDeathCount desc


---Lets break things down by continent 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- showing the continent with the highest death per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
Group by continent 
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.Coviddeath
--Where location like '%state%'
where continent is not null
order by 1,2

---- not done this 

---Looking at the total population vs Vaccination
select Coviddeath.continent, Coviddeath.location,Coviddeath.date,Coviddeath.population, Covidvaccinations.new_vaccinations
, Sum(CONVERT(int, Covidvaccinations.new_vaccinations)) over (Partition by Coviddeath.Location order by Coviddeath-Location, Coviddeath.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath
Join PortfolioProject..Covidvaccinations
	On Coviddeath.location = Covidvaccinations.location
	and Coviddeath.date = Covidvaccinations.date
where Coviddeath.continent is not null
order by 2,3


---- USE CTE
With PopvsVac (continent, location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select Coviddeath.continent, Coviddeath.location, Coviddeath.date, Coviddeath.population, Covidvaccinations.new_vaccinations
, Sum(CONVERT(int,Covidvaccinations.new_vaccinations)) over (Partition by Coviddeath.Location order by Coviddeath.Location, Coviddeath.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath
Join PortfolioProject..Covidvaccinations
	On Coviddeath.location = Covidvaccinations.location
	and Coviddeath.date = Covidvaccinations.date
where Coviddeath.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac

--Temp TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select Coviddeath.continent, Coviddeath.location, Coviddeath.date, Coviddeath.population, Covidvaccinations.new_vaccinations
, Sum(CONVERT(bigint, Covidvaccinations.new_vaccinations)) over (Partition by Coviddeath.Location order by Coviddeath.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath
Join PortfolioProject..Covidvaccinations
	On Coviddeath.location = Covidvaccinations.location
	and Coviddeath.date = Covidvaccinations.date
where Coviddeath.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated

---Creating View to store data for later viusalization

Create view PercentagePopulationVaccinated as
select Coviddeath.continent, Coviddeath.location, Coviddeath.date, Coviddeath.population, Covidvaccinations.new_vaccinations
, Sum(CONVERT(int,Covidvaccinations.new_vaccinations)) over (Partition by Coviddeath.Location order by Coviddeath.location, Coviddeath.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath
Join PortfolioProject..Covidvaccinations
	On Coviddeath.location = Covidvaccinations.location
	and Coviddeath.date = Covidvaccinations.date
where Coviddeath.continent is not null
--order by 2,3

Select * 
From PercentagePopulationVaccinated
