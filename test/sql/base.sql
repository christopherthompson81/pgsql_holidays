BEGIN;

CREATE EXTENSION holidays;

SELECT * FROM holidays.by_country ('FR'::text, 2022, 2023);

SELECT * FROM holidays.by_country ('FR'::text, '10/01/2022'::date, '05/31/2023'::date);

SELECT * FROM holidays.by_country ('FR'::text, daterange('2022/10/01', '2023/05/31'));

ROLLBACK;
