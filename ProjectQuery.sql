select *
from Portfolio_project..covid_deaths
where continent is not NULL

--death percentage
Select location,currentdate,total_cases,total_deaths,Population,(total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..Covid_deaths
where location like 'India'
order by 1,2

--covidspread
Select location,currentdate,total_cases,Population,(total_cases/population)*100 as Covidspread
From Portfolio_Project..Covid_deaths
where location like 'India'
order by 1,2

--highest covidspread
Select location,Population,max(cast(total_cases as int)) as Max_Cases,max((total_cases/population)*100) as Covidspread
From Portfolio_Project..Covid_deaths
where continent is not null
group by location,Population
order by 4 desc

--Covid mortality rate
Select location,Population,max(cast (total_deaths as int)) as Max_deaths,max((total_deaths/population)*100) as Mortality_Rate
From Portfolio_Project..Covid_deaths
where continent is not null
group by location,Population
order by 4 desc

--Country-wise deathcount
Select location,Population,max(cast(total_deaths as int)) as Death_Count
From Portfolio_Project..Covid_deaths
where continent is not null
group by location,Population
order by Death_Count desc

--Continent-wise deathcount
Select location,max(cast(total_deaths as int)) as Death_Count
From Portfolio_Project..Covid_deaths
where continent is null and location not like '%income%'
group by location
order by Death_Count desc

--or (mostly incorrect data)

--Select continent,max(cast(total_deaths as int)) as Death_Count
--From Portfolio_Project..Covid_deaths
--where continent is not null
--group by continent
--order by Death_Count desc

--Global Data
Select currentdate, sum(new_cases) as daily_cases,sum(cast(new_deaths as int)) as daily_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
From Portfolio_Project..Covid_deaths
where continent is not null 
group by currentdate
having sum(new_cases) not like 0

order by 1,2

--Population vs Vaccinations

Select dea.continent,dea.location, dea.currentdate,dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.currentdate) as PeopleVaccinated_Tilldate
from Portfolio_Project..Covid_deaths dea
join Portfolio_Project..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.currentdate = vac.date
where dea.continent is not null
order by 2,3

with PopvsVac (Continent, Location, CurrentDate,Population,New_Vaccinations, PeopleVaccinated_Tilldate)
as 
(
Select dea.continent,dea.location, dea.currentdate,dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.currentdate) as PeopleVaccinated_Tilldate
from Portfolio_Project..Covid_deaths dea
join Portfolio_Project..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.currentdate = vac.date
where dea.continent is not null
)
Select *,(PeopleVaccinated_Tilldate/population)*100 as Percentage_of_People_Vaccinated
from PopvsVac
where Location = 'India'

Create View PeopleVaccinate as 
Select dea.continent,dea.location, dea.currentdate,dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.currentdate) as PeopleVaccinated_Tilldate
from Portfolio_Project..Covid_deaths dea
join Portfolio_Project..Covid_vaccinations vac
	on dea.location = vac.location
	and dea.currentdate = vac.date
where dea.continent is not null
--order by 2,3
