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

		-- New years		
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Újév';
		RETURN NEXT t_holiday;
		IF t_year >= 2014 THEN
			IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
				t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
				t_holiday.description := 'Újév előtti pihenőnap';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
				t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
				t_holiday.description := 'Újév utáni pihenőnap';
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			END IF;
		END IF;

		-- National Day
		IF t_year BETWEEN 1945 AND 1950 OR t_year >= 1989 THEN
			t_datestamp := make_date(t_year, MARCH, 15);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Nemzeti ünnep';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
					t_holiday.description := 'Nemzeti ünnep előtti pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'Nemzeti ünnep utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				END IF;
			END IF;
		END IF;

		-- Soviet era
		IF t_year BETWEEN 1950 AND 1989 THEN
			-- Proclamation of Soviet socialist governing system
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			t_holiday.description := 'A Tanácsköztársaság kikiáltásának ünnepe';
			RETURN NEXT t_holiday;
			-- Liberation Day
			t_holiday.datestamp := make_date(t_year, APRIL, 4);
			t_holiday.description := 'A felszabadulás ünnepe';
			RETURN NEXT t_holiday;
			-- Memorial day of The Great October Soviet Socialist Revolution
			IF t_year NOT IN (1956, 1989) THEN
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 7);
				t_holiday.description := 'A nagy októberi szocialista forradalom ünnepe';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		IF t_year >= 2017 THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
			t_holiday.description := 'Nagypéntek';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Húsvét';
		RETURN NEXT t_holiday;

		-- Second easter day
		IF t_year != 1955 THEN
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Húsvét Hétfő';
			RETURN NEXT t_holiday;
		END IF;

		-- Pentecost
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pünkösd';
		RETURN NEXT t_holiday;

		-- Pentecost monday
		IF t_year <= 1952 or t_year >= 1992 THEN
			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			t_holiday.description := 'Pünkösdhétfő';
			RETURN NEXT t_holiday;
		END IF;

		-- International Workers' Day
		IF t_year >= 1946 THEN
			t_datestamp := make_date(t_year, MAY, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'A Munka ünnepe';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
					t_holiday.description := 'A Munka ünnepe előtti pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'A Munka ünnepe utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				END IF;
			END IF;
		END IF;
		IF t_year BETWEEN 1950 AND 1953 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'A Munka ünnepe';
			RETURN NEXT t_holiday;
		END IF;

		-- State Foundation Day (1771-????, 1891-)
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
				IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
					t_holiday.description := 'Az államalapítás ünnepe előtti pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'Az államalapítás ünnepe utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				END IF;
			END IF;
		END IF;

		-- National Day
		IF t_year >= 1991 THEN
			t_datestamp := make_date(t_year, OCTOBER, 23);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Nemzeti ünnep';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
					t_holiday.description := 'Nemzeti ünnep előtti pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'Nemzeti ünnep utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				END IF;
			END IF;
		END IF;

		-- All Saints' Day
		IF t_year >= 1999 THEN
			t_datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Mindenszentek';
			RETURN NEXT t_holiday;
			IF t_year >= 2010 THEN
				IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
					t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
					t_holiday.description := 'Mindenszentek előtti pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
					t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
					t_holiday.description := 'Mindenszentek utáni pihenőnap';
					t_holiday.observation_shifted := TRUE;
					RETURN NEXT t_holiday;
					t_holiday.observation_shifted := FALSE;
				END IF;
			END IF;
		END IF;

		-- Christmas Eve is not endorsed officially
		-- but nowadays it is usually a day off work
		t_holiday.authority := 'de_facto';
		t_datestamp := make_date(t_year, DECEMBER, 24);
		IF t_year >= 2010 AND NOT DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
			t_holiday.description := 'Szenteste';
			RETURN NEXT t_holiday;
		END IF;
		t_holiday.authority := 'national';

		-- First christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Karácsony';
		RETURN NEXT t_holiday;

		-- Second christmas
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
				END IF;
			END IF;
		END IF;

		-- New Year's Eve
		t_datestamp := make_date(t_year, DECEMBER, 31);
		IF t_year >= 2014 AND DATE_PART('dow', t_datestamp) = MONDAY THEN
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Szilveszter';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;