-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
WITH
cz_data AS (
    SELECT
        year,
        AVG(avg_wage)  AS wage,
        AVG(avg_price) AS price
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year
),
cz_growth_pct AS (
    SELECT
        year,
        100.0 * (wage  / NULLIF(LAG(wage)  OVER (ORDER BY year), 0) - 1) AS wage_growth_pct,
        100.0 * (price / NULLIF(LAG(price) OVER (ORDER BY year), 0) - 1) AS price_growth_pct
    FROM cz_data
),
gdp_data AS (
    SELECT
        year,
        AVG(gdp)::numeric AS gdp
    FROM t_jiri_nemec_project_sql_secondary_final
    WHERE LOWER(country_name) IN ('czech republic', 'česká republika', 'cesko', 'česko', 'cze')
      AND gdp IS NOT NULL
    GROUP BY year
),
gdp_growth_pct AS (
    SELECT
        year,
        100.0 * (gdp / NULLIF(LAG(gdp) OVER (ORDER BY year), 0) - 1) AS gdp_growth_pct
    FROM gdp_data
),
aligned AS (
    SELECT
        g.year,
        g.gdp_growth_pct,
        c1.wage_growth_pct  AS wage_growth_same_year,
        c1.price_growth_pct AS price_growth_same_year,
        c2.wage_growth_pct  AS wage_growth_next_year,
        c2.price_growth_pct AS price_growth_next_year
    FROM gdp_growth_pct g
    LEFT JOIN cz_growth_pct c1 ON c1.year = g.year
    LEFT JOIN cz_growth_pct c2 ON c2.year = g.year + 1
    WHERE g.gdp_growth_pct IS NOT NULL
),
thresholds AS (
    SELECT
        (SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY gdp_growth_pct)  FROM aligned) AS gdp_p75,
        (SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY wage_growth_same_year)  FROM aligned WHERE wage_growth_same_year  IS NOT NULL) AS wage_same_p75,
        (SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY price_growth_same_year) FROM aligned WHERE price_growth_same_year IS NOT NULL) AS price_same_p75,
        (SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY wage_growth_next_year)  FROM aligned WHERE wage_growth_next_year  IS NOT NULL) AS wage_next_p75,
        (SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY price_growth_next_year) FROM aligned WHERE price_growth_next_year IS NOT NULL) AS price_next_p75
),
answer AS (
    SELECT
        a.year,
        ROUND(a.gdp_growth_pct, 2)                 AS gdp_growth_pct,
        ROUND(a.wage_growth_same_year, 2)          AS wage_growth_same_year,
        ROUND(a.price_growth_same_year, 2)         AS price_growth_same_year,
        ROUND(a.wage_growth_next_year, 2)          AS wage_growth_next_year,
        ROUND(a.price_growth_next_year, 2)         AS price_growth_next_year,
        (a.gdp_growth_pct >= t.gdp_p75)            AS gdp_growth_is_high,
        (a.wage_growth_same_year >= t.wage_same_p75)   AS wage_same_is_high,
        (a.price_growth_same_year >= t.price_same_p75) AS price_same_is_high,
        (a.wage_growth_next_year >= t.wage_next_p75)   AS wage_next_is_high,
        (a.price_growth_next_year >= t.price_next_p75) AS price_next_is_high
    FROM aligned a
    CROSS JOIN thresholds t
)
SELECT *
FROM answer
ORDER BY year;
