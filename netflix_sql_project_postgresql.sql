/* ============================================================
   NETFLIX MOVIES & TV SHOWS — SQL ANALYSIS PROJECT
   Database Engine : PostgreSQL
   Dataset         : Netflix Movies and TV Shows (Kaggle-style)
   Columns         : show_id, type, title, director, cast_members,
                     country, date_added, release_year, rating,
                     duration, listed_in, description

   Author's Note:
   This project explores the Netflix catalog using PostgreSQL,
   covering distribution of content types, genre trends, top
   countries, longest movies, release trends, and director-level
   insights.
   ============================================================ */


-- ============================================================
-- 1. TABLE SETUP
-- ============================================================
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id      VARCHAR(10) PRIMARY KEY,
    type         VARCHAR(10),   -- 'Movie' or 'TV Show'
    title        VARCHAR(255),
    director     VARCHAR(255),
    cast_members TEXT,
    country      VARCHAR(255),
    date_added   DATE,
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(255),  -- genres, comma-separated
    description  TEXT
);

-- Load the CSV data (run this from psql, not a plain SQL editor,
-- since \copy reads the file from your local machine):
--
-- \copy netflix FROM 'path/to/netflix_titles.csv' DELIMITER ',' CSV HEADER;


-- ============================================================
-- 2. MOVIES vs TV SHOWS — overall split
-- ============================================================
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM netflix), 2) AS pct_of_catalog
FROM netflix
GROUP BY type
ORDER BY total_titles DESC;


-- ============================================================
-- 3. MOST COMMON GENRES
--    'listed_in' stores multiple comma-separated genres per title,
--    so we split it into individual rows before counting.
-- ============================================================
SELECT
    TRIM(genre) AS genre,
    COUNT(*) AS title_count
FROM netflix,
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY TRIM(genre)
ORDER BY title_count DESC
LIMIT 10;


-- ============================================================
-- 4. TOP COUNTRIES BY NUMBER OF TITLES
--    'country' can also contain multiple comma-separated values.
-- ============================================================
SELECT
    TRIM(country_name) AS country,
    COUNT(*) AS title_count
FROM netflix,
     UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
WHERE country IS NOT NULL
GROUP BY TRIM(country_name)
ORDER BY title_count DESC
LIMIT 10;


-- ============================================================
-- 5. LONGEST MOVIES (by duration in minutes)
--    'duration' is stored as text like '90 min' for movies,
--    and 'X Seasons' for TV shows, so we filter to movies only.
-- ============================================================
SELECT
    title,
    director,
    release_year,
    duration
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY CAST(REPLACE(duration, ' min', '') AS INTEGER) DESC
LIMIT 5;


-- ============================================================
-- 6. RELEASES BY YEAR (trend over time)
-- ============================================================

-- 6a. Split by type
SELECT
    release_year,
    type,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY release_year, type
ORDER BY release_year DESC, type;

-- 6b. Combined total per year
SELECT
    release_year,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY release_year
ORDER BY release_year DESC;


-- ============================================================
-- 7. DIRECTOR ANALYSIS
-- ============================================================

-- 7a. Directors with the most titles overall
SELECT
    director,
    COUNT(*) AS total_titles
FROM netflix
WHERE director IS NOT NULL AND director <> ''
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

-- 7b. Directors who worked in BOTH Movies and TV Shows
SELECT
    director,
    COUNT(DISTINCT type) AS type_variety
FROM netflix
WHERE director IS NOT NULL AND director <> ''
GROUP BY director
HAVING COUNT(DISTINCT type) = 2;

-- 7c. Top director per country (using a window function)
SELECT country, director, total_titles
FROM (
    SELECT
        country,
        director,
        COUNT(*) AS total_titles,
        RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    WHERE director IS NOT NULL AND director <> ''
      AND country IS NOT NULL AND country <> ''
    GROUP BY country, director
) ranked
WHERE rnk = 1
ORDER BY total_titles DESC
LIMIT 15;


-- ============================================================
-- 8. BONUS: Content added by year (date_added vs release_year)
--    Shows when Netflix added a title, which can differ from
--    when it was originally released.
-- ============================================================
SELECT
    EXTRACT(YEAR FROM date_added) AS year_added,
    COUNT(*) AS titles_added
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY EXTRACT(YEAR FROM date_added)
ORDER BY year_added DESC;
