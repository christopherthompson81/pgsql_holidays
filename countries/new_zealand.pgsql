------------------------------------------
------------------------------------------
-- <country> Holidays
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
	-- Provinces
	PROVINCES = ['NTL', 'AUK', 'TKI', 'HKB', 'WGN', 'MBH', 'NSN', 'CAN',
				 'STC', 'WTL', 'OTA', 'STL', 'CIT']
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

		-- Bank Holidays Act 1873
		-- The Employment of Females Act 1873
		-- Factories Act 1894
		-- Industrial Conciliation and Arbitration Act 1894
		-- Labour Day Act 1899
		-- Anzac Day Act 1920, 1949, 1956
		-- New Zealand Day Act 1973
		-- Waitangi Day Act 1960, 1976
		-- Sovereign's Birthday Observance Act 1937, 1952
		-- Holidays Act 1981, 2003
		if year < 1894:
			return

		-- New Year's Day
		name = 'New Year''s Day'
		jan1 = date(year, JANUARY, 1)
		self[jan1] = name
		if jan1.weekday() in WEEKEND:
			self[date(year, JANUARY, 3)] = name + ' (Observed)'

		name = 'Day after New Year''s Day'
		jan2 = date(year, JANUARY, 2)
		self[jan2] = name
		if jan2.weekday() in WEEKEND:
			self[date(year, JANUARY, 4)] = name + ' (Observed)'

		-- Waitangi Day
		if year > 1973:
			name = 'New Zealand Day'
			if year > 1976:
				name = 'Waitangi Day'
			feb6 = date(year, FEB, 6)
			self[feb6] = name
			if year >= 2014 and feb6.weekday() in WEEKEND:
				self[feb6 + rd(weekday=MO)] = name + ' (Observed)'

		-- Easter
		self[easter(year) + rd(weekday=FR(-1))] = 'Good Friday'
		self[easter(year) + rd(weekday=MO)] = 'Easter Monday'

		-- Anzac Day
		if year > 1920:
			name = 'Anzac Day'
			apr25 = date(year, APR, 25)
			self[apr25] = name
			if year >= 2014 and apr25.weekday() in WEEKEND:
				self[apr25 + rd(weekday=MO)] = name + ' (Observed)'

		-- Sovereign's Birthday
		if year >= 1952:
			name = 'Queen''s Birthday'
		ELSIF t_year > 1901 THEN
			name = 'King''s Birthday'
		if year == 1952:
			self[date(year, JUN, 2)] = name  -- Elizabeth II
		ELSIF t_year > 1937 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUN, 1), MO, +1);
			t_holiday.description = name  -- EII & GVI;
			RETURN NEXT t_holiday;
		ELSIF t_year == 1937 THEN
			self[date(year, JUN, 9)] = name  -- George VI
		ELSIF t_year == 1936 THEN
			self[date(year, JUN, 23)] = name  -- Edward VIII
		ELSIF t_year > 1911 THEN
			self[date(year, JUN, 3)] = name  -- George V
		ELSIF t_year > 1901 THEN
			-- http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=NZH19091110.2.67
			self[date(year, NOV, 9)] = name  -- Edward VII

		-- Labour Day
		name = 'Labour Day'
		if year >= 1910:
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 1), MO, +4);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF t_year > 1899 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 1), WE, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- Christmas Day
		name = 'Christmas Day'
		dec25 = date(year, DEC, 25)
		self[dec25] = name
		if dec25.weekday() in WEEKEND:
			self[date(year, DEC, 27)] = name + ' (Observed)'

		-- Boxing Day
		name = 'Boxing Day'
		dec26 = date(year, DEC, 26)
		self[dec26] = name
		if dec26.weekday() in WEEKEND:
			self[date(year, DEC, 28)] = name + ' (Observed)'

		-- Province Anniversary Day
		if self.prov in ('NTL', 'Northland', 'AUK', 'Auckland'):
			if 1963 < year <= 1973 and self.prov in ('NTL', 'Northland'):
				name = 'Waitangi Day'
				dt = date(year, FEB, 6)
			else:
				name = 'Auckland Anniversary Day'
				dt = date(year, JANUARY, 29)
			if dt.weekday() in (TUE, WED, THU):
				self[dt + rd(weekday=MO(-1))] = name
			else:
				self[dt + rd(weekday=MO)] = name

		elif self.prov in ('TKI', 'Taranaki', 'New Plymouth'):
			name = 'Taranaki Anniversary Day'
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		elif self.prov in ('HKB', 'Hawke''s Bay'):
			name = 'Hawke''s Bay Anniversary Day'
			labour_day = find_nth_weekday_date(make_date(t_year, OCT, 1), MO, +4);
			self[labour_day + rd(weekday=FR(-1))] = name

		elif self.prov in ('WGN', 'Wellington'):
			name = 'Wellington Anniversary Day'
			jan22 = date(year, JANUARY, 22)
			if jan22.weekday() in (TUE, WED, THU):
				self[jan22 + rd(weekday=MO(-1))] = name
			else:
				self[jan22 + rd(weekday=MO)] = name

		elif self.prov in ('MBH', 'Marlborough'):
			name = 'Marlborough Anniversary Day'
			labour_day = find_nth_weekday_date(make_date(t_year, OCT, 1), MO, +4);
			self[labour_day + rd(weeks=1)] = name

		elif self.prov in ('NSN', 'Nelson'):
			name = 'Nelson Anniversary Day'
			feb1 = date(year, FEB, 1)
			if feb1.weekday() in (TUE, WED, THU):
				self[feb1 + rd(weekday=MO(-1))] = name
			else:
				self[feb1 + rd(weekday=MO)] = name

		elif self.prov in ('CAN', 'Canterbury'):
			name = 'Canterbury Anniversary Day'
			showday = date(year, NOV, 1) + rd(weekday=TU) + rd(weekday=FR(+2))
			self[showday] = name

		elif self.prov in ('STC', 'South Canterbury'):
			name = 'South Canterbury Anniversary Day'
			dominion_day = find_nth_weekday_date(make_date(t_year, SEP, 1), MO, 4);
			self[dominion_day] = name

		elif self.prov in ('WTL', 'Westland'):
			name = 'Westland Anniversary Day'
			dec1 = date(year, DEC, 1)
			-- Observance varies?!?!
			if year == 2005:  -- special case?!?!
				self[date(year, DEC, 5)] = name
			elif dec1.weekday() in (TUE, WED, THU):
				self[dec1 + rd(weekday=MO(-1))] = name
			else:
				self[dec1 + rd(weekday=MO)] = name

		elif self.prov in ('OTA', 'Otago'):
			name = 'Otago Anniversary Day'
			mar23 = date(year, MAR, 23)
			-- there is no easily determined single day of local observance?!?!
			if mar23.weekday() in (TUE, WED, THU):
				dt = mar23 + rd(weekday=MO(-1))
			else:
				dt = mar23 + rd(weekday=MO)
			if dt == easter(year) + rd(weekday=MO):  -- Avoid Easter Monday
				dt += rd(days=1)
			self[dt] = name

		elif self.prov in ('STL', 'Southland'):
			name = 'Southland Anniversary Day'
			jan17 = date(year, JANUARY, 17)
			if year > 2011:
				self[easter(year) + rd(weekday=TU)] = name
			else:
				if jan17.weekday() in (TUE, WED, THU):
					self[jan17 + rd(weekday=MO(-1))] = name
				else:
					self[jan17 + rd(weekday=MO)] = name

		elif self.prov in ('CIT', 'Chatham Islands'):
			name = 'Chatham Islands Anniversary Day'
			nov30 = date(year, NOV, 30)
			if nov30.weekday() in (TUE, WED, THU):
				self[nov30 + rd(weekday=MO(-1))] = name
			else:
				self[nov30 + rd(weekday=MO)] = name

	END LOOP;
END;

$$ LANGUAGE plpgsql;