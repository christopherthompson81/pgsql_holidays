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

		-- Epiphany
		t_holiday.description := 'Día de los Santos Reyes [Epiphany]';
		t_datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.datestamp := t_datestamp;
		IF t_datestamp >= make_date(1997, 6, 27) THEN
			IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			END IF;
		END IF;
		RETURN NEXT t_holiday;

		-- Lady of Altagracia
		t_holiday.datestamp := make_date(t_year, JANUARY, 21);
		t_holiday.description := 'Día de la Altagracia [Lady of Altagracia]';
		RETURN NEXT t_holiday;

		-- Juan Pablo Duarte Day
		t_holiday.description := 'Día de Duarte [Juan Pablo Duarte Day]';
		t_datestamp := make_date(t_year, JANUARY, 26);
		t_holiday.datestamp := t_datestamp;
		IF t_datestamp >= make_date(1997, 6, 27) THEN
			IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			END IF;
		END IF;
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 27);
		t_holiday.description := 'Día de Independencia [Independence Day]';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Viernes Santo [Good Friday]';
		RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.description := 'Día del Trabajo [Labor Day]';
		t_datestamp := make_date(t_year, MAY, 1);
		t_holiday.datestamp := t_datestamp;
		IF t_datestamp >= make_date(1997, 6, 27) THEN
			IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY, SATURDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			END IF;
		END IF;
		RETURN NEXT t_holiday;

		-- Feast of Corpus Christi
		t_holiday.datestamp := make_date(t_year, JUNE, 11);
		t_holiday.description := 'Corpus Christi [Feast of Corpus Christi]';
		RETURN NEXT t_holiday;

		-- Restoration Day
		-- Judgment No. 14 of Feb 20, 2008 of the Supreme Court of Justice
		t_holiday.description := 'Día de la Restauración [Restoration Day]';
		t_datestamp := make_date(t_year, AUGUST, 16);
		IF ((t_year - 2000) % 4 = 0) AND t_year < 2008 THEN
			t_holiday.datestamp = t_datestamp;
		ELSE
			t_holiday.datestamp := t_datestamp;
			IF t_datestamp >= make_date(1997, 6, 27) THEN
				IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY) THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				END IF;
			END IF;
		END IF;
		RETURN NEXT t_holiday;

		-- Our Lady of Mercedes Day
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 24);
		t_holiday.description := 'Día de las Mercedes [Our Lady of Mercedes Day]';
		RETURN NEXT t_holiday;

		-- Constitution Day
		t_holiday.description := 'Día de la Constitución [Constitution Day]';
		t_datestamp := make_date(t_year, NOVEMBER, 6);
		t_holiday.datestamp := t_datestamp;
		IF t_datestamp >= make_date(1997, 6, 27) THEN
			IF DATE_PART('dow', t_datestamp) in (MONDAY, TUESDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			ELSIF DATE_PART('dow', t_datestamp) in (WEDNESDAY, THURSDAY, SATURDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			END IF;
		END IF;
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Día de Navidad [Christmas Day]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;