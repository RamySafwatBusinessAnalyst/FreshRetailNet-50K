CREATE DATABASE IF NOT EXISTS freshretail_db;
USE freshretail_db;DROP TABLE IF EXISTS freshretail_daily_train;

CREATE TABLE freshretail_daily_train (
    city_id INT,
    store_id INT,
    management_group_id INT,
    first_category_id INT,
    second_category_id INT,
    third_category_id INT,
    product_id INT,
    dt DATE,
    sale_amount DOUBLE,
    stock_hour6_22_cnt INT,
    discount DOUBLE,
    holiday_flag TINYINT,
    activity_flag TINYINT,
    precpt DOUBLE,
    avg_temperature DOUBLE,
    avg_humidity DOUBLE,
    avg_wind_level DOUBLE
);

DROP TABLE IF EXISTS freshretail_daily_eval;

CREATE TABLE freshretail_daily_eval (
    city_id INT,
    store_id INT,
    management_group_id INT,
    first_category_id INT,
    second_category_id INT,
    third_category_id INT,
    product_id INT,
    dt DATE,
    sale_amount DOUBLE,
    stock_hour6_22_cnt INT,
    discount DOUBLE,
    holiday_flag TINYINT,
    activity_flag TINYINT,
    precpt DOUBLE,
    avg_temperature DOUBLE,
    avg_humidity DOUBLE,
    avg_wind_level DOUBLE
);

/* ===========================*================================
 * FreshRetailNet-50K Project
   SQL*Validation Checks
   Database: fre*hretail_db

   Purpose:
   This sc*ipt validates that the prepared da*ly CSV files were
   loaded correc*ly into MySQL.

   Tables:
   - fr*shretail_daily_train
   - freshret*il_daily_eval
   =================*==================================*======= */


/* ==================*==================================*======
   1. Select the project da*abase
   =========================*==================================**/

USE freshretail_db;


/* =====*==================================*===================
   2. Row Coun* Check

   Purpose:
   Verify that*both train and eval tables were lo*ded with the
   expected number of*rows.

   Expected:
   - freshreta*l_daily_train = 4,500,000 rows
   * freshretail_daily_eval  = 350,000*rows
   ==========================*================================= */

SELECT COUNT(*) AS train_total_rows
FROM freshretail_daily_train;
SELECT COUNT(*) AS eval_total_rows
FROM freshretail_daily_eval;


/* *==================================*========================
   3. Dat* Range Check

   Purpose:
   Confi*m that train and eval tables cover*the correct time
   periods.

   E*pected:
   - Train: 2024-03-28 to *024-06-25
   - Eval:  2024-06-26 t* 2024-07-02
   ===================*==================================*===== */

SELECT
    MIN(dt) AS train_min_date,
    MAX(dt) AS train_max_date
FROM freshretail_daily_train;

SELECT
    MIN(dt) AS eval_min_date,
    MAX(dt) AS eval_max_date 
FROM freshretail_daily_eval;


/* *==================================*========================
   4. Uni*ue Entity Count Check

   Purpose:*   Validate that the number of cit*es, stores, and products in
   MyS*L matches the Python preparation s*mmary.

   Expected:
   - unique_c*ties   = 18
   - unique_stores   =*898
   - unique_products = 865
   *==================================*======================== */

SELECT
    COUNT(DISTINCT city_id) AS unique_cities,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(DISTINCT product_id) AS unique_products
FROM freshretail_daily_train;
/* ==============================*=============================
   5* Product Hierarchy Count Check

  *Purpose:
   Confirm the number of *roduct hierarchy levels available *n
   the training dataset.

   Exp*cted:
   - management_groups = 7
 * - first_categories  = 32
   - sec*nd_categories = 84
   - third_cate*ories  = 233
   ==================*==================================*====== */

SELECT
    COUNT(DISTINCT management_group_id) AS management_groups,
    COUNT(DISTINCT first_category_id) AS first_categories,
    COUNT(DISTINCT second_category_id) AS second_categories,
    COUNT(DISTINCT third_category_id) AS third_categories
FROM freshretail_daily_train;


/* =====================*==================================*===
   6. Grain Validation Check

*  Purpose:
   Confirm that each ro* represents one unique product-sto*e-date
   observation.

   Grain:
   store_id + product_id + dt

   Expected:
   This query should return 0 rows.
   If no rows are returned, the grain is valid.
   ============================================================ */

SELECT
    store_id,
    product_id,
    dt,
    COUNT(*) AS row_count
FROM freshretail_daily_train
GROUP BY
    store_id,
    product_id,
    dt
HAVING COUNT(*) > 1;


/* ============================================================
   7. Missing Value Check

   Purpose:
   Check whether any imported column contains NULL values.

   Expected:
   All missing value counts should be 0.
   ============================================================ */

