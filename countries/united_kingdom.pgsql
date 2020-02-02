------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_the_United_Kingdom
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

		-- New Year's Day
		if year >= 1974:
			name = 'New Year''s Day'
			self[date(year, JANUARY, 1)] = name
			if date(year, JANUARY, 1).weekday() == SUN:
				self[date(year, JANUARY, 1) + rd(days=+1)] = name + ' (Observed)'
			elif date(year, JANUARY, 1).weekday() == SAT:
				self[date(year, JANUARY, 1) + rd(days=+2)] = name + ' (Observed)'

		-- New Year Holiday
		if self.country in ('UK', 'Scotland'):
			name = 'New Year Holiday'
			if self.country == 'UK':
				name += ' [Scotland]'
			self[date(year, JANUARY, 2)] = name
			if date(year, JANUARY, 2).weekday() in WEEKEND:
				self[date(year, JANUARY, 2) + rd(days=+2)] = name + ' (Observed)'
			elif date(year, JANUARY, 2).weekday() == MON:
				self[date(year, JANUARY, 2) + rd(days=+1)] = name + ' (Observed)'

		-- St. Patrick's Day
		if self.country in ('UK', 'Northern Ireland', 'Ireland'):
			name = 'St. Patrick''s Day'
			if self.country == 'UK':
				name += ' [Northern Ireland]'
			self[date(year, MAR, 17)] = name
			if date(year, MAR, 17).weekday() in WEEKEND:
				self[date(year, MAR, 17) + rd(weekday=MO)] = name + ' (Observed)'

		-- Good Friday
		if self.country != 'Ireland':
			self[easter(year) + rd(weekday=FR(-1))] = 'Good Friday'

		-- Easter Monday
		if self.country != 'Scotland':
			name = 'Easter Monday'
			if self.country == 'UK':
				name += ' [England, Wales, Northern Ireland]'
			self[easter(year) + rd(weekday=MO)] = name

		-- May Day bank holiday (first Monday in May)
		if year >= 1978:
			name = 'May Day'
			if year == 2020 and self.country != 'Ireland':
				-- Moved to Friday to mark 75th anniversary of VE Day.
				self[date(year, MAY, 8)] = name
			else:
				if year == 1995:
					dt = date(year, MAY, 8)
				else:
					dt = date(year, MAY, 1)
				if dt.weekday() == MON:
					self[dt] = name
				elif dt.weekday() == TUE:
					self[dt + rd(days=+6)] = name
				elif dt.weekday() == WED:
					self[dt + rd(days=+5)] = name
				elif dt.weekday() == THU:
					self[dt + rd(days=+4)] = name
				elif dt.weekday() == FRI:
					self[dt + rd(days=+3)] = name
				elif dt.weekday() == SAT:
					self[dt + rd(days=+2)] = name
				elif dt.weekday() == SUN:
					self[dt + rd(days=+1)] = name

		-- Spring bank holiday (last Monday in May)
		if self.country != 'Ireland':
			name = 'Spring Bank Holiday'
			if year == 2012:
				self[date(year, JUN, 4)] = name
			elif year >= 1971:
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 31), MO, -1);
				t_holiday.description = name;
				RETURN NEXT t_holiday;

		-- June bank holiday (first Monday in June)
		if self.country == 'Ireland':
			self[date(year, JUN, 1) + rd(weekday=MO)] = 'June Bank Holiday'

		-- TT bank holiday (first Friday in June)
		if self.country == 'Isle of Man':
			self[date(year, JUN, 1) + rd(weekday=FR)] = 'TT Bank Holiday'

		-- Tynwald Day
		if self.country == 'Isle of Man':
			t_holiday.datestamp := make_date(t_year, JUL, 5);
		t_holiday.description := 'Tynwald Day';
		RETURN NEXT t_holiday;

		-- Battle of the Boyne
		if self.country in ('UK', 'Northern Ireland'):
			name = 'Battle of the Boyne'
			if self.country == 'UK':
				name += ' [Northern Ireland]'
			self[date(year, JUL, 12)] = name

		-- Summer bank holiday (first Monday in August)
		if self.country in ('UK', 'Scotland', 'Ireland'):
			name = 'Summer Bank Holiday'
			if self.country == 'UK':
				name += ' [Scotland]'
			self[date(year, AUG, 1) + rd(weekday=MO)] = name

		-- Late Summer bank holiday (last Monday in August)
		if self.country not in ('Scotland', 'Ireland') and year >= 1971:
			name = 'Late Summer Bank Holiday'
			if self.country == 'UK':
				name += ' [England, Wales, Northern Ireland]'
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, AUG, 31), MO, -1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- October Bank Holiday (last Monday in October)
		if self.country == 'Ireland':
			name = 'October Bank Holiday'
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCT, 31), MO, -1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- St. Andrew's Day
		if self.country in ('UK', 'Scotland'):
			name = 'St. Andrew''s Day'
			if self.country == 'UK':
				name += ' [Scotland]'
			self[date(year, NOV, 30)] = name

		-- Christmas Day
		name = 'Christmas Day'
		self[date(year, DEC, 25)] = name
		if date(year, DEC, 25).weekday() == SAT:
			self[date(year, DEC, 27)] = name + ' (Observed)'
		elif date(year, DEC, 25).weekday() == SUN:
			self[date(year, DEC, 27)] = name + ' (Observed)'

		-- Boxing Day
		name = 'Boxing Day'
		self[date(year, DEC, 26)] = name
		if date(year, DEC, 26).weekday() == SAT:
			self[date(year, DEC, 28)] = name + ' (Observed)'
		elif date(year, DEC, 26).weekday() == SUN:
			self[date(year, DEC, 28)] = name + ' (Observed)'

		-- Special holidays
		if self.country != 'Ireland':
			if year == 1977:
				t_holiday.datestamp := make_date(t_year, JUN, 7);
				t_holiday.description := 'Silver Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			elif year == 1981:
				t_holiday.datestamp := make_date(t_year, JUL, 29);
				t_holiday.description := 'Wedding of Charles and Diana';
				RETURN NEXT t_holiday;
			elif year == 1999:
				t_holiday.datestamp := make_date(t_year, DEC, 31);
				t_holiday.description := 'Millennium Celebrations';
				RETURN NEXT t_holiday;
			elif year == 2002:
				t_holiday.datestamp := make_date(t_year, JUN, 3);
				t_holiday.description := 'Golden Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			elif year == 2011:
				t_holiday.datestamp := make_date(t_year, APR, 29);
				t_holiday.description := 'Wedding of William and Catherine';
				RETURN NEXT t_holiday;
			elif year == 2012:
				t_holiday.datestamp := make_date(t_year, JUN, 5);
				t_holiday.description := 'Diamond Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;