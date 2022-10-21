------------------------------------------
------------------------------------------
-- Dominican Republic Holidays
--
-- http://ojd.org.do/Normativas/LABORAL/Leyes/Ley%20No.%20%20139-97.pdf
-- https://es.wikipedia.org/wiki/Rep%C3%BAblica_Dominicana--D%C3%ADas_festivos_nacionales
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.dominican_republic(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Localication
	OBSERVED CONSTANT TEXT := ' (Observed)'; -- Spanish Localization required
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_holiday_list holidays.holiday[];

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

		-- Epiphany (Shiftable)
		t_holiday.reference := 'Epiphany';
		t_holiday.description := 'Día de los Santos Reyes';
		t_datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.datestamp := t_datestamp;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Lady of Altagracia
		t_holiday.reference := 'Lady of Altagracia';
		t_holiday.datestamp := make_date(t_year, JANUARY, 21);
		t_holiday.description := 'Día de la Altagracia';
		RETURN NEXT t_holiday;

		-- Juan Pablo Duarte Day (Shiftable)
		t_holiday.reference := 'Juan Pablo Duarte Day';
		t_holiday.description := 'Día de Duarte';
		t_datestamp := make_date(t_year, JANUARY, 26);
		t_holiday.datestamp := t_datestamp;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 27);
		t_holiday.description := 'Día de Independencia';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Viernes Santo';
		RETURN NEXT t_holiday;

		-- Corpus Christi [Easter +60]
		t_holiday.reference := 'Corpus Christi';
		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Corpus Christi';
		RETURN NEXT t_holiday;

		-- Labor Day (Shiftable)
		t_holiday.reference := 'Labor Day';
		t_holiday.description := 'Día del Trabajo';
		t_datestamp := make_date(t_year, MAY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Restoration Day (Shiftable)
		-- Judgment No. 14 of Feb 20, 2008 of the Supreme Court of Justice
		t_holiday.reference := 'Restoration Day';
		t_holiday.description := 'Día de la Restauración';
		t_datestamp := make_date(t_year, AUGUST, 16);
		IF ((t_year - 2000) % 4 = 0) AND t_year < 2008 THEN
			t_holiday.datestamp = t_datestamp;
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_datestamp;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- Our Lady of Mercedes Day
		t_holiday.reference := 'Our Lady of Mercedes Day';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 24);
		t_holiday.description := 'Día de las Mercedes';
		RETURN NEXT t_holiday;

		-- Constitution Day (Shiftable)
		t_holiday.reference := 'Constitution Day';
		t_holiday.description := 'Día de la Constitución';
		t_datestamp := make_date(t_year, NOVEMBER, 6);
		t_holiday.datestamp := t_datestamp;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Día de Navidad';
		RETURN NEXT t_holiday;
			
		-- Apply observation shifting rules to the shiftable holidays.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			IF t_datestamp >= make_date(1997, 6, 27) THEN
				IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
					t_holiday.description := t_holiday.description || OBSERVED;
					t_holiday.observation_shifted := TRUE;
				ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY, SATURDAY) THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
					t_holiday.description := t_holiday.description || OBSERVED;
					t_holiday.observation_shifted := TRUE;
				END IF;
			END IF;
			RETURN NEXT t_holiday;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;