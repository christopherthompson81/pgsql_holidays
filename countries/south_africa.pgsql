------------------------------------------
------------------------------------------
-- South Africa Holidays
--
-- http://www.gov.za/about-sa/public-holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_South_Africa
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.south_africa(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Month Constants
	JANUARY INTEGER := 1;
	FEBRUARY INTEGER := 2;
	MARCH INTEGER := 3;
	APRIL INTEGER := 4;
	MAY INTEGER := 5;
	JUNE INTEGER := 6;
	JULY INTEGER := 7;
	AUGUST INTEGER := 8;
	SEPTEMBER INTEGER := 9;
	OCTOBER INTEGER := 10;
	NOVEMBER INTEGER := 11;
	DECEMBER INTEGER := 12;
	-- Weekday Constants
	SUNDAY INTEGER := 0;
	MONDAY INTEGER := 1;
	TUESDAY INTEGER := 2;
	WEDNESDAY INTEGER := 3;
	THURSDAY INTEGER := 4;
	FRIDAY INTEGER := 5;
	SATURDAY INTEGER := 6;
	WEEKEND INTEGER[] := ARRAY[0, 6];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_holiday_list holidays.holiday[];

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;

		-- Observed since 1910, with a few name changes
		IF t_year > 1909 THEN
			t_holiday.datestamp := make_date(t_year, 1, 1);
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			-- Easter related holidays
			t_datestamp := holidays.easter(t_year);
			
			-- Good Friday
			t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
			t_holiday.description := 'Good Friday';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			-- Easter monday
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			IF t_year > 1979 THEN
				t_holiday.description := 'Family Day';
			ELSE
				t_holiday.description := 'Easter Monday';
			END IF;
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			-- Day of Reconciliation
			IF t_year BETWEEN 1910 AND 1951 THEN
				t_holiday.description := 'Dingaan''s Day';
			ELSIF t_year BETWEEN 1952 AND 1979 THEN
				t_holiday.description := 'Day of the Covenant';
			ELSIF t_year BETWEEN 1980 AND 1994 THEN
				t_holiday.description := 'Day of the Vow';
			ELSE
				t_holiday.description := 'Day of Reconciliation';
			END IF;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 16);
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			-- Christmas Day
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Christmas Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			-- Day of Goodwill / Boxing Day
			IF t_year > 1979 THEN
				t_holiday.description := 'Day of Goodwill';
			ELSE
				t_holiday.description := 'Boxing Day';
			END IF;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- Observed since 1995/1/1
		IF t_year > 1994 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			t_holiday.description := 'Human Rights Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, APRIL, 27);
			t_holiday.description := 'Freedom Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Workers'' Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, JUNE, 16);
			t_holiday.description := 'Youth Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, AUGUST, 9);
			t_holiday.description := 'National Women''s Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 24);
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- Once-off public holidays
		IF t_year = 1999 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 2);
			t_holiday.description := 'National and provincial government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
			t_holiday.description := 'Y2K changeover';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2000 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 2);
			t_holiday.description := 'Y2K changeover';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2004 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 14);
			t_holiday.description := 'National and provincial government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2006 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
			t_holiday.description := 'Local government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2008 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'By presidential decree';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2009 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 22);
			t_holiday.description := 'National and provincial government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2011 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 18);
			t_holiday.description := 'Local government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);

			t_holiday.datestamp := make_date(t_year, DECMBER, 27);
			t_holiday.description := 'By presidential decree';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2014 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 7);
			t_holiday.description := 'National and provincial government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2016 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 3);
			t_holiday.description := 'Local government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;
		IF t_year = 2019 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 8);
			t_holiday.description := 'National and provincial government elections';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- As of 1995/1/1, whenever a public holiday falls on a Sunday,
		-- it rolls over to the following Monday
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			IF t_year > 1994 AND DATE_PART('dow', t_holiday.datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_holiday.datestamp + '1 Day'::INTERVAL;
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;

		-- Historic public holidays no longer observed
		IF t_year BETWEEN 1952 AND 1973 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 6);
			t_holiday.description := 'Van Riebeeck''s Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1980 AND 1994 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 6);
			t_holiday.description := 'Founder''s Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1987 AND 1989 THEN
			-- historic_workers_day
			-- observed on first Friday in May
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), FRIDAY, 1);
			t_holiday.description := 'Workers'' Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1910 AND 1993 THEN
			t_holiday.datestamp := holidays.easter(t_year) + '40 Days'::INTERVAL;
			t_holiday.description := 'Ascension Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1910 AND 1951 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 24);
			t_holiday.description := 'Empire Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1910 AND 1960 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Union Day';
			RETURN NEXT t_holiday;
		ELSIF t_year BETWEEN 1961 AND 1993 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Republic Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1952 AND 1960 THEN
			-- observed on second Monday in June
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 2);
			t_holiday.description := 'Queen''s Birthday';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1961 AND 1973 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 10);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1910 AND 1951 THEN
			-- observed on first Monday in August
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'King''s Birthday';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1952 AND 1979 THEN
			-- observed on first Sunday in September
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), SUNDAY, 1);
			t_holiday.description := 'Settlers'' Day';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year BETWEEN 1952 AND 1993 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 10);
			t_holiday.description := 'Kruger Day';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;