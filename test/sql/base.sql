BEGIN;

CREATE EXTENSION holidays;

SELECT * FROM holidays.by_country ('FR'::text, 2022, 2023);

ROLLBACK;
