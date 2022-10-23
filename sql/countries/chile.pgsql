------------------------------------------
------------------------------------------
-- Chile Holidays
--
-- https://www.feriados.cl
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_feriados_en_Chile
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.chile(p_start_year INTEGER, p_end_year INTEGER)
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

		-- Holy Week
		t_datestamp := holidays.easter(t_year);

		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Semana Santa (Jueves Santo)';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Semana Santa (Viernes Santo)';
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.reference := 'Holy Saturday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
		t_holiday.description := 'Semana Santa (Sábado Santo)';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Día de Pascuas';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Labor Day
		t_holiday.reference := 'Labor Day';
		t_holiday.description := 'Día del Trabajo';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;

		-- Naval Glories Day
		t_holiday.reference := 'Navy Day';
		t_holiday.description := 'Día de las Glorias Navales';
		t_holiday.datestamp := make_date(t_year, MAY, 21);
		RETURN NEXT t_holiday;

		-- Saint Peter and Saint Paul
		t_holiday.reference := 'Saint Peter and Saint Paul';
		t_holiday.description := 'San Pedro y San Pablo';
		t_holiday.datestamp := make_date(t_year, JUNE, 29);
		RETURN NEXT t_holiday;

		-- Day of Virgin of Carmen.
		t_holiday.reference := 'Our Lady of Mount Carmel';
		t_holiday.description := 'Virgen del Carmen';
		t_holiday.datestamp := make_date(t_year, JULY, 16);
		RETURN NEXT t_holiday;

		-- Day of Assumption of the Virgin
		t_holiday.reference := 'Assumption';
		t_holiday.description := 'Asunsión de la Virgen';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Día de la Independencia';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 18);
		RETURN NEXT t_holiday;

		-- Day of Glories of the Army of Chile
		t_holiday.reference := 'Army Day';
		t_holiday.description := 'Día de las Glorias del Ejército de Chile';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 19);
		RETURN NEXT t_holiday;
		
		-- National Holidays Ley 20.215
		t_holiday.reference := 'National Holidays';
		t_datestamp = make_date(t_year, SEPTEMBER, 19);
		t_holiday.description := 'Fiestas Patrias';
		IF t_year > 2014 AND DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY) THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 20);
			RETURN NEXT t_holiday;
		END IF;

		-- Day of the Meeting of Two Worlds
		t_holiday.reference := 'Diversity Day';
		IF t_year < 2010 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día de la Raza [Columbus day]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día del Respeto a la Diversidad';
			RETURN NEXT t_holiday;
		END IF;

		-- National Day of the Evangelical and Protestant Churches
		t_holiday.reference := 'Reformation Day';
		t_holiday.description := 'Día Nacional de las Iglesias Evangélicas y Protestantes';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
		RETURN NEXT t_holiday;

		-- All Saints Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.description := 'Día de Todos los Santos';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'La Inmaculada Concepción';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;

		-- Dec 31	Thursday	New Year's Eve	Bank holiday
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Fiesta de Fin de Año';
		t_holiday.authority := 'bank';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';

	END LOOP;
END;

$$ LANGUAGE plpgsql;