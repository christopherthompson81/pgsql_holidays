------------------------------------------
------------------------------------------
-- Japan Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Japan
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.japan(p_start_year INTEGER, p_end_year INTEGER)
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
	t_year2 INTEGER;
	t_month INTEGER;
	t_day INTEGER;

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- Ensure we're examining a valid year
		IF t_year < 1949 or t_year > 2099 THEN
			RAISE EXCEPTION 'The requested year is not supported by this function --> %', t_year;
		END IF;

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := '元日';
		RETURN NEXT t_holiday;

		-- Coming of Age Day
		IF t_year <= 1999 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 15);
			t_holiday.description := '成人の日';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, JANUARY, 1), MONDAY, 2);
			t_holiday.description := '成人の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Foundation Day
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 11);
		t_holiday.description := '建国記念の日';
		RETURN NEXT t_holiday;

		-- Reiwa Emperor's Birthday
		IF t_year >= 2020 THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 23);
			t_holiday.description := '天皇誕生日';
			RETURN NEXT t_holiday;
		END IF;

		-- Vernal Equinox Day
		t_day := 20;
		IF t_year % 4 = 0 THEN
			IF t_year <= 1956 THEN
				t_day := 21;
			ELSIF t_year >= 2092 THEN
				t_day := 19;
			END IF;
		ELSIF t_year % 4 = 1 THEN
			IF t_year <= 1989 THEN
				t_day := 21;
			END IF;
		ELSIF t_year % 4 = 2 THEN
			IF t_year <= 2022 THEN
				t_day := 21;
			END IF;
		ELSIF t_year % 4 = 3 THEN
			IF t_year <= 2055 THEN
				t_day := 21;
			END IF;
		END IF;
		t_holiday.datestamp := make_date(t_year, MARCH, t_day);
		t_holiday.description := '春分の日';
		RETURN NEXT t_holiday;

		-- Showa Emperor's Birthday, Greenery Day or Showa Day
		IF t_year <= 1988 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 29);
			t_holiday.description := '天皇誕生日';
			RETURN NEXT t_holiday;
		ELSIF t_year <= 2006 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 29);
			t_holiday.description := 'みどりの日';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := make_date(t_year, APRIL, 29);
			t_holiday.description := '昭和の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Constitution Memorial Day
		t_holiday.datestamp := make_date(t_year, MAY, 3);
		t_holiday.description := '憲法記念日';
		RETURN NEXT t_holiday;

		-- Greenery Day
		IF t_year >= 2007 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 4);
			t_holiday.description := 'みどりの日';
			RETURN NEXT t_holiday;
		END IF;

		-- Children's Day
		t_holiday.datestamp := make_date(t_year, MAY, 5);
		t_holiday.description := 'こどもの日';
		RETURN NEXT t_holiday;

		-- Marine Day
		IF t_year BETWEEN 1996 AND 2002 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 20);
			t_holiday.description := '海の日';
			RETURN NEXT t_holiday;
		ELSIF t_year = 2020 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 23);
			t_holiday.description := '海の日';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2003 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, JULY, 1), MONDAY, +3);
			t_holiday.description = '海の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Mountain Day
		IF t_year = 2020 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 10);
			t_holiday.description := '山の日';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2016 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 11);
			t_holiday.description := '山の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Respect for the Aged Day
		IF t_year BETWEEN 1966 AND 2002 THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
			t_holiday.description := '敬老の日';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2003 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), MONDAY, +3);
			t_holiday.description = '敬老の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Autumnal Equinox Day
		t_day := 22;
		IF t_year % 4 = 0 THEN
			IF t_year <= 2008 THEN
				t_day := 23;
			END IF;
		ELSIF t_year % 4 = 1 THEN
			IF t_year <= 2041 THEN
				t_day := 23;
			END IF;
		ELSIF t_year % 4 = 2 THEN
			IF t_year <= 2074 THEN
				t_day := 23;
			END IF;
		ELSIF t_year % 4 = 3 THEN
			IF t_year <= 1979 THEN
				t_day := 24;
			ELSE
				t_day := 23;
			END IF;
		END IF;
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, t_day);
		t_holiday.description := '秋分の日';
		RETURN NEXT t_holiday;

		-- Health and Sports Day
		IF t_year BETWEEN 1966 AND 1999 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 10);
			t_holiday.description := '体育の日';
			RETURN NEXT t_holiday;
		ELSIF t_year = 2020 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 24);
			t_holiday.description := '体育の日';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2000 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MONDAY, +2);
			t_holiday.description = '体育の日';
			RETURN NEXT t_holiday;
		END IF;

		-- Culture Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 3);
		t_holiday.description := '文化の日';
		RETURN NEXT t_holiday;

		-- Labour Thanksgiving Day
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 23);
		t_holiday.description := '勤労感謝の日';
		RETURN NEXT t_holiday;

		-- Heisei Emperor's Birthday
		IF t_year BETWEEN 1989 AND 2018 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 23);
			t_holiday.description := '天皇誕生日';
			RETURN NEXT t_holiday;
		END IF;

		-- Regarding the Emperor of Reiwa
		IF t_year = 2019 THEN
			-- Enthronement Day
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := '天皇の即位の日';
			RETURN NEXT t_holiday;
			-- Enthronement ceremony
			t_holiday.datestamp := make_date(t_year, OCTOBER, 22);
			t_holiday.description := '即位礼正殿の儀が行われる日';
			RETURN NEXT t_holiday;
		END IF;

		-- A weekday between national holidays becomes a holiday too (国民の休日)
		IF t_year in (1993, 1999, 2004, 1988, 1994, 2005, 1989, 1995, 2000, 2006, 1990, 2001, 1991, 1996, 2002) THEN
			t_holiday.datestamp := make_date(t_year, MAY, 4);
			t_holiday.description := '国民の休日';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year in (2032, 2049, 2060, 2077, 2088, 2094) THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 21);
			t_holiday.description := '国民の休日';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year in (2009, 2015, 2026, 2037, 2043, 2054, 2065, 2071, 2099) THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 22);
			t_holiday.description := '国民の休日';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year = 2019 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 30);
			t_holiday.description := '国民の休日';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := '国民の休日';
			RETURN NEXT t_holiday;
		END IF;

		-- Substitute holidays
		IF t_year IN (1978, 1984, 1989, 1995, 2006, 2012, 2017, 2023, 2034, 2040, 2045) THEN
			t_holiday.datestamp := make_date(t_year, 1, 2);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1978, 1984, 1989, 1995) THEN
			t_holiday.datestamp := make_date(t_year, 1, 16);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1979, 1990, 1996, 2001, 2007, 2018, 2024, 2029, 2035, 2046) THEN
			t_holiday.datestamp := make_date(t_year, 2, 12);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (2020) THEN
			t_holiday.datestamp := make_date(t_year, 2, 24);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1988, 2005, 2016, 2033, 2044, 2050) THEN
			t_holiday.datestamp := make_date(t_year, 3, 21);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;	
		IF t_year IN (1982, 1999, 2010, 2027) THEN
			t_holiday.datestamp := make_date(t_year, 3, 22);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1973, 1979, 1984, 1990, 2001, 2007, 2012, 2018, 2029, 2035, 2040, 2046) THEN
			t_holiday.datestamp := make_date(t_year, 4, 30);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1981, 1987, 1992, 1998) THEN
			t_holiday.datestamp := make_date(t_year, 5, 4);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047, 2008, 2014, 2025, 2031, 2036, 2042, 2009, 2015, 2020, 2026, 2037, 2043, 2048) THEN
			t_holiday.datestamp := make_date(t_year, 5, 6);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1997) THEN
			t_holiday.datestamp := make_date(t_year, 7, 21);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (2019, 2024, 2030, 2041, 2047) THEN
			t_holiday.datestamp := make_date(t_year, 8, 12);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1974, 1985, 1991, 1996, 2002) THEN
			t_holiday.datestamp := make_date(t_year, 9, 16);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (2024) THEN
			t_holiday.datestamp := make_date(t_year, 9, 23);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1973, 1984, 1990, 2001, 2007, 2018, 2029, 2035, 2046) THEN
			t_holiday.datestamp := make_date(t_year, 9, 24);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1976, 1982, 1993, 1999) THEN
			t_holiday.datestamp := make_date(t_year, 10, 11);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1974, 1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047) THEN
			t_holiday.datestamp := make_date(t_year, 11, 4);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1975, 1980, 1986, 1997, 2003, 2008, 2014, 2025, 2031, 2036, 2042) THEN
			t_holiday.datestamp := make_date(t_year, 11, 24);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;
		IF t_year IN (1990, 2001, 2007, 2012, 2018) THEN
			t_holiday.datestamp := make_date(t_year, 12, 24);
			t_holiday.description := '振替休日';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;