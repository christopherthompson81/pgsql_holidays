------------------------------------------
------------------------------------------
-- <country> Holidays
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
		name = 'Año Nuevo [New Year''s Day]'
		self[date(year, JANUARY, 1)] = name
		if date(year, JANUARY, 1).weekday() == SUN:
			self[date(year, JANUARY, 1) + rd(days=+1)] = name + ' (Observed)'
		elif date(year, JANUARY, 1).weekday() == SAT:
			-- Add Dec 31st from the previous year without triggering
			-- the entire year to be added
			expand = self.expand
			self.expand = False
			self[date(year, JANUARY, 1) + rd(days=-1)] = name + ' (Observed)'
			self.expand = expand
		-- The next year's observed New Year's Day can be in this year
		-- when it falls on a Friday (Jan 1st is a Saturday)
		if date(year, DEC, 31).weekday() == FRI:
			self[date(year, DEC, 31)] = name + ' (Observed)'

		-- Constitution Day
		name = 'Día de la Constitución [Constitution Day]'
		if 2006 >= year >= 1917:
			self[date(year, FEB, 5)] = name
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, FEB, 1), MO, +1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- Benito Juárez's birthday
		name = 'Natalicio de Benito Juárez [Benito Juárez''s birthday]'
		if 2006 >= year >= 1917:
			self[date(year, MAR, 21)] = name
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +3);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- Labor Day
		if year >= 1923:
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Día del Trabajo [Labour Day]';
			RETURN NEXT t_holiday;
			if date(year, MAY, 1).weekday() == SAT:
				self[date(year, MAY, 1) + rd(days=-1)] = name + ' (Observed)'
			elif date(year, MAY, 1).weekday() == SUN:
				self[date(year, MAY, 1) + rd(days=+1)] = name + ' (Observed)'

		-- Independence Day
		name = 'Día de la Independencia [Independence Day]'
		self[date(year, SEP, 16)] = name
		if date(year, SEP, 16).weekday() == SAT:
			self[date(year, SEP, 16) + rd(days=-1)] = name + ' (Observed)'
		elif date(year, SEP, 16).weekday() == SUN:
			self[date(year, SEP, 16) + rd(days=+1)] = name + ' (Observed)'

		-- Revolution Day
		name = 'Día de la Revolución [Revolution Day]'
		if 2006 >= year >= 1917:
			self[date(year, NOV, 20)] = name
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, NOV, 1), MO, +3);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- Change of Federal Government
		-- Every six years--next observance 2018
		name = 'Transmisión del Poder Ejecutivo Federal'
		name += ' [Change of Federal Government]'
		if (2018 - year) % 6 == 0:
			self[date(year, DEC, 1)] = name
			if date(year, DEC, 1).weekday() == SAT:
				self[date(year, DEC, 1) + rd(days=-1)] = name + ' (Observed)'
			elif date(year, DEC, 1).weekday() == SUN:
				self[date(year, DEC, 1) + rd(days=+1)] = name + ' (Observed)'

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;
		if date(year, DEC, 25).weekday() == SAT:
			self[date(year, DEC, 25) + rd(days=-1)] = name + ' (Observed)'
		elif date(year, DEC, 25).weekday() == SUN:
			self[date(year, DEC, 25) + rd(days=+1)] = name + ' (Observed)'

	END LOOP;
END;

$$ LANGUAGE plpgsql;