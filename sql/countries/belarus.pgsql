------------------------------------------
------------------------------------------
-- Belarus Holidays
--
-- http://president.gov.by/en/holidays_en/
-- http://www.belarus.by/en/about-belarus/national-holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.belarus(p_start_year INTEGER, p_end_year INTEGER)
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
		-- The current set of holidays came into force in 1998
		-- http://laws.newsby.org/documents/ukazp/pos05/ukaz05806.htm
		IF t_year <= 1998 THEN
			RETURN;
		END IF;

		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Новый год';
		RETURN NEXT t_holiday;

		-- Jan 2nd is the national holiday (New Year) from 2020
		-- http://president.gov.by/uploads/documents/2019/464uk.pdf
		IF t_year >= 2020 THEN
			-- New Year's Day
			t_holiday.datestamp := make_date(t_year, JANUARY, 2);
			t_holiday.description := 'Новый год';
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Day (Orthodox)
		t_holiday.reference := 'Christmas Day (Orthodox)';
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		t_holiday.description := 'Рождество Христово (православное Рождество)';
		RETURN NEXT t_holiday;

		-- Women's Day
		t_holiday.reference := 'Women''s Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 8);
		t_holiday.description := 'День женщин';
		RETURN NEXT t_holiday;

		-- Radunitsa ('Day of Rejoicing')
		t_holiday.reference := 'Day of Rejoicing';
		t_datestamp := holidays.easter(t_year, p_method => 'EASTER_ORTHODOX');
		t_holiday.datestamp := t_datestamp + '9 Days'::INTERVAL;
		t_holiday.description := 'Радуница';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Праздник труда';
		RETURN NEXT t_holiday;

		-- Victory Day
		t_holiday.reference := 'Victory Day';
		t_holiday.datestamp := make_date(t_year, MAY, 9);
		t_holiday.description := 'День Победы';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independance Day';
		t_holiday.datestamp := make_date(t_year, JULY, 3);
		t_holiday.description := 'День Независимости Республики Беларусь (День Республики)';
		RETURN NEXT t_holiday;

		-- October Revolution Day
		t_holiday.reference := 'Revolution Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 7);
		t_holiday.description := 'День Октябрьской революции';
		RETURN NEXT t_holiday;

		-- Christmas Day (Catholic)
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Рождество Христово (католическое Рождество)';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;