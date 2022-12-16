# pgsql_holidays

PostgreSQL extension to calculate holiday dates for any country.

# Installation

## Build and install PostgreSQL extension

You can build and install the extension using the following commands:

		make
		make installcheck
		sudo make install

NB. Chinese, Hebrew, Hijri, Hindu, and Jalali calendar functions require
another of my libraries:
[calendar_converter_pgsql](https://github.com/christopherthompson81/calendar_converter_pgsql)

# Usage

You can select holidays from the new schema for your country using the
following syntax. Where there are no sub-regions in a country, the parameter is
omitted from the call.

	SELECT * FROM holidays.canada('ON', 2020, 2020);

The query will return the results:

	datestamp       description                authority      day_off      observation_shifted   start_time   end_time        
	[DATE]          [TEXT]                     [ENUM]         [BOOLEAN]    [BOOLEAN]             [TIME]       [TIME]
	------------    -----------------------    -----------    ---------    -------------------   ----------   ----------
	"2020-01-01"	"New Year's Day"           "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-02-17"	"Family Day"               "provincial"    true        false                 "00:00:00"   "24:00:00"
	"2020-04-10"	"Good Friday"              "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-05-18"	"Victoria Day"             "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-07-01"	"Canada Day"               "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-08-03"	"Civic Holiday"            "provincial"    true        false                 "00:00:00"   "24:00:00"
	"2020-09-07"	"Labour Day"               "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-11-11"	"Remembrance Day"          "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-12-25"	"Christmas Day"            "federal"       true        false                 "00:00:00"   "24:00:00"
	"2020-12-28"	"Boxing Day (Observed)"    "federal"       true        true                  "00:00:00"   "24:00:00"



A convienience "by country" function is also provided which accepts many name
variations and defines a default region.

	SELECT * FROM holidays.by_country('canada', 2020, 2020);

The above query would also produce the same output.

# Development

For ease of use, instead of installing
[pgxn-client](https://pgxn.github.io/pgxnclient/) locally, you can use the
provided docker container.

* Start the container (it will stay up for 10 days by default):

```sh
docker-compose up -d
```

* Enter the container:

```sh
docker-compose exec pgxn-tools bash
```

* Create the instance and the database:

```sh
sudo pg-start 15
createdb -U postgres contrib_regression
```

* Install the extension

```sh
cd /repo && make install
```

* Then you can enter the PostgreSQL instance:

```sh
psql -U postgres -d contrib_regression
```

* Create the extension:

``` sql
create extension holidays;
\dn
```

* Retrieve some holidays:

``` sql
SELECT * FROM holidays.by_country ('FR'::text, 2022, 2023);
```


* To stop the container:

```sh
docker-compose down
```

* To run the test on PostgreSQL 15:

```sh
docker-compose up -d && \
    docker-compose exec pgxn-tools bash -c 'cd /repo && sudo pg-start 15 && pg-build-test' ; \
    docker-compose down
```

# To Do

Cross-port the knowledge from the npm / javascript libraries for the same
purpose. It uses a declarative method (which may be concurrently recorded
here), implements periods, and covers additional countries:

* https://github.com/commenthol/date-holidays-parser

Fill in missing information related to partial holidays, or non-holiday, but special dates:

* https://www.timeanddate.com/holidays/

# Feedback

I openly solicit pull requests and issues as feedback to make this package
better. The port from Python was naive and I'm only intimately knowledgable
about my own country's holidays (Canada). I expect many corrections and
enhancements are necessary.

# Ported From Credits / Attributions

* Primary Code Sources
	* [Python holidays](https://github.com/dr-prodigy/python-holidays)
	* [JavaScript date-holidays](https://github.com/commenthol/date-holidays)
