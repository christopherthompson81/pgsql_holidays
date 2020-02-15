------------------------------------------
------------------------------------------
-- Swedish Holidays
-- 
-- Note that holidays falling on a sunday are 'lost',
-- it will not be moved to another day to make up for the collision.
-- In Sweden, ALL sundays are considered a holiday
-- (https://sv.wikipedia.org/wiki/Helgdagar_i_Sverige).
-- Initialize this class with include_sundays=False
-- to not include sundays as a holiday.
-- Primary sources:
-- https://sv.wikipedia.org/wiki/Helgdagar_i_Sverige and
-- http://www.riksdagen.se/sv/dokument-lagar/dokument/svensk-forfattningssamling/lag-1989253-om-allmanna-helgdagar_sfs-1989-253
-- 
-- :param include_sundays: Whether to consider sundays as a holiday
-- (which they are in Sweden)
-- :param kwargs:
-- 
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.sweden(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nyårsdagen';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Trettondedag jul';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Source: https://sv.wikipedia.org/wiki/F%C3%B6rsta_maj

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		IF t_year >= 1939 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Första maj';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		END IF;

		-- Source: https://sv.wikipedia.org/wiki/Sveriges_nationaldag

		-- National Day
		t_holiday.reference := 'National Day';
		IF t_year >= 2005 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 6);
			t_holiday.description := 'Sveriges nationaldag';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		END IF;

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Julafton';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Juldagen';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Second Day of Christmas
		t_holiday.reference := 'Second Day of Christmas';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Annandag jul';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Nyårsafton';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- ========= Moving holidays =========

		t_datestamp := holidays.easter(t_year);

		-- Never Observed?
		-- maundy_thursday = e - rd(days=3)

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Långfredagen';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Never Observed?
		-- easter_saturday = e - rd(days=1)
		
		-- Resurrection Sunday
		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Påskdagen';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		t_holiday.description := 'Annandag påsk';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Ascension Thursday
		t_holiday.reference := 'Ascension';
		t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
		t_holiday.description := 'Kristi himmelsfärdsdag';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pingstdagen';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);

		-- Pentecost Day Two
		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		IF t_year <= 2004 THEN	
			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			t_holiday.description := 'Annandag pingst';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday.datestamp);
		END IF;
		
		-- Midsummer evening. Friday between June 19th and June 25th
		t_holiday.reference := 'Midsummer Evening';
		t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, JUNE, 19), FRIDAY, 1);
		t_holiday.description = 'Midsommarafton';
		RETURN NEXT t_holiday;

		-- Midsummer Day. Saturday between June 20th and June 26th
		t_holiday.reference := 'Midsummer Day';
		IF t_year >= 1953 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, JUNE, 20), SATURDAY, 1);
			t_holiday.description = 'Midsommardagen';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'Midsommardagen';
			RETURN NEXT t_holiday;
		END IF;
		
		-- All Saints' Day. Friday between October 31th and November 6th
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 31), SATURDAY, 1);
		t_holiday.description = 'Alla helgons dag';
		RETURN NEXT t_holiday;

		-- Annunciation Day
		t_holiday.reference := 'Annunciation Day';
		IF t_year <= 1953 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 25);
			t_holiday.description := 'Jungfru Marie bebådelsedag';
			RETURN NEXT t_holiday;
		END IF;

		-- Porting Modification!
		-- Add all the sundays of the year AFTER determining the 'real' holidays
		t_holiday.reference := 'Sunday';
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