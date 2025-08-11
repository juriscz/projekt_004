DROP TABLE IF EXISTS t_jiri_nemec_project_sql_secondary_final;

CREATE TABLE t_jiri_nemec_project_sql_secondary_final AS
WITH
-- 1. Společné roky z primární tabulky
common_years AS (
    SELECT DISTINCT year
    FROM data_academy_content.t_jiri_nemec_project_sql_primary_final
),
-- 2. Evropské státy (ze tabulky countries)
european_countries AS (
    SELECT country
    FROM data_academy_content.countries
    WHERE continent = 'Europe'
),
-- 3. Ekonomická data (převzata z economies)
economy_data AS (
    SELECT 
        e.country,
        e.year,
        ROUND(e.gdp::numeric, 2) AS gdp,
        ROUND(e.gini::numeric, 2) AS gini,
        e.population
    FROM data_academy_content.economies e
)
-- 4. Výstup: spojení podle názvu státu a roku
SELECT
    e.country AS country_name,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM economy_data e
JOIN european_countries c ON e.country = c.country
JOIN common_years y ON e.year = y.year
ORDER BY e.country, e.year;
