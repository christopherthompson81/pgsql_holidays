------------------------------------------
------------------------------------------
-- <country> Holidays
-- http://www.gov.za/about-sa/public-holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_South_Africa
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

		-- Observed since 1910, with a few name changes
		if year > 1909:
			t_holiday.datestamp := make_date(t_year, 1, 1);
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;

			e = easter(year)
			good_friday = e - rd(days=2)
			easter_monday = e + rd(days=1)
			self[good_friday] = 'Good Friday'
			if year > 1979:
				self[easter_monday] = 'Family Day'
			else:
				self[easter_monday] = 'Easter Monday'

			if 1909 < year < 1952:
				dec_16_name = 'Dingaan''s Day'
			elif 1951 < year < 1980:
				dec_16_name = 'Day of the Covenant'
			elif 1979 < year < 1995:
				dec_16_name = 'Day of the Vow'
			else:
				dec_16_name = 'Day of Reconciliation'
			self[date(year, DEC, 16)] = dec_16_name

			t_holiday.datestamp := make_date(t_year, DEC, 25);
			t_holiday.description := 'Christmas Day';
			RETURN NEXT t_holiday;

			if year > 1979:
				dec_26_name = 'Day of Goodwill'
			else:
				dec_26_name = 'Boxing Day'
			self[date(year, 12, 26)] = dec_26_name

		-- Observed since 1995/1/1
		if year > 1994:
			t_holiday.datestamp := make_date(t_year, MAR, 21);
			t_holiday.description := 'Human Rights Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APR, 27);
			t_holiday.description := 'Freedom Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Workers'' Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 16);
			t_holiday.description := 'Youth Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, AUG, 9);
			t_holiday.description := 'National Women''s Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEP, 24);
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;

		-- Once-off public holidays
		national_election = 'National and provincial government elections'
		y2k = 'Y2K changeover'
		local_election = 'Local government elections'
		presidential = 'By presidential decree'
		if year == 1999:
			self[date(1999, JUN, 2)] = national_election
			self[date(1999, DEC, 31)] = y2k
		if year == 2000:
			self[date(2000, JANUARY, 2)] = y2k
		if year == 2004:
			self[date(2004, APR, 14)] = national_election
		if year == 2006:
			self[date(2006, MAR, 1)] = local_election
		if year == 2008:
			self[date(2008, MAY, 2)] = presidential
		if year == 2009:
			self[date(2009, APR, 22)] = national_election
		if year == 2011:
			self[date(2011, MAY, 18)] = local_election
			self[date(2011, DEC, 27)] = presidential
		if year == 2014:
			self[date(2014, MAY, 7)] = national_election
		if year == 2016:
			self[date(2016, AUG, 3)] = local_election
		if year == 2019:
			self[date(2019, MAY, 8)] = national_election

		-- As of 1995/1/1, whenever a public holiday falls on a Sunday,
		-- it rolls over to the following Monday
		for k, v in list(self.items()):
			if year > 1994 and k.weekday() == SUN:
				self[k + rd(days=1)] = v + ' (Observed)'

		-- Historic public holidays no longer observed
		if 1951 < year < 1974:
			t_holiday.datestamp := make_date(t_year, APR, 6);
			t_holiday.description := 'Van Riebeeck''s Day';
			RETURN NEXT t_holiday;
		elif 1979 < year < 1995:
			t_holiday.datestamp := make_date(t_year, APR, 6);
			t_holiday.description := 'Founder''s Day';
			RETURN NEXT t_holiday;

		if 1986 < year < 1990:
			historic_workers_day = datetime(year, MAY, 1)
			-- observed on first Friday in May
			while historic_workers_day.weekday() != FRI:
				historic_workers_day += rd(days=1)

			self[historic_workers_day] = 'Workers'' Day'

		if 1909 < year < 1994:
			ascension_day = e + rd(days=40)
			self[ascension_day] = 'Ascension Day'

		if 1909 < year < 1952:
			t_holiday.datestamp := make_date(t_year, MAY, 24);
			t_holiday.description := 'Empire Day';
			RETURN NEXT t_holiday;

		if 1909 < year < 1961:
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Union Day';
			RETURN NEXT t_holiday;
		elif 1960 < year < 1994:
			t_holiday.datestamp := make_date(t_year, MAY, 31);
			t_holiday.description := 'Republic Day';
			RETURN NEXT t_holiday;

		if 1951 < year < 1961:
			queens_birthday = datetime(year, JUN, 7)
			-- observed on second Monday in June
			while queens_birthday.weekday() != 0:
				queens_birthday += rd(days=1)

			self[queens_birthday] = 'Queen''s Birthday'

		if 1960 < year < 1974:
			t_holiday.datestamp := make_date(t_year, JUL, 10);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;

		if 1909 < year < 1952:
			kings_birthday = datetime(year, AUG, 1)
			-- observed on first Monday in August
			while kings_birthday.weekday() != 0:
				kings_birthday += rd(days=1)

			self[kings_birthday] = 'King''s Birthday'

		if 1951 < year < 1980:
			settlers_day = datetime(year, SEP, 1)
			while settlers_day.weekday() != 0:
				settlers_day += rd(days=1)

			self[settlers_day] = 'Settlers'' Day'

		if 1951 < year < 1994:
			t_holiday.datestamp := make_date(t_year, OCT, 10);
			t_holiday.description := 'Kruger Day';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;