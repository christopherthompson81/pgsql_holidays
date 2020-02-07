# pgsql_holidays
Package to calculate holiday dates in PostgreSQL

Ported to PL/pgSQL from python: https://github.com/dr-prodigy/python-holidays

# Installation:

There are files provided which will create schemas and functions in your database. The holidays package is intended to reside in a new "holidays" schema.

1. Create the holidays schema using the files in /db_setup/holidays_schema.pgsql
2. Create the "holiday" type in the new schema using /db_setup/holiday_type.pgsql
3. Add the utility functions necessary for your use case. You will most likely need "easter.pgsql", and "find_nth_weekday_date.pgsql".
4. Add your country function. For example: "countries/canada.pgsql"

Alternatively, you can use the python loader.

1. Create a postgresql_config.json file using postgresql_config.example.json as a template
2. Install pipenv

		pip install pipenv

3. Use pipenv to install the prerequisite python modules

		pipenv install

4.  Run the loader

		pipenv run python .\build_holidays_schema.py

# Usage:

You can select holidays from the new schema for your country using the following syntax. Where there are no sub-regions in a country, the parameter is omitted from the call.

	SELECT * FROM holidays.canada('ON', 2020, 2020);

The query will return the results:

	datestamp       description
	[DATE]          [TEXT]
	------------    -----------------------
	"2020-01-01"    "New Year's Day"
	"2020-02-17"    "Family Day"
	"2020-04-10"    "Good Friday"
	"2020-05-18"    "Victoria Day"
	"2020-07-01"    "Canada Day"
	"2020-08-03"    "Civic Holiday"
	"2020-09-07"    "Labour Day"
	"2020-11-11"    "Remembrance Day"
	"2020-12-25"    "Christmas Day"
	"2020-12-28"    "Boxing Day (Observed)"

A convienience "by country" function is also provided which accepts many name variations and defines a default region.

	SELECT * FROM holidays.by_country('canada', 2020, 2020);

The above query would also produce the same output.

# To Do

There are some more complicated countries I have yet to finish porting. Generally, they are the ones using non-Gregorian calendars.

* Egypt (Hijri)
* Hong Kong (Lunar)
* Isreal (Hebrew)
* Singapore (Hijri)
