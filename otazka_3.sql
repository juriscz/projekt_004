-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
WITH ceny AS (
    SELECT
        year,
        food_name,
        AVG(avg_price) AS avg_price
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year, food_name
),
mezinarust AS (
    SELECT
        food_name,
        year,
        avg_price,
        LAG(avg_price) OVER (PARTITION BY food_name ORDER BY year) AS prev_price
    FROM ceny
),
vypocet AS (
    SELECT
        food_name,
        year,
        ((avg_price - prev_price) / prev_price) * 100 AS yoy_growth_pct
    FROM mezinarust
    WHERE prev_price IS NOT NULL
)
SELECT
    food_name,
    ROUND(AVG(yoy_growth_pct), 2) AS avg_yearly_growth_pct
FROM vypocet
GROUP BY food_name
ORDER BY avg_yearly_growth_pct ASC;
