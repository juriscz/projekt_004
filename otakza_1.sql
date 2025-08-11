-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT
    year,
    industry_name,
    ROUND(AVG(avg_wage)::numeric, 2) AS avg_wage
FROM t_jiri_nemec_project_sql_primary_final
GROUP BY year, industry_name
ORDER BY industry_name, year;