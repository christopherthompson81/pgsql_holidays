------------------------------------------
------------------------------------------
-- Australia Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.australia(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Provinces
	PROVINCES = ['ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA']
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

		-- ACT:  Holidays Act 1958
		-- NSW:  Public Holidays Act 2010
		-- NT:   Public Holidays Act 2013
		-- QLD:  Holidays Act 1983
		-- SA:   Holidays Act 1910
		-- TAS:  Statutory Holidays Act 2000
		-- VIC:  Public Holidays Act 1993
		-- WA:   Public and Bank Holidays Act 1972

		-- TODO do more research on history of Aus holidays

		-- New Year's Day
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp = find_nth_weekday_date(t_datestamp, MO, 1);
			t_holiday.description = name + ' (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Australia Day
		t_datestamp := make_date(t_year, JANUARY, 26);
		IF t_year >= 1935 THEN
			IF p_province = 'NSW' AND t_year < 1946 THEN
				t_holiday.description := 'Anniversary Day';
			ELSE
				t_holiday.description := 'Australia Day';
			END IF;
			t_holiday.datestamp = t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 1946 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp = find_nth_weekday_date(t_datestamp, MO, 1);
				t_holiday.description = t_holiday.description + ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		ELSIF t_year >= 1888 AND p_province != 'SA' THEN
			t_holiday.datestamp = t_datestamp;
			t_holiday.description := 'Anniversary Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Adelaide Cup
		IF p_province = 'SA' THEN
			t_holiday.description := 'Adelaide Cup';
			IF t_year >= 2006 THEN
				-- subject to proclamation ?!?!
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +3);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Canberra Day
		-- Info from https://www.timeanddate.com/holidays/australia/canberra-day
		-- and https://en.wikipedia.org/wiki/Canberra_Day
		IF p_province = 'ACT' AND t_year >= 1913 THEN
			t_holiday.description := 'Canberra Day';
			IF t_year >= 1913 AND t_year <= 1957 THEN
				self[date(year, MAR, 12)] = name
			ELSIF t_year >= 1958 AND t_year <= 2007 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +3);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSIF t_year >= 2008 AND t_year != 2012 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSIF t_year == 2012 THEN
				self[date(year, MAR, 12)] = name
			END IF;
		END IF;

		-- Easter
		self[easter(year) + rd(weekday=FR(-1))] = 'Good Friday'
		IF p_province in ('ACT', 'NSW', 'NT', 'QLD', 'SA', 'VIC') THEN
			self[easter(year) + rd(weekday=SA(-1))] = 'Easter Saturday'
		END IF;
		IF p_province in ('ACT', 'NSW', 'QLD', 'VIC') THEN
			self[easter(year)] = 'Easter Sunday'
		END IF;
		self[easter(year) + rd(weekday=MO)] = 'Easter Monday'

		-- Anzac Day
		IF t_year > 1920 THEN
			t_holiday.description := 'Anzac Day';
			t_datestamp := make_date(t_year, APR, 25);
			self[apr25] = name
			IF DATE_PART('dow', t_datestamp) = SAT AND p_province IN ('WA', 'NT') THEN
				self[apr25 + rd(weekday=MO)] = name + ' (Observed)'
			ELSIF DATE_PART('dow', t_datestamp) = SUN AND p_province IN ('ACT', 'QLD', 'SA', 'WA', 'NT')) THEN
				self[apr25 + rd(weekday=MO)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Western Australia Day
		IF p_province = 'WA' AND t_year > 1832 THEN
			IF t_year >= 2015 THEN
				t_holiday.description := 'Western Australia Day';
			ELSE
				t_holiday.description := 'Foundation Day';
			END IF;
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUN, 1), MO, +1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Sovereign's Birthday
		IF t_year >= 1952 THEN
			t_holiday.description := 'Queen''s Birthday';
		ELSIF t_year > 1901 THEN
			t_holiday.description := 'King''s Birthday';
		END IF;
		IF t_year >= 1936 THEN
			t_holiday.description := 'Queen''s Birthday';
			IF p_province = 'QLD' THEN
				IF t_year == 2012 THEN
					t_holiday.datestamp := make_date(t_year, JUN, 11);
					t_holiday.description := 'Queen''s Diamond Jubilee';
					RETURN NEXT t_holiday;
				END IF;
				IF t_year < 2016 AND t_year != 2012 THEN
					dt = find_nth_weekday_date(make_date(t_year, JUN, 1), MO, +2);
					self[dt] = name
				ELSE
					dt = date(year, OCT, 1) + rd(weekday=MO)
					self[dt] = name
				END IF;
			ELSIF p_province = 'WA' THEN
				-- by proclamation ?!?!
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 1), MO, -1);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSIF p_province in ('NSW', 'VIC', 'ACT', 'SA', 'NT', 'TAS') THEN
				dt = find_nth_weekday_date(make_date(t_year, JUN, 1), MO, +2);
				self[dt] = name
			END IF;
		ELSIF t_year > 1911 THEN
			self[date(year, JUN, 3)] = name  -- George V
		ELSIF t_year > 1901 THEN
			self[date(year, NOV, 9)] = name  -- Edward VII
		END IF;

		-- Picnic Day
		IF p_province = 'NT' THEN
			t_holiday.description := 'Picnic Day';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, AUG, 1), 1, MO);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Bank Holiday
		IF p_province = 'NSW' THEN
			IF t_year >= 1912 THEN
				t_holiday.description := 'Bank Holiday';
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, 8, 1), 1, MO);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Labour Day
		t_holiday.description := 'Labour Day';
		IF p_province in ('NSW', 'ACT', 'SA') THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 1), 1, MO);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF p_province == 'WA' THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), 1, MO);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF p_province == 'VIC' THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF p_province == 'QLD' THEN
			IF t_year BETWEEN 2013 AND 2015 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 1), 1, MO);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 1), 1, MO);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_province == 'NT' THEN
			t_holiday.description := 'May Day';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 1), 1, MO);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF p_province == 'TAS' THEN
			t_holiday.description := 'Eight Hours Day';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Family & Community Day
		IF p_province == 'ACT' THEN
			t_holiday.description := 'Family & Community Day';
			IF t_year BETWEEN 2007 AND 2009 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, NOV, 1), 1, TU);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			ELSIF t_year == 2010 THEN
				-- first Monday of the September/October school holidays
				-- moved to the second Monday if this falls on Labour day
				-- TODO need a formula for the ACT school holidays then
				-- http://www.cmd.act.gov.au/communication/holidays
				self[date(year, SEP, 26)] = name
			ELSIF t_year == 2011 THEN
				self[date(year, OCT, 10)] = name
			ELSIF t_year == 2012 THEN
				self[date(year, OCT, 8)] = name
			ELSIF t_year == 2013 THEN
				self[date(year, SEP, 30)] = name
			ELSIF t_year == 2014 THEN
				self[date(year, SEP, 29)] = name
			ELSIF t_year == 2015 THEN
				self[date(year, SEP, 28)] = name
			ELSIF t_year == 2016 THEN
				self[date(year, SEP, 26)] = name
			ELSIF t_year == 2017 THEN
				self[date(year, SEP, 25)] = name
			END IF;
		END IF;

		-- Reconciliation Day
		IF p_province == 'ACT' THEN
			t_holiday.description := 'Reconciliation Day';
			IF t_year >= 2018 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, 5, 27), 1, MO);
				t_holiday.description = name;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		IF p_province == 'VIC' THEN
			-- Grand Final Day
			IF t_year >= 2015 THEN
				t_holiday.datestamp := make_date(t_year, SEP, 24) + rd(weekday=FR);
				t_holiday.description := 'Grand Final Day';
				RETURN NEXT t_holiday;
			END IF;

			-- Melbourne Cup
			t_holiday.datestamp := make_date(t_year, NOV, 1) + rd(weekday=TU);
			t_holiday.description := 'Melbourne Cup';
			RETURN NEXT t_holiday;
		END IF;

		-- The Royal Queensland Show (Ekka)
		-- The Show starts on the first Friday of August - providing this is
		-- not prior to the 5th - in which case it will begin on the second
		-- Friday. The Wednesday during the show is a public holiday.
		IF p_province == 'QLD' THEN
			t_holiday.description := 'The Royal Queensland Show';
			self[date(year, AUG, 5) + rd(weekday=FR) + rd(weekday=WE)] = name
		END IF;

		-- Christmas Day
		t_datestamp = make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			self[date(year, DEC, 27)] = name + ' (Observed)'
		END IF;

		-- Boxing Day
		IF p_province == 'SA' THEN
			t_holiday.description := 'Proclamation Day';
		ELSE
			t_holiday.description := 'Boxing Day';
		END IF;
		dec26 = date(year, DEC, 26)
		self[dec26] = name
		IF dec26.weekday() in WEEKEND THEN
			self[date(year, DEC, 28)] = name + ' (Observed)'
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;