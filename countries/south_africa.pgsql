------------------------------------------
------------------------------------------
-- South Africa Holidays (Porting Unfinished)
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

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Observed since 1910, with a few name changes
		IF t_year > 1909 THEN
			t_holiday.datestamp := make_date(t_year, 1, 1);
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;

			e = easter(year)
			good_friday = e - '2 Days'::INTERVAL
			easter_monday = e + '1 Days'::INTERVAL
			self[good_friday] = 'Good Friday'
			IF t_year > 1979 THEN
				self[easter_monday] = 'Family Day'
			ELSE
				self[easter_monday] = 'Easter Monday'
			END IF;

			IF 1909 < year < 1952 THEN
				t_holiday.description := 'Dingaan''s Day';
			ELSIF 1951 < year < 1980 THEN
				t_holiday.description := 'Day of the Covenant';
			ELSIF 1979 < year < 1995 THEN
				t_holiday.description := 'Day of the Vow';
			ELSE
				t_holiday.description := 'Day of Reconciliation';
			END IF;
			self[date(year, DECEMBER, 16)] = dec_16_name

			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Christmas Day';
			RETURN NEXT t_holiday;

			IF t_year > 1979 THEN
				t_holiday.description := 'Day of Goodwill';
			ELSE
				t_holiday.description := 'Boxing Day';
			END IF;
			self[date(year, 12, 26)] = dec_26_name
		END IF;

		-- Observed since 1995/1/1
		IF t_year > 1994 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			t_holiday.description := 'Human Rights Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APRIL, 27);
			t_holiday.description := 'Freedom Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Workers'' Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUNE, 16);
			t_holiday.description := 'Youth Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, AUGUST, 9);
			t_holiday.description := 'National Women''s Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 24);
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Once-off public holidays
		national_election = 'National and provincial government elections'
		y2k = 'Y2K changeover'
		local_election = 'Local government elections'
		presidential = 'By presidential decree'
		IF t_year == 1999 THEN
			self[date(1999, JUNE, 2)] = national_election
			self[date(1999, DECEMBER, 31)] = y2k
		END IF;
		IF t_year == 2000 THEN
			self[date(2000, JANUARY, 2)] = y2k
		END IF;
		IF t_year == 2004 THEN
			self[date(2004, APRIL, 14)] = national_election
		END IF;
		IF t_year == 2006 THEN
			self[date(2006, MARCH, 1)] = local_election
		END IF;
		IF t_year == 2008 THEN
			self[date(2008, MAY, 2)] = presidential
		END IF;
		IF t_year == 2009 THEN
			self[date(2009, APRIL, 22)] = national_election
		END IF;
		IF t_year == 2011 THEN
			self[date(2011, MAY, 18)] = local_election
			self[date(2011, DECEMBER, 27)] = presidential
		END IF;
		IF t_year == 2014 THEN
			self[date(2014, MAY, 7)] = national_election
		END IF;
		IF t_year == 2016 THEN
			self[date(2016, AUGUST, 3)] = local_election
		END IF;
		IF t_year == 2019 THEN
			self[date(2019, MAY, 8)] = national_election
		END IF;

		-- As of 1995/1/1, whenever a public holiday falls on a Sunday,
		-- it rolls over to the following Monday
		for k, v in list(self.items()):
			IF t_year > 1994 and k.weekday() == SUN THEN
				self[k + rd(days=1)] = v + ' (Observed)'
			END IF;

		-- Historic public holidays no longer observed
		IF 1951 < year < 1974 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 6);
			t_holiday.description := 'Van Riebeeck''s Day';
			RETURN NEXT t_holiday;
		ELSIF 1979 < year < 1995 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 6);
			t_holiday.description := 'Founder''s Day';
			RETURN NEXT t_holiday;
		END IF;

		IF 1986 < year < 1990 THEN
			historic_workers_day = datetime(year, MAY, 1)
			-- observed on first Friday in May
			while historic_workers_day.weekday() != FRI:
				historic_workers_day += rd(days=1)

			self[historic_workers_day] = 'Workers'' Day'
		END IF;

		IF 1909 < year < 1994 THEN
			ascension_day = e + '40 Days'::INTERVAL
			self[ascension_day] = 'Ascension Day'
		END IF;

		IF 1909 < year < 1952 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 24);
			t_holiday.description := 'Empire Day';
			RETURN NEXT t_holiday;
		END IF;

		IF 1909 < year < 1961 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Union Day';
			RETURN NEXT t_holiday;
		ELSIF 1960 < year < 1994 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Republic Day';
			RETURN NEXT t_holiday;
		END IF;

		IF 1951 < year < 1961 THEN
			queens_birthday = datetime(year, JUNE, 7)
			-- observed on second Monday in June
			while queens_birthday.weekday() != 0:
				queens_birthday += rd(days=1)

			self[queens_birthday] = 'Queen''s Birthday'
		END IF;

		IF 1960 < year < 1974 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 10);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		END IF;

		IF 1909 < year < 1952 THEN
			kings_birthday = datetime(year, AUGUST, 1)
			-- observed on first Monday in August
			while kings_birthday.weekday() != 0:
				kings_birthday += rd(days=1)

			self[kings_birthday] = 'King''s Birthday'
		END IF;

		IF 1951 < year < 1980 THEN
			settlers_day = datetime(year, SEPTEMBER, 1)
			while settlers_day.weekday() != 0:
				settlers_day += rd(days=1)

			self[settlers_day] = 'Settlers'' Day'
		END IF;

		IF 1951 < year < 1994 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 10);
			t_holiday.description := 'Kruger Day';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;