------------------------------------------
------------------------------------------
-- Nigeria Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Nigeria
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.nigeria(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s day';
		RETURN NEXT t_holiday;

		-- Worker's day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Worker''s day';
		RETURN NEXT t_holiday;

		-- Children's day
		t_holiday.datestamp := make_date(t_year, MAY, 27);
		t_holiday.description := 'Children''s day';
		RETURN NEXT t_holiday;

		-- Democracy day
		t_holiday.datestamp := make_date(t_year, JUNE, 12);
		t_holiday.description := 'Democracy day';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, OCTOBER, 1);
		t_holiday.description := 'Independence day';
		RETURN NEXT t_holiday;

		-- Christmas day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas day';
		RETURN NEXT t_holiday;

		-- Boxing day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boxing day';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;