# Assignment 1: Airbnb SQL Query Optimization

This coursework investigates how to make multi-table Airbnb queries faster as the volume of listings and reviews grows. It combines SQL query design, execution-plan inspection, and indexing experiments in PostgreSQL, followed by a limited comparison with Databricks.

The strongest reported result is a reduction from **5.717 seconds to 1.365 seconds (approximately 4.19x faster)** for a complaint-related query on the large dataset. These are measurements recorded in the submitted report; the experiments have not been rerun for this publication.

## Problems, methods, and observed results

| Problem | Method used in the submission | Reported outcome |
| --- | --- | --- |
| Search across five tables for Sydney superhost listings priced above 100, with reviews dated 2024–2025 that contain `complaint`, then summarize matching listings by neighbourhood. | Joins, grouped aggregates, and composite indexes on listings and reviews; inspect which conditions are used by the execution plan. | Large dataset: **5.717 s → 1.365 s**, approximately **4.19x faster**. See [report, pp. 4–7](report.pdf#page=4). |
| Count popular listings with an `Ocean view` amenity in each city, while ranking popularity within the city. | Two CTEs, `PERCENT_RANK()` over review counts, the array containment operator `@>`, and a GIN index on `amenities`. | Large dataset: **1.248 s → 1.049 s**. See [report, pp. 7–10](report.pdf#page=7). |
| Retrieve Melbourne's five most-reviewed listings in the preceding 365 days. | Joins, `COUNT`, `MAX`, and a composite index on `(listing_id, review_date)`. | Medium dataset: **354 ms → 172 ms**. See [report, pp. 1–2](report.pdf#page=1). |
| Rank hosts with 100% acceptance rates by their qualifying private-room listings that have reviews. | Joins, `COUNT(DISTINCT ...)`, and an index on `acceptance_rate`. | Medium dataset: **364 ms → 318 ms**. See [report, pp. 3–4](report.pdf#page=3). |

The main engineering difficulty was identifying useful indexes for queries that mix joins, selective filters, aggregation, and array membership. The report compares small, medium, and large tables, examines query plans, and includes box plots described as ten runs with and ten runs without indexes for each group query. The underlying run-by-run measurements and plotting code were not included in the submitted archive.

The Databricks experiment runs the same large-dataset complaint query and records **26.91 s**, compared with **5.717 s** in PostgreSQL ([report, pp. 10–11](report.pdf#page=10)). This documents one coursework setup. Hardware, cluster configuration, cache state, and repeated cross-platform measurements are not sufficiently documented to support a general claim about which platform is faster.

## Data and query scope

The queries use `Cities`, `Neighbourhoods`, `Hosts`, `Listings`, and `Reviews`. The Databricks notebook template lists these expected table sizes:

| Table | Small | Medium | Large |
| --- | ---: | ---: | ---: |
| Listings | 10,500 | 54,000 | 108,182 |
| Reviews | 400,000 | 2,000,000 | 4,000,676 |

The shared tables are expected to contain 12 cities, 551 neighbourhoods, and 61,153 hosts. These counts come from the submission's template; the dataset is not included here and the counts have not been independently revalidated.

For the popularity query, ranking is calculated among listings that have reviews, using `PERCENT_RANK() <= 0.2`; ties can affect the number selected. The complaint query counts reviews containing a substring, rather than using a sentiment classifier or verifying that every matched review is an actual complaint.

## Files

- [`sql/postgres.sql`](sql/postgres.sql): the two individual queries and three group tasks, including indexing experiments for different dataset sizes.
- [`sql/databricks.sql`](sql/databricks.sql): an exported Databricks SQL notebook containing CSV table definitions and the cross-platform comparison experiment.
- [`report.pdf`](report.pdf): the submitted report with results, execution-plan screenshots, charts, and the contribution statement; student identifiers are removed in the public copy.

The SQL files preserve the submitted query logic. Author names are retained, and student identifiers have been removed from comments.

## Running or extending the experiments

These files are historical experiment scripts, with multiple variants intended to be run as selected sections. They are not a complete one-command setup.

1. **Provide the original coursework dataset and environment.** No CSV data, PostgreSQL schema/bootstrap script, or Databricks Bootstrap notebook is included in this submission.
2. **For PostgreSQL, prepare the `airbnb` schema and the referenced tables.** The queries expect the original column names, relationships, and data types, including `amenities` as a text array. An account that can create and drop the experiment indexes is needed for the indexing sections.
3. **For Databricks, provide the missing Bootstrap setup and CSV files.** The exported notebook expects files under `/FileStore/tables/airbnb_*.csv` and defines CSV-backed tables. Its setup cells contain `DROP TABLE IF EXISTS`, so use a dedicated coursework environment and review the cells before execution.
4. **Run selected query variants with explicit index state.** Index names such as `idx_reviews` and `idx_listings` are reused. Executing the PostgreSQL file straight through can leave indexes from earlier tasks in place for sections labeled “No Index.” Record or reset the relevant experiment indexes before comparing timings.
5. **Record the date and benchmark conditions.** The Melbourne query uses `CURRENT_DATE - INTERVAL '365 days'`, so its results change with the execution date. Document the reference date, database/runtime versions, hardware, warm-up, cache conditions, and timing method before presenting new measurements.

### Limitations preserved from the submission

- The Databricks script retains the final `CREATE INDEX` experiment that the report describes as failing. Those statements target the small tables, while the following query uses the large tables. Treat that cell as historical evidence, not a successful setup step.
- In the complaint-query plan shown on report page 6, the indexed conditions are the listing identifier and review dates; `LOWER(comments) LIKE '%complaint%'` remains a filter. The speedup should not be attributed to `md5(comments)` accelerating substring matching.
- The city-name index scan shown on report page 9 does not establish that the city ID join is resolved by an indexed ID lookup: that condition is displayed as a join filter. The report's explanation should be read with the displayed plan.
- The report provides evidence of improvements in its recorded runs, but raw benchmark logs and a fully specified benchmark environment are absent.

## Authors and contribution evidence

**DATA3404, Semester 1 2025 — TUT07, Assignment Group 06**

- **Zhantao Shi:** Individual Question 1; named as a major contributor in the report's contribution statement.
- **Yuanfeng Liu:** Individual Question 2; named as a major contributor in the report's contribution statement.

The individual-query attribution appears in the SQL comments and on report pages 1 and 3. The [contribution statement on page 11](report.pdf#page=11) records the assignments above. Group Tasks 1–3 are presented as the group submission; the report does not provide a finer-grained allocation for those tasks.
