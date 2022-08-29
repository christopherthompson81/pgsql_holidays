------------------------------------------
------------------------------------------
-- Netherlands Holidays
--
-- http://www.iamsterdam.com/en/plan-your-trip/practical-info/public-holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.netherlands(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'Nieuwjaarsdag';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Easter
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Eerste paasdag';
		RETURN NEXT t_holiday;

		-- Second easter day
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Tweede paasdag';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.reference := 'Ascension Day';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Hemelvaart';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Eerste Pinksterdag';
		RETURN NEXT t_holiday;

		-- Pentecost monday
		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Tweede Pinksterdag';
		RETURN NEXT t_holiday;

		-- First christmas
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Eerste Kerstdag';
		RETURN NEXT t_holiday;

		-- Second christmas
		t_holiday.reference := 'Second Day of Christmas';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Tweede Kerstdag';
		RETURN NEXT t_holiday;

		-- Liberation day
		t_holiday.reference := 'Liberation day';
		IF t_year >= 1945 AND t_year % 5 = 0 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 5);
			t_holiday.description := 'Bevrijdingsdag';
			RETURN NEXT t_holiday;
		END IF;

		-- King's Day
		t_holiday.reference := 'King''s Day';
		IF t_year >= 2014 THEN
			t_datestamp :=  make_date(t_year, APRIL, 27);
			t_holiday.description := 'Koningsdag';
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.observation_shifted := TRUE;
				t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
			ELSE
				t_holiday.datestamp := t_datestamp;
			END IF;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Queen's Day
		t_holiday.reference := 'Queen''s Day';
		IF t_year BETWEEN 1891 AND 2013 THEN
			t_holiday.description := 'Koninginnedag';
			IF t_year <= 1948 THEN
				t_datestamp := make_date(t_year, AUGUST, 31);
			ELSE
				t_datestamp := make_date(t_year, APRIL, 30);
			END IF;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.observation_shifted := TRUE;
				IF t_year < 1980 THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
				ELSE
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
				END IF;
			END IF;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;