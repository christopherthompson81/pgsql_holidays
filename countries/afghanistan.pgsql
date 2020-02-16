------------------------------------------
------------------------------------------
-- Afghanistan Holidays
--
-- Some dates use the Jalali Calendar (Persion / Solar Hijri)
-- Some dates use the Hijri Calendar (Islamic)
-- Some dates use the Gregorian Calendar (common modern solar)
--
-- I am using Wikipedia and google translate to localize the names. I am also
-- making an assumption that known-good Arabic names are more likely to translate
-- properly than translating from english. This may or may not be a good
-- assumption.
--
-- Descriptions are direct quotes from:
-- - https://www.iexplore.com/articles/travel-guides/middle-east/afghanistan/festivals-and-events
--
-- Languages
--
-- Persian / Farsi / Dari -> 'fa'
-- Pashto -> 'ps'
--
-- en: Afghanistan
-- ar: أفغانستان
-- fe: افغانستان
-- ps: افغانستان
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.afghanistan(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Jalali Month Constants
	FARVARDIN INTEGER := 1;
	ORDIBEHESHT INTEGER := 2;
	KHORDAD INTEGER := 3;
	TIR INTEGER := 4;
	MORDAD INTEGER := 5;
	SHAHRIVAR INTEGER := 6;
	MEHR INTEGER := 7;
	ABAN INTEGER := 8;
	AZAR INTEGER := 9;
	DEY INTEGER := 10;
	BAHMAN INTEGER := 11;
	ESFAND INTEGER := 12;
	-- Provinces
	PROVINCES TEXT[] := ARRAY[
			'BAL', -- Balkh
			'BAM', -- Bamyan
			'BDG', -- Badghis
			'BDS', -- Badakhshan
			'BGL', -- Baghlan
			'DAY', -- Daykundi
			'FRA', -- Farah
			'FYB', -- Faryab
			'GHA', -- Ghazni
			'GHO', -- Ghōr
			'HEL', -- Helmand
			'HER', -- Herat
			'JOW', -- Jowzjan
			'KAB', -- Kabul
			'KAN', -- Kandahar
			'KAP', -- Kapisa
			'KDZ', -- Kunduz
			'KHO', -- Khost
			'KNR', -- Kunar
			'LAG', -- Laghman
			'LOG', -- Logar
			'NAN', -- Nangarhar
			'NIM', -- Nimruz
			'NUR', -- Nuristan
			'PAN', -- Panjshir
			'PAR', -- Parwan
			'PIA', -- Paktia
			'PKA', -- Paktika
			'SAM', -- Samangan
			'SAR', -- Sar-e Pol
			'TAK', -- Takhar
			'URU', -- Urozgan
			'WAR', -- Maidan Wardak
			'ZAB' -- Zabul
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

		-- Nowruz
		-- 1 Farvardin / Nowruz is the day of the vernal equinox.
		-- (Not sure if those two things agree)
		-- Public Holiday
		-- en: Persian New Year (Nowruz)
		-- ar: نوروز
		-- fe: نوروز‎
		-- ps: نوروز
		t_holiday.reference := 'Nowruz';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_jalali(t_year, FARVARDIN, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'نوروز‎';
			RETURN NEXT t_holiday;
		END LOOP;

		-- First day of Ramadan
		-- Public Holiday
		-- en: First day of Ramadan
		-- ar: اليوم الأول من رمضان
		-- fe: روز اول ماه رمضان
		-- ps: د روژې لومړۍ ورځ
		t_holiday.reference := 'First day of Ramadan';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RAMADAN, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'روز اول ماه رمضان';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Mujahideen Victory Day
		-- fa: سالروز پیروزی مجاهدین
		t_holiday.reference := 'Mujahideen Victory Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 28);
		t_holiday.description := 'سالروز پیروزی مجاهدین';
		RETURN NEXT t_holiday;

		-- Labour Day
		-- ar: عيد العمال
		-- fa: روز کار
		-- ps: د کارګر ورځ
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'روز کار';
		RETURN NEXT t_holiday;

		-- End of Ramadan (Eid e Fitr)
		-- Public Holiday
		-- ar: عيد الفطر
		-- fa: عید فطر
		-- ps: کوچني اختر
		t_holiday.reference := 'End of Ramadan (Eid e Fitr)';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
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

		-- Arafat Day
		-- ar: يوم عرفة‎
		-- fa: در روز عرفه
		-- ps: د عرفې په ورځ
		-- Feast of the Sacrifice (Eid al-Adha)
		-- ar: عيد الأضحى
		-- fa: عید قربان
		-- ps: کوچنی اختر
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 9)
		LOOP
			t_holiday.reference := 'Arafat Day';
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'در روز عرفه';
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

		-- Aug 19	Wednesday	Independence Day (National Day)	Public Holiday
		-- Afghan Independence Day (Jeshyn-Afghan Day)
		-- fe: روز استقلال افغانستان
		-- ps: د افغانستان د خپلواکۍ ورځ
		t_holiday.reference := 'Afghan Independence Day (Jeshyn-Afghan Day)';
		t_holiday.datestamp := make_date(t_year, AUGUST, 19);
		t_holiday.description := 'روز استقلال افغانستان';
		RETURN NEXT t_holiday;

		-- 10 Muharram:
		-- en: Day of Ashura
		-- ar: عاشوراء
		-- fa: عاشورا
		-- ps: عاشورا
		t_holiday.reference := 'Day of Ashura';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, MUHARRAM, 10)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'عاشورا';
			RETURN NEXT t_holiday;
		END LOOP;


		-- Martyrs and Ahmad Shah Masoud Day
		-- Martyrs' Day
		-- Shahrivar 18
		t_holiday.reference := 'Martyrs'' Day';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_jalali(t_year, SHAHRIVAR, 18)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'آمر صاحب شهید';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Birthday of Muhammad (Mawleed al Nabi)
		-- ar: المولد النبويّ
		-- fe: تولد پیامبر
		-- ps: د پیغمبر زیږیدنه
		t_holiday.reference := 'Prophet Muhammad''s Birthday';
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'تولد پیامبر';
			RETURN NEXT t_holiday;
		END LOOP;

	END LOOP;
END;

$$ LANGUAGE plpgsql;
