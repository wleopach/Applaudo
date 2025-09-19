IMPORT DATABASE 'data/db'
  ;
DROP TABLE IF EXISTS daily_demand;
CREATE OR REPLACE TABLE daily_demand AS (WITH sales AS (
      SELECT *
      FROM onboard_sales
      JOIN sailings
      USING (sailing_id)
  )
  SELECT DAYOFYEAR(ts_utc) AS doy, ship_id, location, item_id, SUM(qty) AS qty_day
  FROM sales
  GROUP BY doy, ship_id, location, item_id
  ORDER BY doy, ship_id);

EXPORT DATABASE 'data/db' (FORMAT parquet);