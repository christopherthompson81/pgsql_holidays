------------------------------------------
------------------------------------------
-- Paraguay Holidays
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

		-- Patriots Day
		t_holiday.reference := 'Patriots Day';
		t_holiday.description := 'Día de los Héroes de la Patria';
		t_datestamp := make_date(t_year, MARCH, 1);
		IF DATE_PART('dow', t_datestamp) >= WEDNESDAY THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Holy Week
		-- Easter Based Holidays
		t_datestamp := holidays.easter(t_year);

		-- Holy Thursday
		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Semana Santa (Jueves Santo)';
		RETURN NEXT t_holiday;
		
		-- Holy Friday
		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Semana Santa (Viernes Santo)';
		RETURN NEXT t_holiday;

		-- Easter Day
		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Día de Pascuas';
		RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.reference := 'Labor Day';
		t_holiday.description := 'Día de los Trabajadores';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Día de la Independencia Nacional';
		t_holiday.datestamp := make_date(t_year, MAY, 15);
		RETURN NEXT t_holiday;

		-- Peace in Chaco Day
		t_holiday.reference := 'Peace in Chaco Day';
		t_holiday.description := 'Día de la Paz del Chaco';
		t_datestamp := make_date(t_year, JUNE, 12);
		IF DATE_PART('dow', t_datestamp) >= WEDNESDAY THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Foundation of Asuncion Day
		t_holiday.reference := 'Foundation of Asuncion Day';
		t_holiday.description := 'Día de la Fundación de Asunción';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		RETURN NEXT t_holiday;

		-- Battle of Boqueron
		t_holiday.reference := 'Battle of Boqueron';
		t_holiday.description := 'Batalla de Boquerón';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 29);
		RETURN NEXT t_holiday;

		-- Caacupe Virgin Day
		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.description := 'Día de la Virgen de Caacupé';
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