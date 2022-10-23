------------------------------------------
------------------------------------------
-- Pakistan Holidays
--
-- languages: Urdu - اردو
-- Timezones: - Asia/Karachi
-- Dayoff: Sunday
-- 
-- Attrib: https://en.wikipedia.org/wiki/Public_holidays_in_Pakistan
-- 
-- All languages of Pakistan, besides English, are written in Nastaʿlīq, a modified Perso-Arabic script. 
-- Nastaʿlīq is a caligraphy (stylized) for Arabic lettering, so plain Arabic will work as a storage 
-- mechanism because it corresponds directly.
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
		'BA: Balochistan',
		'GB: Gilgit-Baltistan',
		'IS: Islamabad',
		'JK: Azad Kashmir',
		'KP: Khyber Pakhtunkhwa',
		'PB: Punjab',
		'SD: Sindh',
		'TA: Federally Administered Tribal Areas'
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- Kashmir Solidarity Day
		-- 5 February
		-- یوم یکجحتی کشمیر
		-- Protest against Indian administration in Jammu and Kashmir.

		-- Pakistan Day
		-- 23 March
		-- یوم پاکستان
		-- Commemorates the Lahore Resolution, which formally demanded an independent Muslim-majority state to be created out of the British Indian Empire; the republic was also declared on this day in 1956. A parade is also held on this day to display weapons.

		-- First day of Ramadan
		-- Public Holiday
		-- en: First day of Ramadan
		-- ar: اليوم الأول من رمضان
		-- fe: روز اول ماه رمضان
		-- ps: د روژې لومړۍ ورځ
		t_holiday.reference := 'First day of Ramadan';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RAMADAN, 1)
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

		-- 1 May
		-- Labour Day
		-- یوم مزدور
		-- Celebrates the achievements of workers
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'یوم مزدور';
		RETURN NEXT t_holiday;

		-- End of Ramadan (Eid e Fitr)
		-- Public Holiday
		-- ar: عيد الفطر
		-- fa: عید فطر
		-- ps: کوچني اختر
		t_holiday.reference := 'End of Ramadan (Eid e Fitr)';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
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
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 9)
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
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, MUHARRAM, 10)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'عاشورا';
			RETURN NEXT t_holiday;
		END LOOP;


		-- Martyrs and Ahmad Shah Masoud Day
		-- Martyrs' Day
		-- Shahrivar 18
		--
		-- It's tough finding a good source for translation. If you can help
		-- correct this, please do! I'm currently listing it as a name of
		-- respect for Ahmad Shah Masoud, but this may or may not be correct.
		--
		-- * Massoud's Day: روز مسعود
		-- * (our) martyred commander: آمر صاحب شهید
		-- * Martyrs' Day: روز شهدا
		t_holiday.reference := 'Martyrs'' Day';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_jalali(t_year, SHAHRIVAR, 18)
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
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'تولد پیامبر';
			RETURN NEXT t_holiday;
		END LOOP;

	END LOOP;
END;

$$ LANGUAGE plpgsql;








-- 14 August
-- Independence Day
-- یوم استقلال
-- Marking Pakistani independence from the United Kingdom, formation of Pakistan in 1947

-- 25 December
-- Birthday of Quaid-e-Azam
-- یوم ولادت قائداعظم
-- Birthday of Muhammad Ali Jinnah, founder of Pakistan


-- Holidays of the (lunar) Islamic calendar

-- Dhul Hijja 10th-12th
-- Eid-ul-Adha
-- عید الاضحٰی
-- Marks the end of the Hajj pilgrimage; sacrifices offered on this day commemorate Abraham's willingness to sacrifice his son

-- Shawwal 1st-3rd
-- Eid-ul-Fitr
-- عيد الفطر
-- Marks the end of the fasting month of Ramadan

-- Rabi`-ul-Awwal 12
-- Eid-e-Milad-un-Nabi
-- عيد ميلاد النبی
-- Birthday of the Islamic prophet Muhammad

-- Muharram 9th & 10th
-- Ashura
-- عاشوراء/یوم کربلا
-- Karbala Day for Shias to the mourn for the martyred Imam Hussein ibn Ali

-- Ridván
-- Baháʼí Calendar, 13th of Jalál