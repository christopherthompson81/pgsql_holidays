------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Finland
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_start_year INTEGER, p_end_year INTEGER)
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

e = easter(year)

		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Uudenvuodenpäivä';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Loppiainen';
		RETURN NEXT t_holiday;
		self[e - '2 Days'::INTERVAL] = 'Pitkäperjantai'
		self[e] = 'Pääsiäispäivä'
		self[e + '1 Days'::INTERVAL] = '2. pääsiäispäivä'
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Vappu';
		RETURN NEXT t_holiday;
		self[e + '39 Days'::INTERVAL] = 'Helatorstai'
		self[e + '49 Days'::INTERVAL] = 'Helluntaipäivä'
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 20), SA, 1);
		t_holiday.description := 'Juhannuspäivä';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 31), SA, 1);
		t_holiday.description := 'Pyhäinpäivä';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
		t_holiday.description := 'Itsenäisyyspäivä';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Joulupäivä';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Tapaninpäivä';
		RETURN NEXT t_holiday;

		-- Juhannusaatto (Midsummer Eve) and Jouluaatto (Christmas Eve) are not
		-- official holidays, but are de facto.
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 19), FR, 1);
		t_holiday.description := 'Juhannusaatto';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Jouluaatto';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;