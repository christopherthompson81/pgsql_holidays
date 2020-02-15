------------------------------------------
------------------------------------------
-- Luxembourg Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Luxembourg
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.luxembourg(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;
		
		-- Public holidays

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Neijoerschdag';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		-- Bank holiday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Karfreitag';
		t_holiday.authority := 'bank';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		
		-- Easter Sunday
		-- Observance, Christian
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Ostern';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Easter Monday
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Ouschterméindeg';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Christi Himmelfaart';
		RETURN NEXT t_holiday;

		-- Whit Sunday
		-- Observance, Christian
		t_holiday.reference := 'Whit Sunday';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Ostern';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Péngschtméindeg';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dag vun der Aarbecht';
		RETURN NEXT t_holiday;

		-- Europe Day
		-- Not in legislation yet, but introduced starting 2019
		t_holiday.reference := 'Europe Day';
		IF t_year >= 2019 THEN	
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			t_holiday.description := 'Europadag';
			RETURN NEXT t_holiday;
		END IF;
		
		-- National Day
		t_holiday.reference := 'National Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 23);
		t_holiday.description := 'Nationalfeierdag';
		RETURN NEXT t_holiday;

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Léiffrawëschdag';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Allerhellgen';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		-- Half Day Bank holiday
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Heiligabend';
		t_holiday.authority := 'bank';
		t_holiday.start_time := '13:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.start_time := '00:00:00'::TIME;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Chrëschtdag';
		RETURN NEXT t_holiday;

		-- St. Stephen's Day
		t_holiday.reference := 'St. Stephen''s Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Stiefesdag';
		RETURN NEXT t_holiday;

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Silvester';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

	END LOOP;
END;

$$ LANGUAGE plpgsql;