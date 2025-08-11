-- 1. DROP
DROP TABLE IF EXISTS t_jiri_nemec_project_sql_primary_final;

-- 2. VYTVOŘENÍ TABULKY
CREATE TABLE t_jiri_nemec_project_sql_primary_final AS
WITH
-- 3. Výběr mezd
wage_data AS (
    SELECT
        p.payroll_year AS year,
        COALESCE(ib.name, 'Celkem') AS industry_name,
        ROUND(AVG(p.value)::numeric, 2) AS avg_wage
    FROM data_academy_content.czechia_payroll p
    JOIN data_academy_content.czechia_payroll_value_type vt ON p.value_type_code = vt.code
    JOIN data_academy_content.czechia_payroll_calculation calc ON p.calculation_code = calc.code
    JOIN data_academy_content.czechia_payroll_unit u ON p.unit_code = u.code
    LEFT JOIN data_academy_content.czechia_payroll_industry_branch ib ON p.industry_branch_code = ib.code
    WHERE
        p.value_type_code = 5958   -- průměrná mzda
        AND p.calculation_code = 100  -- přepočtené osoby
        AND p.unit_code = 200         -- Kč
    GROUP BY p.payroll_year, ib.name
),
-- 4. Výběr cen potravin
price_data AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        cat.name AS food_name,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_price
    FROM data_academy_content.czechia_price cp
    JOIN data_academy_content.czechia_price_category cat ON cp.category_code = cat.code
    GROUP BY EXTRACT(YEAR FROM cp.date_from), cat.name
),
-- 5. Roky, které jsou ve mzdách i cenách (společné roky)
common_years AS (
    SELECT DISTINCT w.year
    FROM wage_data w
    INNER JOIN price_data p ON w.year = p.year
)
-- 6. Finální spojení mezd a cen na základě společných roků
SELECT
    w.year,
    w.industry_name,
    w.avg_wage,
    p.food_name,
    p.avg_price
FROM wage_data w
JOIN common_years y ON w.year = y.year
JOIN price_data p ON w.year = p.year
ORDER BY w.year, w.industry_name, p.food_name;
