------------------------------------------
------------------------------------------
-- Paraguay Holidays (Porting Unfinished)
--
-- https://www.ghp.com.py/news/feriados-nacionales-del-ano-2019-en-paraguay
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_feriados_en_Paraguay
-- http://www.calendarioparaguay.com/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.paraguay(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- Patriots day
		t_holiday.description := 'Día de los Héroes de la Patria [Patriots Day]';
		t_datestamp := date(t_year, MARCH, 1);
		IF DATE_PART('dow', t_datestamp) >= WEDNESDAY THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Holy Week
		name_thu = 'Semana Santa (Jueves Santo)  [Holy day (Holy Thursday)]'
		name_fri = 'Semana Santa (Viernes Santo)  [Holy day (Holy Friday)]'
		name_easter = 'Día de Pascuas [Easter Day]'

		self[easter(year) + rd(weekday=TH(-1))] = name_thu
		self[easter(year) + rd(weekday=FR(-1))] = name_fri

		self[easter(year)] = name_easter

		-- Labor Day
		t_holiday.description := 'Día de los Trabajadores [Labour Day]';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia Nacional [Independence Day]';
		t_holiday.datestamp := make_date(t_year, MAY, 15);
		RETURN NEXT t_holiday;

		-- Peace in Chaco Day.
		t_holiday.description := 'Día de la Paz del Chaco [Peace in Chaco Day]';
		t_datestamp := make_date(t_year, JUNE, 12);
		IF DATE_PART('dow', t_datestamp) >= WED THEN
			t_holiday.datestamp = find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Asuncion Fundation's Day
		t_holiday.description := 'Día de la Fundación de Asunción [Asuncion Fundation''s Day]';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		RETURN NEXT t_holiday;

		-- Boqueron's Battle
		t_holiday.description := 'Batalla de Boquerón [Boqueron''s Battle]';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 29);
		RETURN NEXT t_holiday;

		-- Caacupe Virgin Day
		t_holiday.description := 'Día de la Virgen de Caacupé [Caacupe Virgin Day]';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;