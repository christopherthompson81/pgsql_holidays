------------------------------------------
------------------------------------------
-- ISO 3166: United Arab Emirates, AE, ARE
--
-- UAE
-- en: United Arab Emirates
-- ar: دولة الإمارات العربية المتحدة
--
-- langs:
-- - ar
--
-- Time Zones:
-- - Asia/Dubai
--
-- dayoff: ''
--
-- states:
-- AJ -- Ajman
-- AZ -- Abu Dhabi
-- DU -- Dubai
-- FU -- Fujairah
-- RK -- Ras al-Khaimah
-- SH -- Sharjah
-- UQ -- Umm al-Quwain
--
-- https://government.ae/en/information-and-services/public-holidays-and-religious-affairs/public-holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_the_United_Arab_Emirates
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.united_arab_emirates(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Gregorian Month Constants
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
	-- Gregorian Weekday Constants
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
	-- Provinces
	PROVINCES TEXT[] := ARRAY[
		'AJ', -- Ajman
		'AZ', -- Abu Dhabi
		'DU', -- Dubai
		'FU', -- Fujairah
		'RK', -- Ras al-Khaimah
		'SH', -- Sharjah
		'UQ' -- Umm al-Quwain
	];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_dates DATE[];

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
		-- gregorian 01-01
		-- ar: يوم السنة الجديدة
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'يوم السنة الجديدة';
		RETURN NEXT t_holiday;
		
		-- Laylat al-Mi'raj (Muhammad's Ascension to Heaven) 
		-- hijri 27 Rajab
		-- ar: الإسراء والمعراج
		t_holiday.reference := 'Muhammad''s Ascension to Heaven (Laylat al-Mi''raj)';
		t_holiday.description := 'الإسراء والمعراج';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RAJAB, 27)
		LOOP
			t_holiday.datestamp := t_datestamp;
			
			RETURN NEXT t_holiday;
		END LOOP;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- First day of Ramadan 
		-- hijri 1 Ramadan
		-- ar: اليوم الأول من رمضان
		t_holiday.reference := 'First day of Ramadan';
		t_holiday.description := 'اليوم الأول من رمضان';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RAMADAN, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- End of Ramadan (Eid e Fitr)
		-- hijri 1 Shawwal - '1 day'; P4D
		-- -- https://government.ae/en/information-and-services/public-holidays-and-religious-affairs/public-holidays
		-- -- Eid Al Fitr: From last day of the Islamic month of Ramadan to 3 Shawwal* (4 days)
		-- ar: عيد الفطر
		t_holiday.reference := 'End of Ramadan (Eid e Fitr)';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
			t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
			t_holiday.description := 'عید فطر';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'عید فطر 1';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'عید فطر 2';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'عید فطر 3';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Hajj season begins
		-- ex: Jul 22, 2020
		-- Starting on 1 Dhu al-Hijjah and ending on 10 Dhu al-Hijjah
		-- Observance
		-- ar: موسم الحج
		t_holiday.reference := 'Hajj season begins';
		t_holiday.description := 'موسم الحج';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Arafat Day
		-- hijri 9 Dhu al-Hijjah
		-- ar: يوم عرفة‎
		-- and
		-- Feast of the Sacrifice (Eid al-Adha)
		-- hijri 10 Dhu al-Hijjah P3D
		-- ar: عيد الأضحى
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 9)
		LOOP
			t_holiday.reference := 'Arafat Day';
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'يوم عرفة‎';
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Feast of the Sacrifice (Eid al-Adha)';
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'عید قربان 1';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'عید قربان 2';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
			t_holiday.description := 'عید قربان 3';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Islamic New Year
		-- hijri 1 Muharram
		-- ar: رأس السنة الهجرية
		t_holiday.reference := 'Islamic New Year';
		t_holiday.description := 'رأس السنة الهجرية';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, MUHARRAM, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Birthday of Muhammad (Mawleed al Nabi)
		-- hijri 12 Rabi al-awwal
		-- ar: المولد النبويّ
		t_holiday.reference := 'Prophet Muhammad''s Birthday';
		t_holiday.description := 'تولد پیامبر';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Commemoration Day
		-- gregorian 12-01
		-- ar: يوم الشهيد
		t_holiday.reference := 'Commemoration Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 1);
		t_holiday.description := 'يوم الشهيد';
		RETURN NEXT t_holiday;

		-- National Day
		-- gregorian 12-02; P2D;
		-- ar: اليوم الوطني
		t_holiday.reference := 'National Day';
		t_holiday.description := 'اليوم الوطني';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 2);
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 3);
		RETURN NEXT t_holiday;

		-- New Year's Eve
		-- gregorian 12-31
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'ليلة رأس السنة';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

	END LOOP;
END;

$$ LANGUAGE plpgsql;
