------------------------------------------
------------------------------------------
-- UK Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_the_United_Kingdom
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_country TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Countries
	COUNTRIES TEXT[] := ARRAY['England', 'Ireland', 'Isle of Man', 'Northern Ireland', 'Scotland', 'UK', 'Wales'];
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
			t_datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'New Year''s Day';
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_datestamp + '+1 Days'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := t_datestamp + '+2 Days'::INTERVAL;
				t_holiday.description := 'New Year''s Day (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- New Year Holiday
		IF p_country IN ('UK', 'Scotland') THEN
			t_datestamp := make_date(t_year, JANUARY, 2);
			t_holiday.description := 'New Year Holiday';
			IF p_country = 'UK' THEN
				t_holiday.description := 'New Year Holiday [Scotland]';
			END IF;
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := t_datestamp + '+2 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) = MONDAY THEN
				t_holiday.datestamp := t_datestamp + '+1 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- St. Patrick's Day
		IF p_country IN ('UK', 'Northern Ireland', 'Ireland') THEN
			t_datestamp := make_date(t_year, MARCH, 17);
			t_holiday.description := 'St. Patrick''s Day';
			IF p_country = 'UK' THEN
				t_holiday.description := 'St. Patrick''s Day [Northern Ireland]'
			END IF;
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			IF DATE_PART('dow', t_datestamp) IN WEEKEND THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || ' (Observed)';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		IF p_country != 'Ireland' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			t_holiday.description := 'Good Friday';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Monday
		IF p_country != 'Scotland' THEN
			t_holiday.description := 'Easter Monday';
			IF p_country = 'UK' THEN
				t_holiday.description := 'Easter Monday [England, Wales, Northern Ireland]';
			END IF;
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			RETURN NEXT t_holiday;
		END IF;

		-- May Day bank holiday (first Monday in May)
		IF t_year >= 1978 THEN
			t_holiday.description := 'May Day';
			IF t_year = 2020 AND p_country != 'Ireland' THEN
				-- Moved to Friday to mark 75th anniversary of VE Day.
				t_holiday.datestamp := make_date(t_year, MAY, 8);
				RETURN NEXT t_holiday;
			ELSE
				IF t_year = 1995 THEN
					t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 8), MONDAY, 1);
				ELSE
					t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), MONDAY, 1);
				END IF;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Spring bank holiday (last Monday in May)
		IF p_country != 'Ireland' THEN
			t_holiday.description := 'Spring Bank Holiday';
			IF t_year = 2012 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 4);
				RETURN NEXT t_holiday;
			ELSIF t_year >= 1971 THEN
				t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAY, 31), MONDAY, -1);
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- June bank holiday (first Monday in June)
		IF p_country = 'Ireland' THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUNE, 1), MONDAY, 1);
			t_holiday.description = 'June Bank Holiday';
			RETURN NEXT t_holiday;
		END IF;

		-- TT bank holiday (first Friday in June)
		IF p_country = 'Isle of Man' THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUNE, 1), FRIDAY, 1);
			t_holiday.description = 'TT Bank Holiday';
			RETURN NEXT t_holiday;
		END IF;

		-- Tynwald Day
		IF p_country = 'Isle of Man' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 5);
			t_holiday.description := 'Tynwald Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Battle of the Boyne
		IF p_country IN ('UK', 'Northern Ireland') THEN
			t_holiday.description := 'Battle of the Boyne';
			IF p_country = 'UK' THEN
				t_holiday.description := 'Battle of the Boyne [Northern Ireland]';
			END IF;
			t_holiday.datestamp := make_date(t_year, JULY, 12);
			RETURN NEXT t_holiday;
		END IF;

		-- Summer bank holiday (first Monday in August)
		IF p_country IN ('UK', 'Scotland', 'Ireland') THEN
			t_holiday.description := 'Summer Bank Holiday';
			IF p_country = 'UK' THEN
				t_holiday.description := 'Summer Bank Holiday [Scotland]';
			END IF;
			t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), MONDAY, 1);
			RETURN NEXT t_holiday;
		END IF;

		-- Late Summer bank holiday (last Monday in August)
		IF p_country NOT IN ('Scotland', 'Ireland') AND t_year >= 1971 THEN
			t_holiday.description := 'Late Summer Bank Holiday';
			IF p_country = 'UK' THEN
				t_holiday.description := 'Late Summer Bank Holiday [England, Wales, Northern Ireland]';
			END IF;
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, AUGUST, 31), MONDAY, -1);
			RETURN NEXT t_holiday;
		END IF;

		-- October Bank Holiday (last Monday in October)
		IF p_country = 'Ireland' THEN
			t_holiday.description := 'October Bank Holiday';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCTOBER, 31), MONDAY, -1);
			RETURN NEXT t_holiday;
		END IF;

		-- St. Andrew's Day
		IF p_country IN ('UK', 'Scotland') THEN
			t_holiday.description := 'St. Andrew''s Day';
			IF p_country = 'UK' THEN
				t_holiday.description := 'St. Andrew''s Day [Scotland]';
			END IF;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 30);
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Day
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			t_holiday.description := 'Christmas Day (Observed)';
			RETURN NEXT t_holiday;
		ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			t_holiday.description := 'Christmas Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Boxing Day
		t_datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boxing Day';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			t_holiday.description := 'Boxing Day (Observed)';
			RETURN NEXT t_holiday;
		ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			t_holiday.description := 'Boxing Day (Observed)';
			RETURN NEXT t_holiday;
		END IF;

		-- Special holidays
		IF p_country != 'Ireland' THEN
			IF t_year = 1977 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 7);
				t_holiday.description := 'Silver Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			ELSIF t_year = 1981 THEN
				t_holiday.datestamp := make_date(t_year, JULY, 29);
				t_holiday.description := 'Wedding of Charles and Diana';
				RETURN NEXT t_holiday;
			ELSIF t_year = 1999 THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
				t_holiday.description := 'Millennium Celebrations';
				RETURN NEXT t_holiday;
			ELSIF t_year = 2002 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 3);
				t_holiday.description := 'Golden Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			ELSIF t_year = 2011 THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 29);
				t_holiday.description := 'Wedding of William and Catherine';
				RETURN NEXT t_holiday;
			ELSIF t_year = 2012 THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 5);
				t_holiday.description := 'Diamond Jubilee of Elizabeth II';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;