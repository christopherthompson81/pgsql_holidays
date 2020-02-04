------------------------------------------
------------------------------------------
-- Poland Holidays
--
-- https://pl.wikipedia.org/wiki/Dni_wolne_od_pracy_w_Polsce
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.poland(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'Nowy Rok';
		RETURN NEXT t_holiday;
		
		IF t_year >= 2011 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 6);
			t_holiday.description := 'Święto Trzech Króli';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Easter
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Niedziela Wielkanocna';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Poniedziałek Wielkanocny';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Zielone Świątki';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Dzień Bożego Ciała';
		RETURN NEXT t_holiday;

		IF t_year >= 1950 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Święto Państwowe';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 1919 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 3);
			t_holiday.description := 'Święto Narodowe Trzeciego Maja';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Wniebowzięcie Najświętszej Marii Panny';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Uroczystość Wszystkich świętych';
		RETURN NEXT t_holiday;

		IF (t_year BETWEEN 1937 AND 1945) OR t_year >= 1989 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
			t_holiday.description := 'Narodowe Święto Niepodległości';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Boże Narodzenie (pierwszy dzień)';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boże Narodzenie (drugi dzień)';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;