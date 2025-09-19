IMPORT
DATABASE 'data/db';

ALTER TABLE sailings
  DROP COLUMN doy;
D ALTER TABLE calendar ADD COLUMN doy INTEGER;
D UPDATE calendar
  SET doy = DAYOFYEAR(date);

EXPORT DATABASE 'data/db' (FORMAT parquet);