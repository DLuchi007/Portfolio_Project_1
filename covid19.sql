select * from project..covid_death
order by 3,4


--select data that are going to be used
Select location, date, total_cases, new_cases, population
from project..covid_death
order by 1,2

--total_cases vs population
Select location, date, total_cases, population, (total_cases/population) *100 as infection_ratio
from project..covid_death
order by 1,2

--country with highest infection rate compared to population
Select location, total_cases, population, max(total_cases/population) *100 as infected_population_percentage
from project..covid_death
Group by location, population, total_cases
order by infected_population_percentage desc

--select Nigeria data that are going to be used
Select location, date, total_cases, new_cases, population
from project..covid_death
where location like '%Nigeria%'
order by 1,2

--looking at Africa cases
Select location, date, population, total_cases, total_deaths
from project..covid_death
where continent like '%afric%'
order by 1,3

--Africa total_cases vs population
Select location,population, (cast(total_cases as int)/population)*100 as percentage_population_by_case
from project..covid_death
where continent like '%afri%'
order by percentage_population_by_case desc

--highest africa infected country by population
Select location, population, max(cast(total_cases as int)/population) *100 as infected_population_percentage
from project..covid_death
where continent like '%afri%'
Group by location, population
order by infected_population_percentage desc

--highest africa death_count country
Select location, population, max(cast(total_deaths as int)) as  death_count
from project..covid_death
where continent like '%afri%'
Group by location, population
order by death_count desc

--highest africa death_count country by population
Select location, population, max(cast(total_deaths as int)/population)*100 as  percentage_death_count
from project..covid_death
where continent like '%afri%'
Group by location, population
order by percentage_death_count desc

--lookig at Nigeria cases

--total_case vs population
Select location, date, total_cases, population, (total_cases/population) *100 as infection_ratio
from project..covid_death
where location like '%nigeria%'
order by 1,2

--new_cases per day
Select location, date, new_cases
from project..covid_death
where location like '%nigeria%'
order by 1,2 

--max new_case
Select location, date, total_cases, population, (total_cases/population) *100 as infection_ratio
from project..covid_death
where location like '%nigeria%'
order by 1,2

--Nigeria highest infected percentage
Select location, population, max(total_cases/population) *100 as infected_population_percentage
from project..covid_death
where location like '%nigeria%'
Group by location, population


--nigeria death count per population
Select location,population, (cast(total_deaths as int)/population) *100 as percentage_total_death_count
from project..covid_death
where location like '%nigeria%'
order by percentage_total_death_count desc


--nigeria death count
Select location,population,cast(total_deaths as int) as total_death
from project..covid_death
where location like '%nigeria%'
order by total_death desc

--nigeria highest death count
Select location,population,max(cast(total_deaths as int)) as highest_death_count
from project..covid_death
where location like '%nigeria%'
group by location, population

--nigeria total_case vs total_death
Select location,date, total_cases, total_deaths, (cast(total_cases as int)/cast(total_deaths as int)) as case_count
from project..covid_death
where location like '%nigeria%'
order by case_count desc


-----covid_vaccination
select * from project..covid_vacinations

--merging the two tables
select*
from project..covid_death cd
join project..covid_vacinations cv
	on cd.location = cv.location
	and cd.date =cv.date

--looking at total population vs vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from project..covid_death cd
join project..covid_vacinations cv
	on cd.location = cv.location
	and cd.date =cv.date
where cd.continent is not null
order by 1,2

--looking at total population and vaccination (rolling count)
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location
order by cd.location, cd.date) as vaccination_count
from project..covid_death cd
join project..covid_vacinations cv
	on cd.location = cv.location
	and cd.date =cv.date
where cd.continent is not null
order by 2,3


--TEMP TABLE
--looking at total population vs vaccination (rolling count)
drop table if exists #Percentage_Population_Vaccinated
create table #Percentage_Population_Vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_pep_vaccinated numeric
)
insert into #Percentage_Population_Vaccinatd

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location
order by cd.location, cd.date) as Rolling_pep_vaccinated
from project..covid_death cd
join project..covid_vacinations cv
	on cd.location = cv.location
	and cd.date =cv.date
where cd.continent is not null

select*, (rolling_pep_vaccinated/population)*100
from #Percentage_Population_Vaccinated

--creating views to store data for visualization for later
create view Percentage_Population_Vaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location
order by cd.location, cd.date) as Rolling_pep_vaccinated
from project..covid_death cd
join project..covid_vacinations cv
	on cd.location = cv.location
	and cd.date =cv.date
where cd.continent is not null
