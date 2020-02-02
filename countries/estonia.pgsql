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

e = easter(year)

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'uusaasta';
		RETURN NEXT t_holiday;

		-- Independence Day, anniversary of the Republic of Estonia
		t_holiday.datestamp := make_date(t_year, FEB, 24);
		t_holiday.description := 'iseseisvuspäev';
		RETURN NEXT t_holiday;

		-- Good Friday
		self[e - rd(days=2)] = 'suur reede'

		-- Easter Sunday
		self[e] = 'ülestõusmispühade 1. püha'

		-- Spring Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'kevadpüha';
		RETURN NEXT t_holiday;

		-- Pentecost
		self[e + rd(days=49)] = 'nelipühade 1. püha'

		-- Victory Day
		t_holiday.datestamp := make_date(t_year, JUN, 23);
		t_holiday.description := 'võidupüha';
		RETURN NEXT t_holiday;

		-- Midsummer Day
		t_holiday.datestamp := make_date(t_year, JUN, 24);
		t_holiday.description := 'jaanipäev';
		RETURN NEXT t_holiday;

		-- Day of Restoration of Independence
		t_holiday.datestamp := make_date(t_year, AUG, 20);
		t_holiday.description := 'taasiseseisvumispäev';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		t_holiday.datestamp := make_date(t_year, DEC, 24);
		t_holiday.description := 'jõululaupäev';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'esimene jõulupüha';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'teine jõulupüha';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;