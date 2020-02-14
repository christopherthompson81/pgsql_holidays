------------------------------------------
------------------------------------------
-- Serbia Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Serbia
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.serbia(p_start_year INTEGER, p_end_year INTEGER)
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
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Нова година';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'Нова година (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Orthodox Christmas
		t_holiday.description := 'Божић';
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		RETURN NEXT t_holiday;

		-- Statehood day
		t_datestamp := make_date(t_year, FEBRUARY, 15);
		t_holiday.description := 'Дан државности Србије';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'Дан државности Србије (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- International Workers' Day
		t_datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Празник рада';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'Празник рада (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Armistice day
		t_datestamp := make_date(t_year, NOVEMBER, 11);
		t_holiday.description := 'Дан примирја у Првом светском рату';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 12);
			t_holiday.description := 'Дан примирја у Првом светском рату (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter
		t_datestamp := holidays.easter(t_year, 'EASTER_ORTHODOX');

		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Велики петак';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
		t_holiday.description := 'Велика субота';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Васкрс';
		RETURN NEXT t_holiday;
		
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Други дан Васкрса';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;