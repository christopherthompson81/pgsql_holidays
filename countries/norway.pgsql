------------------------------------------
------------------------------------------
-- <country> Holidays
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
-- 
-- 
-- 
-- :param include_sundays: Whether to consider sundays as a holiday
-- (which they are in Norway)
-- :param kwargs:
--
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

		-- Add all the sundays of the year before adding the 'real' holidays
		IF self.include_sundays THEN
			first_day_of_year = date(year, JANUARY, 1)
			first_sunday_of_year = first_day_of_year + rd(days=SUN - first_day_of_year.weekday())
			cur_date = first_sunday_of_year

			while cur_date < date(year + 1, 1, 1):
				assert cur_date.weekday() == SUN

				self[cur_date] = 'Søndag'
				cur_date += rd(days=7)
		END IF;

		-- ========= Static holidays =========
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Første nyttårsdag';
		RETURN NEXT t_holiday;

		-- Source: https://lovdata.no/dokument/NL/lov/1947-04-26-1
		IF t_year >= 1947 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Arbeidernes dag';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 17);
			t_holiday.description := 'Grunnlovsdag';
			RETURN NEXT t_holiday;
		END IF;

		-- According to https://no.wikipedia.org/wiki/F%C3%B8rste_juledag,
		-- these dates are only valid from year > 1700
		-- Wikipedia has no source for the statement, so leaving this be for now
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Første juledag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Andre juledag';
		RETURN NEXT t_holiday;

		-- ========= Moving holidays =========
		-- NOTE: These are probably subject to the same > 1700
		-- restriction as the above dates. The only source I could find for how
		-- long Easter has been celebrated in Norway was
		-- https://www.hf.uio.no/ikos/tjenester/kunnskap/samlinger/norsk-folkeminnesamling/livs-og-arshoytider/paske.html
		-- which says
		-- '(...) has been celebrated for over 1000 years (...)' (in Norway)
		e = easter(year)
		maundy_thursday = e - '3 Days'::INTERVAL
		good_friday = e - '2 Days'::INTERVAL
		resurrection_sunday = e
		easter_monday = e + '1 Days'::INTERVAL
		ascension_thursday = e + '39 Days'::INTERVAL
		pentecost = e + '49 Days'::INTERVAL
		pentecost_day_two = e + '50 Days'::INTERVAL

		assert maundy_thursday.weekday() == THU
		assert good_friday.weekday() == FRI
		assert resurrection_sunday.weekday() == SUN
		assert easter_monday.weekday() == MON
		assert ascension_thursday.weekday() == THU
		assert pentecost.weekday() == SUN
		assert pentecost_day_two.weekday() == MON

		self[maundy_thursday] = 'Skjærtorsdag'
		self[good_friday] = 'Langfredag'
		self[resurrection_sunday] = 'Første påskedag'
		self[easter_monday] = 'Andre påskedag'
		self[ascension_thursday] = 'Kristi himmelfartsdag'
		self[pentecost] = 'Første pinsedag'
		self[pentecost_day_two] = 'Andre pinsedag'

	END LOOP;
END;

$$ LANGUAGE plpgsql;