# Airbnb Query Optimization with PostgreSQL and Spark

**Yuanfeng Liu · DATA3404 group project · Semester 1, 2025**

This project uses Airbnb listings and reviews to study how query design, indexes, and storage affect runtime. It covers two assignments: PostgreSQL index experiments and a PySpark analysis on Databricks. The repository includes the SQL, a notebook with saved outputs, and both reports.

## Results

| Experiment | Before | After | What changed |
|---|---:|---:|---|
| PostgreSQL complaint-related query | 5.717 s | 1.365 s | Indexes on the listing and review tables |
| PostgreSQL popularity query | 1.248 s | 1.049 s | Indexing for joins and amenity filtering |
| Spark review-count query | 1.21 min | 0.328 min | Code changes, Parquet, and review-year partitions |
| Spark occupancy analysis | 2.20 min | 0.831 min | Code changes, Parquet, and review-year partitions |

These are the large-dataset results recorded in the coursework reports. The Spark values are means over ten runs and exclude the initial CSV-to-Parquet conversion. The PostgreSQL and Spark rows use different queries and environments, so they should be read as separate experiments.

See the [PostgreSQL results](assignment-1/report.pdf#page=4), [Spark review-query results](assignment-2/report.pdf#page=6), and [Spark occupancy results](assignment-2/report.pdf#page=8).

## Explore the work

- **[Assignment 1 — SQL and indexing](assignment-1/):** joins, aggregation, window functions, array filtering, and execution-plan analysis. It also includes a small PostgreSQL–Databricks comparison.
- **[Assignment 2 — PySpark and storage](assignment-2/):** filtering and column selection, broadcast joins, caching, and partitioned Parquet. A second analysis estimates neighbourhood occupancy from review counts.

The occupancy analysis is based on assumptions about review frequency and length of stay; it does not measure actual bookings. Each assignment README explains the queries, setup, and limits of the recorded results.

## Contributions

I completed **Individual Question 2 in Assignment 1**, which ranks hosts by their qualifying private-room listings. **Member A** completed Individual Question 1. The remaining experiments and reports were group work by **Yuanfeng Liu and Member A**. The reports include the original contribution statements, with my teammate's name anonymised for privacy.

## Running the code

The original course CSV files and Bootstrap notebook are not included. PostgreSQL needs the `airbnb` schema and matching tables; the Databricks scripts and notebook use course-specific `/FileStore` paths. Setup details are in the assignment READMEs.

The code and saved outputs document the submitted experiments. To collect new timings, prepare the original data and a suitable environment, then control index state, caching, and the timing procedure. Raw benchmark logs and a fully specified runtime environment are not available in this repository.
