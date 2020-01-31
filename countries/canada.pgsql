------------------------------------------
------------------------------------------
-- Canadian Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.canada(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $canada$

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
	provinces_array TEXT[] := ARRAY['AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YK'];
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
		IF t_year >= 1867 THEN
			t_datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;
			-- Handle 'observed' days
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_datestamp + '1 day'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				-- Add Dec 31st from the previous year without triggering
				-- the entire year to be added
				t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
			-- The next year's observed New Year's Day can be in this year
			-- when it falls on a Friday (Jan 1st is a Saturday)
			IF DATE_PART('dow', make_date(t_year, DECEMBER, 31)) = FRIDAY THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Family Day / Louis Riel Day (MB) / Islander Day (PE)
		-- / Heritage Day (NS, YT)
		IF p_province = any(ARRAY['AB', 'SK', 'ON']) and t_year >= 2008 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = any(ARRAY['AB', 'SK']) and t_year >= 2007 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'AB' and t_year >= 1990 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NB' and t_year >= 2018 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Family Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'BC' THEN
			IF t_year >= 2013 AND t_year <= 2018 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 2);
				t_holiday.description := 'Family Day';
				RETURN NEXT t_holiday;
			ELSIF t_year > 2018 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
				t_holiday.description := 'Family Day';
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_province = 'MB' AND t_year >= 2008 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Louis Riel Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'PE' AND t_year >= 2010 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Islander Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'PE' and t_year = 2009 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 2);
			t_holiday.description := 'Islander Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NS' AND t_year >= 2015 THEN
			-- http://novascotia.ca/lae/employmentrights/NovaScotiaHeritageDay.asp
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'YT' THEN
			-- start date?
			-- http://heritageyukon.ca/programs/heritage-day
			-- https://en.wikipedia.org/wiki/Family_Day_(Canada)#Yukon_Heritage_Day
			-- Friday before the last Sunday in February
			t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), SUNDAY, -1);
			t_datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;
		END IF;

		-- St. Patrick's Day
		IF p_province = 'NL' AND t_year >= 1900 THEN
			t_datestamp := make_date(t_year, MARCH, 17);
			-- Nearest Monday to March 17
			t_dt1 := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 17), MONDAY, -1);
			t_dt2 := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 17), MONDAY, 1);
			IF t_dt2 - t_datestamp <= t_datestamp - t_dt1 THEN
				t_holiday.datestamp := t_dt2;
				t_holiday.description := 'St. Patrick''s Day';
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := t_dt1;
				t_holiday.description := 'St. Patrick''s Day';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Good Friday
		IF p_province != 'QC' AND t_year >= 1867 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
			t_holiday.description := 'Good Friday';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Monday
		IF p_province = 'QC' AND t_year >= 1867 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), MONDAY, 1);
			t_holiday.description := 'Easter Monday';
			RETURN NEXT t_holiday;
		END IF;

		-- St. George's Day
		IF p_province = 'NL' AND t_year = 2010 THEN
			-- 4/26 is the Monday closer to 4/23 in 2010
			-- but the holiday was observed on 4/19? Crazy Newfies!
			t_holiday.datestamp := make_date(2010, 4, 19);
			t_holiday.description := 'St. George''s Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NL' AND t_year >= 1990 THEN
			t_datestamp := make_date(t_year, APRIL, 23);
			-- Nearest Monday to April 23
			t_dt1 := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			t_dt2 := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			IF t_dt2 - t_datestamp < t_datestamp - t_dt1 THEN
				t_holiday.datestamp := t_dt2;
				t_holiday.description := 'St. George''s Day';
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := t_dt1;
				t_holiday.description := 'St. George''s Day';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Victoria Day / National Patriots' Day (QC)
		IF p_province != ANY(ARRAY['NB', 'NS', 'PE', 'NL', 'QC']) AND t_year >= 1953 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 24), MONDAY, -1);
			t_holiday.description := 'Victoria Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'QC' AND t_year >= 1953 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 24), MONDAY, -1);
			t_holiday.description := 'National Patriots'' Day';
			RETURN NEXT t_holiday;
		END IF;

		-- National Aboriginal Day
		IF p_province = 'NT' AND t_year >= 1996 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 21);
			t_holiday.description := 'National Aboriginal Day';
			RETURN NEXT t_holiday;
		END IF;

		-- St. Jean Baptiste Day
		IF p_province = 'QC' AND t_year >= 1925 THEN
			t_datestamp = make_date(t_year, JUNE, 24);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'St. Jean Baptiste Day';
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 25);
				t_holiday.description := 'St. Jean Baptiste Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Discovery Day
		IF p_province = 'NL' AND t_year >= 1997 THEN
			t_datestamp := make_date(t_year, JUNE, 24);
			-- Nearest Monday to June 24
			t_dt1 := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			t_dt2 := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			IF t_dt2 - t_datestamp <= t_datestamp - t_dt1 THEN
				t_holiday.datestamp := t_dt2;
				t_holiday.description := 'Discovery Day';
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := t_dt1;
				t_holiday.description := 'Discovery Day';
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_province = 'YT' AND t_year >= 1912 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 3);
			t_holiday.description := 'Discovery Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Canada Day / Memorial Day (NL)
		IF p_province != 'NL' AND t_year >= 1867 THEN
			t_datestamp := make_date(t_year, JULY, 1);
			IF t_year >= 1983 THEN
				t_holiday.description := 'Canada Day';
			ELSE
				t_holiday.description := 'Dominion Day';
			END IF;
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 1879 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		ELSIF t_year >= 1867 THEN
			t_datestamp := make_date(t_year, JULY, 1);
			IF t_year >= 1983 THEN
				t_holiday.description := 'Memorial Day';
			ELSE
				t_holiday.description := 'Dominion Day';
			END IF;
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 1879 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Nunavut Day
		IF p_province = 'NU' AND t_year >= 2001 THEN
			t_datestamp := make_date(t_year, JULY, 9);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Nunavut Day';
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, JULY, 10);
				t_holiday.description := 'Nunavut Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		ELSIF p_province = 'NU' AND t_year = 2000 THEN
			t_holiday.datestamp := make_date(2000, APRIL, 1);
			t_holiday.description := 'Nunavut Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Civic Holiday
		IF p_province = ANY(ARRAY['ON', 'MB', 'NT']) AND t_year >= 1900 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'Civic Holiday';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'AB' AND t_year >= 1974 THEN
			-- https://en.wikipedia.org/wiki/Civic_Holiday#Alberta
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'Heritage Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'BC' AND t_year >= 1974 THEN
			-- https://en.wikipedia.org/wiki/Civic_Holiday
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'British Columbia Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NB' AND t_year >= 1900 THEN
			-- https://en.wikipedia.org/wiki/Civic_Holiday
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'New Brunswick Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'SK' AND t_year >= 1900 THEN
			-- https://en.wikipedia.org/wiki/Civic_Holiday
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			t_holiday.description := 'Saskatchewan Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		IF t_year >= 1894 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), MONDAY, 1);
			t_holiday.description := 'Labour Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Thanksgiving
		IF p_province = ANY(ARRAY['NB', 'NS', 'PE', 'NL']) AND t_year >= 1931 THEN
			IF t_year = 1935 THEN
				-- in 1935, Canadian Thanksgiving was moved due to the General
				-- Election falling on the second Monday of October
				-- https://books.google.ca/books?id=KcwlQsmheG4C&pg=RA1-PA1940&lpg=RA1-PA1940&dq=canada+thanksgiving+1935&source=bl&ots=j4qYrcfGuY&sig=gxXeAQfXVsOF9fOwjSMswPHJPpM&hl=en&sa=X&ved=0ahUKEwjO0f3J2PjOAhVS4mMKHRzKBLAQ6AEIRDAG#v=onepage&q=canada%20thanksgiving%201935&f=false
				t_holiday.datestamp := make_date(1935, OCTOBER, 25);
				t_holiday.description := 'Thanksgiving';
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, 2);
				t_holiday.description := 'Thanksgiving';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Remembrance Day
		t_datestamp := make_date(t_year, NOVEMBER, 11);
		IF p_province != ANY(ARRAY['ON','QC','NS','NL','NT','PE','SK']) AND t_year >= 1931 THEN
			t_holiday.description := 'Remembrance Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		ELSIF p_province = ANY(ARRAY['NS','NL','NT','PE','SK']) AND t_year >= 1931 THEN
			t_holiday.description := 'Remembrance Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'Remembrance Day (Observed)';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Christmas Day
		IF t_year >= 1867 THEN
			t_datestamp = make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Christmas Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.description := 'Christmas Day (Observed)';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'Christmas Day (Observed)';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Boxing Day
		IF t_year >= 1867 THEN
			t_datestamp = make_date(t_year, DECEMBER, 26);
			IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.description := 'Boxing Day (Observed)';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = MONDAY THEN
				t_holiday.description := 'Boxing Day (Observed)';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.description := 'Boxing Day';
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			END IF;
		END IF;
	END LOOP;
END;

$canada$ LANGUAGE plpgsql;