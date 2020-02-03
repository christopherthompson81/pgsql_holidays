------------------------------------------
------------------------------------------
-- Estonia Holidays
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
		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'uusaasta';
		RETURN NEXT t_holiday;

		-- Independence Day, anniversary of the Republic of Estonia
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 24);
		t_holiday.description := 'iseseisvuspäev';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp = holidays.easter(t_year);

		-- Good Friday
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'suur reede';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'ülestõusmispühade 1. püha';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'nelipühade 1. püha';
		RETURN NEXT t_holiday;

		-- Spring Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'kevadpüha';
		RETURN NEXT t_holiday;

		-- Victory Day
		t_holiday.datestamp := make_date(t_year, JUNE, 23);
		t_holiday.description := 'võidupüha';
		RETURN NEXT t_holiday;

		-- Midsummer Day
		t_holiday.datestamp := make_date(t_year, JUNE, 24);
		t_holiday.description := 'jaanipäev';
		RETURN NEXT t_holiday;

		-- Day of Restoration of Independence
		t_holiday.datestamp := make_date(t_year, AUGUST, 20);
		t_holiday.description := 'taasiseseisvumispäev';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'jõululaupäev';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'esimene jõulupüha';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'teine jõulupüha';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;