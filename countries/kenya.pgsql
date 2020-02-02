------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Kenya
-- http://kenyaembassyberlin.de/Public-Holidays-in-Kenya.48.0.html
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
		t_holiday.description := 'New Year''s Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JUN, 1);
		t_holiday.description := 'Madaraka Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, OCT, 20);
		t_holiday.description := 'Mashujaa Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 12);
		t_holiday.description := 'Jamhuri (Independence) Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Christmas Day';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Boxing Day';
		RETURN NEXT t_holiday;
		for k, v in list(self.items()):
			if k.weekday() == SUN:
				self[k + rd(days=1)] = v + ' (Observed)'

		self[easter(year) - rd(weekday=FR(-1))] = 'Good Friday'
		self[easter(year) + rd(weekday=MO(+1))] = 'Easter Monday'

	END LOOP;
END;

$$ LANGUAGE plpgsql;