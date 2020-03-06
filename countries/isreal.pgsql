-------------------------------------------------------------------------------
-- Isreal Holidays
--
-- Shabbat, the weekly Sabbath day of rest, in Israel begins every Friday
-- evening just before sundown, ending Saturday evening just after sundown.
-- Most of the Israeli workforce, including schools, banks, public
-- transportation, government offices, and retailers within Jewish Israeli
-- society are shut down during these approximately 25 hours, with some
-- non-Jewish retailers and most non-kosher restaurants still open.
-------------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.israel(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Hebrew months
	NISAN INTEGER := 1;
	IYYAR INTEGER := 2;
	SIVAN INTEGER := 3;
	TAMMUZ INTEGER := 4;
	AV INTEGER := 5;
	ELUL INTEGER := 6;
	TISHRI INTEGER := 7;
	HESHVAN INTEGER := 8;
	KISLEV INTEGER := 9;
	TEVETH INTEGER := 10;
	SHEVAT INTEGER := 11;
	ADAR INTEGER := 12;
	VEADAR INTEGER := 13;
	-- Hebrew Constants
	HEBREW_YEAR_OFFSET INTEGER := 3760;
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	i INTEGER;
	t_holiday holidays.holiday%rowtype;
	is_leap_year BOOLEAN;
	t_reference TEXT;

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		is_leap_year = calendars.leap_year_hebrew(t_year + HEBREW_YEAR_OFFSET);

		-- Purim
		t_holiday.reference := 'Purim';
		t_holiday.description := 'פורים';
		IF is_leap_year THEN
			t_datestamp := calendars.hebrew_to_possible_gregorian(t_year, VEADAR, 14);
		ELSE
			t_datestamp := calendars.hebrew_to_possible_gregorian(t_year, ADAR, 14);
		END IF;
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- Purim Eve
		t_holiday.reference := 'Purim Eve';
		t_holiday.description := 'ערב פורים';
		t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Shushan Purim
		t_holiday.reference := 'Shushan Purim';
		t_holiday.description := 'שושן פורים';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Passover Eve
		t_datestamp := calendars.hebrew_to_possible_gregorian(t_year, NISAN, 14);
		t_holiday.reference := 'Passover Eve';
		t_holiday.description := 'ערב פסח';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- Passover Day 1
		t_holiday.reference := 'Passover Day 1';
		t_holiday.description := 'פסח';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- Passover Days 2 - 6
		t_reference := 'Passover Day ';
		t_holiday.description := 'חול המועד פסח';
		FOR i IN 1..5 LOOP
			t_holiday.reference := t_reference || (i + 1)::TEXT;
			t_holiday.datestamp := t_datestamp + (i::TEXT || ' Days')::INTERVAL;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Passover Day 7
		t_holiday.reference := 'Passover Day 7';
		t_holiday.description := 'שביעי של פסח';
		t_holiday.datestamp := t_datestamp + '6 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Memorial Day
		t_holiday.reference := 'Memorial Day';
		t_holiday.description := 'יום הזיכרון לחללי מערכות ישראל ונפגעי פעולות האיבה';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, IYYAR, 4);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'יום העצמאות';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, IYYAR, 5);
		RETURN NEXT t_holiday;

		-- Lag BaOmer
		t_holiday.reference := 'Lag BaOmer';
		t_holiday.description := 'ל"ג בעומר';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, IYYAR, 18);
		RETURN NEXT t_holiday;

		-- Shavuot Eve
		t_holiday.reference := 'Shavuot Eve';
		t_holiday.description := 'ערב חג השבועות';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, SIVAN, 5);
		RETURN NEXT t_holiday;

		-- Shavuot
		t_holiday.reference := 'Shavuot';
		t_holiday.description := 'שבועות';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, SIVAN, 6);
		RETURN NEXT t_holiday;

		-- Rosh Hashana Eve
		t_holiday.reference := 'Rosh Hashanah Eve';
		t_holiday.description := 'ערב ראש השנה';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, ELUL, 29);
		RETURN NEXT t_holiday;
		
		-- Rosh Hashana
		t_holiday.reference := 'Rosh Hashanah';
		t_holiday.description := 'ראש השנה';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 1);
		RETURN NEXT t_holiday;
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 2);
		RETURN NEXT t_holiday;

		-- Yom Kippur Eve
		t_holiday.reference := 'Yom Kippur Eve';
		t_holiday.description := 'ערב כיפור';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 9);
		RETURN NEXT t_holiday;

		-- Yom Kippur Eve
		t_holiday.reference := 'Yom Kippur';
		t_holiday.description := 'יום כיפור';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 10);
		RETURN NEXT t_holiday;

		-- Sukkot Eve
		t_holiday.reference := 'Sukkot Eve';
		t_holiday.description := 'ערב סוכות';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 14);
		RETURN NEXT t_holiday;

		-- Sukkot
		t_datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 15);
		t_holiday.reference := 'Sukkot Day 1';
		t_holiday.description := 'סוכות';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- Sukkot Days 2 - 7
		t_reference := 'Sukkot Day ';
		t_holiday.description := 'חול המועד סוכות';
		FOR i IN 1..6 LOOP
			t_holiday.reference := t_reference || (i + 1)::TEXT;
			t_holiday.datestamp := t_datestamp + (i::TEXT || ' Days')::INTERVAL;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Simchat Torah / Shmini Atzeret
		t_holiday.reference := 'Simchat Torah / Shmini Atzeret';
		t_holiday.description := 'שמחת תורה / שמיני עצרת';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, TISHRI, 22);
		RETURN NEXT t_holiday;

		-- Hanukkah
		t_reference := 'Hanukkah Day ';
		t_holiday.description := 'חנוכה';
		t_datestamp := calendars.hebrew_to_possible_gregorian(t_year, KISLEV, 25);
		t_holiday.datestamp := t_datestamp;
		FOR i IN 0..7 LOOP
			t_holiday.reference := t_reference || (i + 1)::TEXT;
			t_holiday.datestamp := t_datestamp + (i::TEXT || ' Days')::INTERVAL;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Asarah B'Tevet (Tenth of Tevet)
		-- Observance, Hebrew

		-- Tu Bishvat
		-- Observance, Hebrew

		-- Election Day
		-- National holiday
		-- By law on the third Tuesday of Heshvan, but rarely held on the legislated day.
		-- Example: Monday, March 2, 2020

		-- Fast of Esther
		-- Observance, Hebrew

		-- Aliyah Day
		-- Official Holiday, Business as usual

		-- Yom HaShoah
		-- Observance, Hebrew

		-- Jerusalem Day
		-- Observance, Hebrew

		-- 17th of Tammuz
		-- Observance, Hebrew

		-- Tisha B'Av Eve
		-- Observance, Hebrew

		-- Tisha B'Av
		-- Observance, Hebrew

		-- Gedaliah Fast
		-- Observance, Hebrew

		-- Aliyah Day School Observance
		-- Observance

	END LOOP;
END;

$$ LANGUAGE plpgsql;