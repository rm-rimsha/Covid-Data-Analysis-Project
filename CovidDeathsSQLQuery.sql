Select * From CovidDeaths;

-- Using CovidDeaths Table
Select continent, country, Date_reported, new_cases, new_deaths 
From CovidDeaths
Order by country, Date_reported;


-- GLOBAL NUMBERS --

-- Shows the total cases and total deaths reported 
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths;

-- Shows the total cases and total deaths reported each year
Select Year(date_reported) as Year, SUM(Convert(bigint,new_cases)) as TotalCases, SUM(Convert(bigint,new_deaths)) as TotalDeaths
From CovidDeaths
Group by Year(date_reported)
Order by Year(date_reported);

-- Shows the percentage of people died out of the people diagnosed with covid over the years since 2020
Select Year(date_reported) as Year, SUM(Convert(bigint,new_cases)) as TotalCases, SUM(Convert(bigint,new_deaths)) as TotalDeaths,
CASE
		When SUM(new_cases) = 0 THEN 0
		ELSE (SUM(new_deaths)/ (NULLIF(SUM(new_cases),0))*100)
	END AS DeathPercentage
From CovidDeaths
Group by Year(date_reported)
Order by Year(date_reported);

--Shows the percentage of people died out of the people diagnosed with covid in each country 
--Analysis of this gives better overview of the death percentages over the years 2020-2023
Select Date_reported, 
	country,
	Cumulative_cases as TotalCases, 
	Cumulative_deaths as TotalDeaths,
	CASE
		When Cumulative_cases = 0 THEN 0
		ELSE (Cumulative_deaths/ (NULLIF(Cumulative_cases,0))*100)
	END AS DeathPercentage
From CovidDeaths
Group by Date_reported, country,Cumulative_cases, Cumulative_deaths
Order by Country;

--Using the population table as well using JOINS
Select * From Population;

Select * From CovidDeaths c JOIN Population p on c.Country = p.Entity;

Select * From CovidDeaths c FULL OUTER JOIN Population p on c.Country = p.Entity OR c.Continent = p.Entity;

--Shows the percentage of people who got covid and died per population in the world
Select MAX(p.population) as WorldPopulation,
	SUM(c.new_cases) as TotalCases,
	SUM(c.New_deaths) as TotalDeaths,
	SUM(c.new_cases)/Max(p.population)*100 as PercentagePopulationGotCovid,
	SUM(c.new_deaths)/Max(p.population)*100 as PercentagePopulationDied
From CovidDeaths c FULL OUTER JOIN Population p on c.Country = p.Entity;

-- Shows the trend of percentage of people who got covid and died due to covid over the years
Select c.Date_reported as Year,
	c.country,
	p.Population,
	c.Cumulative_cases as TotalCases, 
	c.Cumulative_deaths as TotalDeaths,
	c.Cumulative_cases/p.population*100 as PopulationPercentageGotCovid,
	c.Cumulative_deaths/p.Population*100 as PopulationPercentageDied
From CovidDeaths c JOIN Population p on c.Country = p.Entity
Group by c.Date_reported,c.Country, p.Population, c.Cumulative_cases, c.Cumulative_deaths
Order by c.Country;


-- CONTINENTS -- 

--Shows the total cases and total deaths reported in each continent
Select continent, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Group by continent
Order by TotalDeaths DESC;

-- Shows the probability of people contracting covid, dying due to covid per population in each continent
Select c.continent, 
	   MAX(c.Cumulative_cases) as HighestInfectionRate, 
	   MAX(c.Cumulative_deaths) as HighestDeathCount, 
	   MAX((c.Cumulative_cases/p.population))*100 as PopulationInfected,
	   MAX((c.Cumulative_deaths/p.population))*100 as PopulationDied
From CovidDeaths c JOIN Population p ON c.Continent = p.Entity
Group by c.continent
Order by c.Continent;


-- COUNTRY -- 

--Shows the likelihood of dying if you contract covid in this country
Select country as Location,
	Date_reported as Date,
	new_cases as TotalCases,
	new_deaths as TotalDeaths,
		CASE
		When New_cases = 0 THEN 0
		ELSE (New_deaths/ (NULLIF(New_cases,0))*100)
	END AS DeathPercentage
From CovidDeaths
Where country = 'Pakistan'
Order by location, date;

--Shows the percentage of population infected in this country
Select c.country as Location,
	c.Date_reported as Date,
	p.population as Population,
	c.new_cases as TotalCases,
	(c.New_cases/p.Population)*100 as PercentageInfected
From CovidDeaths c JOIN Population p ON c.Country = p.Entity
Where c.country = 'Pakistan'
Order by location, date;


--Shows the percentage of population died in this country
Select c.country as Location,
	c.Date_reported as Date,
	p.population as Population,
	c.new_deaths as TotalDeaths,
	(c.New_deaths/p.Population)*100 as PercentageInfected
From CovidDeaths c JOIN Population p ON c.Country = p.Entity
Where c.country = 'Pakistan'
Order by location, date;

--Rolling the number of cases reported for each country USING PARTITION BY OVER THE COUNTRY
Select country as Country,
	   date_reported as Date,
	   new_cases as NewCases,
	   SUM(new_cases) OVER (Partition by country order by country, date_reported) as TotalCases
From CovidDeaths
Order by country, Date_reported;

-- Shows the top 25 countries with the highest percentage of population infected
Select TOP 25 c.country, 
	   MAX(c.Cumulative_cases) as HighestInfectionRate, 
	   MAX(c.Cumulative_deaths) as HighestDeathCount, 
	   CASE
		When SUM(c.new_cases) = 0 THEN 0
		ELSE (SUM(c.new_deaths)/ (NULLIF(SUM(c.new_cases),0))*100)
	END AS DeathPercentage,
	   MAX((c.Cumulative_cases/p.population))*100 as PercentagePopulationInfected
From CovidDeaths c JOIN Population p ON c.Continent = p.Entity
Group by c.country
Order by PercentagePopulationInfected Desc;
