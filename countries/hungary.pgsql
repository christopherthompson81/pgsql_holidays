------------------------------------------
------------------------------------------
-- Hungary Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Hungary
-- observed days off work around national holidays in the last 10 years:
-- https://www.munkaugyiforum.hu/munkaugyi-segedanyagok/
--	 2018-evi-munkaszuneti-napok-koruli-munkarend-9-2017-ngm-rendelet
-- codification dates:
-- - https://hvg.hu/gazdasag/
--	  20170307_Megszavaztak_munkaszuneti_nap_lett_a_nagypentek
-- - https://www.tankonyvtar.hu/hu/tartalom/historia/
--	  92-10/ch01.html--id496839
--
-- https://hu.wikipedia.org/wiki/Magyarorsz%C3%A1gi_%C3%BCnnepek_%C3%A9s_eml%C3%A9knapok_list%C3%A1ja
--
-- In the Soviet Union, modern Russia, and Hungary, the Friday following a
-- public holiday that falls on Thursday and the Monday before one that falls
-- on Tuesday are transferred to Saturdays to make longer runs of consecutive
-- nonworking days. In this case the "bridge" Monday or Friday is treated as a
-- Saturday in terms of time tables and working hours and the related "working
-- Saturday" is treated as a normal work day. Over the two work weeks
-- concerned, work is done on nine days with one work week running for six days
-- and the other one for three. 
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.hungary(p_start_year INTEGER, p_end_year INTEGER)
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
	OBSERVED CONSTANT TEXT := ' (előtti pihenőnap)'; -- Hungarian
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Újév';
		RETURN NEXT t_holiday;
		IF t_year >= 2014 THEN
			t_holiday_list := array_append(t_holiday_list, t_holiday);
		END IF;

		-- January 22
		-- en: Hungarian Culture Day
		-- hu: A magyar kultúra napja
		-- type: observance

		-- 02-01:
		-- en: Memorial Day of the Republic
		-- hu: A köztársaság emléknapja
		-- type: observance

		-- 02-25:
		-- en: Memorial Day for the Victims of the Communist Dictatorships
		-- hu: A kommunista diktatúrák áldozatainak emléknapja
		-- type: observance

		-- 03-08:
		-- en: International Women's Day
		-- hu: Nemzetközi nőnap
		-- type: observance

		-- 	1848 Revolution Memorial Day
		t_holiday.reference := 'Revolution Memorial Day';
		IF t_year BETWEEN 1945 AND 1950 OR t_year >= 1989 THEN
			t_datestamp := make_date(t_year, MARCH, 15);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := '1848-as forradalom ünnepe';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				t_holiday_list := array_append(t_holiday_list, t_holiday);
			END IF;
		END IF;

		-- April 16
		-- en: Remembrance Day for Holocaust Victims
		-- hu: a holokauszt áldozatainak emléknapja
		-- type: observance
		-- In 1944, on this day, the process of forcing Jews into ghettos for their subsequent deportation began
		-- in Subcarpathia. According to the resolution of the National Assembly in 2000, commemoration day will
		-- be held in high schools on April 16 every year since 2001.

		-- Soviet era
		IF t_year BETWEEN 1950 AND 1989 THEN
			-- Proclamation of Soviet socialist governing system
			t_holiday.reference := 'Soviet Day';
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			t_holiday.description := 'A Tanácsköztársaság kikiáltásának ünnepe';
			RETURN NEXT t_holiday;
			-- Liberation Day
			t_holiday.reference := 'Liberation Day';
			t_holiday.datestamp := make_date(t_year, APRIL, 4);
			t_holiday.description := 'A felszabadulás ünnepe';
			RETURN NEXT t_holiday;
			-- Memorial day of The Great October Soviet Socialist Revolution
			t_holiday.reference := 'Memorial Day';
			IF t_year NOT IN (1956, 1989) THEN
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 7);
				t_holiday.description := 'A nagy októberi szocialista forradalom ünnepe';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		IF t_year >= 2017 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			t_holiday.description := 'Nagypéntek';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Húsvét';
		RETURN NEXT t_holiday;

		-- Second easter day
		t_holiday.reference := 'Easter Monday';
		IF t_year != 1955 THEN
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Húsvét Hétfő';
			RETURN NEXT t_holiday;
		END IF;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pünkösd';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Pentecost monday
		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		IF t_year <= 1952 or t_year >= 1992 THEN
			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			t_holiday.description := 'Pünkösdhétfő';
			RETURN NEXT t_holiday;
		END IF;

		-- 04-16:
		-- en: Memorial Day for the Victims of the Holocaust
		-- hu: A holokauszt áldozatainak emléknapja
		-- type: observance

		-- International Workers' Day
		t_holiday.reference := 'Labour Day';
		IF t_year >= 1946 THEN
			t_datestamp := make_date(t_year, MAY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'A Munka ünnepe';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				t_holiday_list := array_append(t_holiday_list, t_holiday);
			END IF;
		END IF;
		IF t_year BETWEEN 1950 AND 1953 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'A Munka ünnepe';
			RETURN NEXT t_holiday;
		END IF;

		-- 1st sunday in May:
		-- en: Mother's Day
		-- hu: Anyák napja
		-- type: observance

		-- 05-21:
		-- en: National Defense Day
		-- hu: Honvédelmi nap
		-- type: observance

		-- 06-04:
		-- en: Day of National Unity
		-- hu: A nemzeti összetartozás napja
		-- type: observance

		-- June 16
		-- en: Imre Nagy Memorial Day
		-- hu: Nagy Imre emléknap
		-- type: observance
		-- Remembrance Day of Prime Minister Imre Nagy and his martyrs

		-- 06-19:
		-- en: Day of the Independent Hungary
		-- hu: A független Magyarország napja
		-- type: observance

 		-- the last Saturday of June is Hungarian Freedom Day
		-- type: observance

		-- State Foundation Day (1771-????, 1891-)
		t_holiday.reference := 'State Foundation Day';
		IF t_year BETWEEN 1950 AND 1989 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 20);
			t_holiday.description := 'A kenyér ünnepe';
			RETURN NEXT t_holiday;
		ELSE
			t_datestamp := make_date(t_year, AUGUST, 20);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Az államalapítás ünnepe';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				t_holiday_list := array_append(t_holiday_list, t_holiday);
			END IF;
		END IF;

		-- 10-06:
		-- en: Memorial Day for the Martyrs of Arad
		-- hu: Az aradi vértanúk emléknapja
		-- type: observance

		-- 1956 Revolution Memorial Day
		t_holiday.reference := 'Revolution Memorial Day';
		IF t_year >= 1991 THEN
			t_datestamp := make_date(t_year, OCTOBER, 23);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := '1956-os forradalom ünnepe';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				t_holiday_list := array_append(t_holiday_list, t_holiday);
			END IF;
		END IF;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		IF t_year >= 1999 THEN
			t_datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Mindenszentek';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				t_holiday_list := array_append(t_holiday_list, t_holiday);
			END IF;
		END IF;

		-- Saint Nicholas Day
		t_holiday.reference := 'Saint Nicholas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
		t_holiday.description := 'Télapó Mikulás';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Christmas Eve is not endorsed officially
		-- but nowadays it is usually a day off work
		t_holiday.reference := 'Christmas Eve';
		t_holiday.authority := 'national';
		t_holiday.description := 'Szenteste';
		t_datestamp := make_date(t_year, DECEMBER, 24);
		IF t_year >= 2010 AND NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			-- add an Extra work day two Saturdays ago
			t_holiday.reference := 'Extra Work Day';
			t_holiday.authority := 'extra_work_day';
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, SATURDAY, -2);
			t_holiday.description := 'Munkanap';
			t_holiday.day_off := FALSE;
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2010 THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.authority := 'observance';
			t_holiday.day_off := FALSE;
			RETURN NEXT t_holiday;
		END IF;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- First christmas
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Karácsony';
		RETURN NEXT t_holiday;

		-- Second christmas
		t_holiday.reference := 'Second Day of Christmas';
		IF t_year != 1955 THEN
			t_datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Karácsony másnapja';
			RETURN NEXT t_holiday;
			IF t_year >= 2013 THEN
				IF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'Karácsony másnapja utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
					-- add an Extra work day two Saturdays ago
					t_holiday.reference := 'Extra Work Day';
					t_holiday.authority := 'extra_work_day';
					t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, SATURDAY, -2);
					t_holiday.description := 'Munkanap';
					t_holiday.day_off := FALSE;
					RETURN NEXT t_holiday;
				END IF;
			END IF;
		END IF;

		-- New Year's Eve
		-- Dec 31	Thursday	New Year's Eve	Observance
		t_holiday.reference := 'New Year''s Eve';
		t_datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Szilveszter';
		IF t_year >= 2014 AND DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			-- add an Extra work day three Saturdays ago
			t_holiday.reference := 'Extra Work Day';
			t_holiday.authority := 'extra_work_day';
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, SATURDAY, -3);
			t_holiday.description := 'Munkanap';
			t_holiday.day_off := FALSE;
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2014 THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.authority := 'observance';
			t_holiday.day_off := FALSE;
			RETURN NEXT t_holiday;
		END IF;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Apply observation shifting rules to stored dates.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			t_holiday.description := t_holiday.description || OBSERVED;
			t_holiday.observation_shifted := TRUE;
			IF DATE_PART('dow', t_holiday.datestamp) = TUESDAY THEN
				t_holiday.datestamp := t_holiday.datestamp - '1 Days'::INTERVAL;
				RETURN NEXT t_holiday;
				-- add an Extra work day on the following Saturday
				t_holiday.reference := 'Extra Work Day';
				t_holiday.authority := 'extra_work_day';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, SATURDAY, 1);
				t_holiday.description := 'Munkanap';
				t_holiday.day_off := FALSE;
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_holiday.datestamp) = THURSDAY THEN
				t_holiday.datestamp := t_holiday.datestamp + '1 Days'::INTERVAL;
				RETURN NEXT t_holiday;
				-- add an Extra work day in two Saturdays
				t_holiday.reference := 'Extra Work Day';
				t_holiday.authority := 'extra_work_day';
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, SATURDAY, 2);
				t_holiday.description := 'Munkanap';
				t_holiday.day_off := FALSE;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
		t_holiday.observation_shifted := FALSE;

	END LOOP;
END;

$$ LANGUAGE plpgsql;