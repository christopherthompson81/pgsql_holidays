------------------------------------------
------------------------------------------
-- Colombia Holidays
--
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_festivos_en_Colombia
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.colombia(p_start_year INTEGER, p_end_year INTEGER)
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
		-- Fixed date holidays!
		-- If observed=True and they fall on a weekend they are not observed.
		-- If observed=False there are 18 holidays

		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_datestamp := make_date(t_year, JANUARY, 1);
		IF NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Año Nuevo [New Year''s Day]';
			RETURN NEXT t_holiday;
		END IF;

		-- Labor Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_datestamp := make_date(t_year, JULY, 20);
		IF NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Battle of Boyaca
		t_holiday.datestamp := make_date(t_year, AUGUST, 7);
		t_holiday.description := 'Batalla de Boyacá [Battle of Boyacá]';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_datestamp := make_date(t_year, DECEMBER, 8);
		IF NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
			t_holiday.description := 'La Inmaculada Concepción [Immaculate Conception]';
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

		-- Emiliani Law holidays!
		-- Unless they fall on a Monday they are observed the following monday

		--  Epiphany
		t_datestamp := make_date(t_year, JANUARY, 6);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Día de los Reyes Magos [Epiphany]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Día de los Reyes Magos [Epiphany] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Saint Joseph's Day
		t_datestamp := make_date(t_year, MARCH, 19);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Día de San José [Saint Joseph''s Day]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Día de San José [Saint Joseph''s Day] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Saint Peter and Saint Paul's Day
		t_datestamp := make_date(t_year, JUNE, 29);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'San Pedro y San Pablo [Saint Peter and Saint Paul]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'San Pedro y San Pablo [Saint Peter and Saint Paul] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Assumption of Mary
		t_datestamp := make_date(t_year, AUGUST, 15);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'La Asunción [Assumption of Mary]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'La Asunción [Assumption of Mary] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Discovery of America
		t_datestamp := make_date(t_year, OCTOBER, 12);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Descubrimiento de América [Discovery of America]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Descubrimiento de América [Discovery of America] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- All Saints’ Day
		t_datestamp := make_date(t_year, NOVEMBER, 1);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Dia de Todos los Santos [All Saint''s Day]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Dia de Todos los Santos [All Saint''s Day] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Independence of Cartagena
		t_datestamp := make_date(t_year, NOVEMBER, 11);
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Independencia de Cartagena [Independence of Cartagena]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Independencia de Cartagena [Independence of Cartagena] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Holidays based on Easter

		-- Maundy Thursday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), THURSDAY, -1);
		t_holiday.description := 'Jueves Santo [Maundy Thursday]';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Viernes Santo [Good Friday]';
		RETURN NEXT t_holiday;

		-- Holidays based on Easter but are observed the following monday
		-- (unless they occur on a monday)

		-- Ascension of Jesus
		t_datestamp = holidays.easter(t_year) + '39 Days'::INTERVAL;
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Ascensión del señor [Ascension of Jesus]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Ascensión del señor [Ascension of Jesus] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Corpus Christi
		t_datestamp = holidays.easter(t_year) + '60 Days'::INTERVAL;
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Corpus Christi [Corpus Christi]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Corpus Christi [Corpus Christi] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Sacred Heart
		t_datestamp = holidays.easter(t_year) + '68 Days'::INTERVAL;
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Sagrado Corazón [Sacred Heart]';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Sagrado Corazón [Sacred Heart] (Observed)';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;