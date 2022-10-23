------------------------------------------
------------------------------------------
-- Australia Holidays
--
-- ACT:  Holidays Act 1958
-- NSW:  Public Holidays Act 2010
-- NT:   Public Holidays Act 2013
-- QLD:  Holidays Act 1983
-- SA:   Holidays Act 1910
-- TAS:  Statutory Holidays Act 2000
-- VIC:  Public Holidays Act 1993
-- WA:   Public and Bank Holidays Act 1972
--
-- TODO do more research on history of Aus holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.australia(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Localication
	OBSERVED CONSTANT TEXT := ' (Observed)'; -- English
	-- Provinces
	PROVINCES TEXT[] := ARRAY['ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA'];
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description = 'New Year''s Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Australia Day
		t_holiday.reference := 'Australia Day';
		t_datestamp := make_date(t_year, JANUARY, 26);
		IF t_year >= 1935 THEN
			IF p_province = 'NSW' AND t_year < 1946 THEN
				t_holiday.description := 'Anniversary Day';
			ELSE
				t_holiday.description := 'Australia Day';
			END IF;
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 1946 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description = t_holiday.description || OBSERVED;
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		ELSIF t_year >= 1888 AND p_province != 'SA' THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Anniversary Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Adelaide Cup
		t_holiday.reference := 'Adelaide Cup';
		IF p_province = 'SA' THEN
			t_holiday.description := 'Adelaide Cup';
			IF t_year >= 2006 THEN
				-- subject to proclamation ?!?!
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, +2);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, +3);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Canberra Day
		-- Info from https://www.timeanddate.com/holidays/australia/canberra-day
		-- and https://en.wikipedia.org/wiki/Canberra_Day
		t_holiday.reference := 'Canberra Day';
		IF p_province = 'ACT' AND t_year >= 1913 THEN
			t_holiday.description := 'Canberra Day';
			IF t_year BETWEEN 1913 AND 1957 THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 12);
				RETURN NEXT t_holiday;
			ELSIF t_year BETWEEN 1958 AND 2007 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 3);
				RETURN NEXT t_holiday;
			ELSIF t_year >= 2008 AND t_year != 2012 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 2);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2012 THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 12);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		-- Easter Saturday
		IF p_province in ('ACT', 'NSW', 'NT', 'QLD', 'SA', 'VIC') THEN
			t_holiday.reference := 'Easter Saturday';
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
			t_holiday.description := 'Easter Saturday';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Sunday
		IF p_province in ('ACT', 'NSW', 'QLD', 'VIC') THEN
			t_holiday.reference := 'Easter Sunday';
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Easter Sunday';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

		-- Anzac Day
		t_holiday.reference := 'Anzac Day';
		IF t_year > 1920 THEN
			t_datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'Anzac Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SATURDAY AND p_province IN ('WA', 'NT') THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := 'Anzac Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY AND p_province IN ('ACT', 'QLD', 'SA', 'WA', 'NT') THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := 'Anzac Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Western Australia Day
		t_holiday.reference := 'Western Australia Day';
		t_holiday.authority := 'provincial';
		IF p_province = 'WA' AND t_year > 1832 THEN
			IF t_year >= 2015 THEN
				t_holiday.description := 'Western Australia Day';
			ELSE
				t_holiday.description := 'Foundation Day';
			END IF;
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 1);
			RETURN NEXT t_holiday;
		END IF;
		t_holiday.authority := 'national';

		-- Sovereign's Birthday
		t_holiday.reference := 'Sovereign''s Birthday';
		IF t_year >= 1952 THEN
			t_holiday.description := 'Queen''s Birthday';
		ELSIF t_year > 1901 THEN
			t_holiday.description := 'King''s Birthday';
		END IF;
		IF t_year >= 1936 THEN
			t_holiday.description := 'Queen''s Birthday';
			IF p_province = 'QLD' THEN
				IF t_year = 2012 THEN
					t_holiday.datestamp := make_date(t_year, JUNE, 11);
					t_holiday.description := 'Queen''s Diamond Jubilee';
					RETURN NEXT t_holiday;
				END IF;
				IF t_year < 2016 AND t_year != 2012 THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 2);
					RETURN NEXT t_holiday;
				ELSE
					t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, 1);
					RETURN NEXT t_holiday;
				END IF;
			ELSIF p_province = 'WA' THEN
				-- by proclamation ?!?!
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSIF p_province in ('NSW', 'VIC', 'ACT', 'SA', 'NT', 'TAS') THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 2);
				RETURN NEXT t_holiday;
			END IF;
		ELSIF t_year > 1911 THEN
			-- George V
			t_holiday.datestamp := make_date(t_year, JUNE, 3);
			RETURN NEXT t_holiday;
		ELSIF t_year > 1901 THEN
			-- Edward VII
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 9);
			RETURN NEXT t_holiday;
		END IF;

		-- Picnic Day
		t_holiday.reference := 'Picnic Day';
		IF p_province = 'NT' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'Picnic Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Bank Holiday
		t_holiday.reference := 'Bank Holiday';
		IF p_province = 'NSW' THEN
			IF t_year >= 1912 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
				t_holiday.description := 'Bank Holiday';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.description := 'Labour Day';
		IF p_province in ('NSW', 'ACT', 'SA') THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, 1);
			RETURN NEXT t_holiday;
		ELSIF p_province = 'WA' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 1);
			RETURN NEXT t_holiday;
		ELSIF p_province = 'VIC' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 2);
			RETURN NEXT t_holiday;
		ELSIF p_province = 'QLD' THEN
			IF t_year BETWEEN 2013 AND 2015 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, 1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_province = 'NT' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), MONDAY, 1);
			t_holiday.description := 'May Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'TAS' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 2);
			t_holiday.description := 'Eight Hours Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Family & Community Day
		t_holiday.reference := 'Family & Community Day';
		IF p_province = 'ACT' THEN
			t_holiday.description := 'Family & Community Day';
			IF t_year BETWEEN 2007 AND 2009 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), TUESDAY, 1);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2010 THEN
				-- first Monday of the September/October school holidays
				-- moved to the second Monday if this falls on Labour day
				-- TODO need a formula for the ACT school holidays then
				-- http://www.cmd.act.gov.au/communication/holidays
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 26);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2011 THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 10);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2012 THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 8);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2013 THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 30);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2014 THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 29);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2015 THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 28);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2016 THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 26);
				RETURN NEXT t_holiday;
			ELSIF t_year = 2017 THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 25);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Reconciliation Day
		t_holiday.reference := 'Reconciliation Day';
		IF p_province = 'ACT' THEN
			t_holiday.description := 'Reconciliation Day';
			IF t_year >= 2018 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 27), MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Rugby Holidays?
		IF p_province = 'VIC' THEN
			t_holiday.reference := 'Rugby Holidays';
			t_holiday.authority := 'provincial';
			-- Grand Final Day
			IF t_year >= 2015 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 24), FRIDAY, 1);
				t_holiday.description := 'Grand Final Day';
				RETURN NEXT t_holiday;
			END IF;

			-- Melbourne Cup
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), TUESDAY, 1);
			t_holiday.description := 'Melbourne Cup';
			RETURN NEXT t_holiday;
			t_holiday.authority := 'national';
		END IF;

		-- The Royal Queensland Show (Ekka)
		-- The Show starts on the first Friday of August - providing this is
		-- not prior to the 5th - in which case it will begin on the second
		-- Friday. The Wednesday during the show is a public holiday.
		IF p_province = 'QLD' THEN
			t_holiday.reference := 'The Royal Queensland Show';
			t_holiday.authority := 'provincial';
			t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 5), FRIDAY, 1);
			t_datestamp := holidays.find_nth_weekday_date(t_datestamp, WEDNESDAY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'The Royal Queensland Show';
			RETURN NEXT t_holiday;
			t_holiday.authority := 'national';
		END IF;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_datestamp = make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			t_holiday.description := 'Christmas Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		IF p_province = 'SA' THEN
			t_holiday.description := 'Proclamation Day';
		ELSE
			t_holiday.description := 'Boxing Day';
		END IF;
		t_datestamp = make_date(t_year, DECEMBER, 26);
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			t_holiday.description := t_holiday.description || OBSERVED;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;