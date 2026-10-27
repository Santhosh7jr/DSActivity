# Dataset inspection findings

## Main dataset shape

- Rows: **1,587**
- Columns: **13**
- Unique repository full names: **1,049**
- Missing descriptions: **36**
- Duplicate rows across `full_name`, `timeframe`, `search_language`: **0**
- Unique values in `contributors_count`: **1** (value(s): [0])

## Numeric summary

|       |    stars |     forks |   stars_period |   contributors_count |
|:------|---------:|----------:|---------------:|---------------------:|
| count |   1587   |   1587    |        1587    |                 1587 |
| mean  |  16491.5 |   3078.66 |         289.51 |                    0 |
| std   |  24376.8 |   7858.05 |        1402.58 |                    0 |
| min   |     25   |      4    |           0    |                    0 |
| 25%   |   2780.5 |    343    |           4    |                    0 |
| 50%   |   7956   |   1037    |          28    |                    0 |
| 75%   |  20989   |   2856    |         142    |                    0 |
| max   | 434010   | 143957    |       30879    |                    0 |

## Most common languages in the main CSV

| language   |   rows |
|:-----------|-------:|
| C          |    117 |
| Python     |     81 |
| TypeScript |     67 |
| C++        |     66 |
| Rust       |     66 |
| Swift      |     66 |
| Dart       |     65 |
| Ruby       |     64 |
| Scala      |     62 |
| Java       |     62 |

## Highest `stars_period` records

| full_name                | language   |   stars |   forks |   stars_period | timeframe   | url                                         |
|:-------------------------|:-----------|--------:|--------:|---------------:|:------------|:--------------------------------------------|
| sansan0/TrendRadar       | Python     |   36604 |   19908 |          30879 | monthly     | https://github.com/sansan0/TrendRadar       |
| sansan0/TrendRadar       | Python     |   36604 |   19908 |          30879 | monthly     | https://github.com/sansan0/TrendRadar       |
| kavishdevar/librepods    | Kotlin     |   18868 |     886 |          17239 | monthly     | https://github.com/kavishdevar/librepods    |
| usestrix/strix           | Python     |   16398 |    1629 |          13755 | monthly     | https://github.com/usestrix/strix           |
| usestrix/strix           | Python     |   16398 |    1629 |          13755 | monthly     | https://github.com/usestrix/strix           |
| daytonaio/daytona        | TypeScript |   35109 |    2732 |           8130 | monthly     | https://github.com/daytonaio/daytona        |
| sansan0/TrendRadar       | Python     |   36604 |   19908 |           7513 | weekly      | https://github.com/sansan0/TrendRadar       |
| sansan0/TrendRadar       | Python     |   36604 |   19908 |           7513 | weekly      | https://github.com/sansan0/TrendRadar       |
| yeongpin/cursor-free-vip | Python     |   44916 |    5365 |           5309 | monthly     | https://github.com/yeongpin/cursor-free-vip |
| yeongpin/cursor-free-vip | Python     |   44916 |    5365 |           5309 | monthly     | https://github.com/yeongpin/cursor-free-vip |

## Modelling decision

The project uses **one-predictor Linear Regression**: `log1p(stars_period) ~ log1p(forks)`. The logarithmic transform reduces the influence of extremely large counts. `contributors_count` is excluded because it is zero for every row, so it has no variation and cannot help fit a regression model.

## Interpretation cautions

- There are 1,587 rows but only 1,049 unique repository names, so some repositories are represented in multiple collection contexts.
- The dataset captures repositories already found trending. It cannot on its own show what causes a repository to become popular or guarantee predictions for repositories outside this dataset.
- Model quality must be judged from the test metrics printed when the notebook/dashboard runs; do not claim high accuracy before checking them.
