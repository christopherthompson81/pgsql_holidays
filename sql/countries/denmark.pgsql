------------------------------------------
------------------------------------------
-- Denmark Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Denmark
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.denmark(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'Nytårsdag';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Palm Sunday
		t_holiday.reference := 'Palm Sunday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SUNDAY, -2);
		t_holiday.description := 'Palmesøndag';
		RETURN NEXT t_holiday;

		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Skærtorsdag';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Langfredag';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Påskedag';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
		t_holiday.description := 'Anden påskedag';
		RETURN NEXT t_holiday;

		-- Store bededag / Great Prayer Day
		-- Denmark-Specific
		t_holiday.reference := 'Great Prayer Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, +4);
		t_holiday.description := 'Store bededag';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.reference := 'Ascension Day';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Kristi himmelfartsdag';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pinsedag';
		RETURN NEXT t_holiday;
		
		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Anden pinsedag';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Juledag';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Anden juledag';
		RETURN NEXT t_holiday;
	END LOOP;
END;

$$ LANGUAGE plpgsql;