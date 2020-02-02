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
		name = 'Passover I'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.NISAN, 14)
		passover_start_dt = date(year, month, day)
		self[passover_start_dt] = name + ' - Eve'
		self[passover_start_dt + rd(days=1)] = name

		name = 'Passover'
		for offset in range(2, 6):
			self[passover_start_dt + rd(days=offset)] = name + ' - Chol HaMoed'

		name = 'Passover VII'
		self[passover_start_dt + rd(days=6)] = name + ' - Eve'
		self[passover_start_dt + rd(days=7)] = name

		-- Memorial Day
		name = 'Memorial Day'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 3)
		self[date(year, month, day) + rd(days=1)] = name

		observed_delta = 0
		if self.observed:
			day_in_week = date(year, month, day).weekday()
			if day_in_week in (2, 3):
				observed_delta = - (day_in_week - 1)
			elif 2004 <= year and day_in_week == 5:
				observed_delta = 1

			if observed_delta != 0:
				self[date(year, month, day) + rd(days=observed_delta + 1)] = name + ' (Observed)'

		-- Independence Day
		name = 'Independence Day'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 4)
		self[date(year, month, day) + rd(days=1)] = name

		if self.observed and observed_delta != 0:
			self[date(year, month, day) + rd(days=observed_delta + 1)] = name + ' (Observed)'

		-- Lag Baomer
		name = 'Lag B''Omer'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.IYYAR, 18)
		self[date(year, month, day)] = name

		-- Shavuot
		name = 'Shavuot'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.SIVAN, 5)
		self[date(year, month, day)] = name + ' - Eve'
		self[date(year, month, day) + rd(days=1)] = name

		-- Rosh Hashana
		name = 'Rosh Hashanah'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.ELUL, 29)
		self[date(year, month, day)] = name + ' - Eve'
		self[date(year, month, day) + rd(days=1)] = name
		self[date(year, month, day) + rd(days=2)] = name

		-- Yom Kippur
		name = 'Yom Kippur'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.TISHRI, 9)
		self[date(year, month, day)] = name + ' - Eve'
		self[date(year, month, day) + rd(days=1)] = name

		-- Sukkot
		name = 'Sukkot I'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.TISHRI, 14)
		sukkot_start_dt = date(year, month, day)
		self[sukkot_start_dt] = name + ' - Eve'
		self[sukkot_start_dt + rd(days=1)] = name

		name = 'Sukkot'
		for offset in range(2, 7):
			self[sukkot_start_dt + rd(days=offset)] = name + ' - Chol HaMoed'

		name = 'Sukkot VII'
		self[sukkot_start_dt + rd(days=7)] = name + ' - Eve'
		self[sukkot_start_dt + rd(days=8)] = name

		-- Hanukkah
		name = 'Hanukkah'
		year, month, day = hebrew.to_jd_gregorianyear(year, hebrew.KISLEV, 25)
		for offset in range(8):
			self[date(year, month, day) + rd(days=offset)] = name

		-- Purim
		name = 'Purim'
		heb_month = hebrew.VEADAR if is_leap_year else hebrew.ADAR
		year, month, day = hebrew.to_jd_gregorianyear(year, heb_month, 14)
		self[date(year, month, day)] = name

		self[date(year, month, day) - rd(days=1)] = name + ' - Eve'

		name = 'Shushan Purim'
		self[date(year, month, day) + rd(days=1)] = name

	END LOOP;
END;

$$ LANGUAGE plpgsql;