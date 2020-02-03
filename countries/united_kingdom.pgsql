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
		IF t_year >= 1974 THEN
			t_holiday.description := 'New Year''s Day';
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			RETURN NEXT t_holiday;
			t_datestamp := make_date(t_year, JANUARY, 1);
			IF DATE_PART('dow', t_datestamp) == SUN:
				t_holiday.datestamp := make_date(t_year, JANUARY, 1) + '+1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			elIF date(year, JANUARY, 1).weekday() == SAT THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 1) + '+2 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'

		-- New Year Holiday
		IF self.country in ('UK', 'Scotland') THEN
			t_holiday.description := 'New Year Holiday';
			IF self.country == 'UK' THEN
				name += ' [Scotland]'
			t_holiday.datestamp := make_date(t_year, JANUARY, 2);
			RETURN NEXT t_holiday;
			t_datestamp := make_date(t_year, JANUARY, 2);
			IF DATE_PART('dow', t_datestamp) in WEEKEND:
				t_holiday.datestamp := make_date(t_year, JANUARY, 2) + '+2 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			elIF date(year, JANUARY, 2).weekday() == MON THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 2) + '+1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'

		-- St. Patrick's Day
		IF self.country in ('UK', 'Northern Ireland', 'Ireland') THEN
			t_holiday.description := 'St. Patrick''s Day';
			IF self.country == 'UK' THEN
				name += ' [Northern Ireland]'
			t_holiday.datestamp := make_date(t_year, MARCH, 17);
			RETURN NEXT t_holiday;
			t_datestamp := make_date(t_year, MARCH, 17);
			IF DATE_PART('dow', t_datestamp) in WEEKEND:
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 17), MO, 1);
				RETURN NEXT t_holiday; + ' (Observed)'

		-- Good Friday
		IF self.country != 'Ireland' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
			t_holiday.description := 'Good Friday';
			RETURN NEXT t_holiday;

		-- Easter Monday
		IF self.country != 'Scotland' THEN
			t_holiday.description := 'Easter Monday';
			IF self.country == 'UK' THEN
				name += ' [England, Wales, Northern Ireland]'
			self[easter(year) + rd(weekday=MO)] = name

		-- May Day bank holiday (first Monday in May)
		IF t_year >= 1978 THEN
			t_holiday.description := 'May Day';
			IF t_year == 2020 and self.country != 'Ireland' THEN
				-- Moved to Friday to mark 75th anniversary of VE Day.
				t_holiday.datestamp := make_date(t_year, MAY, 8);
				RETURN NEXT t_holiday;
			ELSE
				IF t_year == 1995 THEN
					dt = date(year, MAY, 8)
				ELSE
					dt = date(year, MAY, 1)
				IF dt.weekday() == MON THEN
					self[dt] = name
				elIF dt.weekday() == TUE THEN
					self[dt + '+6 Days'::INTERVAL] = name
				elIF dt.weekday() == WED THEN
					self[dt + '+5 Days'::INTERVAL] = name
				elIF dt.weekday() == THU THEN
					self[dt + '+4 Days'::INTERVAL] = name
				elIF dt.weekday() == FRI THEN
					self[dt + '+3 Days'::INTERVAL] = name
				elIF dt.weekday() == SAT THEN
					self[dt + '+2 Days'::INTERVAL] = name
				elIF dt.weekday() == SUN THEN
					self[dt + '+1 Days'::INTERVAL] = name

		-- Spring bank holiday (last Monday in May)
		IF self.country != 'Ireland' THEN
			t_holiday.description := 'Spring Bank Holiday';
			IF t_year == 2012 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 4);
				RETURN NEXT t_holiday;
			ELSIF t_year >= 1971 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 31), MO, -1);
				t_holiday.description = name;
				RETURN NEXT t_holiday;

		-- June bank holiday (first Monday in June)
		IF self.country == 'Ireland' THEN
			self[date(year, JUNE, 1) + rd(weekday=MO)] = 'June Bank Holiday'

		-- TT bank holiday (first Friday in June)
		IF self.country == 'Isle of Man' THEN
			self[date(year, JUNE, 1) + rd(weekday=FR)] = 'TT Bank Holiday'

		-- Tynwald Day
		IF self.country == 'Isle of Man' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 5);
		t_holiday.description := 'Tynwald Day';
		RETURN NEXT t_holiday;

		-- Battle of the Boyne
		IF self.country in ('UK', 'Northern Ireland') THEN
			t_holiday.description := 'Battle of the Boyne';
			IF self.country == 'UK' THEN
				name += ' [Northern Ireland]'
			t_holiday.datestamp := make_date(t_year, JULY, 12);
			RETURN NEXT t_holiday;

		-- Summer bank holiday (first Monday in August)
		IF self.country in ('UK', 'Scotland', 'Ireland') THEN
			t_holiday.description := 'Summer Bank Holiday';
			IF self.country == 'UK' THEN
				name += ' [Scotland]'
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MO, 1);
			RETURN NEXT t_holiday;

		-- Late Summer bank holiday (last Monday in August)
		IF self.country not in ('Scotland', 'Ireland') and year >= 1971 THEN
			t_holiday.description := 'Late Summer Bank Holiday';
			IF self.country == 'UK' THEN
				name += ' [England, Wales, Northern Ireland]'
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, AUGUST, 31), MO, -1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- October Bank Holiday (last Monday in October)
		IF self.country == 'Ireland' THEN
			t_holiday.description := 'October Bank Holiday';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCTOBER, 31), MO, -1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- St. Andrew's Day
		IF self.country in ('UK', 'Scotland') THEN
			t_holiday.description := 'St. Andrew''s Day';
			IF self.country == 'UK' THEN
				name += ' [Scotland]'
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 30);
			RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		RETURN NEXT t_holiday;
		t_datestamp := make_date(t_year, DECEMBER, 25);
		IF DATE_PART('dow', t_datestamp) == SAT:
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			RETURN NEXT t_holiday; + ' (Observed)'
		elIF date(year, DECEMBER, 25).weekday() == SUN THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Boxing Day
		t_holiday.description := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		RETURN NEXT t_holiday;
		t_datestamp := make_date(t_year, DECEMBER, 26);
		IF DATE_PART('dow', t_datestamp) == SAT:
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			RETURN NEXT t_holiday; + ' (Observed)'
		elIF date(year, DECEMBER, 26).weekday() == SUN THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Special holidays
		IF self.country != 'Ireland' THEN
			IF t_year == 1977 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 7);
				t_holiday.description := 'Silver Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			ELSIF t_year == 1981 THEN
				t_holiday.datestamp := make_date(t_year, JULY, 29);
				t_holiday.description := 'Wedding of Charles and Diana';
				RETURN NEXT t_holiday;
			ELSIF t_year == 1999 THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
				t_holiday.description := 'Millennium Celebrations';
				RETURN NEXT t_holiday;
			ELSIF t_year == 2002 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 3);
				t_holiday.description := 'Golden Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			ELSIF t_year == 2011 THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 29);
				t_holiday.description := 'Wedding of William and Catherine';
				RETURN NEXT t_holiday;
			ELSIF t_year == 2012 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 5);
				t_holiday.description := 'Diamond Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;