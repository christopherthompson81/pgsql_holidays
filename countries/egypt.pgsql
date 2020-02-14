------------------------------------------
------------------------------------------
-- Egypt Holidays (Porting Unfinished)
--
-- Holidays here are estimates, it is common for the day to be pushed
-- if falls in a weekend, although not a rule that can be implemented.
--
-- Holidays after 2020: the following four moving date holidays whose exact
-- date is announced yearly are estimated (and so denoted):
-- - Eid El Fetr*
-- - Eid El Adha*
-- - Arafat Day*
-- - Moulad El Naby*
--
-- is_weekend function is there, however not activated for accuracy.
--
--def is_weekend(self, hol_date, hol_name):
--	--Function to store the holiday name in the appropriate
--	--date and to shift the Public holiday in case it happens
--	--on a Saturday(Weekend)
--	IF hol_date.weekday() == FRI THEN
--		self[hol_date] = hol_name + ' [Friday]'
--		self[hol_date + '+2 Days'::INTERVAL] = 'Sunday following ' + hol_name
--	ELSE
--		self[hol_date] = hol_name
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.egypt(p_start_year INTEGER, p_end_year INTEGER)
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

		-- New Year's Day
		-- Bank Holiday
		-- ar: عطلة البنوك
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'عطلة البنوك';
		RETURN NEXT t_holiday;

		-- Coptic Christmas
		-- ar: عيد الميلاد المجيد
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		t_holiday.description := 'عيد الميلاد المجيد';
		RETURN NEXT t_holiday;

		-- Revolution Day January 25
		-- ar: عيد الثورة 25 يناير
		-- Police Day
		-- ar: عيد الشرطة
		IF t_year >= 2012 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 25);
			t_holiday.description := 'عيد الثورة 25 يناير';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2009 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 25);
			t_holiday.description := 'عيد الشرطة';
			RETURN NEXT t_holiday;
		END IF;

		-- Orthodox Easter Based Dates
		t_datestamp := holidays.easter(t_year, 'EASTER_ORTHODOX');

		-- -2 days; Coptic Good Friday; Observance
		-- -1 day; Coptic Holy Saturday; Observance

		-- Coptic Easter - Orthodox Easter
		-- ar: 	عيد القيامة المجيد
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'عيد القيامة المجيد';
		RETURN NEXT t_holiday;

		-- Spring Festival (Sham El Nessim)
		-- ar: شم النسيم
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'شم النسيم';
		RETURN NEXT t_holiday;

		-- Sinai Libration Day
		-- ar: عيد تحرير سيناء
		IF t_year > 1982 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'عيد تحرير سيناء';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		-- ar: عيد العمال
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'عيد العمال';
		RETURN NEXT t_holiday;

		-- 30 June Revolution Day
		-- ar: ثورة 30 يونيو
		IF t_year >= 2014 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 30);
			t_holiday.description := 'ثورة 30 يونيو';
			RETURN NEXT t_holiday;
		END IF;

		-- July 1 Bank Holiday
		-- Bank Holiday

		-- Revolution Day (July 23)
		-- ar: عيد الثورة
		IF t_year > 1952 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 23);
			t_holiday.description := 'عيد الثورة';
			RETURN NEXT t_holiday;
		END IF;

		-- Flooding of the Nile
		-- August 15
		-- Observance
		-- ar: عيد وفاء النيل
		
		-- Coptic New Year (Nayrouz)
		-- September 11
		-- Observance
		-- ar: السنة القبطية

		-- Armed Forces Day
		-- ar: عيد القوات المسلحة
		t_holiday.datestamp := make_date(t_year, OCTOBER, 6);
		t_holiday.description := 'عيد القوات المسلحة';
		RETURN NEXT t_holiday;

		-- End of Ramadan (Eid e Fitr) 
		-- ar: 'عيد الفطر'
		-- Feast Festive
		-- date of observance is announced yearly, This is an estimate since
		-- having the Holiday on Weekend does change the number of days,
		-- deceided to leave it since marking a Weekend as a holiday
		-- wouldn't do much harm.
		-- 1 Shawwal:
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, SHAWWAL, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'عيد الفطر 1';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'عيد الفطر 2';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'عيد الفطر 3';
			RETURN NEXT t_holiday;
		END LOOP;
			
		-- Arafat Day
		-- ar: يوم عرفة‎
		-- Feast of the Sacrifice (Eid al-Adha)
		-- ar: 'عيد الأضحى المبارك'
		-- date of observance is announced yearly
		-- 10 Dhu al-Hijjah:					
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, DHU_AL_HIJJAH, 9)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'يوم عرفة‎';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'عيد الأضحى المبارك 1';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'عيد الأضحى المبارك 2';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
			t_holiday.description := 'عيد الأضحى المبارك 3';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '4 Days'::INTERVAL;
			t_holiday.description := 'عيد الأضحى المبارك 4';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Islamic New Year
		-- 1 Muharram / Islamic New Year
		-- ar: 'عيد رأس السنة الهجرية'
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, MUHARRAM, 1)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'عيد رأس السنة الهجرية';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Prophet Muhammad's Birthday
		-- 12 Rabi al-awwal: / Birthday of Muhammad (Mawlid)
		-- ar: 'المولد النبوي الشريف'
		FOR t_datestamp IN
			SELECT * FROM holidays.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'المولد النبوي الشريف';
			RETURN NEXT t_holiday;
		END LOOP;

	END LOOP;
END;

$$ LANGUAGE plpgsql;