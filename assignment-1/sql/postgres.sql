/* Individual Question 1 (By Zhantao Shi)*/ 

/* Individual Question 1 samll dataset(No Index) (By Zhantao Shi)*/ 
SELECT ls.id, ls.listing_name, COUNT(rs.id) AS num_reviews, MAX(rs.review_date) AS last_review
FROM airbnb.listings_small ls
JOIN airbnb.reviews_small rs ON ls.id = rs.listing_id
JOIN airbnb.cities c ON ls.city_id = c.id
WHERE c.city_name = 'Melbourne'
    AND rs.review_date >= (CURRENT_DATE - INTERVAL '365 days')
GROUP BY ls.id, ls.listing_name
ORDER BY num_reviews DESC, ls.listing_name
LIMIT 5;

/* Individual Question 1 medium dataset(No Index) (By Zhantao Shi)*/ 
SELECT lm.id, lm.listing_name, COUNT(rm.id) AS num_reviews, MAX(rm.review_date) AS last_review
FROM airbnb.listings_medium lm
JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
JOIN airbnb.cities c ON lm.city_id = c.id
WHERE c.city_name = 'Melbourne'
    AND rm.review_date >= (CURRENT_DATE - INTERVAL '365 days')
GROUP BY lm.id, lm.listing_name
ORDER BY num_reviews DESC, lm.listing_name
LIMIT 5;

/* Individual Question 1 medium dataset(With Index) (By Zhantao Shi)*/ 
DROP INDEX IF EXISTS airbnb.idx_reviews;
CREATE INDEX idx_reviews ON airbnb.reviews_medium (listing_id, review_date);

SELECT lm.id, lm.listing_name, COUNT(rm.id) AS num_reviews, MAX(rm.review_date) AS last_review
FROM airbnb.listings_medium lm
JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
JOIN airbnb.cities c ON lm.city_id = c.id
WHERE c.city_name = 'Melbourne'
    AND rm.review_date >= (CURRENT_DATE - INTERVAL '365 days')
GROUP BY lm.id, lm.listing_name
ORDER BY num_reviews DESC, lm.listing_name
LIMIT 5;

/* Individual Question 2 (By Yuanfeng Liu)*/ 

/* Individual Question 2 samll dataset(No Index) (By Yuanfeng Liu)*/ 
SELECT h.id, h.host_name, COUNT(DISTINCT ls.id) AS num_of_listings
FROM airbnb.hosts h
JOIN airbnb.listings_small ls ON h.id = ls.host_id
JOIN airbnb.reviews_small rs ON ls.id = rs.listing_id
WHERE h.acceptance_rate = '100%'
 AND ls.room_type = 'Private room'
GROUP BY h.id, h.host_name
ORDER BY num_of_listings DESC, h.host_name
LIMIT 10;

/* Individual Question 2 medium dataset(No Index) (By Yuanfeng Liu)*/ 
SELECT h.id, h.host_name, COUNT(DISTINCT lm.id) AS num_of_listings
FROM airbnb.hosts h
JOIN airbnb.listings_medium lm ON h.id = lm.host_id
JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
WHERE h.acceptance_rate = '100%'
 AND lm.room_type = 'Private room'
GROUP BY h.id, h.host_name
ORDER BY num_of_listings DESC, h.host_name
LIMIT 10;

/* Individual Question 2 medium dataset(With Index) (By Yuanfeng Liu)*/ 
DROP INDEX IF EXISTS airbnb.idx_hosts;
CREATE INDEX idx_hosts ON airbnb.hosts (acceptance_rate);

SELECT h.id, h.host_name, COUNT(DISTINCT lm.id) AS num_of_listings
FROM airbnb.hosts h
JOIN airbnb.listings_medium lm ON h.id = lm.host_id
JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
WHERE h.acceptance_rate = '100%'
 AND lm.room_type = 'Private room'
GROUP BY h.id, h.host_name
ORDER BY num_of_listings DESC, h.host_name
LIMIT 10;



/* Group Task 1*/ 

