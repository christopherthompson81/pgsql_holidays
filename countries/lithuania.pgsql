------------------------------------------
------------------------------------------
-- Lithuania Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Lithuania
-- https://www.kalendorius.today/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.lithuania(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'Naujieji metai';
		RETURN NEXT t_holiday;

		-- Day of Restoration of the State of Lithuania (1918)
		IF t_year >= 1918 THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 16);
			t_holiday.description := 'Lietuvos valstybės atkūrimo diena';
			RETURN NEXT t_holiday;
		END IF;

		-- Day of Restoration of Independence of Lithuania
		-- (from the Soviet Union, 1990)
		IF t_year >= 1990 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 11);
			t_holiday.description := 'Lietuvos nepriklausomybės atkūrimo diena';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter
		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Velykos';
		RETURN NEXT t_holiday;

		-- Easter 2nd day
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Velykų antroji diena';
		RETURN NEXT t_holiday;

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Tarptautinė darbo diena';
		RETURN NEXT t_holiday;

		-- Mother's day. First Sunday in May
		t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 1), SUNDAY, 1);
		t_holiday.description = 'Motinos diena';
		RETURN NEXT t_holiday;

		-- Fathers's day. First Sunday in June
		t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUNE, 1), SUNDAY, 1);
		t_holiday.description = 'Tėvo diena';
		RETURN NEXT t_holiday;

		-- St. John's Day [Christian name],
		-- Day of Dew [original pagan name]
		IF t_year >= 2003 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'Joninės, Rasos';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day
		IF t_year >= 1991 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 6);
			t_holiday.description := 'Valstybės (Lietuvos karaliaus Mindaugo karūnavimo) diena';
			RETURN NEXT t_holiday;
		END IF;

		-- Assumption Day
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Žolinė (Švč. Mergelės Marijos ėmimo į dangų diena)';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Visų šventųjų diena (Vėlinės)';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Šv. Kūčios';
		RETURN NEXT t_holiday;

		-- Christmas 1st day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Šv. Kalėdų pirma diena';
		RETURN NEXT t_holiday;

		-- Christmas 2nd day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Šv. Kalėdų antra diena';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;