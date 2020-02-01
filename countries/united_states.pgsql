------------------------------------------
------------------------------------------
-- United States Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_the_United_States
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.usa(p_state TEXT, p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $usa$

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
	-- States
	states_array TEXT[] := ARRAY[
		'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL',
		'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME',
		'MD', 'MH', 'MA', 'MI', 'FM', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV',
		'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW',
		'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'VI',
		'WA', 'WV', 'WI', 'WY'];
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
		t_datestamp = make_date(t_year, JANUARY, 1)
		IF t_year > 1870 THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				-- Add Dec 31st from the previous year without triggering
				-- the entire year to be added
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			-- The next year's observed New Year's Day can be IN this year
			-- when it falls on a Friday (Jan 1st is a Saturday)
			IF make_date(t_year, DECEMBER, 31).weekday() = FRIDAY THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Epiphany
		IF p_state = 'PR' THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 6);
			t_holiday.description := 'Epiphany';
			RETURN NEXT t_holiday;
		END IF;

		-- Three King's Day
		IF p_state = 'VI' THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 6);
			t_holiday.description := 'Three King''s Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Lee Jackson Day
		IF p_state = 'VA' AND t_year >= 2000 THEN
			t_datestamp := find_nth_weekday_date(make_date(t_year, JANUARY, 1), MONDAY, 3);
			t_holiday.datestamp := find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			t_holiday.description := 'Lee Jackson Day';
			RETURN NEXT t_holiday;
		ELSIF p_state = 'VA' AND t_year >= 1983 THEN
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, JANUARY, 1), MONDAY, 3);
			t_holiday.description := 'Lee Jackson Day';
			RETURN NEXT t_holiday;
		ELSIF p_state = 'VA' AND t_year >= 1889 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 19);
			t_holiday.description := 'Lee Jackson Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Inauguration Day
		IF p_state IN ('DC', 'LA', 'MD', 'VA') AND t_year >= 1789 THEN
			IF (t_year - 1789) % 4 = 0 AND t_year >= 1937 THEN
				t_datestamp := make_date(t_year, JANUARY, 20);
				t_holiday.datestamp := t_datestamp;
				t_holiday.description := 'Inauguration Day';
				RETURN NEXT t_holiday;
				IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
					t_holiday.datestamp := make_date(t_year, JANUARY, 21);
					t_holiday.description := 'Inauguration Day (Observed)';
					RETURN NEXT t_holiday;
				END IF;
			ELSIF (t_year - 1789) % 4 = 0 THEN
				t_datestamp := make_date(t_year, MARCH, 4);
				t_holiday.datestamp := t_datestamp;
				t_holiday.description := 'Inauguration Day';
				RETURN NEXT t_holiday;
				IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
					t_holiday.datestamp := make_date(t_year, MARCH, 5);
					t_holiday.description := 'Inauguration Day (Observed)';
					RETURN NEXT t_holiday;
				END IF;
			END IF;
		END IF;

		-- Martin Luther King, Jr. Day
		IF t_year >= 1986 THEN
			t_holiday.description := 'Martin Luther King, Jr. Day';
			IF p_state = 'AL' THEN
				t_holiday.description := 'Robert E. Lee/Martin Luther King Birthday';
			ELSIF p_state IN ('AS', 'MS') THEN
				t_holiday.description := 'Dr. Martin Luther King Jr. and Robert E. Lee''s Birthdays';
			ELSIF p_state IN ('AZ', 'NH') THEN
				t_holiday.description := 'Dr. Martin Luther King Jr./Civil Rights Day';
			ELSIF p_state = 'GA' AND t_year < 2012 THEN
				t_holiday.description := 'Robert E. Lee''s Birthday';
			ELSIF p_state = 'ID' AND t_year >= 2006 THEN
				t_holiday.description := 'Martin Luther King, Jr. - Idaho Human Rights Day';
			END IF;
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, JANUARY, 1), MONDAY, 3);
			RETURN NEXT t_holiday;
		END IF;

		-- Lincoln's Birthday
		t_holiday.description := = 'Lincoln''s Birthday';
		IF (p_state IN ('CT', 'IL', 'IA', 'NJ', 'NY') AND t_year >= 1971)
		OR (p_state = 'CA' AND 1971 <= year <= 2009) THEN
			t_datestamp := make_date(t_year, FEBRUARY, 12);
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 11);
				t_holiday.description := 'Lincoln''s Birthday (Observed)';
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 13);
				t_holiday.description := 'Lincoln''s Birthday (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Susan B. Anthony Day
		IF p_state = 'CA' AND t_year >= 2014)
		OR p_state = 'FL' AND t_year >= 2011)
		OR p_state = 'NY' AND t_year >= 2004)
		OR p_state = 'WI' AND t_year >= 1976) THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 15);
			t_holiday.description := 'Susan B. Anthony Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Washington's Birthday
		t_holiday.description := 'Washington''s Birthday';
		IF p_state = 'AL' THEN
			t_holiday.description := 'George Washington/Thomas Jefferson Birthday';
		ELSIF p_state = 'AS' THEN
			t_holiday.description := 'George Washington''s Birthday and Daisy Gatson Bates Day';
		ELSIF p_state IN ('PR', 'VI') THEN
			t_holiday.description := 'Presidents'' Day';
		END IF;
		IF p_state not IN ('DE', 'FL', 'GA', 'NM', 'PR') THEN
			IF t_year > 1970 THEN
				t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
				RETURN NEXT t_holiday;
			ELSIF t_year >= 1879 THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 22);
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_state = 'GA' THEN
			t_datestamp := make_date(t_year, DECEMBER, 24);
			IF DATE_PART('dow', t_datestamp) != WEDNESDAY THEN
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_state IN ('PR', 'VI') THEN
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			RETURN NEXT t_holiday;
		END IF;

		-- Mardi Gras
		IF p_state = 'LA' AND t_year >= 1857 THEN
			t_holiday.datestamp := holidays.easter(t_year) - '47 Days'::INTERVAL;
			t_holiday.description := 'Mardi Gras';
			RETURN NEXT t_holiday;
		END IF;

		-- Guam Discovery Day
		IF p_state = 'GU' AND t_year >= 1970 THEN
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 1);
			t_holiday.description := 'Guam Discovery Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Casimir Pulaski Day
		IF p_state = 'IL' AND t_year >= 1978 THEN
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, 1);
			t_holiday.description := 'Casimir Pulaski Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Texas Independence Day
		IF p_state = 'TX' AND t_year >= 1874 THEN
			t_holiday.datestamp := make_date(t_year, MAR, 2);
			t_holiday.description := 'Texas Independence Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Town Meeting Day
		IF p_state = 'VT' AND t_year >= 1800 THEN
			t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, MARCH, 1), TUESDAY, 1);
			t_holiday.description := 'Town Meeting Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Evacuation Day
		IF p_state = 'MA' AND t_year >= 1901 THEN
			t_datestamp = make_date(t_year, MARCH, 17);
			t_holiday.description := 'Evacuation Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := find_nth_weekday_date(make_date(t_year, MARCH, 17), MONDAY, 1);
				t_holiday.description := 'Evacuation Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Emancipation Day
		IF p_state = 'PR' THEN
			t_datestamp = make_date(t_year, MARCH, 22);
			t_holiday.description := 'Emancipation Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'Emancipation Day (Observed)';
				t_holiday.datestamp := make_date(t_year, MARCH, 23);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Prince Jonah Kuhio Kalanianaole Day
		IF p_state = 'HI' AND t_year >= 1949 THEN
			t_datestamp = make_date(t_year, MARCH, 26);
			t_holiday.description := 'Prince Jonah Kuhio Kalanianaole Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.description := 'Prince Jonah Kuhio Kalanianaole Day (Observed)';
				t_holiday.datestamp := make_date(t_year, MARCH, 25);
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'Prince Jonah Kuhio Kalanianaole Day (Observed)';
				t_holiday.datestamp := make_date(t_year, MARCH, 27);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Steward's Day
		t_holiday.description := 'Steward''s Day';
		IF p_state = 'AK' AND t_year >= 1955 THEN
			t_datestamp := make_date(t_year, APRIL, 1) - '1 Day'::INTERVAL;
			t_holiday.datestamp := find_nth_weekday_date(t_datestamp, MONDAY, -1);
			RETURN NEXT t_holiday;
		ELSIF p_state = 'AK' AND t_year >= 1918 THEN
			t_datestamp := make_date(t_year, MARCH, 30);
			RETURN NEXT t_holiday;
		END IF;

		-- César Chávez Day
		t_holiday.description := 'César Chávez Day'
		IF p_state = 'CA' AND t_year >= 1995 THEN
			t_datestamp = make_date(t_year, MAR, 31);
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'César Chávez Day (Observed)'
				t_datestamp = make_date(t_year, APRIL, 1);
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_state = 'TX' AND t_year >= 2000 THEN
			t_holiday.datestamp = make_date(t_year, MAR, 31);
			RETURN NEXT t_holiday;
		END IF;

		-- Transfer Day
		IF p_state = 'VI' THEN
			t_holiday.description := 'Transfer Day';
			t_datestamp = make_date(t_year, MARCH, 31);
			RETURN NEXT t_holiday;
		END IF;

		-- Emancipation Day
		IF p_state = 'DC' AND t_year >= 2005 THEN
			t_holiday.description := 'Emancipation Day'
			make_date(t_year, APR, 16)] = name
			IF make_date(t_year, APR, 16).weekday() = SATURDAY THEN
				make_date(t_year, APR, 15)] = name + ' (Observed)'
			ELSIF date(t_year, APR, 16).weekday() = SUNDAY THEN
				make_date(t_year, APR, 17)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Patriots' Day
		IF p_state IN ('ME', 'MA') AND t_year >= 1969 THEN
			make_date(t_year, APR, 1) + rd(weekday=MO(+3))] = 'Patriots'' Day'
		ELSIF p_state IN ('ME', 'MA') AND t_year >= 1894 THEN
			make_date(t_year, APR, 19)] = 'Patriots'' Day'
		END IF;

		-- Holy Thursday
		IF p_state = 'VI' THEN
			self[easter(year) + rd(weekday=TH(-1))] = 'Holy Thursday'
		END IF;

		-- Good Friday
		IF p_state IN ('CT', 'DE', 'GU', 'IN', 'KY', 'LA', 'NJ', 'NC', 'PR', 'TN', 'TX', 'VI') THEN
			self[easter(year) + rd(weekday=FR(-1))] = 'Good Friday'
		END IF;

		-- Easter Monday
		IF p_state = 'VI' THEN
			self[easter(year) + rd(weekday=MO)] = 'Easter Monday'
		END IF;

		-- Confederate Memorial Day
		t_holiday.description := 'Confederate Memorial Day'
		IF p_state IN ('AL', 'GA', 'MS', 'SC') AND t_year >= 1866 THEN
			IF p_state = 'GA' AND t_year >= 2016 THEN
				name = 'State Holiday'
			END IF;
			make_date(t_year, APR, 1) + rd(weekday=MO(+4))] = name
		ELSIF p_state = 'TX' AND t_year >= 1931 THEN
			make_date(t_year, JANUARY, 19)] = name
		END IF;

		-- San Jacinto Day
		IF p_state = 'TX' AND t_year >= 1875 THEN
			make_date(t_year, APR, 21)] = 'San Jacinto Day'
		END IF;

		-- Arbor Day
		IF p_state = 'NE' AND t_year >= 1989 THEN
			make_date(t_year, APR, 30) + rd(weekday=FR(-1))] = 'Arbor Day'
		ELSIF p_state = 'NE' AND t_year >= 1875 THEN
			make_date(t_year, APR, 22)] = 'Arbor Day'
		END IF;

		-- Primary Election Day
		IF p_state = 'IN' AND ((year >= 2006 AND t_year % 2 = 0) OR t_year >= 2015) THEN
			dt = date(t_year, MAY, 1) + rd(weekday=MO)
			self[dt + rd(days=+1)] = 'Primary Election Day'
		END IF;

		-- Truman Day
		IF p_state = 'MO' AND t_year >= 1949 THEN
			t_holiday.description := 'Truman Day'
			make_date(t_year, MAY, 8)] = name
			IF make_date(t_year, MAY, 8).weekday() = SATURDAY THEN
				make_date(t_year, MAY, 7)] = name + ' (Observed)'
			ELSIF date(t_year, MAY, 8).weekday() = SUNDAY THEN
				make_date(t_year, MAY, 10)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Memorial Day
		IF t_year > 1970 THEN
			make_date(t_year, MAY, 31) + rd(weekday=MO(-1))] = 'Memorial Day'
		ELSIF t_year >= 1888 THEN
			make_date(t_year, MAY, 30)] = 'Memorial Day'
		END IF;

		-- Jefferson Davis Birthday
		t_holiday.description := 'Jefferson Davis Birthday'
		IF p_state = 'AL' AND t_year >= 1890 THEN
			make_date(t_year, JUN, 1) + rd(weekday=MO)] = name
		END IF;

		-- Kamehameha Day
		IF p_state = 'HI' AND t_year >= 1872 THEN
			make_date(t_year, JUN, 11)] = 'Kamehameha Day'
			IF t_year >= 2011 THEN
				IF make_date(t_year, JUN, 11).weekday() = SATURDAY THEN
					make_date(t_year, JUN, 10)] = 'Kamehameha Day (Observed)'
				ELSIF date(t_year, JUN, 11).weekday() = SUNDAY THEN
					make_date(t_year, JUN, 12)] = 'Kamehameha Day (Observed)'
				END IF;
			END IF;
		END IF;

		-- Emancipation Day In Texas
		IF p_state = 'TX' AND t_year >= 1980 THEN
			make_date(t_year, JUN, 19)] = 'Emancipation Day In Texas'
		END IF;

		-- West Virginia Day
		name = 'West Virginia Day'
		IF p_state = 'WV' AND t_year >= 1927 THEN
			make_date(t_year, JUN, 20)] = name
			IF make_date(t_year, JUN, 20).weekday() = SATURDAY THEN
				make_date(t_year, JUN, 19)] = name + ' (Observed)'
			ELSIF date(t_year, JUN, 20).weekday() = SUNDAY THEN
				make_date(t_year, JUN, 21)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Emancipation Day IN US Virgin Islands
		IF p_state = 'VI' THEN
			make_date(t_year, JUL, 3)] = 'Emancipation Day'
		END IF;

		-- Independence Day
		IF t_year > 1870 THEN
			t_holiday.description := 'Independence Day'
			make_date(t_year, JUL, 4)] = name
			IF make_date(t_year, JUL, 4).weekday() = SATURDAY THEN
				make_date(t_year, JUL, 4) + rd(days=-1)] = name + ' (Observed)'
			ELSIF date(t_year, JUL, 4).weekday() = SUNDAY THEN
				make_date(t_year, JUL, 4) + rd(days=+1)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Liberation Day (Guam)
		IF p_state = 'GU' AND t_year >= 1945 THEN
			make_date(t_year, JUL, 21)] = 'Liberation Day (Guam)'
		END IF;

		-- Pioneer Day
		IF p_state = 'UT' AND t_year >= 1849 THEN
			t_holiday.description := 'Pioneer Day'
			make_date(t_year, JUL, 24)] = name
			IF make_date(t_year, JUL, 24).weekday() = SATURDAY THEN
				make_date(t_year, JUL, 24) + rd(days=-1)] = name + ' (Observed)'
			ELSIF date(t_year, JUL, 24).weekday() = SUNDAY THEN
				make_date(t_year, JUL, 24) + rd(days=+1)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Constitution Day
		IF p_state = 'PR' THEN
			make_date(t_year, JUL, 25)] = 'Constitution Day'
			IF make_date(t_year, JUL, 25).weekday() = SUNDAY THEN
				make_date(t_year, JUL, 26)] = 'Constitution Day (Observed)'
			END IF;
		END IF;

		-- Victory Day
		IF p_state = 'RI' AND t_year >= 1948 THEN
			make_date(t_year, AUG, 1) + rd(weekday=MO(+2))] = 'Victory Day'
		END IF;

		-- Statehood Day (Hawaii)
		IF p_state = 'HI' AND t_year >= 1959 THEN
			make_date(t_year, AUG, 1) + rd(weekday=FR(+3))] = 'Statehood Day'
		END IF;

		-- Bennington Battle Day
		IF p_state = 'VT' AND t_year >= 1778 THEN
			t_holiday.description := 'Bennington Battle Day'
			make_date(t_year, AUG, 16)] = name
			IF make_date(t_year, AUG, 16).weekday() = SATURDAY THEN
				make_date(t_year, AUG, 15)] = name + ' (Observed)'
			ELSIF date(t_year, AUG, 16).weekday() = SUNDAY THEN
				make_date(t_year, AUG, 17)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Lyndon Baines Johnson Day
		IF p_state = 'TX' AND t_year >= 1973 THEN
			make_date(t_year, AUG, 27)] = 'Lyndon Baines Johnson Day'
		END IF;

		-- Labor Day
		IF t_year >= 1894 THEN
			make_date(t_year, SEP, 1) + rd(weekday=MO)] = 'Labor Day'
		END IF;

		-- Columbus Day
		IF p_state not IN ('AK', 'AR', 'DE', 'FL', 'HI', 'NV') THEN
			IF p_state = 'SD' THEN
				t_holiday.description := 'Native American Day'
			ELSIF p_state = 'VI' THEN
				t_holiday.description := 'Columbus Day and Puerto Rico Friendship Day'
			ELSE
				t_holiday.description := 'Columbus Day'
			END IF;
			IF t_year >= 1970 THEN
				make_date(t_year, OCT, 1) + rd(weekday=MO(+2))] = name
			ELSIF t_year >= 1937 THEN
				make_date(t_year, OCT, 12)] = name
			END IF;
		END IF;

		-- Alaska Day
		IF p_state = 'AK' AND t_year >= 1867 THEN
			t_holiday.description := 'Alaska Day'
			make_date(t_year, OCT, 18)] = name
			IF make_date(t_year, OCT, 18).weekday() = SATURDAY THEN
				make_date(t_year, OCT, 18) + rd(days=-1)] = name + ' (Observed)'
			ELSIF make_date(t_year, OCT, 18).weekday() = SUNDAY THEN
				make_date(t_year, OCT, 18) + rd(days=+1)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Nevada Day
		IF p_state = 'NV' AND t_year >= 1933 THEN
			dt = date(t_year, OCT, 31)
			IF t_year >= 2000 THEN
				dt += rd(weekday=FR(-1))
			END IF;
			self[dt] = 'Nevada Day'
			if dt.weekday() = SATURDAY THEN
				self[dt + rd(days=-1)] = 'Nevada Day (Observed)'
			ELSIF dt.weekday() = SUNDAY THEN
				self[dt + rd(days=+1)] = 'Nevada Day (Observed)'
			END IF;
		END IF;

		-- Liberty Day
		IF p_state = 'VI' THEN
			make_date(t_year, NOV, 1)] = 'Liberty Day'
		END IF;

		-- Election Day
		IF (
			p_state IN ('DE', 'HI', 'IL', 'IN', 'LA', 'MT', 'NH', 'NJ', 'NY', 'WV')
			AND t_year >= 2008
			AND t_year % 2 = 0
		)
		OR (
			p_state IN ('IN', 'NY')
			AND t_year >= 2015
		) THEN
			dt = date(t_year, NOV, 1) + rd(weekday=MO)
			self[dt + rd(days=+1)] = 'Election Day'
		END IF;

		-- All Souls' Day
		IF p_state = 'GU' THEN
			make_date(t_year, NOV, 2)] = 'All Souls'' Day'
		END IF;

		-- Veterans Day
		IF t_year > 1953 THEN
			t_holiday.description := 'Veterans Day'
		ELSE
			t_holiday.description := 'Armistice Day'
		END IF;
		IF 1978 > year > 1970 THEN
			make_date(t_year, OCT, 1) + rd(weekday=MO(+4))] = name
		ELSIF t_year >= 1938 THEN
			make_date(t_year, NOV, 11)] = name
			IF make_date(t_year, NOV, 11).weekday() = SATURDAY THEN
				make_date(t_year, NOV, 11) + rd(days=-1)] = name + ' (Observed)'
			ELSIF make_date(t_year, NOV, 11).weekday() = SUNDAY THEN
				make_date(t_year, NOV, 11) + rd(days=+1)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Discovery Day
		IF p_state = 'PR' THEN
			make_date(t_year, NOV, 19)] = 'Discovery Day'
			IF make_date(t_year, NOV, 19).weekday() = SUNDAY THEN
				make_date(t_year, NOV, 20)] = 'Discovery Day (Observed)'
			END IF;
		END IF;

		-- Thanksgiving
		IF t_year > 1870 THEN
			make_date(t_year, NOV, 1) + rd(weekday=TH(+4))] = 'Thanksgiving'
		END IF;

		-- Day After Thanksgiving
		-- Friday After Thanksgiving
		-- Lincoln's Birthday
		-- American Indian Heritage Day
		-- Family Day
		-- New Mexico Presidents' Day
		IF (p_state IN ('DE', 'FL', 'NH', 'NC', 'OK', 'TX', 'WV') AND t_year >= 1975)
		OR (p_state = 'IN' AND t_year >= 2010)
		OR (p_state = 'MD' AND t_year >= 2008)
		OR p_state IN ('NV', 'NM') THEN
			IF p_state IN ('DE', 'NH', 'NC', 'OK', 'WV') THEN
				t_holiday.description := 'Day After Thanksgiving'
			ELSIF p_state IN ('FL', 'TX') THEN
				t_holiday.description := 'Friday After Thanksgiving'
			ELSIF p_state = 'IN' THEN
				t_holiday.description := 'Lincoln''s Birthday'
			ELSIF p_state = 'MD' AND t_year >= 2008 THEN
				t_holiday.description := 'American Indian Heritage Day'
			ELSIF p_state = 'NV' THEN
				t_holiday.description := 'Family Day'
			ELSIF p_state = 'NM' THEN
				t_holiday.description := 'Presidents'' Day'
			END IF;
			dt = date(t_year, NOV, 1) + rd(weekday=TH(+4))
			self[dt + rd(days=+1)] = name
		END IF;

		-- Robert E. Lee's Birthday
		IF p_state = 'GA' AND t_year >= 1986 THEN
			IF t_year >= 2016 THEN
				t_holiday.description := 'State Holiday'
			ELSE
				t_holiday.description := 'Robert E. Lee''s Birthday'
			END IF;
			make_date(t_year, NOV, 29) + rd(weekday=FR(-1))] = name
		END IF;

		-- Lady of Camarin Day
		IF p_state = 'GU' THEN
			make_date(t_year, DEC, 8)] = 'Lady of Camarin Day'
		END IF;

		-- Christmas Eve
		IF p_state = 'AS'
		OR (p_state IN ('KS', 'MI', 'NC') AND t_year >= 2013)
		OR (p_state = 'TX' AND t_year >= 1981)
		OR (p_state = 'WI' AND t_year >= 2012) THEN
			t_holiday.description := 'Christmas Eve'
			make_date(t_year, DEC, 24)] = name
			name = name + ' (Observed)'
			-- If on Friday, observed on Thursday
			IF make_date(t_year, DEC, 24).weekday() = FRIDAY THEN
				make_date(t_year, DEC, 24) + rd(days=-1)] = name
			-- If on Saturday or Sunday, observed on Friday
			ELSIF make_date(t_year, DEC, 24).weekday() IN WEEKEND THEN
				make_date(t_year, DEC, 24) + rd(weekday=FR(-1))] = name
			END IF;
		END IF;

		-- Christmas Day
		IF t_year > 1870 THEN
			t_holiday.description := 'Christmas Day'
			make_date(t_year, DEC, 25)] = 'Christmas Day'
			IF make_date(t_year, DEC, 25).weekday() = SATURDAY THEN
				make_date(t_year, DEC, 25) + rd(days=-1)] = name + ' (Observed)'
			ELSIF make_date(t_year, DEC, 25).weekday() = SUNDAY THEN
				make_date(t_year, DEC, 25) + rd(days=+1)] = name + ' (Observed)'
			END IF;
		END IF;

		-- Day After Christmas
		IF p_state = 'NC' AND t_year >= 2013 THEN
			t_holiday.description := 'Day After Christmas'
			make_date(t_year, DEC, 26)] = name
			name = name + ' (Observed)'
			-- If on Saturday or Sunday, observed on Monday
			IF make_date(t_year, DEC, 26).weekday() IN WEEKEND THEN
				make_date(t_year, DEC, 26) + rd(weekday=MO)] = name
			-- If on Monday, observed on Tuesday
			ELSIF make_date(t_year, DEC, 26).weekday() = MON THEN
				make_date(t_year, DEC, 26) + rd(days=+1)] = name
			END IF;
		ELSIF p_state = 'TX' AND t_year >= 1981 THEN
			make_date(t_year, DEC, 26)] = 'Day After Christmas'
		ELSIF p_state = 'VI' THEN
			make_date(t_year, DEC, 26)] = 'Christmas Second Day'
		END IF;

		-- New Year's Eve
		IF (p_state IN ('KY', 'MI') AND t_year >= 2013)
		OR (p_state = 'WI' AND t_year >= 2012) THEN
			t_holiday.description := 'New Year''s Eve'
			make_date(t_year, DEC, 31)] = name
			IF make_date(t_year, DEC, 31).weekday() = SATURDAY THEN
				make_date(t_year, DEC, 30)] = name + ' (Observed)'
			END IF;
		END IF;

	END LOOP;
END;

$usa$ LANGUAGE plpgsql;