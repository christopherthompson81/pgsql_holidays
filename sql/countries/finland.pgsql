------------------------------------------
------------------------------------------
-- Finland Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Finland
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.finland(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Uudenvuodenpäivä';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Loppiainen';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);
		
		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Pitkäperjantai';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Pääsiäispäivä';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := '2. pääsiäispäivä';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.reference := 'Ascension Day';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Helatorstai';
		RETURN NEXT t_holiday;

		-- Pentecost Day
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Helluntaipäivä';
		RETURN NEXT t_holiday;

		-- Non-Easter related holidays

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Vappu';
		RETURN NEXT t_holiday;

		-- Midsummer Day
		t_holiday.reference := 'Midsummer Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 20), SATURDAY, 1);
		t_holiday.description := 'Juhannuspäivä';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 31), SATURDAY, 1);
		t_holiday.description := 'Pyhäinpäivä';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
		t_holiday.description := 'Itsenäisyyspäivä';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Joulupäivä';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Tapaninpäivä';
		RETURN NEXT t_holiday;

		-- Juhannusaatto (Midsummer Eve) and Jouluaatto (Christmas Eve) are not
		-- official holidays, but are de facto.
		t_holiday.authority := 'de_facto';

		-- Midsummer Eve
		t_holiday.reference := 'Midsummer Eve';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 19), FRIDAY, 1);
		t_holiday.description := 'Juhannusaatto';
		RETURN NEXT t_holiday;
		
		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Jouluaatto';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;