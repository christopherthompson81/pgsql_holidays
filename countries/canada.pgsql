------------------------------------------
------------------------------------------
-- Canada Holidays
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
		-- Defaults for additional attributes
		t_holiday.authority := 'federal';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- Jan 1
		-- New Year's Day
		-- National holiday

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		IF t_year >= 1867 THEN
			t_datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'New Year''s Day';
			RETURN NEXT t_holiday;
			-- Handle 'observed' days
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_datestamp + '1 day'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				-- Add Dec 31st from the previous year without triggering
				-- the entire year to be added
				t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
			-- The next year's observed New Year's Day can be in this year
			-- when it falls on a Friday (Jan 1st is a Saturday)
			IF DATE_PART('dow', make_date(t_year, DECEMBER, 31)) = FRIDAY THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
				t_holiday.description := 'New Year''s Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Jan 2
		-- Day After New Year’s Day
		-- Local holiday
		-- Quebec

		-- Jan 6
		-- Epiphany
		-- Observance, Christian

		-- Jan 7
		-- Orthodox Christmas Day
		-- Orthodox

		-- Jan 14
		-- Orthodox New Year
		-- Orthodox

		-- Jan 25
		-- Chinese New Year
		-- Observance

		-- Feb 2
		-- Groundhog Day
		-- Observance

		-- Feb 10
		-- Tu B'Shevat (Arbor Day)
		-- Jewish holiday

		-- Feb 14
		-- Valentine's Day
		-- Observance

		-- Feb 15
		-- National Flag of Canada Day
		-- Observance

		-- Feb 17
		-- Islander Day
		-- Common local holiday
		-- Prince Edward Island

		-- Feb 17
		-- Family Day
		-- Common local holiday
		-- AB, BC, NB, ON, SK

		-- Feb 17
		-- Nova Scotia Heritage Day
		-- Common local holiday
		-- Nova Scotia

		-- Feb 17
		-- Louis Riel Day
		-- Common local holiday
		-- Manitoba

		-- Feb 21
		-- Yukon Heritage Day
		-- Local de facto holiday
		-- Yukon


		

		-- Family Day / Louis Riel Day (MB) / Islander Day (PE)
		-- / Heritage Day (NS, YT)
		t_holiday.reference := 'Family Day';
		t_holiday.authority := 'provincial';
		t_holiday.description := 'Family Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 3);
		IF p_province = any(ARRAY['AB', 'SK', 'ON']) and t_year >= 2008 THEN
			RETURN NEXT t_holiday;
		ELSIF p_province = any(ARRAY['AB', 'SK']) and t_year >= 2007 THEN
			RETURN NEXT t_holiday;
		ELSIF p_province = 'AB' and t_year >= 1990 THEN
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NB' and t_year >= 2018 THEN
			RETURN NEXT t_holiday;
		ELSIF p_province = 'BC' THEN
			IF t_year BETWEEN 2013 AND 2018 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 2);
				RETURN NEXT t_holiday;
			ELSIF t_year > 2018 THEN
				RETURN NEXT t_holiday;
			END IF;
		END IF;
		-- Louis Riel Day (MB)
		t_holiday.reference := 'Louis Riel Day';
		IF p_province = 'MB' AND t_year >= 2008 THEN
			t_holiday.description := 'Louis Riel Day';
			RETURN NEXT t_holiday;
		END IF;
		-- Islander Day (PE)
		t_holiday.reference := 'Islander Day';
		IF p_province = 'PE' AND t_year >= 2010 THEN
			t_holiday.description := 'Islander Day';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'PE' and t_year = 2009 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, 2);
			t_holiday.description := 'Islander Day';
			RETURN NEXT t_holiday;
		END IF;
		-- Heritage Day (NS, YT)
		t_holiday.reference := 'Heritage Day';
		IF p_province = 'NS' AND t_year >= 2015 THEN
			-- http://novascotia.ca/lae/employmentrights/NovaScotiaHeritageDay.asp
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


		-- Feb 25
		-- Carnival / Shrove Tuesday
		-- Christian

		-- Feb 26
		-- Ash Wednesday
		-- Christian

		-- Mar 1
		-- St David's Day
		-- Observance

		-- Mar 8
		-- Daylight Saving Time starts
		-- Clock change/Daylight Saving Time

		-- Mar 9
		-- Commonwealth Day
		-- Observance

		-- Mar 10
		-- Purim
		-- Jewish holiday

		-- Mar 16
		-- St. Patrick's Day
		-- Local holiday
		-- Newfoundland and Labrador

		-- Mar 17
		-- St. Patrick's Day
		-- Observance

		-- St. Patrick's Day
		t_holiday.reference := 'St. Patrick''s Day';
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

		-- Mar 19
		-- March Equinox
		-- Season

		-- Mar 22
		-- Isra and Mi'raj
		-- Muslim

		-- Apr 5
		-- Palm Sunday
		-- Christian

		-- Apr 6
		-- National Tartan Day
		-- Observance

		-- Apr 9
		-- Maundy Thursday
		-- Christian

		-- Apr 9
		-- First day of Passover
		-- Jewish holiday

		-- Apr 9
		-- Vimy Ridge Day
		-- Observance

		-- Apr 10
		-- Good Friday
		-- National holiday, Christian

		-- Apr 11
		-- Holy Saturday
		-- Christian

		-- Apr 12
		-- Easter Sunday
		-- Designated Retail Closing Day
		-- Nova Scotia

		-- Apr 12
		-- Easter Sunday
		-- Observance, Christian

		-- Apr 13
		-- Easter Monday
		-- National holiday
		-- NB, NT, NU, QC

		-- Apr 13
		-- Easter Monday
		-- Optional holiday
		-- Alberta

		-- Apr 13
		-- Easter Monday
		-- Local de facto holiday
		-- Yukon

		-- Apr 16
		-- Last day of Passover
		-- Jewish holiday

		-- Apr 17
		-- Orthodox Good Friday
		-- Orthodox

		-- Apr 18
		-- Orthodox Holy Saturday
		-- Orthodox

		-- Apr 19
		-- Orthodox Easter
		-- Orthodox

		-- Apr 20
		-- Orthodox Easter Monday
		-- Orthodox

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.authority := 'federal';
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


		-- Apr 20
		-- St. George's Day
		-- Local holiday
		-- Newfoundland and Labrador

		-- Apr 21
		-- Yom HaShoah
		-- Jewish commemoration

		-- Apr 24
		-- Ramadan Start
		-- Muslim

		-- Apr 29
		-- Yom HaAtzmaut
		-- Jewish holiday

		-- May 10
		-- Mother's Day
		-- Observance

		-- May 12
		-- Lag B'Omer
		-- Jewish holiday

		-- St. George's Day
		t_holiday.reference := 'St. George''s Day';
		t_holiday.authority := 'provincial';
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

		-- May 18
		-- Victoria Day
		-- National holiday
		-- All except NS, PE, QC

		-- May 18
		-- National Patriots' Day
		-- Local holiday
		-- Quebec

		-- May 19
		-- Laylatul Qadr (Night of Power)
		-- Muslim

		-- May 21
		-- Ascension Day
		-- Christian


		-- Victoria Day / National Patriots' Day (QC)
		t_holiday.reference := 'Victoria Day';
		IF p_province != ANY(ARRAY['NB', 'NS', 'PE', 'NL', 'QC']) AND t_year >= 1953 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 24), MONDAY, -1);
			t_holiday.description := 'Victoria Day';
			t_holiday.authority := 'federal';
			RETURN NEXT t_holiday;
			t_holiday.authority := 'provincial';
		ELSIF p_province = 'QC' AND t_year >= 1953 THEN
			t_holiday.reference := 'National Patriots'' Day';
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 24), MONDAY, -1);
			t_holiday.description := 'National Patriots'' Day';
			RETURN NEXT t_holiday;
		END IF;

		-- May 24
		-- Eid ul Fitr
		-- Muslim

		-- May 29
		-- Shavuot
		-- Jewish holiday

		-- May 31
		-- Pentecost
		-- Christian

		-- Jun 1
		-- Whit Monday
		-- Christian

		-- Jun 7
		-- Trinity Sunday
		-- Christian

		-- Jun 11
		-- Corpus Christi
		-- Christian

		-- Jun 20
		-- June Solstice
		-- Season

		-- Jun 21
		-- Father's Day
		-- Observance

		-- Jun 21
		-- National Indigenous Peoples Day
		-- Observance

		-- Jun 21
		-- National Indigenous Peoples Day
		-- Local holiday
		-- Northwest Territories, Yukon


		-- National Aboriginal Day
		t_holiday.reference := 'National Aboriginal Day';
		IF p_province = 'NT' AND t_year >= 1996 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 21);
			t_holiday.description := 'National Aboriginal Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Jun 22
		-- Discovery Day
		-- Local holiday
		-- Newfoundland and Labrador

		-- Jun 24
		-- St. Jean Baptiste Day
		-- Local holiday
		-- Quebec

		-- St. Jean Baptiste Day
		t_holiday.reference := 'St. Jean Baptiste Day';
		IF p_province = 'QC' AND t_year >= 1925 THEN
			t_datestamp = make_date(t_year, JUNE, 24);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'St. Jean Baptiste Day';
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 25);
				t_holiday.description := 'St. Jean Baptiste Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Discovery Day
		t_holiday.reference := 'Discovery Day';
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

		-- Jul 1
		-- Canada Day
		-- National holiday

		-- Jul 1
		-- Memorial Day
		-- Local holiday
		-- Newfoundland and Labrador

		-- Canada Day / Memorial Day (NL)
		t_holiday.reference := 'Canada Day';
		t_holiday.authority := 'federal';
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
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
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
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Jul 9
		-- Nunavut Day
		-- Local holiday
		-- Nunavut

		-- Jul 13
		-- Orangemen's Day
		-- Local holiday
		-- Newfoundland and Labrador

		-- Jul 30
		-- Tisha B'Av
		-- Jewish holiday

		-- Jul 31
		-- Eid ul Adha
		-- Muslim

		-- Nunavut Day
		t_holiday.reference := 'Nunavut Day';
		t_holiday.authority := 'provincial';
		IF p_province = 'NU' AND t_year >= 2001 THEN
			t_datestamp := make_date(t_year, JULY, 9);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Nunavut Day';
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := make_date(t_year, JULY, 10);
				t_holiday.description := 'Nunavut Day (Observed)';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		ELSIF p_province = 'NU' AND t_year = 2000 THEN
			t_holiday.datestamp := make_date(2000, APRIL, 1);
			t_holiday.description := 'Nunavut Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Aug 3
		-- Heritage Day
		-- Optional holiday
		-- Alberta

		-- Aug 3
		-- Civic/Provincial Day
		-- Common local holiday
		-- Northwest Territories, Nunavut

		-- Aug 3
		-- Civic/Provincial Day
		-- Local observance
		-- Ontario

		-- Aug 3
		-- Saskatchewan Day
		-- Common local holiday
		-- Saskatchewan

		-- Aug 3
		-- Terry Fox Day
		-- Local observance
		-- Manitoba

		-- Aug 3
		-- New Brunswick Day
		-- Prescribed Day of Rest
		-- New Brunswick

		-- Aug 3
		-- British Columbia Day
		-- Common local holiday
		-- British Columbia

		-- Aug 3
		-- Natal Day
		-- Common local holiday
		-- Nova Scotia

		-- Civic Holiday
		t_holiday.reference := 'Civic Holiday';
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

		-- Aug 5
		-- The Royal St John's Regatta (Regatta Day)
		-- Local holiday
		-- Newfoundland and Labrador

		-- Aug 15
		-- Assumption of Mary
		-- Christian

		-- Aug 17
		-- Discovery Day
		-- Local holiday
		-- Yukon

		-- Aug 20
		-- Muharram/Islamic New Year
		-- Muslim

		-- Aug 21
		-- Gold Cup Parade
		-- Local holiday
		-- Prince Edward Island

		-- Sep 7
		-- Labour Day
		-- National holiday

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.authority := 'federal';
		IF t_year >= 1894 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), MONDAY, 1);
			t_holiday.description := 'Labour Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Sep 19
		-- Rosh Hashana
		-- Jewish holiday

		-- Sep 22
		-- September Equinox
		-- Season

		-- Sep 28
		-- Yom Kippur
		-- Jewish holiday

		-- Oct 3
		-- First day of Sukkot
		-- Jewish holiday

		-- Oct 4
		-- Feast of St Francis of Assisi
		-- Christian

		-- Oct 9
		-- Hoshana Rabbah
		-- Jewish holiday

		-- Oct 10
		-- Shemini Atzeret
		-- Jewish holiday

		-- Oct 11
		-- Simchat Torah
		-- Jewish holiday

		-- Oct 12
		-- Thanksgiving Day
		-- National holiday
		-- All except NB, NS, PE

		-- Oct 12
		-- Thanksgiving Day
		-- Designated Retail Closing Day
		-- Nova Scotia

		-- Oct 12
		-- Thanksgiving Day
		-- Prescribed Day of Rest
		-- New Brunswick

		-- Thanksgiving
		t_holiday.reference := 'Thanksgiving';
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

		-- Oct 18
		-- Healthcare Aide Day
		-- Observance
		-- British Columbia, Manitoba

		-- Oct 29
		-- Milad un Nabi (Mawlid)
		-- Muslim

		-- Oct 31
		-- Halloween
		-- Observance

		-- Nov 1
		-- Daylight Saving Time ends
		-- Clock change/Daylight Saving Time

		-- Nov 1
		-- All Saints' Day
		-- Observance, Christian

		-- Nov 2
		-- All Souls' Day
		-- Observance, Christian

		-- Nov 11
		-- Remembrance Day
		-- National holiday
		-- All except MB, NS, ON, QC

		-- Nov 11
		-- Remembrance Day
		-- Observance
		-- MB, NS, ON

		-- Remembrance Day
		t_holiday.reference := 'Remembrance Day';
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
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Nov 14
		-- Diwali/Deepavali
		-- Observance

		-- Nov 29
		-- First Sunday of Advent
		-- Observance

		-- Dec 8
		-- Feast of the Immaculate Conception
		-- Christian

		-- Dec 11
		-- First Day of Hanukkah
		-- Jewish holiday

		-- Dec 11
		-- Anniversary of the Statute of Westminster
		-- Observance

		-- Dec 18
		-- Last day of Hanukkah
		-- Jewish holiday

		-- Dec 21
		-- December Solstice
		-- Season

		-- Dec 24
		-- Christmas Eve
		-- Observance

		-- Dec 25
		-- Christmas Day
		-- National holiday, Christian

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		IF t_year >= 1867 THEN
			t_datestamp = make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Christmas Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.description := 'Christmas Day (Observed)';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := 'Christmas Day (Observed)';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- Dec 26
		-- Boxing Day
		-- National holiday
		-- NB, NL, NT, NU, ON

		-- Dec 26
		-- Boxing Day
		-- Designated Retail Closing Day
		-- Nova Scotia

		-- Dec 26
		-- Boxing Day
		-- Optional holiday
		-- Alberta

		-- Dec 26
		-- Boxing Day
		-- Local de facto holiday
		-- Yukon

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		IF t_year >= 1867 THEN
			t_datestamp = make_date(t_year, DECEMBER, 26);
			IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.description := 'Boxing Day (Observed)';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSE
				t_holiday.description := 'Boxing Day';
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Dec 31
		-- New Year's Eve
		-- Observance

	END LOOP;
END;

$canada$ LANGUAGE plpgsql;