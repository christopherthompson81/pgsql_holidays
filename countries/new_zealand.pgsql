------------------------------------------
------------------------------------------
-- New Zealand Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.new_zealand(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	PROVINCES TEXT[] := ARRAY[
		'NTL', 'AUK', 'TKI', 'HKB', 'WGN', 'MBH', 'NSN', 'CAN', 'STC', 'WTL',
		'OTA', 'STL', 'CIT'
	];
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
		IF t_year < 1894 THEN
			RETURN;
		END IF;

		-- New Year's Day
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 3);
			t_holiday.description := 'New Year''s Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Day after New Year's Day
		t_datestamp := make_date(t_year, JANUARY, 2);
		t_holiday.description := 'Day after New Year''s Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 4);
			t_holiday.description := 'Day after New Year''s Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Waitangi Day
		IF t_year > 1973 THEN
			t_holiday.description := 'New Zealand Day';
			IF t_year > 1976 THEN
				t_holiday.description := 'Waitangi Day';
			END IF;
			t_datestamp := make_date(t_year, FEBRUARY, 6);
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 2014 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Easter
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), MONDAY, 1);
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

		-- Anzac Day
		IF t_year > 1920 THEN
			t_datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'Anzac Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF t_year >= 2014 AND DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.description := 'Anzac Day (Observed)';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Sovereign's Birthday
		IF t_year >= 1952 THEN
			t_holiday.description := 'Queen''s Birthday';
		ELSIF t_year > 1901 THEN
			t_holiday.description := 'King''s Birthday';
		END IF;
		IF t_year = 1952 THEN
			-- Elizabeth II
			t_holiday.datestamp := make_date(t_year, JUNE, 2);
			RETURN NEXT t_holiday;
		ELSIF t_year > 1937 THEN
		 	-- EII & GVI;
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, +1);
			RETURN NEXT t_holiday;
		ELSIF t_year = 1937 THEN
			-- George VI
			t_holiday.datestamp := make_date(t_year, JUNE, 9);
			RETURN NEXT t_holiday;
		ELSIF t_year = 1936 THEN
			-- Edward VIII
			t_holiday.datestamp := make_date(t_year, JUNE, 23);
			RETURN NEXT t_holiday;
		ELSIF t_year > 1911 THEN
			-- George V
			t_holiday.datestamp := make_date(t_year, JUNE, 3);
			RETURN NEXT t_holiday;
		ELSIF t_year > 1901 THEN
			-- Edward VII
			-- http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=NZH19091110.2.67
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 9);
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.description := 'Labour Day';
		IF t_year >= 1910 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, +4);
			RETURN NEXT t_holiday;
		ELSIF t_year > 1899 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), WE, +2);
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Day
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			t_holiday.description := 'Christmas Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Boxing Day
		t_datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boxing Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			t_holiday.description := 'Boxing Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Province Anniversary Day
		IF p_province IN ('NTL', 'Northland', 'AUK', 'Auckland') THEN
			IF t_year BETWEEN 1964 AND 1973 AND p_province IN ('NTL', 'Northland') THEN
				t_holiday.description := 'Waitangi Day';
				t_datestamp := make_date(t_year, FEBRUARY, 6);
			ELSE
				t_holiday.description := 'Auckland Anniversary Day';
				t_datestamp := make_date(t_year, JANUARY, 29);
			END IF;
			IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;

		ELSIF p_province IN ('TKI', 'Taranaki', 'New Plymouth') THEN
			t_holiday.description := 'Taranaki Anniversary Day';
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, +2);
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('HKB', 'Hawke''s Bay') THEN
			t_holiday.description := 'Hawke''s Bay Anniversary Day';
			t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, +4);
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('WGN', 'Wellington') THEN
			t_holiday.description := 'Wellington Anniversary Day';
			t_datestamp := make_date(t_year, JANUARY, 22);
			IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;

		ELSIF p_province IN ('MBH', 'Marlborough') THEN
			t_holiday.description := 'Marlborough Anniversary Day';
			t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, +4);
			t_holiday.datestamp := t_datestamp + '1 Week'::INTERVAL;
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('NSN', 'Nelson') THEN
			t_holiday.description := 'Nelson Anniversary Day';
			t_datestamp := make_date(t_year, FEBRUARY, 1);
			IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;

		ELSIF p_province IN ('CAN', 'Canterbury') THEN
			t_holiday.description := 'Canterbury Anniversary Day';
			t_datestamp := holidays.find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), TUESDAY, 1);
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, 2);
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('STC', 'South Canterbury') THEN
			t_holiday.description := 'South Canterbury Anniversary Day';
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), MONDAY, 4);
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('WTL', 'Westland') THEN
			t_holiday.description := 'Westland Anniversary Day';
			t_datestamp := make_date(t_year, DECEMBER, 1);
			-- Observance varies?!?!
			IF t_year = 2005 THEN  -- special case?!?!
				t_holiday.datestamp := make_date(t_year, DECEMBER, 5);
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;

		ELSIF p_province IN ('OTA', 'Otago') THEN
			t_holiday.description := 'Otago Anniversary Day';
			t_datestamp := make_date(t_year, MARCH, 23);
			-- there is no easily determined single day of local observance?!?!
			IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				
			END IF;
			-- Avoid Easter Monday
			IF t_datestamp = holidays.find_nth_weekday_date(holidays.easter(t_year), MONDAY, 1) THEN
				t_holiday.datestamp := t_holiday.datestamp + '1 Day'::INTERVAL;
			END IF;
			RETURN NEXT t_holiday;

		ELSIF p_province IN ('STL', 'Southland') THEN
			t_holiday.description := 'Southland Anniversary Day';
			IF t_year > 2011 THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), TUESDAY, 1);
				RETURN NEXT t_holiday;
			ELSE
				t_datestamp := make_date(t_year, JANUARY, 17);
				IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
					RETURN NEXT t_holiday;
				ELSE
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
					RETURN NEXT t_holiday;
				END IF;
			END IF;

		ELSIF p_province IN ('CIT', 'Chatham Islands') THEN
			t_holiday.description := 'Chatham Islands Anniversary Day';
			t_datestamp := make_date(t_year, NOVEMBER, 30);
			IF DATE_PART('dow', t_datestamp) IN (TUESDAY, WEDNESDAY, THURSDAY) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, -1);
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;