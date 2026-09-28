# Assignment 2: Scaling Airbnb Analysis with PySpark

This project translates a multi-table SQL query into PySpark, investigates its performance bottlenecks, and applies query and storage optimizations to an Airbnb dataset with up to **108,182 listings and 4,009,676 reviews**. It also builds a neighborhood ranking from a review-based estimate of occupancy.

The main challenge was the cost of repeatedly scanning CSV data, joining tables of very different sizes, and ranking aggregated results as the input grew. The report records a reduction in the large-dataset review query from **1.21 to 0.328 minutes**, and in the large-dataset occupancy analysis from **2.20 to 0.831 minutes**, after combining code changes with Parquet storage and year partitions.

## What the project does

| Part | Problem | Implementation |
| --- | --- | --- |
| Task 1 | Reproduce an SQL query using the PySpark DataFrame API | Join hosts, listings, reviews, and cities; retain Australian entire-home/apartment listings from superhosts with reviews in 2025; return the top five listing-name/city groups by distinct review count. |
| Task 2 | Reduce the cost of that query | Compare the CSV baseline, code optimization, and code optimization combined with a different physical storage design. |
| Task 3 | Analyze neighborhood occupancy and scalability | Estimate each Sydney listing's occupancy from 2024 reviews, rank the top ten neighborhoods by mean estimated occupancy, and return five highly ranked listings per neighborhood. |

The notebook scaffold lists 12 cities, 551 neighborhoods, and 61,153 hosts. The small, medium, and large variants contain 10,500 / 54,000 / 108,182 listings and 400,000 / 2,000,000 / 4,009,676 reviews respectively. These are the original assignment's stated dataset sizes.

## How the bottlenecks were addressed

- **Carry fewer rows and columns into joins.** The optimized code selects the fields needed for joins and final outputs, and applies country, room-type, city, and year filters earlier in the DataFrame pipeline.
- **Use small tables efficiently.** Explicit broadcast hints are applied to small dimension tables in the optimized variants. Broadcasting lets the relevant joins use local lookups without shuffling both sides. It does not remove every shuffle from the full query.
- **Avoid repeated work.** Filtered review DataFrames are cached in the code-optimized paths, and the occupancy ranking joins the top-ten neighborhood result before constructing the per-neighborhood output.
- **Scan the relevant portion of the data.** CSV inputs are converted to Parquet, and reviews are partitioned by year. Reading the specific `yr=2025` or `yr=2024` directory avoids scanning other years; Parquet also supports column-oriented reads and vectorized scanning.
- **Inspect execution behavior.** `explain(True)` and `sparkmeasure.StageMetrics` expose execution plans, elapsed time, executor time, garbage collection, stages, tasks, and shuffle volumes. The work compares these observations with runtime tables and boxplots.

These changes are evaluated as combined variants. Spark can already optimize portions of a DataFrame plan, so moving a filter in the source code alone is not proof that it caused an observed speedup.

## Results recorded in the report

The following are **means from ten runs**, in minutes, reported on page 6 for Task 2 and page 8 for Task 3. They are historical assignment measurements, not benchmarks rerun for this repository.

| Large-dataset workload | CSV baseline | Code optimization | Code + physical optimization | Reduction from baseline |
| --- | ---: | ---: | ---: | ---: |
| Task 2: review-count query | 1.21 | 0.76 | 0.328 | About 73% |
| Task 3: neighborhood occupancy analysis | 2.20 | 1.27 | 0.831 | About 62% |

The physical variant retains code optimizations and adds Parquet/year-partitioned inputs. One-time CSV-to-Parquet conversion runs before the measured query; these figures do not include its setup cost. Runtime depends on the original Databricks environment, caching state, data, and execution conditions.

The report's stage tables provide another view of resource use: Task 2 tasks fall from 642 to 416 and stages from 15 to 10; Task 3 tasks fall from 2,260 to 839 and stages from 29 to 18. Task 3's physical variant does not reduce every shuffle metric, so the improvement should not be described as eliminating shuffle altogether.

The notebook retains useful original outputs, including physical plans, result tables, and metrics from individual executions. Those single executions differ from the report's ten-run means. The report also contains some inconsistent narrative figures; the comparison above follows its mean-runtime tables rather than mixing narrative, single-run, and averaged values.

## Interpreting the occupancy estimate

Task 3 estimates demand from reviews; it does not use actual booking or availability records. It assumes:

1. Half of stays receive a review, so each review represents two stays.
2. Each stay lasts `minimum_nights` when that value is between 4 and 21 inclusive; otherwise it lasts 3 nights.
3. Estimated occupied days are summed per listing, divided by 365, and capped at 1. Listings without reviews receive 0.

The implementation uses 365 even for its 2024 analysis. The estimate therefore reflects the assignment's calculation assumptions rather than a verified annual occupancy rate. Neighborhood scores are averages across their listings, including zero-review listings.

Rankings also have a reproducibility limitation: equal occupancy rates have no secondary ordering key, and the collected listing arrays are not explicitly sorted after aggregation. Different runs or optimization variants can therefore display different listings or listing orders when scores tie. The published notebook preserves the original logic.

## Files and execution requirements

- [airbnb_spark_optimization.ipynb](airbnb_spark_optimization.ipynb): original analysis code and useful recorded outputs, with student/account identity metadata removed.
- [report.pdf](report.pdf): the accompanying report, including results, runtime comparisons, and execution-plan appendices.

The notebook was written for **Databricks with an active Spark session**. It contains `%sql` and `%pip` cells and reads paths under `dbfs:/FileStore/tables/`; generated Parquet files use `dbfs:/FileStore/tables_parquet/`. It uses PySpark and `sparkmeasure`, and its metrics collection requires a compatible Spark-side spark-measure setup as well as the Python package.

The original CSV data and the **Bootstrap notebook are not included**. The notebook explicitly assumes the assignment Bootstrap has populated the dataset and SQL tables, including those used in Assignment 1. This is an analysis submission rather than a standalone local application.

To reproduce the work in a suitable Databricks environment:

1. Obtain the assignment dataset and Bootstrap separately, populate the expected DBFS paths, and check the stated table sizes.
2. Confirm compatible Spark/PySpark and spark-measure runtime dependencies. The preserved installation cell alone is not a pinned environment specification.
3. Read the setup cells before running them: the SQL setup recreates the named tables, and the conversion cells overwrite the specified Parquet destinations. Use a dedicated project workspace/data location.
4. Run the notebook in order; later sections reuse earlier variables and generated Parquet files. Select the matching small/medium/large paths when comparing dataset sizes.
5. Establish a consistent timing protocol if producing new benchmark results. The notebook contains individual executions; it does not include a complete automated ten-run benchmark or the scripts that generated every report chart.

Adaptive query execution and cost-based optimization are disabled in the recorded experiments, and the Task 3 baseline explicitly hints merge joins. These conditions matter when interpreting the comparison and should be documented for any new runs. The repository preparation did not execute the notebook or change its analytical logic.
