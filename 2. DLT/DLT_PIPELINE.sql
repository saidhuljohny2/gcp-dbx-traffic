-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Bronze layer

-- COMMAND ----------

-- CREATE STREAMING LIVE TABLE -→ Declares a streaming DLT table.
-- cloud_files(path, format) -→ Autoloader-infers schema & reads continuously from Google Cloud Storage in CSV format.
-- current_timestamp() -→ Adds ingestion audit column.

-- COMMAND ----------

CREATE STREAMING LIVE TABLE customers
AS SELECT *,current_timestamp() as ingestion_date FROM cloud_files("gs://project-bkt-26082025/landing/dlt_source/customers/", "csv");

-- COMMAND ----------

CREATE STREAMING LIVE TABLE sales
AS SELECT *,current_timestamp() as ingestion_date FROM cloud_files("gs://project-bkt-26082025/landing/dlt_source/sales/", "csv");

-- COMMAND ----------

CREATE STREAMING LIVE TABLE products
AS SELECT *, current_timestamp() as ingestion_date FROM cloud_files("gs://project-bkt-26082025/landing/dlt_source/products/", "csv");

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Silver layer

-- COMMAND ----------

create streaming table sales_silver
(constraint valid_order_id expect (order_id is not null) on violation drop row)
as
select distinct * from Stream(LIVE.sales)

-- COMMAND ----------

-- Constraint: Ensures order_id is not null; bad rows are dropped.
-- distinct *: Removes duplicates.
-- Stream(LIVE.sales): Reads continuously from Bronze.

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE customer_silver;

APPLY CHANGES INTO
  live.customer_silver
FROM
  stream(LIVE.customers)
KEYS
  (customer_id)
APPLY AS DELETE WHEN
  operation = "DELETE"
SEQUENCE BY
  sequenceNum
COLUMNS * EXCEPT
  (operation, sequenceNum, _rescued_data, ingestion_date)
STORED AS
  SCD TYPE 2;

-- COMMAND ----------

-- APPLY CHANGES INTO → Declarative way to apply CDC (Change Data Capture).
-- KEYS (customer_id) → Unique identifier for dimension records.
-- APPLY AS DELETE → Deletes records where operation = "DELETE".
-- SEQUENCE BY sequenceNum → Orders changes chronologically.
-- SCD TYPE 2 → Maintains full history of changes with __START_AT and __END_AT system columns.

-- COMMAND ----------

create streaming table customer_silver_active as 
select customer_id,customer_name,customer_email,customer_city,customer_state from STREAM(live.customer_silver) where `__END_AT` is null

-- COMMAND ----------

-- Filters only currently active records from SCD2 history table.

-- COMMAND ----------

-- Create and populate the target table.
CREATE OR REFRESH STREAMING TABLE product_silver;

APPLY CHANGES INTO
  live.product_silver
FROM
  stream(LIve.products)
KEYS
  (product_id)
APPLY AS DELETE WHEN
  operation = "DELETE"
SEQUENCE BY
  seqNum
COLUMNS * EXCEPT
  (operation,seqNum ,_rescued_data,ingestion_date
)
STORED AS
  SCD TYPE 1;

-- COMMAND ----------

-- SCD Type 1: Only keeps the latest value (no history).
-- Good for products because only current attributes matter (price, category).

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Gold layer

-- COMMAND ----------

-- Total Sales by Customer
-- materialized view
create live table total_sales_customer as 
SELECT 
    c.customer_id,
    c.customer_name,
    round(SUM(s.total_amount)) AS total_sales,
    SUM(s.discount_amount) AS total_discount
FROM LIVE.sales_silver s
JOIN LIVE.customer_silver_active c
    ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC;

-- COMMAND ----------

-- Total Sales by Product Category
create live table total_sales_category as
SELECT 
    p.product_category,
    round(SUM(s.total_amount)) AS total_sales
FROM LIVE.sales_silver s
JOIN live.product_silver p
    ON s.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;
