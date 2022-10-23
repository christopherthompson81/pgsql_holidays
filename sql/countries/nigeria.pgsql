------------------------------------------
------------------------------------------
-- Nigeria Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Nigeria
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.nigeria(p_start_year INTEGER, p_end_year INTEGER)
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
	t_easter DATE;
	t_holiday holidays.holiday%rowtype;

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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s day';
		RETURN NEXT t_holiday;

		-- Eid al-Fitr
		-- Muslim holiday celebrating the end of Ramadan, a month of fasting.
		t_holiday.reference := 'End of Ramadan';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Eid e Fitr';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Easter Related Holidays
		t_easter := holidays.easter(t_year);

		-- Good Friday
		-- Christian holiday celebrating the crucifixion of Jesus.
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_easter - '2 Days'::INTERVAL;
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		-- Easter Monday
		-- Christian holiday celebrating the Resurrection of Jesus Christ Easter.
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_easter + '1 Day'::INTERVAL;
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

		-- Worker's Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Worker''s day';
		RETURN NEXT t_holiday;

		-- Children's Day
		t_holiday.reference := 'Children''s Day';
		t_holiday.datestamp := make_date(t_year, MAY, 27);
		t_holiday.description := 'Children''s day';
		RETURN NEXT t_holiday;

		-- Democracy Day
		t_holiday.reference := 'Democracy Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 12);
		t_holiday.description := 'Democracy day';
		RETURN NEXT t_holiday;

		-- Eid al-Adha
		-- Muslim holiday celebrating the willingness of Ibrahim to sacrifice his son
		-- Feast of the Sacrifice (Eid al-Adha)
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 10)
		LOOP
			t_holiday.reference := 'Feast of the Sacrifice';
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Eid al-Adha';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Mawlid
		-- Muslim holiday celebrating the birthday of Prophet Muhammad.
		t_holiday.reference := 'Prophet Muhammad''s Birthday';
		t_holiday.description := 'Mawlid';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 1);
		t_holiday.description := 'Independence day';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas day';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Boxing day';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;