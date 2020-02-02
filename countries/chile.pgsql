------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://www.feriados.cl
	-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_feriados_en_Chile
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

		-- Holy Week
		name_fri = 'Semana Santa (Viernes Santo) [Holy day (Holy Friday)]'
		name_easter = 'Día de Pascuas [Easter Day]'

		self[easter(year) + rd(weekday=FR(-1))] = name_fri
		self[easter(year)] = name_easter

		-- Labor Day
		name = 'Día del Trabajo [Labour Day]'
		self[date(year, MAY, 1)] = name

		-- Naval Glories Day
		name = 'Día de las Glorias Navales [Naval Glories Day]'
		self[date(year, MAY, 21)] = name

		-- Saint Peter and Saint Paul.
		name = 'San Pedro y San Pablo [Saint Peter and Saint Paul]'
		self[date(year, JUN, 29)] = name

		-- Day of Virgin of Carmen.
		name = 'Virgen del Carmen [Virgin of Carmen]'
		self[date(year, JUL, 16)] = name

		-- Day of Assumption of the Virgin
		name = 'Asunsión de la Virgen [Assumption of the Virgin]'
		self[date(year, AUG, 15)] = name

		-- Independence Day
		name = 'Día de la Independencia [Independence Day]'
		self[date(year, SEP, 18)] = name

		-- Day of Glories of the Army of Chile
		name = 'Día de las Glorias del Ejército de Chile [Day of Glories of the Army of Chile]'
		self[date(year, SEP, 19)] = name
		-- National Holidays Ley 20.215
		name = 'Fiestas Patrias [National Holidays]'
		if year > 2014 and date(year, SEP, 19).weekday() in [WED, THU]:
			self[date(year, SEP, 20)] = name

		-- Day of the Meeting of Two Worlds
		if year < 2010:
			t_holiday.datestamp := make_date(t_year, OCT, 12);
			t_holiday.description := 'Día de la Raza [Columbus day]';
			RETURN NEXT t_holiday;
		else:
			t_holiday.datestamp := make_date(t_year, OCT, 12);
			t_holiday.description := 'Día del Respeto a la Diversidad [Day of the Meeting of Two Worlds]';
			RETURN NEXT t_holiday;

		-- National Day of the Evangelical and Protestant Churches
		name = 'Día Nacional de las Iglesias Evangélicas y Protestantes [National Day of the Evangelical and Protestant Churches]'
		self[date(year, OCT, 31)] = name

		-- All Saints Day
		name = 'Día de Todos los Santos [All Saints Day]'
		self[date(year, NOV, 1)] = name

		-- Immaculate Conception
		t_holiday.datestamp := make_date(t_year, DEC, 8);
		t_holiday.description := 'La Inmaculada Concepción [Immaculate Conception]';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;