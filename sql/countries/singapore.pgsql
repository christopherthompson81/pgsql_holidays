------------------------------------------
------------------------------------------
-- Singapore Holidays (Porting Unfinished)
--
-- Holidays Act: https://sso.agc.gov.sg/Act/HA1998
-- https://www.mom.gov.sg/employment-practices/public-holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Singapore

-- Holidays prior to 1969 (Act 24 of 1968—Holidays (Amendment) Act 1968)
-- are estimated.

-- Holidays prior to 2000 may not be accurate.

-- Holidays after 2020: the following four moving date holidays whose exact
-- date is announced yearly are estimated (and so denoted):
-- - Hari Raya Puasa*
-- - Hari Raya Haji*
-- - Vesak Day
-- - Deepavali
--
-- * only if hijri-converter library is installed, otherwise a warning is
--  raised that this holiday is missing.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.singapore(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Hijri Month Constants
	MUHARRAM INTEGER := 1;
	SAFAR INTEGER := 2;
	RABI_AL_AWWAL INTEGER := 3;
	RABI_AL_THANI INTEGER := 4;
	JUMADA_AL_AWWAL INTEGER := 5;
	JUMADA_AL_THANI INTEGER := 6;
	RAJAB INTEGER := 7;
	SHABAN INTEGER := 8;
	RAMADAN INTEGER := 9;
	SHAWWAL INTEGER := 10;
	DHU_AL_QIDAH INTEGER := 11;
	DHU_AL_HIJJAH INTEGER := 12;
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_description TEXT;
	t_easter DATE;
	t_holiday holidays.holiday%rowtype;
	t_shifting_holidays holidays.holiday[];

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.description := '元旦';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Chinese New Year (two days)
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		t_holiday.reference := 'Chinese New Year';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := '春節';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- End of Ramadan (Eid e Fitr) / Hari Raya Puasa
		-- hijri 1 Shawwal
		-- date of observance is announced yearly
		t_holiday.reference := 'End of Ramadan (Eid e Fitr)';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Hari Raya Puasa';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Hari Raya Puasa Day 2';
			t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);
		END LOOP;

		-- Feast of the Sacrifice (Eid al-Adha) / Hari Raya Haji
		-- hijri 10 Dhu al-Hijjah
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 10)
		LOOP
			t_holiday.reference := 'Feast of the Sacrifice (Eid al-Adha)';
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Hari Raya Haji';
			t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);
		END LOOP;

		-- Easter related dates
		t_easter := holidays.easter(t_year);

		-- Holy Saturday (up to and including 1968)
		IF t_year <= 1968 THEN
			t_holiday.datestamp := t_easter - '1 Day'::INTERVAL;
			t_holiday.reference := 'Holy Saturday';
			t_holiday.description := 'Holy Saturday';
			RETURN NEXT t_holiday;
		END IF;

		-- Good Friday
		t_holiday.datestamp := t_easter - '2 Days'::INTERVAL;
		t_holiday.reference := 'Good Friday';
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		-- Easter Monday
		IF t_year <= 1968 THEN
			t_holiday.datestamp := t_easter + '1 Day'::INTERVAL;
			t_holiday.reference := 'Easter Monday';
			t_holiday.description := 'Easter Monday';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.reference := 'Labour Day';
		t_holiday.description := 'Labour Day';
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Birthday of the Buddha / Vesek
		t_holiday.reference := 'Birthday of the Buddha / Vesek';
		t_holiday.description := '佛誕';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 4,
			c_leap_month => FALSE,
			c_day => 8
		);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- National Day
		t_holiday.datestamp := make_date(t_year, AUGUST, 9);
		t_holiday.reference := 'National Day';
		t_holiday.description := 'National Day';
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Deepavali
		-- aka Diwali
		-- date of observance is announced yearly
		-- Diwali is usually celebrated eighteen days after the Dussehra festival
		-- Dussehra starts on Ashvin Shukla Prathama
		-- Ashwin begins on the new moon after the autumn equinox
		-- Shukla Prathama is the full moon thereafter
		-- Unimplemented

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.reference := 'Christmas Day';
		t_holiday.description := 'Christmas Day';
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Boxing day (up to and including 1968)
		IF t_year <= 1968 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.reference := 'Boxing Day';
			t_holiday.description := 'Boxing Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Polling Day
		t_holiday.reference := 'Polling Day';
		t_holiday.description := 'Polling Day';
		IF t_year = 2001 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 3);
			RETURN NEXT t_holiday;
		ELSIF t_year = 2006 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 6);
			RETURN NEXT t_holiday;
		ELSIF t_year = 2011 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 7);
			RETURN NEXT t_holiday;
		ELSIF t_year = 2015 THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 11);
			RETURN NEXT t_holiday;
		END IF;

		-- SG50 Public holiday
		-- Announced on 14 March 2015
		-- https://www.mom.gov.sg/newsroom/press-releases/2015/sg50-public-holiday-on-7-august-2015
		IF t_year = 2015 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 7);
			t_holiday.reference := 'SG50 Public Holiday';
			t_holiday.description := 'SG50 Public Holiday';
			RETURN NEXT t_holiday;
		END IF;

		-- implement Section 4(2) of the Holidays Act:
		-- 'if any day specified in the Schedule falls on a Sunday,
		-- the day next following not being itself a public holiday
		-- is declared a public holiday in Singapore.'
		FOREACH t_holiday IN ARRAY t_shifting_holidays LOOP
			t_datestamp := t_holiday.datestamp;
			t_description := t_holiday.description;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.description := t_description || ' [Sunday]';
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
				t_holiday.description := t_description;
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSE
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;