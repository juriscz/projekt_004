-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH mzdy AS (
    SELECT
        year,
        AVG(avg_wage) AS wage
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year
),
ceny AS (
    SELECT
        year,
        AVG(avg_price) AS price
    FROM t_jiri_nemec_project_sql_primary_final
    GROUP BY year
),
spojene AS (
    SELECT
        m.year,
        m.wage,
        c.price,
        LAG(m.wage) OVER (ORDER BY m.year) AS prev_wage,
        LAG(c.price) OVER (ORDER BY c.year) AS prev_price
    FROM mzdy m
    JOIN ceny c ON m.year = c.year
),
vypocet AS (
    SELECT
        year,
        ROUND(((price - prev_price) / prev_price) * 100, 2) AS price_growth_pct,
        ROUND(((wage - prev_wage) / prev_wage) * 100, 2) AS wage_growth_pct,
        ROUND(
            ((price - prev_price) / prev_price) * 100
            - ((wage - prev_wage) / prev_wage) * 100, 2
        ) AS difference
    FROM spojene
    WHERE prev_wage IS NOT NULL AND prev_price IS NOT NULL
)
SELECT *
FROM vypocet
ORDER BY year;