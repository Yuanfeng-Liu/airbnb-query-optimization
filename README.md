# Airbnb Query Optimization with PostgreSQL and Spark

How can multi-table analytics over millions of Airbnb reviews become faster without changing the analytical question? This DATA3404 group project investigates that problem with two complementary approaches: **query-specific PostgreSQL indexes** and **PySpark execution and storage optimization**.

The submitted experiments report a complaint-analysis query falling from **5.717 s to 1.365 s (4.19× speedup)** after indexing, and a Spark query's mean elapsed time falling from **1.21 min to 0.328 min (3.69× speedup)** after code and physical-storage optimization. These are historical coursework measurements, not new benchmark runs.

## Challenges, approach, and measured outcome

| Challenge | What the team implemented | Outcome in the submitted reports |
|---|---|---|
| Expensive joins and selective filters across listings, hosts, cities, and millions of reviews | Examined execution plans and tested indexes matched to join and filter columns | Assignment 1 complaint query: 5.717 → 1.365 s, about 76.1% less elapsed time |
| Array filtering combined with review-based ranking | SQL CTEs, `PERCENT_RANK()`, and a GIN index for amenities | Assignment 1 ranking query: 1.248 → 1.049 s, about 15.9% less elapsed time |
| Repeated CSV scans and unnecessary distributed work in Spark | Early filtering and column selection, small-table broadcasting, caching, Parquet, and review-year partitions | Assignment 2 query: 1.21 → 0.76 → 0.328 min, about 72.9% less elapsed time overall |
| Producing neighbourhood-level insights from listing-level records | A review-based occupancy estimator, aggregation, and per-neighbourhood ranking | Assignment 2 large-data occupancy query: 2.20 → 1.27 → 0.831 min, about 62.2% less elapsed time overall |

The three Spark timings correspond to baseline, code optimization, and code plus physical-storage optimization. Spark values are reported means over ten runs. Index results come from Assignment 1's large-data measurements. The workloads and environments differ, so the rows are not a ranking of database engines.

## What made the work difficult

**Query shape determines which optimization helps.** A compound index useful for a listing-and-date join does not automatically accelerate a leading-wildcard text search. The project examines query plans and timing changes rather than assuming that adding indexes always helps.

**Distributed execution has its own costs.** Spark scans, shuffles, task scheduling, and repeated materialization can outweigh the work of a small result set. Reducing the rows and columns that reach joins and reading only the required Parquet partition addresses different sources of overhead.

**Performance comparisons need consistent scope.** Results depend on table size, cache and index state, and what preprocessing is included. The saved scripts preserve the submitted experiments; the accompanying notes explain prerequisites and interpretation limits instead of presenting them as a portable one-command benchmark.

**Useful analytics required an explicit assumption.** The occupancy task estimates stays from review counts. It assumes half of guests leave reviews and applies a rule for length of stay, then caps occupancy at 100%. This is an analytical proxy, not measured bookings or actual occupancy.

## Repository map

| Directory | Contents |
|---|---|
| [assignment-1/](assignment-1/) | PostgreSQL and Databricks SQL, index experiments, query-plan analysis, and an 11-page report |
| [assignment-2/](assignment-2/) | Databricks notebook with saved outputs, Spark optimization, occupancy analytics, and a 23-page report |

Evidence: [Assignment 1 report, pp. 4–10](assignment-1/report.pdf#page=4); [Assignment 2 Task 2 results, p. 6](assignment-2/report.pdf#page=6); [Assignment 2 Task 3 results, p. 8](assignment-2/report.pdf#page=8). Each assignment README provides query descriptions and more detailed setup notes.

## Running and reproducing the experiments

The original Airbnb CSV data and course Bootstrap notebook are **not included** in the supplied submission. The PostgreSQL script expects an existing `airbnb` schema. The Databricks material uses course-specific `/FileStore` paths and Spark notebook commands. Follow the prerequisites in each assignment directory and obtain the matching course data before attempting a run.

The release retains submitted SQL logic and notebook outputs. Publication preparation removed student IDs and private workspace metadata, and redacted IDs from report copies. It did not execute SQL, start a Spark cluster, or rerun benchmarks. The original files are preserved outside this repository.

## Team and attribution

This is a **DATA3404, TUT07 Assignment Group 06** coursework project by **Zhantao Shi and Yuanfeng Liu**. The SQL, notebook, reports, and group results retain their shared authorship. The Assignment 1 report attributes the first individual query to Zhantao Shi and the second to Yuanfeng Liu; the group experiments should not be interpreted as the work of one member alone.

## 中文简介

本项目围绕 Airbnb 多表查询中的性能瓶颈展开：一部分分析 PostgreSQL 执行计划并设计索引，另一部分使用 PySpark、Parquet 和年份分区降低读取与分布式计算开销。报告中，投诉分析查询从 5.717 秒降至 1.365 秒；Spark 查询平均耗时从 1.21 分钟降至 0.328 分钟。还实现了根据评论估算入住率的街区和房源排名。以上为课程报告中的历史实验结果，原始数据、运行环境及实验口径的限制已在各目录说明。
