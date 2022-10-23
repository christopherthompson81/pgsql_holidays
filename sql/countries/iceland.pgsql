------------------------------------------
------------------------------------------
-- Iceland Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Iceland
-- https://www.officeholidays.com/countries/iceland/index.php
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.iceland(p_start_year INTEGER, p_end_year INTEGER)
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- Public holidays

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nýársdagur';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := t_datestamp - '3 Days'::INTERVAL;
		t_holiday.description := 'Skírdagur';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Föstudagurinn langi';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Páskadagur';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Annar í páskum';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.reference := 'Ascension Day';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Uppstigningardagur';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Hvítasunnudagur';
		RETURN NEXT t_holiday;

		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Annar í hvítasunnu';
		RETURN NEXT t_holiday;

		-- First Day of Summer
		t_holiday.reference := 'First Day of Summer';
		t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, APRIL, 19), THURSDAY, +1);
		t_holiday.description = 'Sumardagurinn fyrsti';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Verkalýðsdagurinn';
		RETURN NEXT t_holiday;

		-- Icelandic National Day
		t_holiday.reference := 'Icelandic National Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 17);
		t_holiday.description := 'Þjóðhátíðardagurinn';
		RETURN NEXT t_holiday;
		
		-- Commerce Day
		t_holiday.reference := 'Commerce Day';
		t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, +1);
		t_holiday.description = 'Frídagur verslunarmanna';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Aðfangadagur';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Jóladagur';
		RETURN NEXT t_holiday;

		-- Second Day of Christmas
		t_holiday.reference := 'Second Day of Christmas';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Annar í jólum';
		RETURN NEXT t_holiday;

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Gamlársdagur';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;