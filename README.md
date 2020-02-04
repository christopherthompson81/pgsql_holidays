# pgsql_holidays
Package to calculate holiday dates in PostgreSQL

Ported to PL/pgSQL from python: https://github.com/dr-prodigy/python-holidays

# Installation:

There are files provided which will create schemas and functions in your database. The holidays package is intended to reside in a new "holidays" schema.

1. Create the holidays schema using the files in /db_setup/holidays_schema.pgsql
2. Create the "holiday" type in the new schema using /db_setup/holiday_type.pgsql
3. Add the utility functions necessary for your use case. You will most likely need "easter.pgsql", and "find_nth_weekday_date.pgsql".
4. Add your country function. For example: "countries/canada.pgsql"

# Usage:

You can select holidays from the new schema for your country using the following syntax. Where there are no sub-regions in a country, the parameter is omitted from the call.

	SELECT * FROM holidays.canada('ON', 2020, 2020);

# ToDo

There are some more complicated countries I have yet to finish porting. Generally, they are the ones using non-Gregorian calendars.

* Egypt (Hijri)
* Hong Kong (Lunar)
* Isreal (Hebrew)
* Singapore (Hijri)
