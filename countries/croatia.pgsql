------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Croatia
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

		-- New years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nova Godina';
		RETURN NEXT t_holiday;
		-- Epiphany
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Sveta tri kralja';
		RETURN NEXT t_holiday;
		easter_date = easter(year)

		-- Easter
		self[easter_date] = 'Uskrs'
		-- Easter Monday
		self[easter_date + rd(days=1)] = 'Uskrsni ponedjeljak'

		-- Corpus Christi
		self[easter_date + rd(days=60)] = 'Tijelovo'

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Međunarodni praznik rada';
		RETURN NEXT t_holiday;

		-- Anti-fascist struggle day
		t_holiday.datestamp := make_date(t_year, JUN, 22);
		t_holiday.description := 'Dan antifašističke borbe';
		RETURN NEXT t_holiday;

		-- Statehood day
		t_holiday.datestamp := make_date(t_year, JUN, 25);
		t_holiday.description := 'Dan državnosti';
		RETURN NEXT t_holiday;

		-- Victory and Homeland Thanksgiving Day
		t_holiday.datestamp := make_date(t_year, AUG, 5);
		t_holiday.description := 'Dan pobjede i domovinske zahvalnosti';
		RETURN NEXT t_holiday;

		-- Assumption of Mary
		t_holiday.datestamp := make_date(t_year, AUG, 15);
		t_holiday.description := 'Velika Gospa';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, OCT, 8);
		t_holiday.description := 'Dan neovisnosti';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.datestamp := make_date(t_year, NOV, 1);
		t_holiday.description := 'Svi sveti';
		RETURN NEXT t_holiday;

		-- Christmas day
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Božić';
		RETURN NEXT t_holiday;

		-- St. Stephen's day
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Sveti Stjepan';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;