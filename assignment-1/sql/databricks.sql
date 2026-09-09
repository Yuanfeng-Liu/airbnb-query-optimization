-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## DATA3404 Assignment 1
-- MAGIC
-- MAGIC This is the SQL template notebook for the assignment on Databricks, 2025s1.
-- MAGIC
-- MAGIC This notebook assumes that you have executed the **Bootstrap** notebook first.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Schema Creation - RUN THE FOLLOWING CELL ONLY ONCE
-- MAGIC As the first step for any SQL work with HIVE, we are mapping the imported CSV files as SQL tables so that they are available for subsequent SQL queries using Hive with a number of tables:
-- MAGIC **Cities**, **Neighbourhoods**, **Hosts** and three variants of the
-- MAGIC **Listings_**_scale_ and the **Reviews_**_scale_  tables. You can switch between differenty dataset sizes by
-- MAGIC referring to _either_ the **Listings_small**, _or_ **Listings_medium** _or_
-- MAGIC **Listings_large** tables, and reespectively for the **Reviews_**_scale_  tables.

-- COMMAND ----------

DROP TABLE IF EXISTS Cities;
CREATE TABLE Cities (
  id             INTEGER,
  city_name      VARCHAR(20),
  state          VARCHAR(40),
  country        VARCHAR(40),
  country_code   CHAR(2)
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_cities.csv", header "true");

DROP TABLE IF EXISTS Neighbourhoods;
CREATE TABLE Neighbourhoods (
  id             INTEGER,
  city_id        INTEGER,
  nhood_name     VARCHAR(50),
  nhood_group    VARCHAR(50),
  geometry       BINARY
) 
USING csv
OPTIONS (path "/FileStore/tables/airbnb_neighbourhoods.csv", header "true");

DROP TABLE IF EXISTS Hosts;
CREATE TABLE Hosts (
  id              INTEGER,
  host_name       VARCHAR(50),
  host_since      DATE,
  host_about      VARCHAR(1000),
  is_superhost    CHAR(1),
  response_time   VARCHAR(20),
  response_rate   VARCHAR(4),
  acceptance_rate VARCHAR(4),
  last_scraped    DATE
) 
USING csv
OPTIONS (path "/FileStore/tables/airbnb_hosts.csv", header "true");

DROP TABLE IF EXISTS Listings_tiny;
CREATE TABLE Listings_tiny (
  id             BIGINT,
  listing_name   VARCHAR(250),
  property_type  VARCHAR(40),
  room_type      VARCHAR(15),
  price          FLOAT,
  minimum_nights INTEGER,
  host_id        INTEGER,
  city_id        INTEGER,
  neighbourhood  INTEGER,
  latitude       NUMERIC(9,6),
  longitude      NUMERIC(9,6),
  description    VARCHAR(1000),
  accommodates   INT,
  bathrooms      INT,
  bedrooms       INT,
  beds           INT,
  amenities      STRING, -- ARRAY<STRING>,
  last_scraped   DATE
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_listings-tiny.csv", header "true");

DROP TABLE IF EXISTS Listings_small;
CREATE TABLE Listings_Small (
  id             BIGINT,
  listing_name   VARCHAR(250),
  property_type  VARCHAR(40),
  room_type      VARCHAR(15),
  price          FLOAT,
  minimum_nights INTEGER,
  host_id        INTEGER,
  city_id        INTEGER,
  neighbourhood  INTEGER,
  latitude       NUMERIC(9,6),
  longitude      NUMERIC(9,6),
  description    VARCHAR(1000),
  accommodates   INT,
  bathrooms      INT,
  bedrooms       INT,
  beds           INT,
  amenities      STRING, -- ARRAY<STRING>
  last_scraped   DATE
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_listings-small.csv", header "true");

DROP TABLE IF EXISTS Listings_medium;
CREATE TABLE Listings_Medium (
  id             BIGINT,
  listing_name   VARCHAR(250),
  property_type  VARCHAR(40),
  room_type      VARCHAR(15),
  price          FLOAT,
  minimum_nights INTEGER,
  host_id        INTEGER,
  city_id        INTEGER,
  neighbourhood  INTEGER,
  latitude       NUMERIC(9,6),
  longitude      NUMERIC(9,6),
  description    VARCHAR(1000),
  accommodates   INT,
  bathrooms      INT,
  bedrooms       INT,
  beds           INT,
  amenities      STRING, -- ARRAY<STRING>,
  last_scraped   DATE
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_listings-medium.csv", header "true");

DROP TABLE IF EXISTS Listings_large;
CREATE TABLE Listings_Large (
  id             BIGINT,
  listing_name   VARCHAR(250),
  property_type  VARCHAR(40),
  room_type      VARCHAR(15),
  price          FLOAT,
  minimum_nights INTEGER,
  host_id        INTEGER,
  city_id        INTEGER,
  neighbourhood  INTEGER,
  latitude       NUMERIC(9,6),
  longitude      NUMERIC(9,6),
  description    VARCHAR(1000),
  accommodates   INT,
  bathrooms      INT,
  bedrooms       INT,
  beds           INT,
  amenities      STRING, -- ARRAY<STRING>,
  last_scraped   DATE
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_listings-large.csv", header "true");

DROP TABLE IF EXISTS Reviews_tiny;
CREATE TABLE Reviews_tiny (
  id             BIGINT,
  listing_id     BIGINT,
  review_date    DATE    NOT NULL,
  reviewer_id    INTEGER NOT NULL,
  reviewer_name  VARCHAR(50),
  comments       STRING
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_reviews-tiny.csv", header "true");

DROP TABLE IF EXISTS Reviews_small;
CREATE TABLE Reviews_small (
  id             BIGINT,
  listing_id     BIGINT,
  review_date    DATE    NOT NULL,
  reviewer_id    INTEGER NOT NULL,
  reviewer_name  VARCHAR(50),
  comments       STRING
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_reviews-small.csv", header "true");

DROP TABLE IF EXISTS Reviews_medium;
CREATE TABLE Reviews_medium (
  id             BIGINT,
  listing_id     BIGINT,
  review_date    DATE    NOT NULL,
  reviewer_id    INTEGER NOT NULL,
  reviewer_name  VARCHAR(50),
  comments       STRING
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_reviews-medium.csv", header "true");

DROP TABLE IF EXISTS Reviews_large;
CREATE TABLE Reviews_large (
  id             BIGINT,
  listing_id     BIGINT,
  review_date    DATE    NOT NULL,
  reviewer_id    INTEGER NOT NULL,
  reviewer_name  VARCHAR(50),
  comments       STRING
)
USING csv
OPTIONS (path "/FileStore/tables/airbnb_reviews-large.csv", header "true");

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Check whether schema has been created correctly
-- MAGIC
-- MAGIC Expected table sizes:  
-- MAGIC <style scoped>
-- MAGIC table {
-- MAGIC   font-size: 10px;
-- MAGIC }
-- MAGIC </style>
-- MAGIC | table         |  count  |
-- MAGIC |---------------|--------:|
-- MAGIC |Cities         |      12 |
-- MAGIC |Neighbourhoods |     551 |
-- MAGIC |Hosts          |   61153 |
-- MAGIC |Listings_small |   10500 |
-- MAGIC |Listings_medium|   54000 |
-- MAGIC |Listings_large |  108182 |
-- MAGIC |Reviews_small  |  400000 |
-- MAGIC |Reviews_medium | 2000000 |
-- MAGIC |Reviews_large  | 4000676 |

-- COMMAND ----------

SELECT 'Cities', COUNT(*) FROM Cities
UNION
SELECT 'Neighbourhoods', COUNT(*) FROM Neighbourhoods
UNION
SELECT 'Hosts', COUNT(*) FROM Hosts
UNION
SELECT 'Listings_tiny', COUNT(*) FROM Listings_tiny
UNION
SELECT 'Listings_small', COUNT(*) FROM Listings_small
UNION
SELECT 'Listings_medium', COUNT(*) FROM Listings_medium
UNION
SELECT 'Listings_large', COUNT(*) FROM Listings_large
UNION
SELECT 'Reviews_tiny', COUNT(*) FROM Reviews_tiny
UNION
SELECT 'Reviews_small', COUNT(*) FROM Reviews_small
UNION
SELECT 'Reviews_medium', COUNT(*) FROM Reviews_medium
UNION
SELECT 'Reviews_large', COUNT(*) FROM Reviews_large

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # **Assignment Task 3**
-- MAGIC Next, I will use the query from Group Task 1 to compare query runtimes between PostgreSQL and Databricks on the large dataset.

-- COMMAND ----------

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM cities c JOIN neighbourhoods n ON n.city_id = c.id
JOIN listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN hosts h ON h.id = ll.host_id
JOIN reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100      
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;


-- COMMAND ----------

-- MAGIC %md
-- MAGIC I found that running the same code on Databricks takes longer. This is mainly because Databricks splits the query into distributed tasks and schedules them across the cluster.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Next, I tried to add an index in Databricks, but it failed because Databricks does not support creating indexes.

-- COMMAND ----------

CREATE INDEX idx_listings ON listings_small (city_id, price);
CREATE INDEX idx_reviews ON reviews_small (listing_id, review_date, md5(comments));

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM cities c JOIN neighbourhoods n ON n.city_id = c.id
JOIN listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN hosts h ON h.id = ll.host_id
JOIN reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100      
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;