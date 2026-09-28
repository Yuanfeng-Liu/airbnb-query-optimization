# Assignment 2: Airbnb Analysis with PySpark

We translated an Airbnb SQL query into PySpark, compared several ways to run it, and extended the analysis to estimate occupancy by neighbourhood. The work was completed on Databricks using three dataset sizes, with roughly four million reviews in the largest version.

## Analysis

**Tasks 1 and 2: review counts.** Join hosts, listings, reviews, and cities to find Australian entire-home/apartment listings from superhosts with reviews in 2025. Group by listing name and city, then return the top five groups by distinct review count. Compare the CSV baseline with code and storage changes.

**Task 3: occupancy estimates.** Use 2024 reviews to estimate occupancy for Sydney listings, rank the top ten neighbourhoods by their mean estimate, and select five listings per neighbourhood.

The course scaffold specifies 12 cities, 551 neighbourhoods, and 61,153 hosts. Its small, medium, and large variants contain 10,500 / 54,000 / 108,182 listings and 400,000 / 2,000,000 / 4,009,676 reviews.

## Optimization

The notebook compares three versions of each analysis:

1. **CSV baseline:** read the CSV inputs and run the query.
2. **Code optimization:** select needed columns and filter earlier, use broadcast hints for small tables, and cache filtered review data. The occupancy query also narrows the output to the top ten neighbourhoods before building the listing results.
3. **Code and storage optimization:** retain those code changes, convert inputs to Parquet, and partition reviews by year. Each query reads the required `yr=2025` or `yr=2024` directory.

We used `explain(True)` and `sparkmeasure.StageMetrics` to inspect execution plans, stages, tasks, elapsed time, and shuffle volumes. The variants combine several changes, so the timings do not isolate the effect of any single optimization.

## Results

The report gives the following **mean runtimes over ten runs**, in minutes, for the large dataset:

| Workload | CSV baseline | Code optimization | Code + storage optimization |
|---|---:|---:|---:|
| Task 2: review-count query | 1.21 | 0.76 | 0.328 |
| Task 3: occupancy analysis | 2.20 | 1.27 | 0.831 |

These correspond to reductions of approximately **73%** and **62%** from the respective baselines. See [Task 2 results, page 6](report.pdf#page=6) and [Task 3 results, page 8](report.pdf#page=8).

CSV-to-Parquet conversion happens before timing, so its setup cost is excluded. The notebook's saved metrics come from individual executions and differ from these ten-run means. Where narrative figures in the report are inconsistent, the table above follows the report's mean-runtime tables.

The stage tables also show fewer tasks and stages: Task 2 goes from 642 to 416 tasks and 15 to 10 stages; Task 3 goes from 2,260 to 839 tasks and 29 to 18 stages. Shuffle is not eliminated, and some Task 3 shuffle metrics increase in the final variant.

## Occupancy assumptions

The occupancy estimate uses reviews rather than booking records:

- Each review represents two stays, assuming half of guests leave a review.
- Each stay lasts `minimum_nights` when that value is between 4 and 21; otherwise it lasts three nights.
- Estimated occupied days are divided by 365 and capped at 100%. Listings without reviews receive zero.

Neighbourhood scores average these estimates across listings. The code uses 365 days even for 2024, and the result should be interpreted as a review-based proxy for occupancy.

Tied scores have no secondary ordering key, and listing arrays are not explicitly sorted after aggregation. As a result, tied listings or their displayed order may differ between runs.

## Files and setup

- [airbnb_spark_optimization.ipynb](airbnb_spark_optimization.ipynb): analysis code, execution plans, result tables, and saved metrics.
- [report.pdf](report.pdf): methods, runtime comparisons, and execution-plan appendices.

The notebook requires Databricks with an active Spark session, PySpark, and compatible Python and Spark-side `sparkmeasure` dependencies. It uses `%sql` and `%pip` cells, reads from `dbfs:/FileStore/tables/`, and writes Parquet files to `dbfs:/FileStore/tables_parquet/`.

To run it:

1. Obtain the original CSV data and course Bootstrap notebook, which are not included. Populate the expected paths and SQL tables, including those reused from Assignment 1.
2. Check the runtime dependencies. The installation cell does not pin a complete environment.
3. Review the setup and conversion cells: they recreate tables and overwrite Parquet destinations. Use a dedicated project data location.
4. Run the notebook in order, since later sections reuse earlier variables and generated files. Choose the matching paths for each dataset size.
5. Set a consistent timing procedure for new comparisons. The repository contains individual saved runs, but no automated ten-run benchmark or scripts for every report chart.

Adaptive query execution and cost-based optimization were disabled in the recorded experiments, and the Task 3 baseline explicitly hints merge joins. These settings, along with caching and the cluster configuration, affect the results.

This is group work by **Yuanfeng Liu and Member A** for DATA3404, Semester 1, 2025.
