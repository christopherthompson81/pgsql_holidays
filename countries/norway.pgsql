------------------------------------------
------------------------------------------
-- Norway Holidays
-- 
-- Norwegian holidays.
-- Note that holidays falling on a sunday is 'lost',
-- it will not be moved to another day to make up for the collision.
-- 
-- In Norway, ALL sundays are considered a holiday (https://snl.no/helligdag).
-- Initialize this class with include_sundays=False
-- to not include sundays as a holiday.
-- 
-- Primary sources:
-- https://lovdata.no/dokument/NL/lov/1947-04-26-1
-- https://no.wikipedia.org/wiki/Helligdager_i_Norge
-- https://www.timeanddate.no/merkedag/norge/
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.norway(p_start_year INTEGER, p_end_year INTEGER)
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
	t_holiday_list DATE[];

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- ========= Static holidays =========
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Første nyttårsdag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Source: https://lovdata.no/dokument/NL/lov/1947-04-26-1
		IF t_year >= 1947 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Arbeidernes dag';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
			t_holiday.datestamp := make_date(t_year, MAY, 17);
			t_holiday.description := 'Grunnlovsdag';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		END IF;

		-- According to https://no.wikipedia.org/wiki/F%C3%B8rste_juledag,
		-- these dates are only valid from year > 1700
		-- Wikipedia has no source for the statement, so leaving this be for now
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Første juledag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Andre juledag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- ========= Moving holidays =========
		-- NOTE: These are probably subject to the same > 1700
		-- restriction as the above dates. The only source I could find for how
		-- long Easter has been celebrated in Norway was
		-- https://www.hf.uio.no/ikos/tjenester/kunnskap/samlinger/norsk-folkeminnesamling/livs-og-arshoytider/paske.html
		-- which says
		-- '(...) has been celebrated for over 1000 years (...)' (in Norway)
		t_datestamp := holidays.easter(t_year);
		
		-- maundy_thursday
		t_holiday.datestamp := t_datestamp - '3 Days'::INTERVAL;
		t_holiday.description := 'Skjærtorsdag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		
		--good_friday
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Langfredag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		--resurrection_sunday
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Første påskedag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		
		--easter_monday
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Andre påskedag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
				
		--ascension_thursday
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Kristi himmelfartsdag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
				
		--pentecost
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Første pinsedag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		
		--pentecost_day_two
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Andre pinsedag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Porting Modification!
		-- Add all the sundays of the year AFTER determining the 'real' holidays
		t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, 1, 1), SUNDAY, 1);
		LOOP
			IF NOT t_datestamp = ANY(t_holiday_list) THEN
				t_holiday.datestamp := t_datestamp;
				t_holiday.description := 'Søndag';
				RETURN NEXT t_holiday;
			END IF;
			t_datestamp := t_datestamp + '7 Days'::INTERVAL;
			EXIT WHEN t_datestamp >= make_date(t_year + 1, 1, 1);
		END LOOP;

	END LOOP;
END;

$$ LANGUAGE plpgsql;