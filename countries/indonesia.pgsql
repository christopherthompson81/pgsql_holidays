-------------------------------------------------------------------------------
-- Indonesia Holidays
--
-- id: Indonesia
-- dayoff: sunday
-- languages: [id, jv, su, mad]
-- timezones: [Asia/Jakarta; Asia/Pontianak; Asia/Makassar; Asia/Jayapura]
--
-- Source: https://en.wikipedia.org/wiki/Public_holidays_in_Indonesia
-------------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.indonesia(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Hindu Month Constants
	CHAITRA INTEGER := 1;
	VAISHAKHA INTEGER := 2;
	JYESHTHA INTEGER := 3;
	ASHADHA INTEGER := 4;
	SHRAVANA INTEGER := 5;
	BHADRAPADA INTEGER := 6;
	ASHVIN INTEGER := 7;
	KARTIKA INTEGER := 8;
	MARGASHIRSHA INTEGER := 9;
	PAUSHA INTEGER := 10;
	MAGHA INTEGER := 11;
	PHALGUNA INTEGER := 12;
	-- Sub-Regions
	
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
		t_holiday.description := 'Tahun Baru Masehi';
		RETURN NEXT t_holiday;

		-- Chinese Lunar New Year's Day
		t_holiday.reference := 'Chinese Lunar New Year''s Day';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		t_holiday.description := 'Tahun Baru Imlek';
		RETURN NEXT t_holiday;

		-- Ascension of the Prophet Muhammad
		-- id: Isra Mikraj Nabi Muhammad
		-- Hijri 27 Rajab
		-- Example: Mar 22, 2020
		t_holiday.reference := 'Ascension of the Prophet Muhammad';
		t_holiday.description := 'Isra Mikraj Nabi Muhammad';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RAJAB, 27)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Bali's Day of Silence and Hindu New Year
		-- id: Hari Raya Nyepi dan Tahun Baru Saka
		-- Indonesia: Nyepi
		-- India: Ugadi
		-- Balinese Saka Kasa 1 (approximated using Indian Civil Calendar plus Astronomia)
		-- Example: Mar 25, 2020
		t_holiday.reference := 'Bali''s Day of Silence and Hindu New Year';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, CHAITRA, 1));
		t_holiday.description := 'Hari Raya Nyepi dan Tahun Baru Saka';
		RETURN NEXT t_holiday;

		-- Easter
		t_easter := holidays.easter(t_year);

		-- Good Friday
		-- id: Wafat Yesus Kristus
		-- Easter -2
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_easter - '2 Days'::INTERVAL;
		t_holiday.description := 'Wafat Yesus Kristus';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		-- id: Minggu paskah
		-- Observance
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_easter;
		t_holiday.description := 'Minggu paskah';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';

		-- International Labor Day
		-- id: Hari Buruh Internasional
		-- Gregorian May 1
		t_holiday.reference := 'International Labor Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Hari Buruh Internasional';
		RETURN NEXT t_holiday;

		-- Waisak Day (Buddha's Anniversary)
		-- id: Hari Raya Waisak
		-- Chinese 04-0-14
		-- In Indonesia, Vesak is celebrated on the fourteenth or fifteenth day of the fourth month in the Chinese lunar calendar
		t_holiday.reference := 'Waisak Day (Buddha''s Anniversary)';
		t_holiday.description := 'Hari Raya Waisak';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 4,
			c_leap_month => FALSE,
			c_day => 14
		);
		RETURN NEXT t_holiday;

		-- Ascension Day of Jesus Christ
		t_holiday.reference := 'Ascension Day of Jesus Christ';
		t_holiday.datestamp := t_easter + '39 Days'::INTERVAL;
		t_holiday.description := 'Kenaikan Yesus Kristus';
		RETURN NEXT t_holiday;

		-- Cuti Bersama (Joint Holiday)
		-- Hari Raya Idul Fitri / Lebaran / End of the Ramadan fasting month
		-- id: Hari Raya Idul Fitri
		-- Hijri 1 Shawwal
		-- Duration 5 Days
		-- Idul Fitri Day 2, 3, Cuti Bersama 2, 3
		t_holiday.reference := 'Joint Holiday';
		t_holiday.description := 'Cuti Bersama - Hari Raya Idul Fitri';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '4 Days'::INTERVAL;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Pancasila Day
		t_holiday.reference := 'Pancasila Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 1);
		t_holiday.description := 'Hari Lahir Pancasila';
		RETURN NEXT t_holiday;

		-- Feast of the Sacrifice (Eid al-Adha)
		t_holiday.reference := 'Feast of the Sacrifice (Eid al-Adha)';
		t_holiday.description := 'Hari Raya Idul Adha';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 10)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Indonesian Independence Day
		t_holiday.reference := 'Indonesian Independence Day';
		t_holiday.datestamp := make_date(t_year, AUGUST, 17);
		t_holiday.description := 'Hari Ulang Tahun Kemerdekaan Republik Indonesia';
		RETURN NEXT t_holiday;

		-- Islamic New Year
		t_holiday.reference := 'Islamic New Year';
		t_holiday.description := 'Tahun Baru Islam 1440 Hijriah';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, MUHARRAM, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- The Prophet Muhammad's Birthday
		t_holiday.reference := 'The Prophet Muhammad''s Birthday';
		t_holiday.description := 'Maulid Nabi Muhammad';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Malam natal (Cuti Bersama)';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Hari Raya Natal';
		RETURN NEXT t_holiday;

		-- New Year's Eve
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Malam tahun baru';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';



		-- Hindu Holidays (not public holidays)
		t_holiday.authority := 'religious';
		t_holiday.day_off := FALSE;

		-- Maha Shivaratri
		t_holiday.reference := 'Maha Shivaratri';
		t_holiday.datestamp := calendars.hindu_next_waning_moon((t_year, PHALGUNA, 1));
		t_holiday.description := 'Maha Shivaratri';
		RETURN NEXT t_holiday;

		-- Holi
		t_holiday.reference := 'Holi';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, PHALGUNA, 1));
		t_holiday.description := 'Holi';
		RETURN NEXT t_holiday;

		-- Raksha Bandhan
		t_holiday.reference := 'Raksha Bandhan';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, SHRAVANA, 1));
		t_holiday.description := 'Raksha Bandhan';
		RETURN NEXT t_holiday;

		-- Janmashtami
		t_holiday.reference := 'Janmashtami';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, SHRAVANA, 1));
		t_holiday.description := 'Janmashtami';
		RETURN NEXT t_holiday;

		-- Ganesh Chaturthi
		t_holiday.reference := 'Ganesh Chaturthi';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, BHADRAPADA, 1)) + '4 Days'::INTERVAL;
		t_holiday.description := 'Ganesh Chaturthi';
		RETURN NEXT t_holiday;

		-- Navaratri
		t_holiday.reference := 'Navaratri';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, ASHVIN, 1));
		t_holiday.description := 'Navaratri';
		RETURN NEXT t_holiday;

		-- Dussehra
		-- India: Vijayadashami
		t_holiday.reference := 'Dussehra';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, ASHVIN, 1)) + '10 Days'::INTERVAL;
		t_holiday.description := 'Dussehra';
		RETURN NEXT t_holiday;

		-- Diwali/Deepavali
		t_holiday.reference := 'Diwali/Deepavali';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, ASHVIN, 1));
		t_holiday.description := 'Diwali/Deepavali';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;