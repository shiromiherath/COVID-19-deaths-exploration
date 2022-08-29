/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
--WHERE location LIKE '%States%'
GROUP BY population, location
ORDER BY percent_population_infected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS highest_death_count
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT location, MAX(total_deaths) AS highest_death_count
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
--WHERE location LIKE '%States%'
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM `geometric-vim-314715.covid_data_project.covid_deaths`
--WHERE location LIKE '%States%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
, (rolling_people_vaccinated/dea.population)*100
FROM `geometric-vim-314715.covid_data_project.covid_deaths` AS dea
JOIN `geometric-vim-314715.covid_data_project.covid_vaccinations` AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `geometric-vim-314715.covid_data_project.covid_deaths` AS dea
JOIN `geometric-vim-314715.covid_data_project.covid_vaccinations` AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
Select *, (rolling_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM pop_vs_vac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS `geometric-vim-314715.covid_data_project.percent_population_vaccinated`;
CREATE TABLE `geometric-vim-314715.covid_data_project.percent_population_vaccinated`
( `continent` STRING,
`location` STRING,
`date` DATE,
`population` INT64,
`new_vaccinations` INT64,
`rolling_people_vaccinated` INT64
)

INSERT INTO `geometric-vim-314715.covid_data_project.percent_population_vaccinated`
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `geometric-vim-314715.covid_data_project.covid_deaths` AS dea
JOIN `geometric-vim-314715.covid_data_project.covid_vaccinations` AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Select *, (rolling_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM `geometric-vim-314715.covid_data_project.percent_population_vaccinated`

-- Creating View to store data for later visualizations

CREATE VIEW `geometric-vim-314715.covid_data_project.percent_population_vaccinated_view` AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `geometric-vim-314715.covid_data_project.covid_deaths` AS dea
JOIN `geometric-vim-314715.covid_data_project.covid_vaccinations` AS vac
    ON dea.location = vac.location 
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
