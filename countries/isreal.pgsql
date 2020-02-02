------------------------------------------
------------------------------------------
-- <country> Holidays
-- from convertdate import hebrew
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

		is_leap_year = hebrew.leap(year + hebrew.HEBREW_YEAR_OFFSET)

		-- Passover
		t_holiday.description := 'Passover I';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.NISAN, 14)
		passover_start_dt = date(year, month, day)
		self[passover_start_dt] = name + ' - Eve'
		self[passover_start_dt + '1 Days'::INTERVAL] = name

		t_holiday.description := 'Passover';
		for offset in range(2, 6):
			self[passover_start_dt + rd(days=offset)] = name + ' - Chol HaMoed'

		t_holiday.description := 'Passover VII';
		self[passover_start_dt + '6 Days'::INTERVAL] = name + ' - Eve'
		self[passover_start_dt + '7 Days'::INTERVAL] = name

		-- Memorial Day
		t_holiday.description := 'Memorial Day';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 3)
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		observed_delta = 0
		IF self.observed THEN
			day_in_week = date(year, month, day).weekday()
			IF day_in_week in (2, 3) THEN
				observed_delta = - (day_in_week - 1)
			elIF 2004 <= year and day_in_week == 5 THEN
				observed_delta = 1

			IF observed_delta != 0 THEN
				t_holiday.datestamp := make_date(t_year, month, day) + rd(days=observed_delta + 1);
				RETURN NEXT t_holiday; + ' (Observed)'

		-- Independence Day
		t_holiday.description := 'Independence Day';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 4)
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		IF self.observed and observed_delta != 0 THEN
			t_holiday.datestamp := make_date(t_year, month, day) + rd(days=observed_delta + 1);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Lag Baomer
		t_holiday.description := 'Lag B''Omer';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 18)
		t_holiday.datestamp := make_date(t_year, month, day);
		RETURN NEXT t_holiday;

		-- Shavuot
		t_holiday.description := 'Shavuot';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.SIVAN, 5)
		t_holiday.datestamp := make_date(t_year, month, day);
		RETURN NEXT t_holiday; + ' - Eve'
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Rosh Hashana
		t_holiday.description := 'Rosh Hashanah';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.ELUL, 29)
		t_holiday.datestamp := make_date(t_year, month, day);
		RETURN NEXT t_holiday; + ' - Eve'
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, month, day) + '2 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Yom Kippur
		t_holiday.description := 'Yom Kippur';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.TISHRI, 9)
		t_holiday.datestamp := make_date(t_year, month, day);
		RETURN NEXT t_holiday; + ' - Eve'
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Sukkot
		t_holiday.description := 'Sukkot I';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.TISHRI, 14)
		sukkot_start_dt = date(year, month, day)
		self[sukkot_start_dt] = name + ' - Eve'
		self[sukkot_start_dt + '1 Days'::INTERVAL] = name

		t_holiday.description := 'Sukkot';
		for offset in range(2, 7):
			self[sukkot_start_dt + rd(days=offset)] = name + ' - Chol HaMoed'

		t_holiday.description := 'Sukkot VII';
		self[sukkot_start_dt + '7 Days'::INTERVAL] = name + ' - Eve'
		self[sukkot_start_dt + '8 Days'::INTERVAL] = name

		-- Hanukkah
		t_holiday.description := 'Hanukkah';
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.KISLEV, 25)
		for offset in range(8):
			t_holiday.datestamp := make_date(t_year, month, day) + rd(days=offset);
			RETURN NEXT t_holiday;

		-- Purim
		t_holiday.description := 'Purim';
		heb_month = hebrew.VEADAR if is_leap_year else hebrew.ADAR
		year, month, day = hebrew.to_jd_gregorianyear(year, heb_month, 14)
		t_holiday.datestamp := make_date(t_year, month, day);
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, month, day) - '1 Days'::INTERVAL;
		RETURN NEXT t_holiday; + ' - Eve'

		t_holiday.description := 'Shushan Purim';
		t_holiday.datestamp := make_date(t_year, month, day) + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;