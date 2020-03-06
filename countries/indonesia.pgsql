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
    ASHWIN INTEGER := 7;
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
	t_dt1 DATE;
	t_dt2 DATE;
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
		-- Balinese Saka Kasa 1
		-- Example: Mar 25, 2020
		t_holiday.reference := 'Bali''s Day of Silence and Hindu New Year';
		t_holiday.datestamp := calendars.hindu_to_gregorian((t_year, CHAITRA, 1));
		t_holiday.description := 'Hari Raya Nyepi dan Tahun Baru Saka';
		RETURN NEXT t_holiday;


		-- Good Friday
		-- id: Wafat Yesus Kristus
		-- Easter -2

		-- Easter Sunday
		-- id: Minggu paskah
		-- Observance

		-- International Labor Day
		-- id: Hari Buruh Internasional
		-- Gregorian May 1

		-- Waisak Day (Buddha's Anniversary)
		-- id: Hari Raya Waisak
		-- Chinese 04-0-14
		-- In Indonesia, Vesak is celebrated on the fourteenth or fifteenth day of the fourth month in the Chinese lunar calendar

		-- Ascension Day of Jesus Christ
		-- id: Kenaikan Yesus Kristus
		-- Easter +39

		-- Cuti Bersama (Joint Holiday)
		-- Hari Raya Idul Fitri / Lebaran / End of the Ramadan fasting month
		-- id: Hari Raya Idul Fitri
		-- Hijri 1 Shawwal
		-- Duration 5 Days
		-- Idul Fitri Day 2, 3, Cuti Bersama 2, 3

		-- Pancasila Day
		-- id: Hari Lahir Pancasila
		-- Gregorian June 1

		-- Eid al-Adha
		-- id: Hari Raya Idul Adha
		-- Hijri 10 Dhu al-Hijjah

		-- Indonesian Independence Day
		-- id: Hari Ulang Tahun Kemerdekaan Republik Indonesia
		-- Gregorian Aug 17

		-- Islamic New Year
		-- id: Tahun Baru Islam 1440 Hijriah
		-- Hijri 1 Muharram

		-- The Prophet Muhammad's Birthday
		-- id: Maulid Nabi Muhammad
		-- hijri 12 Rabi al-awwal

		-- Christmas Eve
		-- id: Malam natal (Cuti Bersama)
		-- Gregorian Dec 24
		-- Joint Holiday

		-- Christmas Day
		-- id: Hari Raya Natal
		-- Gregorian Dec 25

		-- New Year's Eve
		-- id: Malam tahun baru
		-- Gregorian Dec 31
		-- Observance

		-- Hindu Holidays (not public holidays)

		-- Maha Shivaratri
		-- Hindu Phalguna 13 (New Moon minus 1?)
		-- 13th night (waning moon) and 14th day of the month Phalguna
		-- Conflicting Info: Thirteenth night of the waning moon of Magh
		-- Example: Feb 21, 2020
		-- Hindu Religious Holiday

		-- Holi
		-- Hindu Phalguna 30 (Full Moon)
		-- It lasts for a night and a day
		-- Example: Mar 10, 2020
		-- Hindu Religious Holiday

		-- Raksha Bandhan
		-- Full Moon
		-- Hindu Shraavana 1
		-- Hindu Religious Holiday

		-- Janmashtami
		-- New Moon
		-- Hindu Shraavana 14
		-- Hindu Religious Holiday

		-- Ganesh Chaturthi
		-- Hindu Bhadrapada 4
		-- Hindu Religious Holiday

		-- Navaratri
		-- Hindu Ashvin 1
		-- Hindu Religious Holiday

		-- Dussehra
		-- India: Vijayadashami
		-- Hindu Ashvin 10 / Full Moon plus 10
		-- Tenth day of waxing moon of Ashvin
		-- Hindu Religious Holiday

		-- Diwali/Deepavali
		-- Hindu Ashvin 14
		-- New moon of Ashvin (Hindu calendar)
		-- Observance

	END LOOP;
END;

$$ LANGUAGE plpgsql;