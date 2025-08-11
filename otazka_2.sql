-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
WITH ceny AS (
    SELECT year, food_name, AVG(avg_price) AS avg_price
    FROM t_jiri_nemec_project_sql_primary_final
    WHERE food_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
    GROUP BY year, food_name
),
mzdy AS (
    SELECT year, AVG(avg_wage) AS avg_wage
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year
),
spojene AS (
    SELECT
        c.year,
        c.food_name,
        c.avg_price,
        m.avg_wage,
        ROUND(m.avg_wage / c.avg_price, 2) AS quantity_affordable
    FROM ceny c
    JOIN mzdy m ON c.year = m.year
)
SELECT *
FROM spojene
WHERE year IN (
    (SELECT MIN(year) FROM spojene),
    (SELECT MAX(year) FROM spojene)
)
ORDER BY food_name, year;