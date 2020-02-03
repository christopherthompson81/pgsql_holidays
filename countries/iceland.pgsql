------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Iceland
	-- https://www.officeholidays.com/countries/iceland/index.php
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
		-- Public holidays
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nýársdagur';
		RETURN NEXT t_holiday;
		self[easter(year) - '3 Days'::INTERVAL] = 'Skírdagur'
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Föstudagurinn langi';
		RETURN NEXT t_holiday;
		self[easter(year)] = 'Páskadagur'
		self[easter(year) + '1 Days'::INTERVAL] = 'Annar í páskum'
		t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, APRIL, 19), TH, +1);
		t_holiday.description = 'Sumardagurinn fyrsti';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Verkalýðsdagurinn';
		RETURN NEXT t_holiday;
		self[easter(year) + '39 Days'::INTERVAL] = 'Uppstigningardagur'
		self[easter(year) + '49 Days'::INTERVAL] = 'Hvítasunnudagur'
		self[easter(year) + '50 Days'::INTERVAL] = 'Annar í hvítasunnu'
		t_holiday.datestamp := make_date(t_year, JUNE, 17);
		t_holiday.description := 'Þjóðhátíðardagurinn';
		RETURN NEXT t_holiday;
		-- First Monday of August
		t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, AUGUST, 1), MO, +1);
		t_holiday.description = 'Frídagur verslunarmanna';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Aðfangadagur';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Jóladagur';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Annar í jólum';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Gamlársdagur';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;