SELECT
    SUM(CASE WHEN city_id IS NULL THEN 1 ELSE 0 END) AS missing_city_id,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS missing_store_id,
    SUM(CASE WHEN management_group_id IS NULL THEN 1 ELSE 0 END) AS missing_management_group_id,
    SUM(CASE WHEN first_category_id IS NULL THEN 1 ELSE 0 END) AS missing_first_category_id,
    SUM(CASE WHEN second_category_id IS NULL THEN 1 ELSE 0 END) AS missing_second_category_id,
    SUM(CASE WHEN third_category_id IS NULL THEN 1 ELSE 0 END) AS missing_third_category_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN dt IS NULL THEN 1 ELSE 0 END) AS missing_dt,
    SUM(CASE WHEN sale_amount IS NULL THEN 1 ELSE 0 END) AS missing_sale_amount,
    SUM(CASE WHEN stock_hour6_22_cnt IS NULL THEN 1 ELSE 0 END) AS missing_stockout_cnt,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN holiday_flag IS NULL THEN 1 ELSE 0 END) AS missing_holiday_flag,
    SUM(CASE WHEN activity_flag IS NULL THEN 1 ELSE 0 END) AS missing_activity_flag,
    SUM(CASE WHEN precpt IS NULL THEN 1 ELSE 0 END) AS missing_precpt,
    SUM(CASE WHEN avg_temperature IS NULL THEN 1 ELSE 0 END) AS missing_avg_temperature,
    SUM(CASE WHEN avg_humidity IS NULL THEN 1 ELSE 0 END) AS missing_avg_humidity,
    SUM(CASE WHEN avg_wind_level IS NULL THEN 1 ELSE 0 END) AS missing_avg_wind_level
FROM freshretail_daily_train;


/* ============================================================
   8. Numeric Value Range Check

   Purpose:
   Validate the numeric ranges for the main analytical fields.

   Expected from Python:
   - sale_amount:          0.0 to 44.9
   - stock_hour6_22_cnt:   0 to 16
   - discount:             0.0 to 1.088
   ============================================================ */

SELECT
    MIN(sale_amount) AS min_sale_amount,
    MAX(sale_amount) AS max_sale_amount,
    MIN(stock_hour6_22_cnt) AS min_stockout_hours,
    MAX(stock_hour6_22_cnt) AS max_stockout_hours,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount
FROM freshretail_daily_train;


/* ============================================================
   9. Binary Flag Value Check

   Purpose:
   Confirm that binary flag columns contain only valid values.

   Expected:
   - holiday_flag  = 0, 1
   - activity_flag = 0, 1
   ============================================================ */

SELECT DISTINCT holiday_flag
FROM freshretail_daily_train
ORDER BY holiday_flag;

SELECT DISTINCT activity_flag
FROM freshretail_daily_train
ORDER BY activity_flag;


/* ============================================================
   10. Train vs Eval Continuity Check

   Purpose:
   Confirm that the evaluation period starts directly after the
   training period.

   Expected:
   - train_max_date = 2024-06-25
   - eval_min_date  = 2024-06-26
   ============================================================ */

SELECT
    (SELECT MAX(dt) FROM freshretail_daily_train) AS train_max_date,
    (SELECT MIN(dt) FROM freshretail_daily_eval) AS eval_min_date;


/* ============================================================
   11. Basic Preview Check

   Purpose:
   Quickly inspect sample records from the imported training table.
   ============================================================ */

SELECT *
FROM freshretail_daily_train
LIMIT 10;


/* ============================================================
   12. Create SQL Validation Summary View

   Purpose:
   Create a reusable validation summary view for the training table.
   This view can be queried later without rewriting the validation
   aggregation logic.
   ============================================================ */

CREATE OR REPLACE VIEW vw_train_validation_summary AS
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT city_id) AS unique_cities,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT management_group_id) AS management_groups,
    COUNT(DISTINCT first_category_id) AS first_categories,
    COUNT(DISTINCT second_category_id) AS second_categories,
    COUNT(DISTINCT third_category_id) AS third_categories,
    MIN(dt) AS min_date,
    MAX(dt) AS max_date,
    MIN(sale_amount) AS min_sale_amount,
    MAX(sale_amount) AS max_sale_amount,
    MIN(stock_hour6_22_cnt) AS min_stockout_hours,
    MAX(stock_hour6_22_cnt) AS max_stockout_hours,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount
FROM freshretail_daily_train;


/* ============================================================
   13. Query the Validation Summary View

   Purpose:
   Review the final summarized validation results.
   ============================================================ */

SELECT *
FROM vw_train_validation_summary;

/* ============================================================
   9.2.1 Create Daily Sales Base View

   Purpose:
   Create a reusable base view for the prepared daily training data.
   This view keeps the validated product-store-date grain and will
   be used as the foundation for later analytical views.
   ============================================================ */

