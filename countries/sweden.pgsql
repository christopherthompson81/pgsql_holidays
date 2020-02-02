------------------------------------------
------------------------------------------
-- Swedish holidays.
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

				self[cur_date] = 'Söndag'
				cur_date += rd(days=7)

		-- ========= Static holidays =========
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nyårsdagen';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Trettondedag jul';
		RETURN NEXT t_holiday;

		-- Source: https://sv.wikipedia.org/wiki/F%C3%B6rsta_maj
		IF t_year >= 1939 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Första maj';
			RETURN NEXT t_holiday;

		-- Source: https://sv.wikipedia.org/wiki/Sveriges_nationaldag
		IF t_year >= 2005 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 6);
			t_holiday.description := 'Sveriges nationaldag';
			RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Julafton';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Juldagen';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Annandag jul';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Nyårsafton';
		RETURN NEXT t_holiday;

		-- ========= Moving holidays =========
		e = easter(year)
		maundy_thursday = e - rd(days=3)
		good_friday = e - rd(days=2)
		easter_saturday = e - rd(days=1)
		resurrection_sunday = e
		easter_monday = e + rd(days=1)
		ascension_thursday = e + rd(days=39)
		pentecost = e + rd(days=49)
		pentecost_day_two = e + rd(days=50)

		assert maundy_thursday.weekday() == THU
		assert good_friday.weekday() == FRI
		assert easter_saturday.weekday() == SAT
		assert resurrection_sunday.weekday() == SUN
		assert easter_monday.weekday() == MON
		assert ascension_thursday.weekday() == THU
		assert pentecost.weekday() == SUN
		assert pentecost_day_two.weekday() == MON

		self[good_friday] = 'Långfredagen'
		self[resurrection_sunday] = 'Påskdagen'
		self[easter_monday] = 'Annandag påsk'
		self[ascension_thursday] = 'Kristi himmelsfärdsdag'
		self[pentecost] = 'Pingstdagen'
		IF t_year <= 2004 THEN
			self[pentecost_day_two] = 'Annandag pingst'

		-- Midsummer evening. Friday between June 19th and June 25th
		self[date(year, JUNE, 19) + rd(weekday=FR)] = 'Midsommarafton'

		-- Midsummer day. Saturday between June 20th and June 26th
		IF t_year >= 1953 THEN
			self[date(year, JUNE, 20) + rd(weekday=SA)] = 'Midsommardagen'
		ELSE
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'Midsommardagen';
			RETURN NEXT t_holiday;
		
		-- All saints day. Friday between October 31th and November 6th
		self[date(year, OCTOBER, 31) + rd(weekday=SA)] = 'Alla helgons dag'

		IF t_year <= 1953 THEN
			t_holiday.datestamp := make_date(t_year, MAR, 25);
			t_holiday.description := 'Jungfru Marie bebådelsedag';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;