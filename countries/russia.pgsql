------------------------------------------
------------------------------------------
-- Russia Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Russia
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.russia(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 2);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 3);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 4);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 5);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- Christmas Day (Orthodox)
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		t_holiday.description := 'Православное Рождество';
		RETURN NEXT t_holiday;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 8);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- Man Day
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 23);
		t_holiday.description := 'День защитника отечества';
		RETURN NEXT t_holiday;

		-- Women's Day
		t_holiday.datestamp := make_date(t_year, MARCH, 8);
		t_holiday.description := 'День женщин';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Праздник Весны и Труда';
		RETURN NEXT t_holiday;

		-- Victory Day
		t_holiday.datestamp := make_date(t_year, MAY, 9);
		t_holiday.description := 'День Победы';
		RETURN NEXT t_holiday;

		-- Russia's Day
		t_holiday.datestamp := make_date(t_year, JUNE, 12);
		t_holiday.description := 'День России';
		RETURN NEXT t_holiday;
		
		-- Unity Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 4);
		t_holiday.description := 'День народного единства';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;