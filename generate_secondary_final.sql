-- 1) Smazat starou verzi
DROP TABLE IF EXISTS t_jiri_nemec_project_sql_secondary_final;

-- 2) Vytvořit sekundární tabulku
CREATE TABLE t_jiri_nemec_project_sql_secondary_final AS
WITH eu_countries AS (
  -- DISTINCT kvůli jistotě, kdyby countries obsahovaly duplicitní názvy
  SELECT DISTINCT
         c.country,          -- textový název země (v datasets Engeto bývá v tomto sloupci název)
         c.continent
  FROM data_academy_content.countries c
  WHERE c.continent = 'Europe'
),
econ_dedup AS (
  -- Kdyby economies náhodou měly více řádků pro tutéž dvojici (country, year),
  -- sjednotíme je agregací. MAX je bezpečné pro shodné hodnoty; pokud by se lišily,
  -- máš aspoň deterministický výsledek (můžeš nahradit AVG/SUM dle potřeby).
  SELECT
      e.country,
      e.year,
      MAX(e.gdp)        AS gdp,
      MAX(NULLIF(e.gini,0)) AS gini,   -- 0 → NULL, pokud je v datasetu „nula“ místo chybějící hodnoty
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
-- Pokud chceš omezit na stejné období jako primární tabulka:
-- WHERE ed.year BETWEEN 2006 AND 2018
ORDER BY country_name, year;