/* Group Question 1 small dataset(No Index)*/ 
SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ls.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rs.id) AS NUMERIC) / COUNT(DISTINCT ls.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_small ls ON ls.city_id = c.id AND ls.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ls.host_id
JOIN airbnb.reviews_small rs ON rs.listing_id = ls.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't'  
  AND ls.price > 100      
  AND rs.review_date >= '2024-01-01'
  AND rs.review_date <= '2025-12-31'
  AND LOWER(rs.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 1 medium dataset(No Index)*/ 
SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT lm.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rm.id) AS NUMERIC) / COUNT(DISTINCT lm.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_medium lm ON lm.city_id = c.id AND lm.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = lm.host_id
JOIN airbnb.reviews_medium rm ON rm.listing_id = lm.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND lm.price > 100    
  AND rm.review_date >= '2024-01-01'
  AND rm.review_date <= '2025-12-31'
  AND LOWER(rm.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 1 large dataset(No Index)*/ 
SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ll.host_id
JOIN airbnb.reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100       
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 1 small dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_reviews;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_small (city_id, price);
CREATE INDEX idx_reviews ON airbnb.reviews_small (listing_id, review_date, md5(comments));

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ls.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rs.id) AS NUMERIC) / COUNT(DISTINCT ls.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_small ls ON ls.city_id = c.id AND ls.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ls.host_id
JOIN airbnb.reviews_small rs ON rs.listing_id = ls.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't'  
  AND ls.price > 100      
  AND rs.review_date >= '2024-01-01'
  AND rs.review_date <= '2025-12-31'
  AND LOWER(rs.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 1 medium dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_reviews;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_medium (city_id, price);
CREATE INDEX idx_reviews ON airbnb.reviews_medium (listing_id, review_date, md5(comments));

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT lm.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rm.id) AS NUMERIC) / COUNT(DISTINCT lm.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_medium lm ON lm.city_id = c.id AND lm.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = lm.host_id
JOIN airbnb.reviews_medium rm ON rm.listing_id = lm.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND lm.price > 100    
  AND rm.review_date >= '2024-01-01'
  AND rm.review_date <= '2025-12-31'
  AND LOWER(rm.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 1 large dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_reviews;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_large (city_id, price);
CREATE INDEX idx_reviews ON airbnb.reviews_large (listing_id, review_date, md5(comments));

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ll.host_id
JOIN airbnb.reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100       
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;


/* Group Task 2*/ 

/* Group Question 2 small dataset(No Index)*/ 
WITH popular_listings AS (
    SELECT ls.id, ls.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY ls.city_id
            ORDER BY COUNT(rs.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_small ls JOIN airbnb.reviews_small rs ON ls.id = rs.listing_id
    GROUP BY ls.id, ls.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_small ls ON pl.id = ls.id
    WHERE ls.amenities @> ARRAY['Ocean view']::text[] 
       AND pl.popularity_rank <= 0.2 
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.cities c ON pol.city_id = c.id
ORDER BY c.city_name;


/* Group Question 2 medium dataset(No Index)*/ 
WITH popular_listings AS (
    SELECT lm.id, lm.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY lm.city_id
            ORDER BY COUNT(rm.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_medium lm JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
    GROUP BY lm.id, lm.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_medium lm ON pl.id = lm.id
    WHERE lm.amenities @> ARRAY['Ocean view']::text[]
       AND pl.popularity_rank <= 0.2
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.cities c ON pol.city_id = c.id
ORDER BY c.city_name;

/* Group Question 2 large dataset(No Index)*/ 
WITH popular_listings AS (
    SELECT ll.id, ll.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY ll.city_id
            ORDER BY COUNT(rl.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_large ll JOIN airbnb.reviews_large rl ON ll.id = rl.listing_id
    GROUP BY ll.id, ll.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_large ll ON pl.id = ll.id
    WHERE ll.amenities @> ARRAY['Ocean view']::text[]
       AND pl.popularity_rank <= 0.2 
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.Cities c ON pol.city_id = c.id
ORDER BY c.city_name;


/* Group Question 2 small dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_cities;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_small USING gin (amenities);
CREATE INDEX idx_cities ON airbnb.cities (city_name);

WITH popular_listings AS (
    SELECT ls.id, ls.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY ls.city_id
            ORDER BY COUNT(rs.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_small ls JOIN airbnb.reviews_small rs ON ls.id = rs.listing_id
    GROUP BY ls.id, ls.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_small ls ON pl.id = ls.id
    WHERE ls.amenities @> ARRAY['Ocean view']::text[] 
       AND pl.popularity_rank <= 0.2 
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.cities c ON pol.city_id = c.id
ORDER BY c.city_name;


/* Group Question 2 medium dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_cities;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_medium USING gin (amenities);
CREATE INDEX idx_cities ON airbnb.cities (city_name);

WITH popular_listings AS (
    SELECT lm.id, lm.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY lm.city_id
            ORDER BY COUNT(rm.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_medium lm JOIN airbnb.reviews_medium rm ON lm.id = rm.listing_id
    GROUP BY lm.id, lm.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_medium lm ON pl.id = lm.id
    WHERE lm.amenities @> ARRAY['Ocean view']::text[]
       AND pl.popularity_rank <= 0.2
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.cities c ON pol.city_id = c.id
ORDER BY c.city_name;

/* Group Question 2 large dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_cities;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_large USING gin (amenities);
CREATE INDEX idx_cities ON airbnb.cities (city_name);

WITH popular_listings AS (
    SELECT ll.id, ll.city_id,
        PERCENT_RANK() OVER (
			PARTITION BY ll.city_id
            ORDER BY COUNT(rl.reviewer_id) DESC
        ) AS popularity_rank
    FROM airbnb.listings_large ll JOIN airbnb.reviews_large rl ON ll.id = rl.listing_id
    GROUP BY ll.id, ll.city_id
),

popular_oceanview_listings AS (
    SELECT pl.city_id, COUNT(pl.id) AS num_popular_oceanview_listings
    FROM popular_listings pl JOIN airbnb.listings_large ll ON pl.id = ll.id
    WHERE ll.amenities @> ARRAY['Ocean view']::text[]
       AND pl.popularity_rank <= 0.2 
    GROUP BY pl.city_id
)

SELECT c.city_name, pol.num_popular_oceanview_listings
FROM popular_oceanview_listings pol JOIN airbnb.Cities c ON pol.city_id = c.id
ORDER BY c.city_name;


/* Group Question 3 */ 
/* I will use the query from Group Task 1 to compare query runtimes between PostgreSQL and Databricks on the large dataset.*/ 
/*The following is the code used to compare the PostgreSQL query speed in the query speed*/ 

/* Group Question 3 large dataset(No Index)*/ 
SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ll.host_id
JOIN airbnb.reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100       
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;

/* Group Question 3 large dataset(With Index)*/ 
DROP INDEX IF EXISTS airbnb.idx_reviews;
DROP INDEX IF EXISTS airbnb.idx_listings;
CREATE INDEX idx_listings ON airbnb.listings_large (city_id, price);
CREATE INDEX idx_reviews ON airbnb.reviews_large (listing_id, review_date, md5(comments));

SELECT c.city_name AS city, n.nhood_name AS nhood_name,
    COUNT(DISTINCT ll.id) AS num_complaint_listings,
    ROUND(CAST(COUNT(rl.id) AS NUMERIC) / COUNT(DISTINCT ll.id), 2) AS avg_complaints_per_listing
FROM airbnb.cities c JOIN airbnb.neighbourhoods n ON n.city_id = c.id
JOIN airbnb.listings_large ll ON ll.city_id = c.id AND ll.neighbourhood = n.id
JOIN airbnb.hosts h ON h.id = ll.host_id
JOIN airbnb.reviews_large rl ON rl.listing_id = ll.id
WHERE c.city_name = 'Sydney'
  AND h.is_superhost = 't' 
  AND ll.price > 100       
  AND rl.review_date >= '2024-01-01'
  AND rl.review_date <= '2025-12-31'
  AND LOWER(rl.comments) LIKE '%complaint%' 
GROUP BY c.city_name, n.nhood_name
ORDER BY num_complaint_listings DESC
LIMIT 10;



/* The code used to view the establishment status of the index*/ 
SELECT *
FROM pg_indexes
WHERE schemaname = 'airbnb';

