------------------------------------------
------------------------------------------
-- Argentinian Holidays
--
-- https://www.argentina.gob.ar/interior/feriados
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_feriados_en_Argentina
-- http://servicios.lanacion.com.ar/feriados
-- https://www.clarin.com/feriados/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.argentina(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $argentina$

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

		-- Carnival days
		t_datestamp := holidays.easter(t_year);
		t_holiday.description := 'Día de Carnaval [Carnival''s Day]';
		t_holiday.datestamp := t_datestamp - '48 Days'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp - '47 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Memory's National Day for the Truth and Justice
		t_holiday.description := 'Día Nacional de la Memoria por la Verdad y la Justicia [Memory''s National Day for the Truth and Justice]';
		t_holiday.datestamp := make_date(t_year, MARCH, 24);
		RETURN NEXT t_holiday;

		-- Holy Week
		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Semana Santa (Jueves Santo) [Holy day (Holy Thursday)]';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Semana Santa (Viernes Santo) [Holy day (Holy Friday)]';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Día de Pascuas [Easter Day]';
		RETURN NEXT t_holiday;

		-- Veterans Day and the Fallen in the Malvinas War
		t_holiday.datestamp := make_date(t_year, APRIL, 2);
		t_holiday.description := 'Día del Veterano y de los Caidos en la Guerra de Malvinas [Veterans Day and the Fallen in the Malvinas War]';
		RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;

		-- May Revolution Day
		t_holiday.description := 'Día de la Revolucion de Mayo [May Revolution Day]';
		t_holiday.datestamp := make_date(t_year, MAY, 25);
		RETURN NEXT t_holiday;

		-- Day Pass to the Immortality of General Martín Miguel de Güemes.
		t_holiday.description := 'Día Pase a la Inmortalidad del General Martín Miguel de Güemes [Day Pass to the Immortality of General Martín Miguel de Güemes]';
		t_holiday.datestamp := make_date(t_year, JUNE, 17);
		RETURN NEXT t_holiday;

		-- Day Pass to the Immortality of General D. Manuel Belgrano.
		t_holiday.description := 'Día Pase a la Inmortalidad del General D. Manuel Belgrano [Day Pass to the Immortality of General D. Manuel Belgrano]';
		t_holiday.datestamp := make_date(t_year, JUNE, 20);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_holiday.datestamp := make_date(t_year, JULY, 9);
		RETURN NEXT t_holiday;

		-- Day Pass to the Immortality of General D. José de San Martin
		t_holiday.description := 'Día Pase a la Inmortalidad del General D. José de San Martin [Day Pass to the Immortality of General D. José de San Martin]';
		t_holiday.datestamp := make_date(t_year, AUGUST, 17);
		RETURN NEXT t_holiday;

		-- Respect for Cultural Diversity Day or Columbus day
		IF t_year < 2010 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día de la Raza [Columbus day]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día del Respeto a la Diversidad Cultural [Respect for Cultural Diversity Day]';
			RETURN NEXT t_holiday;
		END IF;
		
		-- National Sovereignty Day
		t_holiday.description := 'Día Nacional de la Soberanía [National Sovereignty Day]';
		IF t_year >= 2010 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			RETURN NEXT t_holiday;
		END IF;

		-- Immaculate Conception
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'La Inmaculada Concepción [Immaculate Conception]';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$argentina$ LANGUAGE plpgsql;