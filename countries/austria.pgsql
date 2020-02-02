------------------------------------------
------------------------------------------
-- <country> Holidays
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
	-- Provinces
	PROVINCES = ['B', 'K', 'N', 'O', 'S', 'ST', 'T', 'V', 'W']
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

		-- public holidays
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Neujahr';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Heilige Drei Könige';
		RETURN NEXT t_holiday;
		self[easter(year) + rd(weekday=MO)] = 'Ostermontag'
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Staatsfeiertag';
		RETURN NEXT t_holiday;
		self[easter(year) + rd(days=39)] = 'Christi Himmelfahrt'
		self[easter(year) + rd(days=50)] = 'Pfingstmontag'
		self[easter(year) + rd(days=60)] = 'Fronleichnam'
		t_holiday.datestamp := make_date(t_year, AUG, 15);
		t_holiday.description := 'Mariä Himmelfahrt';
		RETURN NEXT t_holiday;
		if 1919 <= year <= 1934:
			t_holiday.datestamp := make_date(t_year, NOV, 12);
			t_holiday.description := 'Nationalfeiertag';
			RETURN NEXT t_holiday;
		if year >= 1967:
			t_holiday.datestamp := make_date(t_year, OCT, 26);
			t_holiday.description := 'Nationalfeiertag';
			RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, NOV, 1);
		t_holiday.description := 'Allerheiligen';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 8);
		t_holiday.description := 'Mariä Empfängnis';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Christtag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Stefanitag';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;