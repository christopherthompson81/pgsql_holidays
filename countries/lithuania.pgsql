------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Lithuania
-- https://www.kalendorius.today/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.datestamp := make_date(t_year, 1, 1);
		t_holiday.description := 'Naujieji metai';
		RETURN NEXT t_holiday;

		-- Day of Restoration of the State of Lithuania (1918)
		IF t_year >= 1918 THEN
			t_holiday.datestamp := make_date(t_year, 2, 16);
			t_holiday.description := 'Lietuvos valstybės atkūrimo diena';
			RETURN NEXT t_holiday;

		-- Day of Restoration of Independence of Lithuania
		-- (from the Soviet Union, 1990)
		IF t_year >= 1990 THEN
			t_holiday.datestamp := make_date(t_year, 3, 11);
			t_holiday.description := 'Lietuvos nepriklausomybės atkūrimo diena';
			RETURN NEXT t_holiday;

		-- Easter
		easter_date = easter(year)
		self[easter_date] = 'Velykos'

		-- Easter 2nd day
		self[easter_date + '1 Days'::INTERVAL] = 'Velykų antroji diena'

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, 5, 1);
		t_holiday.description := 'Tarptautinė darbo diena';
		RETURN NEXT t_holiday;

		-- Mother's day. First Sunday in May
		self[date(year, 5, 1) + rd(weekday=SU)] = 'Motinos diena'

		-- Fathers's day. First Sunday in June
		self[date(year, 6, 1) + rd(weekday=SU)] = 'Tėvo diena'

		-- St. John's Day [Christian name],
		-- Day of Dew [original pagan name]
		IF t_year >= 2003 THEN
			t_holiday.datestamp := make_date(t_year, 6, 24);
			t_holiday.description := 'Joninės, Rasos';
			RETURN NEXT t_holiday;

		-- Statehood Day
		IF t_year >= 1991 THEN
			t_holiday.datestamp := make_date(t_year, 7, 6);
			t_holiday.description := 'Valstybės (Lietuvos karaliaus Mindaugo karūnavimo) diena';
			RETURN NEXT t_holiday;

		-- Assumption Day
		t_holiday.datestamp := make_date(t_year, 8, 15);
		t_holiday.description := 'Žolinė (Švč. Mergelės Marijos ėmimo į dangų diena)';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.datestamp := make_date(t_year, 11, 1);
		t_holiday.description := 'Visų šventųjų diena (Vėlinės)';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.datestamp := make_date(t_year, 12, 24);
		t_holiday.description := 'Šv. Kūčios';
		RETURN NEXT t_holiday;

		-- Christmas 1st day
		t_holiday.datestamp := make_date(t_year, 12, 25);
		t_holiday.description := 'Šv. Kalėdų pirma diena';
		RETURN NEXT t_holiday;

		-- Christmas 2nd day
		t_holiday.datestamp := make_date(t_year, 12, 26);
		t_holiday.description := 'Šv. Kalėdų antra diena';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;