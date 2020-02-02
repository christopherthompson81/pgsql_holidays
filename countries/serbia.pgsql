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
		name = 'Нова година'
		self[date(year, JANUARY, 1)] = name
		self[date(year, JANUARY, 2)] = name
		if self.observed and date(year, JANUARY, 1).weekday() in WEEKEND:
			self[date(year, JANUARY, 3)] = name + ' (Observed)'
		-- Orthodox Christmas
		name = 'Божић'
		self[date(year, JANUARY, 7)] = name
		-- Statehood day
		name = 'Дан државности Србије'
		self[date(year, FEB, 15)] = name
		self[date(year, FEB, 16)] = name
		if self.observed and date(year, FEB, 15).weekday() in WEEKEND:
			self[date(year, FEB, 17)] = name + ' (Observed)'
		-- International Workers' Day
		name = 'Празник рада'
		self[date(year, MAY, 1)] = name
		self[date(year, MAY, 2)] = name
		if self.observed and date(year, MAY, 1).weekday() in WEEKEND:
			self[date(year, MAY, 3)] = name + ' (Observed)'
		-- Armistice day
		name = 'Дан примирја у Првом светском рату'
		self[date(year, NOV, 11)] = name
		if self.observed and date(year, NOV, 11).weekday() == SUN:
			self[date(year, NOV, 12)] = name + ' (Observed)'
		-- Easter
		self[easter(year, method=EASTER_ORTHODOX) - rd(days=2)] = 'Велики петак'
		self[easter(year, method=EASTER_ORTHODOX) - rd(days=1)] = 'Велика субота'
		self[easter(year, method=EASTER_ORTHODOX)] = 'Васкрс'
		self[easter(year, method=EASTER_ORTHODOX) + rd(days=1)] = 'Други дан Васкрса'

	END LOOP;
END;

$$ LANGUAGE plpgsql;