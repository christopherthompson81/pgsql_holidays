------------------------------------------
------------------------------------------
-- <country> Holidays
-- 
-- Contains all work-free public holidays in Slovenia.
-- No holidays are returned before year 1991 when Slovenia became independent
-- country. Before that Slovenia was part of Socialist federal republic of
-- Yugoslavia.
-- 
-- List of holidays (including those that are not work-free:
-- https://en.wikipedia.org/wiki/Public_holidays_in_Slovenia
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

		IF t_year <= 1990 THEN
			return

		IF t_year > 1991 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'novo leto';
			RETURN NEXT t_holiday;

			-- Between 2012 and 2017 2nd January was not public holiday,
			-- or at least not work-free day
			IF t_year < 2013 or year > 2016 THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 2);
				t_holiday.description := 'novo leto';
				RETURN NEXT t_holiday;

			-- Prešeren's day, slovenian cultural holiday
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 8);
			t_holiday.description := 'Prešernov dan';
			RETURN NEXT t_holiday;

			-- Easter monday is the only easter related work-free day
			easter_day = easter(year)
			self[easter_day + '1 Days'::INTERVAL] = 'Velikonočni ponedeljek'

			-- Day of uprising against occupation
			t_holiday.datestamp := make_date(t_year, APRIL, 27);
			t_holiday.description := 'dan upora proti okupatorju';
			RETURN NEXT t_holiday;

			-- Labour day, two days of it!
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'praznik dela';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'praznik dela';
			RETURN NEXT t_holiday;

			-- Statehood day
			t_holiday.datestamp := make_date(t_year, JUNE, 25);
			t_holiday.description := 'dan državnosti';
			RETURN NEXT t_holiday;

			-- Assumption day
			t_holiday.datestamp := make_date(t_year, AUGUST, 15);
			t_holiday.description := 'Marijino vnebovzetje';
			RETURN NEXT t_holiday;

			-- Reformation day
			t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
			t_holiday.description := 'dan reformacije';
			RETURN NEXT t_holiday;

			-- Remembrance day
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'dan spomina na mrtve';
			RETURN NEXT t_holiday;

			-- Christmas
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Božič';
			RETURN NEXT t_holiday;

			-- Day of independence and unity
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.description := 'dan samostojnosti in enotnosti';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;