# Assignment 1: Airbnb SQL Query Optimization

This assignment explores indexing for queries that combine several Airbnb tables. We wrote the queries, inspected PostgreSQL execution plans, and compared runtimes at three dataset sizes. We also ran one of the group queries in Databricks.

## Queries and results

| Query | Main SQL features | Reported runtime before → after indexing |
|---|---|---:|
| Count Sydney superhost listings priced above 100 with 2024–2025 reviews containing `complaint`, grouped by neighbourhood | Five-table join, filtering, aggregation, composite indexes | **5.717 → 1.365 s** (large dataset) |
| Count popular listings with an `Ocean view` amenity in each city | CTEs, `PERCENT_RANK()`, array containment, GIN index | **1.248 → 1.049 s** (large dataset) |
| Find Melbourne's five most-reviewed listings over the preceding 365 days | Joins, `COUNT`, `MAX`, index on `(listing_id, review_date)` | **354 → 172 ms** (medium dataset) |
| Rank hosts with a 100% acceptance rate by their private-room listings that have reviews | Joins, `COUNT(DISTINCT ...)`, index on `acceptance_rate` | **364 → 318 ms** (medium dataset) |

The [report](report.pdf) contains the execution plans and timing comparisons. It also shows box plots described as ten runs with and without indexes for each group query; the underlying run-by-run data and plotting scripts are not included.

The large complaint-related query took **26.91 s in Databricks**, compared with **5.717 s in PostgreSQL** in the recorded comparison ([pp. 10–11](report.pdf#page=10)). The two environments were not documented closely enough to treat this as a general comparison of the platforms.

## Data and interpretation

The queries use `Cities`, `Neighbourhoods`, `Hosts`, `Listings`, and `Reviews`. The course template specifies:

| Table | Small | Medium | Large |
|---|---:|---:|---:|
| Listings | 10,500 | 54,000 | 108,182 |
| Reviews | 400,000 | 2,000,000 | 4,000,676 |

The shared tables contain 12 cities, 551 neighbourhoods, and 61,153 hosts according to the same template. The original data is not included.

Two query definitions affect the interpretation of the results:

- `LIKE '%complaint%'` counts a substring match. It is not a classification of whether a review expresses a complaint.
- The popularity query applies `PERCENT_RANK() <= 0.2` within each city, among listings with reviews. Ties can change the proportion selected.

## Files

- [`sql/postgres.sql`](sql/postgres.sql): individual and group queries, with indexing variants for different dataset sizes.
- [`sql/databricks.sql`](sql/databricks.sql): exported SQL notebook with table setup and the platform comparison.
- [`report.pdf`](report.pdf): results, query plans, charts, and team contributions. Student identifiers are redacted and the other contributor is listed as Member A.

## Running the experiments

1. Obtain the course CSV files and setup materials separately. The repository does not include the PostgreSQL schema/bootstrap script or the Databricks Bootstrap notebook.
2. For PostgreSQL, create the `airbnb` schema with the expected tables and types, including `amenities` as a text array. Run selected query sections: index names are reused, so reset the relevant indexes before each comparison.
3. For Databricks, prepare the CSV files under `/FileStore/tables/` and review the table-creation cells. They use `DROP TABLE IF EXISTS`; run them in a dedicated project environment.
4. Record the runtime, hardware, cache state, and timing method for new measurements. The Melbourne query uses `CURRENT_DATE`, so its 365-day window also depends on the run date.

### Notes on the submitted code and report

- The complaint-query plan uses the listing ID and review-date index conditions. The substring search remains a filter; `md5(comments)` does not account for faster substring matching.
- In the popularity-query plan, the city-name index scan does not establish an indexed lookup on the city ID. The ID condition appears as a join filter.
- The final Databricks `CREATE INDEX` experiment failed in the original environment. Its statements target the small tables, while the following query uses the large tables; skip this cell when setting up the analysis.

## Contributions

**Yuanfeng Liu:** Individual Question 2, the host-ranking query.

**Member A:** Individual Question 1, the Melbourne review query.

Group Tasks 1–3 were completed as a team. See the [contribution statement on page 11](report.pdf#page=11). This was a DATA3404 submission by TUT07, Assignment Group 06, in Semester 1, 2025.
