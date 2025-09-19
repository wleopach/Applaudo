IMPORT
DATABASE 'data/db';
DROP TABLE IF EXISTS crew_members_by_date;
CREATE TABLE crew_members_by_date AS
    (WITH hours AS (SELECT UNNEST(
                                   generate_series(
                                           (SELECT MIN(start_ts_utc) FROM crew_shifts_hist),
                                           (SELECT MAX(end_ts_utc) FROM crew_shifts_hist) + INTERVAL '1 hour',
                                           INTERVAL '1 hour'
                                   )
                           ) AS hour_start)
     SELECT h.hour_start,
            s.ship_id,
            c.role,
            COUNT(DISTINCT c.crew_id) AS distinct_crew
     FROM hours h
              JOIN crew_shifts_hist c
                   ON c.start_ts_utc <= h.hour_start
                       AND (c.end_ts_utc IS NULL OR c.end_ts_utc > h.hour_start)
              JOIN sailings s
                   ON c.sailing_id = s.sailing_id
     GROUP BY h.hour_start, s.ship_id, c.role
     ORDER BY h.hour_start, s.ship_id, c.role);

DROP TABLE IF EXISTS crew_members_by_dow;
CREATE
OR REPLACE TABLE crew_members_by_dow AS (
    SELECT DAYOFWEEK(hour_start) dow, HOUR(hour_start) "hour",ship_id, role, AVG(distinct_crew) avg_crew, MIN(distinct_crew) min_crew, MAX(distinct_crew) max_crew
  FROM crew_members_by_date
  GROUP BY dow, "hour" ,ship_id, role
  ORDER BY ship_id, dow, "hour");

EXPORT DATABASE 'data/db' (FORMAT parquet);