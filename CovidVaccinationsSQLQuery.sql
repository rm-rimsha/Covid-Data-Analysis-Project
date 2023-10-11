Select * From CovidVaccination;

-- Shows the countinent with highest vaccination rate per hundred people
Select d.continent, MAX(v.total_vaccinations_per100) as MaxVaccinationRate
From CovidVaccination v JOIN CovidDeaths d on v.country = d.country
Group by d.continent
Order by MaxVaccinationRate DESC;

--Shows the countries with the highest and lowest vaccination rate
Select d.country, Max(v.total_vaccinations_per100) as MaxVaccinationRate
From CovidVaccination v JOIN CovidDeaths d on v.country = d.country
Group by d.country
Order by MaxVaccinationRate Desc;

--Shows the total number of vaccinations in the United Kingdom
Select Distinct d.country, v.total_vaccinations
From CovidVaccination v JOIN CovidDeaths d ON v.country = d.country
Where d.country = 'United Kingdom';


--Shows the total number of vaccinations in the country
Select Distinct TOP 25 d.country, v.total_vaccinations
From CovidVaccination v JOIN CovidDeaths d ON v.country = d.country
Order by v.TOTAL_VACCINATIONS DESC;


--Shows the percentage of people vaccinated in each contient using CTE
With PercentagePeopleVaccinated as 
	(Select d.continent as Continent,
			p.population as Population,
			v.persons_vaccinated_1plus_dose as PeopleVaccinated,
			v.persons_vaccinated_1plus_dose/p.Population*100 as PercentagePeopleVaccinated
	From CovidVaccination v 
		JOIN CovidDeaths d on v.country = d.country 
		JOIN Population p on d.country = p.Entity
	Group by d.continent, p.Population,v.persons_vaccinated_1plus_dose)

Select Continent, MAX(Population), MAX(PeopleVaccinated), MAX(PercentagePeopleVaccinated)
From PercentagePeopleVaccinated
group by continent;

--Shows the percentage of people vaccinated in each country using CTE
With PercentagePeopleVaccinated as 
	(Select d.country as Country,
			p.population as Population,
			v.persons_vaccinated_1plus_dose as PeopleVaccinated,
			v.persons_vaccinated_1plus_dose/p.Population*100 as PercentagePeopleVaccinated
	From CovidVaccination v 
		JOIN CovidDeaths d on v.country = d.country 
		JOIN Population p on d.country = p.Entity
	Group by d.country, p.Population, v.persons_vaccinated_1plus_dose)

Select Country, Population, PeopleVaccinated, PercentagePeopleVaccinated 
From PercentagePeopleVaccinated
Where PercentagePeopleVaccinated < 100
Order by PercentagePeopleVaccinated DESC;

--Shows the country with High Booster Dose
Select country,
       persons_booster_add_dose_per100 as HighBoosterDoseRate
From CovidVaccination
Order by HighBoosterDoseRate DESC;


--USING VACCINES META DATA
Select * From VaccinationMetaData;

--Shows the vaccines in each country
Select Distinct v.country as Country,
	   m.vaccine_name as VaccineName
From CovidVaccination v JOIN VaccinationMetaData m on v.iso3 = m.iso3
Group by v.country, m.VACCINE_NAME;

--Shows the vaccines used in the most countries
Select TOP 5 m.vaccine_name as VaccineName,
	   Count(m.vaccine_name) as NumberOfCountries
From CovidVaccination v JOIN VaccinationMetaData m on v.iso3 = m.iso3
Group by m.VACCINE_NAME
Order by count(m.vaccine_name) Desc;
