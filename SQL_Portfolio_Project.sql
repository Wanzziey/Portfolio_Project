-- total cases vs population in POLAND

SELECT Location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS '%cases_all'
FROM Portfolio_Project..Covid_Deaths
WHERE location='Poland'
ORDER BY 1,2

--highest amount of total cases in every country

SELECT Location, population, MAX(total_cases) AS highest_amount_of_cases
FROM Portfolio_Project..Covid_Deaths
WHERE CONTINENT IS NOT NULL
GROUP BY location, population
ORDER BY highest_amount_of_cases DESC

--highest amount of total cases in every Region(+EU & World count)

SELECT Location, MAX(total_cases) AS highest_amount_of_cases
FROM Portfolio_Project..Covid_Deaths
WHERE CONTINENT IS NULL
GROUP BY location, population
ORDER BY highest_amount_of_cases DESC

--showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- highest amount of total deaths in every Region(+EU & World count)

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--showing continents with the highest deathcount

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers

SELECT SUM(MAX(total_cases)) AS suma, continent
FROM Portfolio_Project..Covid_Deaths
ORDER BY continent

--total cases by location

SELECT location, MAX(total_cases) AS quantity
FROM Portfolio_Project..Covid_Deaths
GROUP BY location 
ORDER BY quantity DESC

-- Creating new table showing %vaccinated, creating total of vaccinated people column
USE Portfolio_Project
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
ON dea.location=vac.location AND vac.date=dea.date


Select *, (RollingPeopleVaccinated/Population)*100 AS '%vaccinated'
From #PercentPopulationVaccinated

--creating view
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location=vac.location AND vac.date=dea.date
	WHERE dea.continent IS NOT NULL
