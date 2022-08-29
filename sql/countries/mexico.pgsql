------------------------------------------
------------------------------------------
-- Mexico Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.mexico(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Localication
	OBSERVED CONSTANT TEXT := ' (Observed)'; -- Spanish Localization Needed
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_holiday_list holidays.holiday[];

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Reset Array
		t_holiday_list := ARRAY[]::TEXT[];

		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);
		
		-- The next year's observed New Year's Day can be in this year
		-- when it falls on a Friday (Jan 1st is a Saturday)
		t_datestamp := make_date(t_year, DECEMBER, 31);
		IF DATE_PART('dow', t_datestamp) = FRIDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := t_holiday.description || OBSERVED;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		-- Jan 6
		-- Monday
		-- Day of the Holy Kings
		-- Observance

		-- Feb 2
		-- Sunday
		-- Candlemas
		-- Observance

		-- Constitution Day
		-- Double Check Observation Shifting Rules
		t_holiday.reference := 'Constitution Day';
		t_holiday.description := 'Día de la Constitución';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 5);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MONDAY, +1);
			RETURN NEXT t_holiday;
		END IF;

		-- Feb 14
		-- Friday
		-- Valentine's Day
		-- Observance

		-- Feb 24
		-- Monday
		-- Flag Day
		-- Observance

		-- Feb 26
		-- Wednesday
		-- Ash Wednesday
		-- Observance, Christian

		-- Mar 16
		-- Monday
		-- Day off for Benito Juárez's Birthday Memorial
		-- National holiday

		-- Mar 18
		-- Wednesday
		-- Oil Expropriation Day
		-- Observance

		-- Benito Juárez's birthday
		t_holiday.reference := 'Benito Juárez''s birthday';
		t_holiday.description := 'Natalicio de Benito Juárez';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, MARCH, 1), MONDAY, +3);
			RETURN NEXT t_holiday;
		END IF;

		-- Apr 5
		-- Sunday
		-- Palm Sunday
		-- Observance, Christian

		-- Apr 9
		-- Thursday
		-- Maundy Thursday
		-- Bank holiday

		-- Apr 10
		-- Friday
		-- Good Friday
		-- Bank holiday

		-- Apr 11
		-- Saturday
		-- Holy Saturday
		-- Observance

		-- Apr 12
		-- Sunday
		-- Easter Sunday
		-- Observance, Christian

		-- Apr 30
		-- Thursday
		-- Children's Day
		-- Observance

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		IF t_year >= 1923 THEN
			t_datestamp := make_date(t_year, MAY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Día del Trabajo';
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- May 5
		-- Tuesday
		-- Battle of Puebla (Cinco de Mayo)
		-- Common local holiday

		-- May 10
		-- Sunday
		-- Mother's Day
		-- Observance

		-- May 15
		-- Friday
		-- Teacher's Day
		-- Observance

		-- May 21
		-- Thursday
		-- Ascension Day
		-- Observance

		-- May 31
		-- Sunday
		-- Whit Sunday
		-- Observance

		-- Jun 11
		-- Thursday
		-- Corpus Christi
		-- Observance

		-- Jun 21
		-- Sunday
		-- Father's Day
		-- Observance

		-- Aug 15
		-- Saturday
		-- Assumption of Mary
		-- Observance

		-- Sep 15
		-- Tuesday
		-- Shout of Dolores
		-- Observance

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_datestamp := make_date(t_year, SEPTEMBER, 16);
		t_holiday.description := 'Día de la Independencia';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Oct 12
		-- Monday
		-- Columbus Day
		-- Observance

		-- Oct 31
		-- Saturday
		-- Halloween
		-- Observance

		-- Nov 1
		-- Sunday
		-- All Saints' Day
		-- Observance

		-- Nov 2
		-- Monday
		-- All Souls' Day
		-- Observance

		-- Revolution Day
		-- Couble Check Observation Rules
		t_holiday.reference := 'Revolution Day';
		t_holiday.description := 'Día de la Revolución';
		IF t_year BETWEEN 1917 AND 2006 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = holidays.find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), MONDAY, +3);
			RETURN NEXT t_holiday;
		END IF;

		-- Nov 22
		-- Sunday
		-- Christ the King Day
		-- Observance

		-- Change of Federal Government
		-- Every six years
		-- Known Observance: 2018
		t_holiday.reference := 'Change of Federal Government';
		t_holiday.description := 'Transmisión del Poder Ejecutivo Federal';
		IF (2018 - t_year) % 6 = 0 THEN
			t_datestamp := make_date(t_year, DECEMBER, 1);
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- Dec 8
		-- Tuesday
		-- Feast of the Immaculate Conception
		-- Observance

		-- Dec 12
		-- Saturday
		-- Day of the Virgin of Guadalupe
		-- Bank holiday

		-- Dec 24
		-- Thursday
		-- Christmas Eve
		-- Observance, Christian

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Dec 28
		-- Monday
		-- Day of the Holy Innocents
		-- Observance

		-- Dec 31
		-- Thursday
		-- New Year's Eve
		-- Observance

		-- Apply observation shifting rules to the above.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			t_holiday.observation_shifted := TRUE;
			IF DATE_PART('dow', t_holiday.datestamp) = SATURDAY THEN
				t_holiday.datestamp := t_holiday.datestamp - '1 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || OBSERVED;
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_holiday.datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_holiday.datestamp + '1 Days'::INTERVAL;
				t_holiday.description := t_holiday.description || OBSERVED;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;