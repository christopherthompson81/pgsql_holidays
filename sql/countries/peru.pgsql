------------------------------------------
------------------------------------------
-- Peru Holidays
--
-- https://www.gob.pe/feriados
-- https://es.wikipedia.org/wiki/Anexo:Días_feriados_en_el_Perú
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.peru(p_start_year INTEGER, p_end_year INTEGER)
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo';
		RETURN NEXT t_holiday;

		-- Feast of Saints Peter and Paul
		t_holiday.reference := 'Feast of Saints Peter and Paul';
		t_holiday.description := 'San Pedro y San Pablo';
		t_holiday.datestamp := make_date(t_year, JUNE, 29);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Día de la Independencia';
		t_holiday.datestamp := make_date(t_year, JULY, 28);
		RETURN NEXT t_holiday;

		-- Independence Day (2)
		t_holiday.reference := 'Independence Day (2)';
		t_holiday.description := 'Día de las Fuerzas Armadas y la Policía del Perú';
		t_holiday.datestamp := make_date(t_year, JULY, 29);
		RETURN NEXT t_holiday;

		-- Santa Rosa de Lima
		t_holiday.reference := 'Santa Rosa de Lima';
		t_holiday.description := 'Día de Santa Rosa de Lima';
		t_holiday.datestamp := make_date(t_year, AUGUST, 30);
		RETURN NEXT t_holiday;

		-- Battle of Angamos
		t_holiday.reference := 'Battle of Angamos';
		t_holiday.description := 'Combate Naval de Angamos';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 8);
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Holy Thursday
		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Jueves Santo';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Viernes Santo';
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.reference := 'Holy Saturday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
		t_holiday.description := 'Sábado de Gloria';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Domingo de Resurrección';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.description := 'Día de Todos Los Santos';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.description := 'Inmaculada Concepción';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;