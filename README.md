# Netflix Movies & TV Shows — SQL Analysis Project

A PostgreSQL-based exploratory analysis of the Netflix Movies and TV Shows dataset.

## Dataset

The dataset contains metadata for titles available on Netflix, with the following columns:

| Column | Description |
|---|---|
| show_id | Unique ID for each title |
| type | 'Movie' or 'TV Show' |
| title | Title name |
| director | Director name |
| cast_members | Cast list |
| country | Country/countries of production |
| date_added | Date the title was added to Netflix |
| release_year | Year the title was originally released |
| rating | Content rating (e.g. TV-MA, PG-13) |
| duration | Movie length in minutes, or number of TV seasons |
| listed_in | Genre(s), comma-separated |
| description | Short synopsis |

## Analysis Covered

1. **Movies vs TV Shows** — overall catalog split
2. **Most common genres** — genres split from comma-separated values and ranked
3. **Top countries** — countries split from comma-separated values and ranked
4. **Longest movies** — top 5 movies by runtime
5. **Releases by year** — trend of titles by release year, split by type
6. **Director analysis** — most prolific directors, directors active in both Movies and TV Shows, and top director per country

## How to Run

1. Install PostgreSQL and open the `psql` shell (or use a GUI client like pgAdmin / DBeaver / VS Code with SQLTools).
2. Create a database:
   ```sql
   CREATE DATABASE netflix_db;
   \c netflix_db
   ```
3. Run the `CREATE TABLE` statement at the top of `netflix_sql_project_postgresql.sql`.
4. Load the dataset CSV:
   ```sql
   \copy netflix FROM 'path/to/netflix_titles.csv' DELIMITER ',' CSV HEADER;
   ```
5. Run the analysis queries in `netflix_sql_project_postgresql.sql` section by section.

## Notes

- Written and tested against **PostgreSQL 16**.
- Genre and country splitting relies on PostgreSQL's `UNNEST` and `STRING_TO_ARRAY` functions, which are Postgres-specific (a MySQL equivalent would need a recursive CTE instead).
