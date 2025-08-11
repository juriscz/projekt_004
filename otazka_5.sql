-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
WITH cz_data AS (
    SELECT
        year,
        ROUND(AVG(avg_wage), 2) AS wage,
        ROUND(AVG(avg_price), 2) AS price
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year
),
cz_growth AS (
    SELECT
        year,
        wage,
        price,
        LAG(wage) OVER (ORDER BY year) AS prev_wage,
        LAG(price) OVER (ORDER BY year) AS prev_price
    FROM cz_data
),
cz_growth_pct AS (
    SELECT
        year,
        ROUND(((wage - prev_wage) / prev_wage) * 100, 2) AS wage_growth_pct,
        ROUND(((price - prev_price) / prev_price) * 100, 2) AS price_growth_pct
    FROM cz_growth
    WHERE prev_wage IS NOT NULL AND prev_price IS NOT NULL
),
gdp_data AS (
    SELECT
        year,
        ROUND(AVG(gdp)::numeric, 2) AS gdp  -- důležité: agregace HDP, aby byl 1 záznam / rok
    FROM t_jiri_nemec_project_sql_secondary_final
    WHERE country_name = 'Czech Republic'
    GROUP BY year
),
gdp_growth AS (
    SELECT
        year,
        gdp,
        LAG(gdp) OVER (ORDER BY year) AS prev_gdp
    FROM gdp_data
),
gdp_growth_pct AS (
    SELECT
        year,
        ROUND(((gdp - prev_gdp) / prev_gdp) * 100, 2) AS gdp_growth_pct
    FROM gdp_growth
    WHERE prev_gdp IS NOT NULL
),
final AS (
    SELECT
        g.year,
        g.gdp_growth_pct,
        c1.wage_growth_pct AS wage_growth_same_year,
        c1.price_growth_pct AS price_growth_same_year,
        c2.wage_growth_pct AS wage_growth_next_year,
        c2.price_growth_pct AS price_growth_next_year
    FROM gdp_growth_pct g
    LEFT JOIN cz_growth_pct c1 ON c1.year = g.year
    LEFT JOIN cz_growth_pct c2 ON c2.year = g.year + 1
)
SELECT *
FROM final
ORDER BY year;