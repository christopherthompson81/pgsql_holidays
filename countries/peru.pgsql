------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://www.gob.pe/feriados
	-- https://es.wikipedia.org/wiki/Anexo:Días_feriados_en_el_Perú
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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- Feast of Saints Peter and Paul
		t_holiday.description := 'San Pedro y San Pablo [Feast of Saints Peter and Paul]';
		t_holiday.datestamp := make_date(t_year, JUNE, 29);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_holiday.datestamp := make_date(t_year, JULY, 28);
		RETURN NEXT t_holiday;

		t_holiday.description := 'Día de las Fuerzas Armadas y la Policía del Perú';
		t_holiday.datestamp := make_date(t_year, JULY, 29);
		RETURN NEXT t_holiday;

		-- Santa Rosa de Lima
		t_holiday.description := 'Día de Santa Rosa de Lima';
		t_holiday.datestamp := make_date(t_year, AUGUST, 30);
		RETURN NEXT t_holiday;

		-- Battle of Angamos
		t_holiday.description := 'Combate Naval de Angamos [Battle of Angamos]';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 8);
		RETURN NEXT t_holiday;

		-- Holy Thursday
		self[easter(year) + rd(weekday=TH(-1))
			 ] = 'Jueves Santo [Maundy Thursday]'

		-- Good Friday
		self[easter(year) + rd(weekday=FR(-1))
			 ] = 'Viernes Santo [Good Friday]'

		-- Holy Saturday
		self[easter(year) + rd(weekday=SA(-1))
			 ] = 'Sábado de Gloria [Holy Saturday]'

		-- Easter Sunday
		self[easter(year) + rd(weekday=SU(-1))
			 ] = 'Domingo de Resurrección [Easter Sunday]'

		-- Labor Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		RETURN NEXT t_holiday;

		-- All Saints Day
		t_holiday.description := 'Día de Todos Los Santos [All Saints Day]';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		RETURN NEXT t_holiday;

		-- Inmaculada Concepción
		t_holiday.description := 'Inmaculada Concepción [Immaculate Conception]';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;