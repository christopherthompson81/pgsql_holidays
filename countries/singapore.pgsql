------------------------------------------
------------------------------------------
-- <country> Holidays
-- Holidays Act: https://sso.agc.gov.sg/Act/HA1998
-- https://www.mom.gov.sg/employment-practices/public-holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Singapore

-- Holidays prior to 1969 (Act 24 of 1968—Holidays (Amendment) Act 1968)
-- are estimated.

-- Holidays prior to 2000 may not be accurate.

-- Holidays after 2020: the following four moving date holidays whose exact
-- date is announced yearly are estimated (and so denoted):
-- - Hari Raya Puasa*
-- - Hari Raya Haji*
-- - Vesak Day
-- - Deepavali
--
-- * only if hijri-converter library is installed, otherwise a warning is
--  raised that this holiday is missing.
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

		def storeholiday(self, hol_date, hol_name):x
			-- Function to store the holiday name in the appropriate
			-- date and to implement Section 4(2) of the Holidays Act:
			-- 'if any day specified in the Schedule falls on a Sunday,
			-- the day next following not being itself a public holiday
			-- is declared a public holiday in Singapore.'
			IF hol_date.weekday() == SUN THEN
				self[hol_date] = hol_name + ' [Sunday]'
				self[hol_date + '+1 Days'::INTERVAL] = 'Monday following ' + hol_name
			ELSE
				self[hol_date] = hol_name

		-- New Year's Day
		storeholiday(self, date(year, JANUARY, 1), 'New Year''s Day')

		-- Chinese New Year (two days)
		hol_date = self.get_lunar_n_y_date(year)
		self[hol_date] = 'Chinese New Year'
		storeholiday(self, hol_date + rd(days=+1), 'Chinese New Year')

		-- Hari Raya Puasa
		-- aka Eid al-Fitr
		-- date of observance is announced yearly
		dates_obs = {2001: [(DECEMBER, 16)], 2002: [(DECEMBER, 6)],
					 2003: [(NOVEMBER, 25)], 2004: [(NOVEMBER, 14)], 2005: [(NOVEMBER, 3)],
					 2006: [(OCTOBER, 24)], 2007: [(OCTOBER, 13)], 2008: [(OCTOBER, 1)],
					 2009: [(SEPTEMBER, 20)], 2010: [(SEPTEMBER, 10)], 2011: [(AUGUST, 30)],
					 2012: [(AUGUST, 19)], 2013: [(AUGUST, 8)], 2014: [(JULY, 28)],
					 2015: [(JULY, 17)], 2016: [(JULY, 6)], 2017: [(JUNE, 25)],
					 2018: [(JUNE, 15)], 2019: [(JUNE, 5)], 2020: [(MAY, 24)]}
		IF t_year in dates_obs THEN
			for date_obs in dates_obs[year]:
				hol_date = date(year, *date_obs)
				storeholiday(self, hol_date, 'Hari Raya Puasa')
				-- Second day of Hari Raya Puasa (up to and including 1968)
				-- Removed since we don't have Hari Raya Puasa dates for the
				-- the years <= 1968:
				-- if year <= 1968:
				--	 storeholiday(self, hol_date + rd(days=+1),
				--				  'Second day of Hari Raya Puasa')
		ELSE
			for date_obs in self.get_hrp_date(year):
				hol_date = date_obs
				storeholiday(self, hol_date,
							 'Hari Raya Puasa* (*estimated)')
				-- Second day of Hari Raya Puasa (up to and including 1968)
				IF t_year <= 1968 THEN
					storeholiday(self, hol_date + '+1 Days'::INTERVAL,
								 'Second day of Hari Raya Puasa* (*estimated)')

		-- Hari Raya Haji
		-- aka Eid al-Adha
		-- date of observance is announced yearly
		dates_obs = {2001: [(MARCH, 6)], 2002: [(FEBRUARY, 23)],
					 2003: [(FEBRUARY, 12)], 2004: [(FEBRUARY, 1)], 2005: [(JANUARY, 21)],
					 2006: [(JANUARY, 10)], 2007: [(DECEMBER, 20)], 2008: [(DECEMBER, 8)],
					 2009: [(NOVEMBER, 27)], 2010: [(NOVEMBER, 17)], 2011: [(NOVEMBER, 6)],
					 2012: [(OCTOBER, 26)], 2013: [(OCTOBER, 15)], 2014: [(OCTOBER, 5)],
					 2015: [(SEPTEMBER, 24)], 2016: [(SEPTEMBER, 12)], 2017: [(SEPTEMBER, 1)],
					 2018: [(AUGUST, 22)], 2019: [(AUGUST, 11)], 2020: [(JULY, 31)]}
		IF t_year in dates_obs THEN
			for date_obs in dates_obs[year]:
				hol_date = date(year, *date_obs)
				storeholiday(self, hol_date,
							 'Hari Raya Haji')
		ELSE
			for date_obs in self.get_hrh_date(year):
				hol_date = date_obs
				storeholiday(self, hol_date,
							 'Hari Raya Haji* (*estimated)')

		-- Holy Saturday (up to and including 1968)
		IF t_year <= 1968 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), SA, -1);
			t_holiday.description := 'Holy Saturday';
			RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		-- Easter Monday
		IF t_year <= 1968 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), MO, 1);
			t_holiday.description := 'Easter Monday';
			RETURN NEXT t_holiday;

		-- Labour Day
		storeholiday(self, date(year, MAY, 1), 'Labour Day')

		-- Vesak Day
		-- date of observance is announced yearly
		-- https://en.wikipedia.org/wiki/Vesak--Dates_of_observance
		dates_obs = {2001: (MAY, 7), 2002: (MAY, 27),
					 2003: (MAY, 15), 2004: (JUNE, 2), 2005: (MAY, 23),
					 2006: (MAY, 12), 2007: (MAY, 31), 2008: (MAY, 19),
					 2009: (MAY, 9), 2010: (MAY, 28), 2011: (MAY, 17),
					 2012: (MAY, 5), 2013: (MAY, 24), 2014: (MAY, 13),
					 2015: (JUNE, 1), 2016: (MAY, 20), 2017: (MAY, 10),
					 2018: (MAY, 29), 2019: (MAY, 19), 2020: (MAY, 7)}
		IF t_year in dates_obs THEN
			hol_date = date(year, *dates_obs[year])
			storeholiday(self, hol_date, 'Vesak Day')
		ELSE
			storeholiday(self, self.get_vesak_date(year),
						 'Vesak Day* (*estimated; ~10% chance +/- 1 day)')

		-- National Day
		storeholiday(self, date(year, AUGUST, 9), 'National Day')

		-- Deepavali
		-- aka Diwali
		-- date of observance is announced yearly
		dates_obs = {2001: (NOVEMBER, 14), 2002: (NOVEMBER, 3),
					 2003: (OCTOBER, 23), 2004: (NOVEMBER, 11), 2005: (NOVEMBER, 1),
					 2006: (OCTOBER, 21), 2007: (NOVEMBER, 8), 2008: (OCTOBER, 27),
					 2009: (OCTOBER, 17), 2010: (NOVEMBER, 5), 2011: (OCTOBER, 26),
					 2012: (NOVEMBER, 13), 2013: (NOVEMBER, 2), 2014: (OCTOBER, 22),
					 2015: (NOVEMBER, 10), 2016: (OCTOBER, 29), 2017: (OCTOBER, 18),
					 2018: (NOVEMBER, 6), 2019: (OCTOBER, 27), 2020: (NOVEMBER, 14)}
		IF t_year in dates_obs THEN
			hol_date = date(year, *dates_obs[year])
			storeholiday(self, hol_date, 'Deepavali')
		ELSE
			storeholiday(self, self.get_s_diwali_date(year), 'Deepavali* (*estimated; rarely on day after)')

		-- Christmas Day
		storeholiday(self, date(year, DECEMBER, 25), 'Christmas Day')

		-- Boxing day (up to and including 1968)
		IF t_year <= 1968 THEN
			storeholiday(self, date(year, DECEMBER, 26), 'Boxing Day')

		-- Polling Day
		dates_obs = {2001: (NOVEMBER, 3), 2006: (MAY, 6),
					 2011: (MAY, 7), 2015: (SEPTEMBER, 11)}
		IF t_year in dates_obs THEN
			self[date(year, *dates_obs[year])] = 'Polling Day'

		-- SG50 Public holiday
		-- Announced on 14 March 2015
		-- https://www.mom.gov.sg/newsroom/press-releases/2015/sg50-public-holiday-on-7-august-2015
		IF t_year == 2015 THEN
			self[date(2015, AUGUST, 7)] = 'SG50 Public Holiday'

	-- The below is used to calcluate lunar new year (i.e. Chinese new year)
	-- Code borrowed from Hong Kong entry as of 16-Nov-19
	-- Should probably be a function available to multiple countries

	-- Store the number of days per year from 1901 to 2099, and the number of
	-- days from the 1st to the 13th to store the monthly (including the month
	-- of the month), 1 means that the month is 30 days. 0 means the month is
	-- 29 days. The 12th to 15th digits indicate the month of the next month.
	-- If it is 0x0F, it means that there is no leap month.
	g_lunar_month_days = [
		0xF0EA4, 0xF1D4A, 0x52C94, 0xF0C96, 0xF1536,
		0x42AAC, 0xF0AD4, 0xF16B2, 0x22EA4, 0xF0EA4,  -- 1901-1910
		0x6364A, 0xF164A, 0xF1496, 0x52956, 0xF055A,
		0xF0AD6, 0x216D2, 0xF1B52, 0x73B24, 0xF1D24,  -- 1911-1920
		0xF1A4A, 0x5349A, 0xF14AC, 0xF056C, 0x42B6A,
		0xF0DA8, 0xF1D52, 0x23D24, 0xF1D24, 0x61A4C,  -- 1921-1930
		0xF0A56, 0xF14AE, 0x5256C, 0xF16B4, 0xF0DA8,
		0x31D92, 0xF0E92, 0x72D26, 0xF1526, 0xF0A56,  -- 1931-1940
		0x614B6, 0xF155A, 0xF0AD4, 0x436AA, 0xF1748,
		0xF1692, 0x23526, 0xF152A, 0x72A5A, 0xF0A6C,  -- 1941-1950
		0xF155A, 0x52B54, 0xF0B64, 0xF1B4A, 0x33A94,
		0xF1A94, 0x8152A, 0xF152E, 0xF0AAC, 0x6156A,  -- 1951-1960
		0xF15AA, 0xF0DA4, 0x41D4A, 0xF1D4A, 0xF0C94,
		0x3192E, 0xF1536, 0x72AB4, 0xF0AD4, 0xF16D2,  -- 1961-1970
		0x52EA4, 0xF16A4, 0xF164A, 0x42C96, 0xF1496,
		0x82956, 0xF055A, 0xF0ADA, 0x616D2, 0xF1B52,  -- 1971-1980
		0xF1B24, 0x43A4A, 0xF1A4A, 0xA349A, 0xF14AC,
		0xF056C, 0x60B6A, 0xF0DAA, 0xF1D92, 0x53D24,  -- 1981-1990
		0xF1D24, 0xF1A4C, 0x314AC, 0xF14AE, 0x829AC,
		0xF06B4, 0xF0DAA, 0x52D92, 0xF0E92, 0xF0D26,  -- 1991-2000
		0x42A56, 0xF0A56, 0xF14B6, 0x22AB4, 0xF0AD4,
		0x736AA, 0xF1748, 0xF1692, 0x53526, 0xF152A,  -- 2001-2010
		0xF0A5A, 0x4155A, 0xF156A, 0x92B54, 0xF0BA4,
		0xF1B4A, 0x63A94, 0xF1A94, 0xF192A, 0x42A5C,  -- 2011-2020
		0xF0AAC, 0xF156A, 0x22B64, 0xF0DA4, 0x61D52,
		0xF0E4A, 0xF0C96, 0x5192E, 0xF1956, 0xF0AB4,  -- 2021-2030
		0x315AC, 0xF16D2, 0xB2EA4, 0xF16A4, 0xF164A,
		0x63496, 0xF1496, 0xF0956, 0x50AB6, 0xF0B5A,  -- 2031-2040
		0xF16D4, 0x236A4, 0xF1B24, 0x73A4A, 0xF1A4A,
		0xF14AA, 0x5295A, 0xF096C, 0xF0B6A, 0x31B54,  -- 2041-2050
		0xF1D92, 0x83D24, 0xF1D24, 0xF1A4C, 0x614AC,
		0xF14AE, 0xF09AC, 0x40DAA, 0xF0EAA, 0xF0E92,  -- 2051-2060
		0x31D26, 0xF0D26, 0x72A56, 0xF0A56, 0xF14B6,
		0x52AB4, 0xF0AD4, 0xF16CA, 0x42E94, 0xF1694,  -- 2061-2070
		0x8352A, 0xF152A, 0xF0A5A, 0x6155A, 0xF156A,
		0xF0B54, 0x4174A, 0xF1B4A, 0xF1A94, 0x3392A,  -- 2071-2080
		0xF192C, 0x7329C, 0xF0AAC, 0xF156A, 0x52B64,
		0xF0DA4, 0xF1D4A, 0x41C94, 0xF0C96, 0x8192E,  -- 2081-2090
		0xF0956, 0xF0AB6, 0x615AC, 0xF16D4, 0xF0EA4,
		0x42E4A, 0xF164A, 0xF1516, 0x22936,		   -- 2090-2099
	]
	-- Define range of years
	START_YEAR, END_YEAR = 1901, 1900 + len(g_lunar_month_days)
	-- 1901 The 1st day of the 1st month of the Gregorian calendar is 1901/2/19
	LUNAR_START_DATE, SOLAR_START_DATE = (1901, 1, 1), date(1901, 2, 19)
	-- The Gregorian date for December 30, 2099 is 2100/2/8
	LUNAR_END_DATE, SOLAR_END_DATE = (2099, 12, 30), date(2100, 2, 18)

	def get_leap_month(self, lunar_year):
		return (self.g_lunar_month_days[lunar_year - self.START_YEAR] >> 16) & 0x0F

	def lunar_month_days(self, lunar_year, lunar_month):
		return 29 + ((self.g_lunar_month_days[lunar_year - self.START_YEAR] >>
					  lunar_month) & 0x01)

	def lunar_year_days(self, year):
		days = 0
		months_day = self.g_lunar_month_days[year - self.START_YEAR]
		for i in range(1, 13 if self.get_leap_month(year) == 0x0F else 14):
			day = 29 + ((months_day >> i) & 0x01)
			days += day
		return days

	-- Calculate Gregorian date of lunar new year
	def get_lunar_n_y_date(self, year):
		span_days = 0
		for y in range(self.START_YEAR, year):
			span_days += self.lunar_year_days(y)
		-- Always in first month (by definition)
		-- leap_month = self.get_leap_month(year)
		-- for m in range(1, 1 + (1 > leap_month)):
		--	 span_days += self.lunar_month_days(year, m)
		return self.SOLAR_START_DATE + timedelta(span_days)

	-- Estimate Gregorian date of Vesak
	def get_vesak_date(self, year):
		span_days = 0
		for y in range(self.START_YEAR, year):
			span_days += self.lunar_year_days(y)
		leap_month = self.get_leap_month(year)
		for m in range(1, 4 + (4 > leap_month)):
			span_days += self.lunar_month_days(year, m)
		span_days += 14
		return (self.SOLAR_START_DATE + timedelta(span_days))

	-- Estimate Gregorian date of Southern India Diwali
	def get_s_diwali_date(self, year):
		span_days = 0
		for y in range(self.START_YEAR, year):
			span_days += self.lunar_year_days(y)
		leap_month = self.get_leap_month(year)
		for m in range(1, 10 + (10 > leap_month)):
			span_days += self.lunar_month_days(year, m)
		span_days -= 2
		return (self.SOLAR_START_DATE + timedelta(span_days))

	-- Estimate Gregorian date(s) of Hara Rasa Puasa
	def get_hrp_date(self, year):
		try:
			from hijri_converter import convert
		except ImportError:
			import warnings

			def warning_on_one_line(message, category, filename,
									lineno, file=None, line=None):
				return filename + ': ' + str(message) + '\n'
			warnings.formatwarning = warning_on_one_line
			warnings.warn('Hari Raja Puasa is missing. To estimate, install hijri-converter library')
			warnings.warn('pip install -U hijri-converter')
			warnings.warn('(see https://hijri-converter.readthedocs.io/ )')
			return []
		Hyear = convert.Gregorian(year, 1, 1).to_hijri().datetuple()[0]
		hrps = []
		hrps.append(convert.Hijri(Hyear - 1, 10, 1).to_gregorian())
		hrps.append(convert.Hijri(Hyear, 10, 1).to_gregorian())
		hrps.append(convert.Hijri(Hyear + 1, 10, 1).to_gregorian())
		hrp_dates = []
		for hrp in hrps:
			IF hrp.year == year THEN
				hrp_dates.append(date(*hrp.datetuple()))
		return hrp_dates

	-- Estimate Gregorian date(s) of Hara Rasa Haji
	def get_hrh_date(self, year):
		try:
			from hijri_converter import convert
		except ImportError:
			import warnings

			def warning_on_one_line(message, category, filename, lineno,
									file=None, line=None):
				return filename + ': ' + str(message) + '\n'
			warnings.formatwarning = warning_on_one_line
			warnings.warn('Hari Raja Haji is missing. To estimate, install hijri-converter library')
			warnings.warn('pip install -U hijri-converter')
			warnings.warn('(see https://hijri-converter.readthedocs.io/ )')
			return []
		Hyear = convert.Gregorian(year, 1, 1).to_hijri().datetuple()[0]
		hrhs = []
		hrhs.append(convert.Hijri(Hyear - 1, 12, 10).to_gregorian())
		hrhs.append(convert.Hijri(Hyear, 12, 10).to_gregorian())
		hrhs.append(convert.Hijri(Hyear + 1, 12, 10).to_gregorian())
		hrh_dates = []
		for hrh in hrhs:
			IF hrh.year == year THEN
				hrh_dates.append(date(*hrh.datetuple()))
		return hrh_dates

	END LOOP;
END;

$$ LANGUAGE plpgsql;