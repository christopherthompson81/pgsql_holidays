------------------------------------------
------------------------------------------
-- Colombia Holidays
--
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_festivos_en_Colombia
--
-- Emiliani Law holidays!
-- Unless they fall on a Monday they are observed the following monday
-- [Epiphany, Saint Joseph's Day, Saint Peter and Saint Paul's Day,
-- Assumption of Mary, Discovery of America, All Saints’ Day,
-- Independence of Cartagena]
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Año Nuevo';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Día de los Reyes Magos';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;
		
		-- Women's Day
		t_holiday.reference := 'Women''s Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 8);
		t_holiday.description := 'Día de la Mujer';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Saint Joseph's Day
		t_holiday.reference := 'Saint Joseph''s Day';
		t_datestamp := make_date(t_year, MARCH, 19);
		t_holiday.description := 'Día de San José';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;			
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Holidays based on Easter
		t_datestamp := holidays.easter(t_year);

		-- Palm Sunday [Easter -7]
		-- Observance, Christian
		t_holiday.reference := 'Palm Sunday';
		t_holiday.datestamp := t_datestamp - '7 Days'::INTERVAL;
		t_holiday.description := 'Domingo de ramos';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Maundy Thursday [Easter -3]
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Jueves Santo';
		RETURN NEXT t_holiday;

		-- Good Friday [Easter -2]
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Viernes Santo';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		-- Observance, Christian
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Domingo de Pascua';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Ascension of Jesus [Easter +39]
		-- Columbia observes Ascension on the Monday following the actual religious day.
		--
		-- Porting note: This used useless logic. Ascension will always be a Thursday
		-- and therefore the following Monday is always 43 days after Easter.
		t_holiday.reference := 'Ascension';
		t_holiday.datestamp := t_datestamp + '43 Days'::INTERVAL;
		t_holiday.description := 'Ascensión del señor';
		t_holiday.observation_shifted := TRUE;
		RETURN NEXT t_holiday;
		t_holiday.observation_shifted := FALSE;

		-- Corpus Christi [Easter +60]
		-- Columbia observes Corpus Christi on the Monday following the actual religious day.
		--
		-- Porting note: This used useless logic. Corpus Christi will always be a Thursday
		-- and therefore the following Monday is always 64 days after Easter.
		t_holiday.reference := 'Corpus Christi';
		t_holiday.datestamp := t_datestamp + '64 Days'::INTERVAL;
		t_holiday.description := 'Corpus Christi';
		t_holiday.observation_shifted := TRUE;
		RETURN NEXT t_holiday;
		t_holiday.observation_shifted := FALSE;

		-- Sacred Heart [Easter +68]
		-- Columbia observes Sacred Heart on the Monday following the actual religious day.
		--
		-- Porting note: This used useless logic. Sacred Heart will always be a Friday
		-- and therefore the following Monday is always 71 days after Easter.
		t_holiday.reference := 'Sacred Heart';
		t_holiday.datestamp := t_datestamp + '71 Days'::INTERVAL;
		t_holiday.description := 'Sagrado Corazón';
		t_holiday.observation_shifted := TRUE;
		RETURN NEXT t_holiday;
		t_holiday.observation_shifted := FALSE;

		-- Language Day
		t_holiday.reference := 'Language Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 23);
		t_holiday.description := 'Día de la Lengua';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Children's Day
		-- The last Saturday in April
		t_holiday.reference := 'Children''s Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, APRIL, 30), SATURDAY, -1);
		t_holiday.description := 'Día del Niño';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Secretaries' Day
		t_holiday.reference := 'Secretaries'' Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 26);
		t_holiday.description := 'Día de la Secretaria';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Arbour Day / Day of Trees
		t_holiday.reference := 'Arbour Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 29);
		t_holiday.description := 'Día del Árbol';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Labor Day
		t_holiday.reference := 'Labor Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo';
		RETURN NEXT t_holiday;

		-- Mother's Day
		t_holiday.reference := 'Mother''s Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), SUNDAY, 2);
		t_holiday.description := 'Día de la Madre';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Teacher's Day
		t_holiday.reference := 'Teacher''s Day';
		t_holiday.datestamp := make_date(t_year, MAY, 15);
		t_holiday.description := 'Día del Maestro';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Father's Day
		-- Third Sunday of June
		t_holiday.reference := 'Father''s Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), SUNDAY, 3);
		t_holiday.description := 'Día del Padre';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Saint Peter and Saint Paul's Day
		t_holiday.reference := 'Saint Peter and Saint Paul';
		t_datestamp := make_date(t_year, JUNE, 29);
		t_holiday.description := 'San Pedro y San Pablo';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Día de la Independencia';
		t_datestamp := make_date(t_year, JULY, 20);
		IF NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Battle of Boyaca
		t_holiday.reference := 'Battle of Boyacá';
		t_holiday.datestamp := make_date(t_year, AUGUST, 7);
		t_holiday.description := 'Batalla de Boyacá';
		RETURN NEXT t_holiday;

		-- Assumption of Mary
		t_holiday.reference := 'Assumption';
		t_datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'La Asunción';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;			
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Valentine's Day
		t_holiday.reference := 'Valentine''s Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), SATURDAY, 3);
		t_holiday.description := 'Día de Amor y Amistad';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		
		-- Discovery of America
		t_holiday.reference := 'Discovery of America';
		t_datestamp := make_date(t_year, OCTOBER, 12);
		t_holiday.description := 'Descubrimiento de América';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;			
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Halloween
		t_holiday.reference := 'Halloween';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
		t_holiday.description := 'Día de las brujas';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		
		-- All Saints’ Day
		t_holiday.reference := 'All Saint''s Day';
		t_datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Dia de Todos los Santos';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;			
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Independence of Cartagena
		t_holiday.reference := 'Independence of Cartagena';
		t_datestamp := make_date(t_year, NOVEMBER, 11);
		t_holiday.description := 'Independencia de Cartagena';
		IF DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;			
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Colombian Women's Day
		t_holiday.reference := 'Colombian Women''s Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 14);
		t_holiday.description := 'Día de la Mujer Colombiana';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Little Candles Day
		t_holiday.reference := 'Little Candles Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 7);
		t_holiday.description := 'Día de las Velitas';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

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

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Año Viejo';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
	END LOOP;
END;

$$ LANGUAGE plpgsql;