-- 1. DROP
DROP TABLE IF EXISTS t_jiri_nemec_project_sql_secondary_final;

-- 2. VYTVOŘENÍ TABULKY
CREATE TABLE t_jiri_nemec_project_sql_secondary_final AS
WITH eu_countries AS (
  SELECT DISTINCT
         c.country,
         c.continent
  FROM data_academy_content.countries c
  WHERE c.continent = 'Europe'
),
econ_dedup AS (
  SELECT
      e.country,
      e.year,
      MAX(e.gdp)        AS gdp,
      MAX(NULLIF(e.gini,0)) AS gini,
      MAX(e.population) AS population
  FROM data_academy_content.economies e
  GROUP BY e.country, e.year
)
SELECT
    ec.country        AS country_name,
    ed.year,
    ed.gdp::numeric       AS gdp,
    ed.gini::numeric      AS gini,
    ed.population::numeric AS population
FROM eu_countries ec
JOIN econ_dedup ed
  ON ed.country = ec.country
ORDER BY country_name, year;
