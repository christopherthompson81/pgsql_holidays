------------------------------------------
------------------------------------------
-- Anguilla Holidays
--
-- ISO 3166: Anguilla; AI; AIA;
--
-- langs: en
--
-- dayoff: sunday
--
-- weekend: [saturday, sunday]
--
-- Time zones:
-- - America/Port_of_Spain
--
-- http://www.gov.ai/holiday.php
--
-- Where fixed date holidays (such as Christmas Day and Boxing Day) fall on a
-- weekend, the holiday is taken in lieu on the next succeeding working day.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.anguilla(p_start_year INTEGER, p_end_year INTEGER)
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
	OBSERVED CONSTANT TEXT := ' (Observed)';
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
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s Day';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- James Ronald Webster Day
		t_holiday.reference := 'James Ronald Webster Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 2);
		t_holiday.description := 'James Ronald Webster Day';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Easter Sunday';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Anguilla Day
		t_holiday.reference := 'Anguilla Day';
		t_dt1 := make_date(t_year, MAY, 30);
		t_holiday.description := 'Anguilla Day';
		t_holiday.datestamp := t_dt1;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_dt1) = ANY(WEEKEND) THEN
			t_dt2 := holidays.find_nth_weekday_date(t_dt1, MONDAY, 1);
			-- If this needs to be shifted, it could conflict with Whit Monday.
			IF t_dt2 = (t_datestamp + '50 Days'::INTERVAL) THEN
				t_holiday.datestamp := t_dt2 + '1 Day'::INTERVAL;
			ELSE
				t_holiday.datestamp := t_dt2;
			END IF;
			t_holiday.description := t_holiday.description || OBSERVED;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pentecost';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Whit Monday';
		RETURN NEXT t_holiday;

		-- Celebration of the Birthday of Her Majesty the Queen
		-- 2nd monday in June
		t_holiday.reference := 'Sovereign''s Birthday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 2);
		t_holiday.description := 'Celebration of the Birthday of Her Majesty the Queen';
		RETURN NEXT t_holiday;

		-- August Holidays
		t_datestamp := make_date(t_year, AUGUST, 1);

		-- August Monday
		-- 1st monday in August
		t_holiday.reference := 'August Monday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
		t_holiday.description := 'August Monday';
		RETURN NEXT t_holiday;

		-- August Thursday
		-- 1st thursday in August
		t_holiday.reference := 'August Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, 1);
		t_holiday.description := 'August Thursday';
		RETURN NEXT t_holiday;

		-- Constitution Day
		-- 1st friday in August
		t_holiday.reference := 'Constitution Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, 1);
		t_holiday.description := 'Constitution Day';
		RETURN NEXT t_holiday;

		-- National Heroes and Heroines Day
		t_holiday.reference := 'National Heroes and Heroines Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 19);
		t_holiday.description := 'National Heroes and Heroines Day';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Christmas Day
		-- substitute: true
		t_holiday.reference := 'Christmas Day';
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Boxing Day
		-- substitute: true
		t_holiday.reference := 'Boxing Day';
		t_datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boxing Day';
		IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			-- Still two Days because Christmas will also be shifted
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Apply observation shifting rules to the above.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			IF DATE_PART('dow', t_holiday.datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || OBSERVED;
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
		t_holiday.observation_shifted := FALSE;
	END LOOP;
END;

$$ LANGUAGE plpgsql;