------------------------------------------
------------------------------------------
-- Mexico Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.mexico(p_start_year INTEGER, p_end_year INTEGER)
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
	OBSERVED CONSTANT TEXT := ' (Observed)'; -- Spanish Localization Needed
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

		-- Constitution Day
		t_holiday.description := 'Día de la Constitución [Constitution Day]';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 5);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, +1);
			RETURN NEXT t_holiday;
		END IF;

		-- Benito Juárez's birthday
		t_holiday.description := 'Natalicio de Benito Juárez [Benito Juárez''s birthday]';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, +3);
			RETURN NEXT t_holiday;
		END IF;

		-- Revolution Day
		t_holiday.description := 'Día de la Revolución [Revolution Day]';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), MONDAY, +3);
			RETURN NEXT t_holiday;
		END IF;

		-- New Year's Day
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Año Nuevo [New Year''s Day] (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			-- Add Dec 31st from the previous year
			t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
			t_holiday.description := 'Año Nuevo [New Year''s Day] (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;
		
		-- The next year's observed New Year's Day can be in this year
		-- when it falls on a Friday (Jan 1st is a Saturday)
		t_datestamp := make_date(t_year, DECEMBER, 31);
		IF DATE_PART('dow', t_datestamp) = FRIDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Año Nuevo [New Year''s Day] (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Labor Day
		IF t_year >= 1923 THEN
			t_datestamp := make_date(t_year, MAY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Día del Trabajo [Labour Day]';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := make_date(t_year, MAY, 1) - '1 Days'::INTERVAL;
				t_holiday.description := 'Día del Trabajo [Labour Day] (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, MAY, 1) + '1 Days'::INTERVAL;
				t_holiday.description := 'Día del Trabajo [Labour Day] (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Independence Day
		t_datestamp := make_date(t_year, SEPTEMBER, 16);
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);
		IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
			t_holiday.description := 'Día de la Independencia [Independence Day] (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Día de la Independencia [Independence Day] (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Change of Federal Government
		-- Every six years--next observance 2018
		t_holiday.description := 'Transmisión del Poder Ejecutivo Federal [Change of Federal Government]';
		IF (2018 - t_year) % 6 = 0 THEN
			t_datestamp := make_date(t_year, DECEMBER, 1);
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 1) - '1 Days'::INTERVAL;
				t_holiday.description := 'Transmisión del Poder Ejecutivo Federal [Change of Federal Government] (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 1) + '1 Days'::INTERVAL;
				t_holiday.description := 'Transmisión del Poder Ejecutivo Federal [Change of Federal Government] (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Christmas
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);


		-- Apply observation shifting rules to the above.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			t_holiday.observation_shifted := TRUE;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || OBSERVED;
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || OBSERVED;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;