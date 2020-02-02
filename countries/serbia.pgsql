------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Serbia
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

		-- New Year's Day
		t_holiday.description := 'Нова година';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JANUARY, 2);
		RETURN NEXT t_holiday;
		IF self.observed and date(year, JANUARY, 1).weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 3);
			RETURN NEXT t_holiday; + ' (Observed)'
		-- Orthodox Christmas
		t_holiday.description := 'Божић';
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		RETURN NEXT t_holiday;
		-- Statehood day
		t_holiday.description := 'Дан државности Србије';
		t_holiday.datestamp := make_date(t_year, FEB, 15);
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, FEB, 16);
		RETURN NEXT t_holiday;
		IF self.observed and date(year, FEB, 15).weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, FEB, 17);
			RETURN NEXT t_holiday; + ' (Observed)'
		-- International Workers' Day
		t_holiday.description := 'Празник рада';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 2);
		RETURN NEXT t_holiday;
		IF self.observed and date(year, MAY, 1).weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, MAY, 3);
			RETURN NEXT t_holiday; + ' (Observed)'
		-- Armistice day
		t_holiday.description := 'Дан примирја у Првом светском рату';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
		RETURN NEXT t_holiday;
		IF self.observed and date(year, NOVEMBER, 11).weekday() == SUN THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 12);
			RETURN NEXT t_holiday; + ' (Observed)'
		-- Easter
		self[easter(year, method=EASTER_ORTHODOX) - '2 Days'::INTERVAL] = 'Велики петак'
		self[easter(year, method=EASTER_ORTHODOX) - '1 Days'::INTERVAL] = 'Велика субота'
		self[easter(year, method=EASTER_ORTHODOX)] = 'Васкрс'
		self[easter(year, method=EASTER_ORTHODOX) + '1 Days'::INTERVAL] = 'Други дан Васкрса'

	END LOOP;
END;

$$ LANGUAGE plpgsql;