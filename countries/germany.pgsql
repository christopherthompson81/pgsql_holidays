------------------------------------------
------------------------------------------
-- Germany Holidays
--
-- Official holidays for Germany in its current form.
-- 
-- This class doesn't return any holidays before 1990-10-03.
-- 
-- Before that date the current Germany was separated into the 'German
-- Democratic Republic' and the 'Federal Republic of Germany' which both had
-- somewhat different holidays. Since this class is called 'Germany' it
-- doesn't really make sense to include the days from the two former
-- countries.
-- 
-- Note that Germany doesn't have rules for holidays that happen on a
-- Sunday. Those holidays are still holiday days but there is no additional
-- day to make up for the 'lost' day.
-- 
-- Also note that German holidays are partly declared by each province there
-- are some weired edge cases:
-- 
-- - 'Mariä Himmelfahrt' is only a holiday in Bavaria (BY) if your
-- municipality is mostly catholic which in term depends on census data.
-- Since we don't have this data but most municipalities in Bavaria
-- *are* mostly catholic, we count that as holiday for whole Bavaria.
-- - There is an 'Augsburger Friedensfest' which only exists in the town
-- Augsburg. This is excluded for Bavaria.
-- - 'Gründonnerstag' (Thursday before easter) is not a holiday but pupils
-- don't have to go to school (but only in Baden Württemberg) which is
-- solved by adjusting school holidays to include this day. It is
-- excluded from our list.
-- - 'Fronleichnam' is a holiday in certain, explicitly defined
-- municipalities in Saxony (SN) and Thuringia (TH). We exclude it from
-- both provinces.
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.germany(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
		'BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW', 'RP', 'SL',
		'SN', 'ST', 'SH', 'TH'
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
		IF t_year <= 1989 THEN
			RETURN;
		END IF;
		
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		IF t_year > 1990 THEN

			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Neujahr';
			RETURN NEXT t_holiday;

			IF p_province IN ('BW', 'BY', 'ST') THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 6);
				t_holiday.description := 'Heilige Drei Könige';
				RETURN NEXT t_holiday;
			END IF;

			t_datestamp := holidays.easter(t_year);
			t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
			t_holiday.description := 'Karfreitag';
			RETURN NEXT t_holiday;

			IF p_province = 'BB' THEN
				-- will always be a Sunday and we have no 'observed' rule so
				-- this is pretty pointless but it's nonetheless an official
				-- holiday by law
				t_holiday.datestamp := t_datestamp;
				t_holiday.description := 'Ostersonntag';
				RETURN NEXT t_holiday;
			END IF;

			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Ostermontag';
			RETURN NEXT t_holiday;

			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Erster Mai';
			RETURN NEXT t_holiday;

			IF p_province = 'BE' AND t_year = 2020 THEN
				t_holiday.datestamp := make_date(t_year, MAY, 8);
				t_holiday.description := '75. Jahrestag der Befreiung vom Nationalsozialismus und der Beendigung des Zweiten Weltkriegs in Europa';
				RETURN NEXT t_holiday;
			END IF;

			t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
			t_holiday.description := 'Christi Himmelfahrt';
			RETURN NEXT t_holiday;

			IF p_province = 'BB' THEN
				-- will always be a Sunday and we have no 'observed' rule so
				-- this is pretty pointless but it's nonetheless an official
				-- holiday by law
				t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
				t_holiday.description := 'Pfingstsonntag';
				RETURN NEXT t_holiday;
			END IF;

			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			t_holiday.description := 'Pfingstmontag';
			RETURN NEXT t_holiday;

			IF p_province IN ('BW', 'BY', 'HE', 'NW', 'RP', 'SL') THEN
				t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
				t_holiday.description := 'Fronleichnam';
				RETURN NEXT t_holiday;
			END IF;

			IF p_province IN ('BY', 'SL') THEN
				t_holiday.datestamp := make_date(t_year, AUGUST, 15);
				t_holiday.description := 'Mariä Himmelfahrt';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
		t_holiday.description := 'Tag der Deutschen Einheit';
		RETURN NEXT t_holiday;

		IF p_province IN ('BB', 'MV', 'SN', 'ST', 'TH') THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province IN ('HB', 'SH', 'NI', 'HH') AND t_year >= 2018 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;
		END IF;

		-- in 2017 all states got the Reformationstag (500th anniversary of
		-- Luther's thesis)
		IF t_year = 2017 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province IN ('BW', 'BY', 'NW', 'RP', 'SL') THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Allerheiligen';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year <= 1994 OR p_province = 'SN' THEN
			-- can be calculated as 'last wednesday before year-11-23' which is
			-- why we need to go back two wednesdays if year-11-23 happens to be
			-- a wednesday
			t_datestamp = make_date(t_year, NOVEMBER, 23);
			IF DATE_PART('dow', t_datestamp) = WEDNESDAY THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, WEDNESDAY, -2);
			ELSE
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, WEDNESDAY, -1);
			END IF;
			t_holiday.description := 'Buß- und Bettag';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 2019 THEN
			IF p_province = 'TH' THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 20);
				t_holiday.description := 'Weltkindertag';
				RETURN NEXT t_holiday;
			END IF;

			IF p_province = 'BE' THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 8);
				t_holiday.description := 'Internationaler Frauentag';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Erster Weihnachtstag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Zweiter Weihnachtstag';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;