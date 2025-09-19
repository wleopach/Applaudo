-- Load all CSVs from the data/ directory into a DuckDB database.
-- Each table is named after the CSV file (without extension).
--
-- Usage examples:
--   1) Create/refresh a database file and run this script:
--        duckdb applaudo.duckdb -c ".read load_duckdb.sql"
--   2) Or from within an interactive DuckDB session connected to your DB:
--        .read load_duckdb.sql
--
-- Notes:
-- - read_csv_auto will infer column types from the full file (SAMPLE_SIZE=-1).
-- - IGNORE_ERRORS=true ensures rows with bad formatting won't abort the load;
--   you can change this to false if you want strict loading.
-- - Paths are relative to the project root (this file lives at the root).

-- Optional: put everything into a dedicated schema if you prefer
-- CREATE SCHEMA IF NOT EXISTS raw;
-- SET schema='raw';

PRAGMA threads=4;

-- calendar.csv
DROP TABLE IF EXISTS calendar;
CREATE OR REPLACE TABLE calendar AS
SELECT * FROM read_csv_auto('data/calendar.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- crew.csv
DROP TABLE IF EXISTS crew;
CREATE OR REPLACE TABLE crew AS
SELECT * FROM read_csv_auto('data/crew.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- crew_shifts_hist.csv
DROP TABLE IF EXISTS crew_shifts_hist;
CREATE OR REPLACE TABLE crew_shifts_hist AS
SELECT * FROM read_csv_auto('data/crew_shifts_hist.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- deliveries.csv
DROP TABLE IF EXISTS deliveries;
CREATE OR REPLACE TABLE deliveries AS
SELECT * FROM read_csv_auto('data/deliveries.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- events.csv
DROP TABLE IF EXISTS events;
CREATE OR REPLACE TABLE events AS
SELECT * FROM read_csv_auto('data/events.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- inventory_items.csv
DROP TABLE IF EXISTS inventory_items;
CREATE OR REPLACE TABLE inventory_items AS
SELECT * FROM read_csv_auto('data/inventory_items.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- onboard_sales.csv
DROP TABLE IF EXISTS onboard_sales;
CREATE OR REPLACE TABLE onboard_sales AS
SELECT * FROM read_csv_auto('data/onboard_sales.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- ports.csv
DROP TABLE IF EXISTS ports;
CREATE OR REPLACE TABLE ports AS
SELECT * FROM read_csv_auto('data/ports.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- sailings.csv
DROP TABLE IF EXISTS sailings;
CREATE OR REPLACE TABLE sailings AS
SELECT * FROM read_csv_auto('data/sailings.csv', SAMPLE_SIZE=-1, IGNORE_ERRORS=true);

-- Optional quick sanity checks (comment out if not needed)
-- SELECT 'calendar' AS table, COUNT(*) AS n FROM calendar
-- UNION ALL SELECT 'crew', COUNT(*) FROM crew
-- UNION ALL SELECT 'crew_shifts_hist', COUNT(*) FROM crew_shifts_hist
-- UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries
-- UNION ALL SELECT 'events', COUNT(*) FROM events
-- UNION ALL SELECT 'inventory_items', COUNT(*) FROM inventory_items
-- UNION ALL SELECT 'onboard_sales', COUNT(*) FROM onboard_sales
-- UNION ALL SELECT 'ports', COUNT(*) FROM ports
-- UNION ALL SELECT 'sailings', COUNT(*) FROM sailings;
EXPORT DATABASE '/data/db' (FORMAT parquet);


IMPORT DATABASE 'data/db';