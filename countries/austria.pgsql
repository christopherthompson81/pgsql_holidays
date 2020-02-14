------------------------------------------
------------------------------------------
-- Austria Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.austria(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	PROVINCES TEXT[] := ARRAY['B', 'K', 'N', 'O', 'S', 'ST', 'T', 'V', 'W'];
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

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Neujahr';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Heilige Drei Könige';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
		t_holiday.description := 'Ostermontag';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.reference := 'Ascension Day';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Christi Himmelfahrt';
		RETURN NEXT t_holiday;

		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Pfingstmontag';
		RETURN NEXT t_holiday;

		-- Corpus Christi
		t_holiday.reference := 'Corpus Christi';
		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Fronleichnam';
		RETURN NEXT t_holiday;

		-- National Holiday
		t_holiday.reference := 'National Holiday';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Staatsfeiertag';
		RETURN NEXT t_holiday;

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Mariä Himmelfahrt';
		RETURN NEXT t_holiday;

		-- National day
		t_holiday.reference := 'National Day';
		IF t_year BETWEEN 1919 AND 1934 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 12);
			t_holiday.description := 'Nationalfeiertag';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year >= 1967 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 26);
			t_holiday.description := 'Nationalfeiertag';
			RETURN NEXT t_holiday;
		END IF;
		
		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Allerheiligen';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Mariä Empfängnis';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christtag';
		RETURN NEXT t_holiday;

		-- St. Stephen's Day
		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Stefanitag';
		RETURN NEXT t_holiday;
	END LOOP;
END;

$$ LANGUAGE plpgsql;
