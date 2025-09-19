IMPORT DATABASE 'data/db'
  ;
-- Get tasks for each crew role for each ship.
DROP TABLE IF EXISTS tasks;
CREATE OR REPLACE TABLE tasks AS (
  SELECT
      s.ship_id,
      c.role,
      ARRAY_AGG(
          STRUCT_PACK(
              start_ts := c.start_ts_utc,
              end_ts := c.end_ts_utc,
              sailing_id := c.sailing_id
          )
          ORDER BY c.start_ts_utc
      ) AS tasks
  FROM crew_shifts_hist c
  JOIN sailings s
      ON c.sailing_id = s.sailing_id
  GROUP BY s.ship_id, c.role
  ORDER BY s.ship_id, c.role
);
EXPORT DATABASE 'data/db' (FORMAT parquet);
