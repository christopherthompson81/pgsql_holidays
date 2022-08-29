------------------------------------------
------------------------------------------
-- Estonia Holidays
--
-- TODO: Implement Day Shortening
-- https://www.tooelu.ee/en/Employee/Working-relations/Working-time-and-rest-period/Shortening-Working-Time-Before-National-and-State-Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.estonia(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'uusaasta';
		RETURN NEXT t_holiday;

		-- Day Preceeding of Restoration of Independence
		t_holiday.reference := 'Independance Eve';
		t_holiday.datestamp := make_date(t_year, February, 23);
		t_holiday.description := 'Päev enne iseseisvuspäeva';
		t_holiday.start_time := '14:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;

		-- Independence Day, anniversary of the Republic of Estonia
		t_holiday.reference := 'Independence Day';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 24);
		t_holiday.description := 'iseseisvuspäev';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp = holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'suur reede';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'ülestõusmispühade 1. püha';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'nelipühade 1. püha';
		RETURN NEXT t_holiday;

		-- Spring Day
		t_holiday.reference := 'Spring Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'kevadpüha';
		RETURN NEXT t_holiday;

		-- Day Preceeding of Victory Day
		t_holiday.reference := 'Victory Eve';
		t_holiday.datestamp := make_date(t_year, JUNE, 22);
		t_holiday.description := 'Päev enne võidupüha';
		t_holiday.start_time := '14:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;

		-- Victory Day
		t_holiday.reference := 'Victory Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 23);
		t_holiday.description := 'võidupüha';
		RETURN NEXT t_holiday;

		-- Midsummer Day
		t_holiday.reference := 'Midsummer Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 24);
		t_holiday.description := 'jaanipäev';
		RETURN NEXT t_holiday;

		-- Day of Restoration of Independence
		t_holiday.reference := 'Independence Restoration Day';
		t_holiday.datestamp := make_date(t_year, AUGUST, 20);
		t_holiday.description := 'taasiseseisvumispäev';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'jõululaupäev';
		t_holiday.start_time := '14:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'esimene jõulupüha';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'teine jõulupüha';
		RETURN NEXT t_holiday;

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'vanaaasta õhtu';
		t_holiday.start_time := '14:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;

	END LOOP;
END;

$$ LANGUAGE plpgsql;