CREATE OR REPLACE VIEW vw_daily_sales_base AS
SELECT
    city_id,
    store_id,
    management_group_id,
    first_category_id,
    second_category_id,
    third_category_id,
    product_id,
    dt,
    sale_amount,
    stock_hour6_22_cnt,
    discount,
    holiday_flag,
    activity_flag,
    precpt,
    avg_temperature,
    avg_humidity,
    avg_wind_level
FROM freshretail_daily_train;

/* ============================================================
   9.2.2 Create Product Performance View

   Purpose:
   Summarize product-level demand and stockout behavior.
   This view supports product performance analysis, ABC analysis,
   and later inventory risk segmentation.
   ============================================================ */

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    product_id,
    management_group_id,
    first_category_id,
    second_category_id,
    third_category_id,
    COUNT(*) AS total_observations,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_daily_sales,
    MAX(sale_amount) AS max_daily_sales,
    SUM(CASE WHEN sale_amount > 0 THEN 1 ELSE 0 END) AS active_sales_days,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours,
    AVG(discount) AS avg_discount
FROM vw_daily_sales_base
GROUP BY
    product_id,
    management_group_id,
    first_category_id,
    second_category_id,
    third_category_id;
    
    /* ============================================================
   9.2.3 Create Store Performance View

   Purpose:
   Summarize store-level sales and stockout behavior.
   This view supports store comparison and Power BI store-level
   dashboard visuals.
   ============================================================ */

CREATE OR REPLACE VIEW vw_store_performance AS
SELECT
    city_id,
    store_id,
    COUNT(*) AS total_observations,
    COUNT(DISTINCT product_id) AS active_products,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_daily_sales,
    MAX(sale_amount) AS max_daily_sales,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours,
    AVG(discount) AS avg_discount
FROM vw_daily_sales_base
GROUP BY
    city_id,
    store_id;
    
    /* ============================================================
   9.2.4 Create Daily Summary View

   Purpose:
   Summarize demand and stockout behavior by date.
   This view supports time-series trend analysis and dashboard
   visuals at the daily level.
   ============================================================ */

CREATE OR REPLACE VIEW vw_daily_summary AS
SELECT
    dt,
    COUNT(*) AS total_observations,
    COUNT(DISTINCT store_id) AS active_stores,
    COUNT(DISTINCT product_id) AS active_products,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_sales_per_observation,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours,
    AVG(discount) AS avg_discount
FROM vw_daily_sales_base
GROUP BY dt;

/* ============================================================
   9.2.5 Create Monthly Summary View

   Purpose:
   Aggregate daily demand into monthly business summaries.
   This view supports executive-level reporting in Power BI.
   ============================================================ */

CREATE OR REPLACE VIEW vw_monthly_summary AS
SELECT
    YEAR(dt) AS sales_year,
    MONTH(dt) AS sales_month,
    COUNT(*) AS total_observations,
    COUNT(DISTINCT store_id) AS active_stores,
    COUNT(DISTINCT product_id) AS active_products,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_sales_per_observation,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours,
    AVG(discount) AS avg_discount
FROM vw_daily_sales_base
GROUP BY
    YEAR(dt),
    MONTH(dt);
    
/* ============================================================
   9.2.6 Create Stockout Summary View

   Purpose:
   Summarize stockout exposure at product-store level.
   This view supports stockout risk monitoring and inventory
   availability analysis.
   ============================================================ */

CREATE OR REPLACE VIEW vw_product_store_stockout_summary AS
SELECT
    city_id,
    store_id,
    product_id,
    COUNT(*) AS total_days,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours,
    SUM(CASE WHEN stock_hour6_22_cnt > 0 THEN 1 ELSE 0 END) AS stockout_days,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_daily_sales
FROM vw_daily_sales_base
GROUP BY
    city_id,
    store_id,
    product_id;
    
    /* ============================================================
   9.2.7 Create Discount Preparation View

   Purpose:
   Prepare discount-level summaries to support later analysis of
   discount behavior and demand response.
   ============================================================ */

CREATE OR REPLACE VIEW vw_discount_summary AS
SELECT
    discount,
    COUNT(*) AS total_observations,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS avg_sales,
    SUM(stock_hour6_22_cnt) AS total_stockout_hours,
    AVG(stock_hour6_22_cnt) AS avg_stockout_hours
FROM vw_daily_sales_base
GROUP BY discount;

/* ============================================================
   9.2.8 Validate Created Views

   Purpose:
   Confirm that the SQL preparation views were created successfully.
   ============================================================ */

SELECT *
FROM vw_daily_summary
LIMIT 10;

SELECT *
FROM vw_product_performance
LIMIT 10;

SELECT *
FROM vw_store_performance
LIMIT 10;

SELECT *
FROM vw_product_store_stockout_summary
LIMIT 10;

SELECT *
FROM vw_monthly_summary;

SELECT *
FROM vw_discount_summary
LIMIT 10;
