BEGIN;

CREATE EXTENSION holidays;

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, '14610');

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, 'Basse Normandie');

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, '67270');

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, 'Alsace-Moselle');

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, '97160');

SELECT * FROM holidays.by_country ('FR'::text, 2023, 2023, 'Guadeloupe');

ROLLBACK;
