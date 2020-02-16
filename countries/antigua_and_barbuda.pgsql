------------------------------------------
------------------------------------------
-- Antigua and Barbuda Holidays
--
-- ISO 3166: Antigua and Barbuda; AG; ATG;
-- 
-- langs: [en]
--
-- dayoff: [sunday]
-- weekend: [saturday, sunday]
--
-- Time zones:
-- - America/Port_of_Spain
--
-- http://www.ab.gov.ag/detail_page.php?page=4
-- http://www.laws.gov.ag/acts/2005/a2005-8.pdf
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.antigua_and_barbuda(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	PROVINCES TEXT[] := ARRAY['Saint George', 'Saint John', 'Saint Mary', 'Saint Paul', 'Saint Peter', 'Saint Philip', 'Barbuda', 'Redonda'];
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
		t_holiday.description := 'New Year''s Day';
		t_datestamp := make_date(t_year, JANUARY, 1);
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);
		
		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.description := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- easter:
		-- type: observance
		t_holiday.reference := 'Easter Sunday';
		t_holiday.description := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		
		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.description := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		RETURN NEXT t_holiday;
		
		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.description := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;
		
		-- Province: Barbuda
		IF p_province = 'Barbuda' THEN
			-- Caribana
			-- type: observance
			-- easter 47 P4D:
			t_holiday.reference := 'Caribana';
			t_holiday.description := 'Caribana';
			t_holiday.authority := 'observance';
			t_holiday.day_off := FALSE;
			t_holiday.datestamp := t_datestamp + '47 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '48 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.authority := 'national';
			t_holiday.day_off := TRUE;
		END IF;

		-- Pentecost
		-- type: observance
		t_holiday.reference := 'Pentecost';
		t_holiday.description := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		
		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.description := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Carnival Related Dates
		-- from the end of July to the first Tuesday in August
		t_datestamp := make_date(t_year, AUGUST, 1);

		-- Carnival Begins
		-- type: observance
		t_holiday.reference := 'Carnival Begins';
		t_holiday.description := 'Carnival Begins';
		t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- J'Ouvert Morning
		t_holiday.reference := 'J''Ouvert Morning';
		t_holiday.description := 'J''Ouvert Morning';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		
		-- Carnival Monday
		t_holiday.reference := 'Carnival Monday';
		t_holiday.description := 'Carnival Monday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
		RETURN NEXT t_holiday;

		-- Carnival Tuesday
		t_holiday.reference := 'Carnival Tuesday';
		t_holiday.description := 'Carnival Tuesday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, TUESDAY, 1);
		RETURN NEXT t_holiday;

		-- Last Lap
		t_holiday.reference := 'Last Lap';
		t_holiday.description := 'Last Lap';
		t_holiday.datestamp := make_date(t_year, AUGUST, 2);
		RETURN NEXT t_holiday;
		
		-- Independence Day
		-- 11-01 if saturday,sunday then next monday:
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Independence Day';
		t_datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;
		
		-- V.C Bird Day
		t_holiday.reference := 'V.C Bird Day';
		t_holiday.description := 'V.C Bird Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 9);
		RETURN NEXT t_holiday;
		
		-- Christmas Day
		-- 12-25 and if saturday then next monday if sunday then next tuesday
		t_holiday.reference := 'Christmas Day';
		t_holiday.description := 'Christmas Day';
		t_datestamp := make_date(t_year, DECEMBER, 25);
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp + '2 Day'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;
		
		-- Boxing Day
		-- 12-26 and if sunday then next monday
		t_holiday.reference := 'Boxing Day';
		t_holiday.description := 'Boxing Day';
		t_datestamp := make_date(t_year, DECEMBER, 26);
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;