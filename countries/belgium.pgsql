------------------------------------------
------------------------------------------
-- Belgium Holidays
--
-- https://www.belgium.be/nl/over_belgie/land/belgie_in_een_notendop/feestdagen
-- https://nl.wikipedia.org/wiki/Feestdagen_in_Belgi%C3%AB
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.belgium(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nieuwjaarsdag';
		RETURN NEXT t_holiday;

		-- For easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Easter
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Pasen';
		RETURN NEXT t_holiday;

		-- Second easter day
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		t_holiday.description := 'Paasmaandag';
		RETURN NEXT t_holiday;

		-- Ascension day
		t_holiday.datestamp := t_datestamp + '39 Day'::INTERVAL;
		t_holiday.description := 'O.L.H. Hemelvaart';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.datestamp := t_datestamp + '49 Day'::INTERVAL;
		t_holiday.description := 'Pinksteren';
		RETURN NEXT t_holiday;

		-- Pentecost monday
		t_holiday.datestamp := t_datestamp + '50 Day'::INTERVAL;
		t_holiday.description := 'Pinkstermaandag';
		RETURN NEXT t_holiday;

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dag van de Arbeid';
		RETURN NEXT t_holiday;

		-- Belgian National Day
		t_holiday.datestamp := make_date(t_year, JULY, 21);
		t_holiday.description := 'Nationale feestdag';
		RETURN NEXT t_holiday;

		-- Assumption of Mary
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'O.L.V. Hemelvaart';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Allerheiligen';
		RETURN NEXT t_holiday;

		-- Armistice Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
		t_holiday.description := 'Wapenstilstand';
		RETURN NEXT t_holiday;

		-- First christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Kerstmis';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;