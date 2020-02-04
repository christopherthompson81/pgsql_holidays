------------------------------------------
------------------------------------------
-- Nicaragua Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.nicaragua(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Provinces
	PROVINCES TEXT[] := ARRAY['MN'];
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

		-- New Years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;
		-- Maundy Thursday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), THURSDAY, -1);
		t_holiday.description := 'Jueves Santo [Maundy Thursday]';
		RETURN NEXT t_holiday;
		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Viernes Santo [Good Friday]';
		RETURN NEXT t_holiday;
		-- Labor Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		RETURN NEXT t_holiday;
		-- Revolution Day
		IF t_year BETWEEN 1979 AND 2020 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 19);
			t_holiday.description := 'Día de la Revolución [Revolution Day]';
			RETURN NEXT t_holiday;
		END IF;
		-- Battle of San Jacinto Day
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 14);
		t_holiday.description := 'Batalla de San Jacinto [Battle of San Jacinto]';
		RETURN NEXT t_holiday;
		-- Independence Day
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		RETURN NEXT t_holiday;
		-- Virgin's Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Concepción de María [Virgin''s Day]';
		RETURN NEXT t_holiday;
		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

		-- Provinces festive day
		IF p_province = 'MN' THEN
			-- Santo Domingo Day Down
			t_holiday.datestamp := make_date(t_year, AUGUST, 1);
			t_holiday.description := 'Bajada de Santo Domingo';
			RETURN NEXT t_holiday;
			-- Santo Domingo Day Up
			t_holiday.datestamp := make_date(t_year, AUGUST, 10);
			t_holiday.description := 'Subida de Santo Domingo';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;