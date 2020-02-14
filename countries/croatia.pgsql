------------------------------------------
------------------------------------------
-- Croatia Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Croatia
-- https://publicholidays.com.hr/2020-dates/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.croatia(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nova Godina';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Sveta tri kralja';
		RETURN NEXT t_holiday;

		-- Easter
		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Uskrs';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Uskrsni ponedjeljak';
		RETURN NEXT t_holiday;

		-- Corpus Christi
		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Tijelovo';
		RETURN NEXT t_holiday;

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Međunarodni praznik rada';
		RETURN NEXT t_holiday;

		-- Anti-fascist struggle day
		t_holiday.datestamp := make_date(t_year, JUNE, 22);
		t_holiday.description := 'Dan antifašističke borbe';
		RETURN NEXT t_holiday;

		-- Statehood Day
		-- Memorial Day
		IF t_year < 2020 THEN
			-- Statehood Day
			t_holiday.datestamp := make_date(t_year, JUNE, 25);
			t_holiday.description := 'Dan državnosti';
			RETURN NEXT t_holiday;
		ELSE
			-- Memorial Day
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 18);
			t_holiday.description := 'Dan sjećanja';
			RETURN NEXT t_holiday;
		END IF;

		-- Victory and Homeland Thanksgiving Day
		t_holiday.datestamp := make_date(t_year, AUGUST, 5);
		t_holiday.description := 'Dan pobjede i domovinske zahvalnosti';
		RETURN NEXT t_holiday;

		-- Assumption of Mary
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Velika Gospa';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, OCTOBER, 8);
		t_holiday.description := 'Dan neovisnosti';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Svi sveti';
		RETURN NEXT t_holiday;

		-- Christmas day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Božić';
		RETURN NEXT t_holiday;

		-- St. Stephen's day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Sveti Stjepan';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;