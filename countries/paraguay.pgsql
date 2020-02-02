------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://www.ghp.com.py/news/feriados-nacionales-del-ano-2019-en-paraguay
	-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_feriados_en_Paraguay
	-- http://www.calendarioparaguay.com/
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
		if not self.observed and date(year, JANUARY, 1).weekday() in WEEKEND:
			pass
		else:
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Año Nuevo [New Year''s Day]';
			RETURN NEXT t_holiday;

		-- Patriots day
		name = 'Día de los Héroes de la Patria [Patriots Day]'

		if not self.observed and date(year, MAR, 1).weekday() in WEEKEND:
			pass
		elif date(year, MAR, 1).weekday() >= WED:
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		else:
			self[date(year, MAR, 1)] = name

		-- Holy Week
		name_thu = 'Semana Santa (Jueves Santo)  [Holy day (Holy Thursday)]'
		name_fri = 'Semana Santa (Viernes Santo)  [Holy day (Holy Friday)]'
		name_easter = 'Día de Pascuas [Easter Day]'

		self[easter(year) + rd(weekday=TH(-1))] = name_thu
		self[easter(year) + rd(weekday=FR(-1))] = name_fri

		if not self.observed and easter(year).weekday() in WEEKEND:
			pass
		else:
			self[easter(year)] = name_easter

		-- Labor Day
		name = 'Día de los Trabajadores [Labour Day]'
		if not self.observed and date(year, MAY, 1).weekday() in WEEKEND:
			pass
		else:
			self[date(year, MAY, 1)] = name

		-- Independence Day
		name = 'Día de la Independencia Nacional [Independence Day]'
		if not self.observed and date(year, MAY, 15).weekday() in WEEKEND:
			pass
		else:
			self[date(year, MAY, 15)] = name

		-- Peace in Chaco Day.
		name = 'Día de la Paz del Chaco [Peace in Chaco Day]'
		if not self.observed and date(year, JUN, 12).weekday() in WEEKEND:
			pass
		elif date(year, JUN, 12).weekday() >= WED:
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUN, 12), MO, +1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		else:
			self[date(year, JUN, 12)] = name

		-- Asuncion Fundation's Day
		name = 'Día de la Fundación de Asunción [Asuncion Fundation''s Day]'
		if not self.observed and date(year, AUG, 15).weekday() in WEEKEND:
			pass
		else:
			self[date(year, AUG, 15)] = name

		-- Boqueron's Battle
		name = 'Batalla de Boquerón [Boqueron''s Battle]'
		if not self.observed and date(year, SEP, 29).weekday() in WEEKEND:
			pass
		else:
			self[date(year, SEP, 29)] = name

		-- Caacupe Virgin Day
		name = 'Día de la Virgen de Caacupé [Caacupe Virgin Day]'
		if not self.observed and date(year, DEC, 8).weekday() in WEEKEND:
			pass
		else:
			self[date(year, DEC, 8)] = name

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;