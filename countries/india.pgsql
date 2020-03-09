------------------------------------------
------------------------------------------
-- India Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_India
-- https://www.calendarlabs.com/holidays/india/
-- https://slusi.dacnet.nic.in/watershedatlas/list_of_state_abbreviation.htm
--
-- So many calendars needed!
-- * Gregorian (Solar Tropical Year based)
-- * Hindu
-- 		* Vikram Samvat (Luni-solar)
--		* Shaka Samvat (Saka Era) (Luni-solar)
--		* Indian National Calendar (Solar Tropical Year based)
-- 		* Malayalam (Sidereal Solar)
-- * Hebrew (Luni-solar)
-- * Persian
-- 		* Modern Jalali (Solar Observation Based)
-- 		* Shahenshahi Zoroastrian (Leap-Year Agnostic Medieval Iranian-derived Calendar)
-- * Hijri (Lunar Based)
-- * Chinese (Luni-solar)
-- * Nanakshahi (Sikh) (Solar Tropical Year based)
-- * Bengali (Luni-solar)
-- * Non-calendar Stellar Observations (VSOP87B + Meeus Algorithms + Swiss Emphemeris Algorithms Required)
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.india(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Hindu Month Constants
	CHAITRA INTEGER := 1;
	VAISHAKHA INTEGER := 2;
	JYESHTHA INTEGER := 3;
	ĀSHADHA INTEGER := 4;
	SHRAVANA INTEGER := 5;
	BHADRAPADA INTEGER := 6;
	ASHVIN INTEGER := 7;
	KARTIKA INTEGER := 8;
	MARGASHIRSHA INTEGER := 9;
	PAUSHA INTEGER := 10;
	MAGHA INTEGER := 11;
	PHALGUNA INTEGER := 12;
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
	-- Hebrew months
	NISAN INTEGER := 1;
	IYYAR INTEGER := 2;
	SIVAN INTEGER := 3;
	TAMMUZ INTEGER := 4;
	AV INTEGER := 5;
	ELUL INTEGER := 6;
	TISHRI INTEGER := 7;
	HESHVAN INTEGER := 8;
	KISLEV INTEGER := 9;
	TEVETH INTEGER := 10;
	SHEVAT INTEGER := 11;
	ADAR INTEGER := 12;
	VEADAR INTEGER := 13;
	-- Provinces
	PROVINCES TEXT[] := ARRAY['AS', 'CG', 'SK', 'KA', 'GJ', 'BR', 'RJ', 'OD',
				 'TN', 'AP', 'WB', 'KL', 'HR', 'MH', 'MP', 'UP', 'UK', 'TS'];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_holi DATE;
	t_easter DATE;
	t_ugadi DATE;
	t_navaratri DATE;
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

		-- Set up Holi for Holi related dates
		t_holi := calendars.hindu_next_full_moon((t_year, PHALGUNA, 1)) + '1 Day'::INTERVAL;

		-- Set up Easteer for Easter related dates
		t_easter := holidays.easter(t_year);

		-- Set up Ugadi for dates related to the solar new year
		t_ugadi := calendars.hindu_next_new_moon((t_year, CHAITRA, 1)) + '1 Day'::INTERVAL;

		-- Set up Navaratri for dates related to the autumn festival
		t_navaratri := calendars.hindu_next_new_moon((t_year, ASHVIN, 1)) + '1 Day'::INTERVAL;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'New Year''s Day';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Guru Govind Singh Jayanti
		-- Nanakshahi calendar; 23 Poh => Gregorian 5 January
		--
		-- Confusing information available on this. The Nanakshahi calendar is
		-- based on the solar tropical year and therefore corresponds precisely
		-- with the Gregorian calendar, but the celebration date is shown as
		-- moving against the Gregorian Calendar. I assume this is incorrect
		-- implementation elsewhere.
		--
		-- There are also conflicting birth Dates for the Guru (Dec 22 / Jan 5)
		t_holiday.reference := 'Guru Govind Singh Jayanti';
		t_holiday.datestamp := make_date(t_year, JANUARY, 5);
		t_holiday.description := 'Guru Govind Singh Jayanti';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Lohri
		-- Gregorian-Reckoned
		t_holiday.reference := 'Lohri';
		t_holiday.datestamp := make_date(t_year, JANUARY, 14);
		t_holiday.description := 'Lohri';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;
		
		-- Pongal / Makar Sankranti
		-- "The beginning of sun’s movement towards the zodiac Capricorn (Makarm Rashi)"
		-- TODO: This type of astronomical calculation has not yet been ported.
		--t_holiday.reference := 'Pongal / Makar Sankranti';
		--t_holiday.datestamp := make_date(t_year, JANUARY, 15);
		--t_holiday.description := 'Makar Sankranti / Pongal';
		--t_holiday.authority := 'optional';
		--RETURN NEXT t_holiday;

		-- Chinese New Year
		t_holiday.reference := 'Chinese New Year';
		t_holiday.description := 'Chinese New Year';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		IF t_year >= 1950 THEN
			-- Republic Day
			-- Gregorian-Reckoned
			t_holiday.reference := 'Republic Day';
			t_holiday.datestamp := make_date(t_year, JANUARY, 26);
			t_holiday.description := 'Republic Day';
			t_holiday.authority := 'national';
			RETURN NEXT t_holiday;
		END IF;

		-- Vasant Panchami
		-- Hindu; Holi -40
		t_holiday.reference := 'Vasant Panchami';
		t_holiday.datestamp := t_holi - '40 Days'::INTERVAL;
		t_holiday.description := 'Vasant Panchami';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Guru Ravidas Jayanti
		t_holiday.reference := 'Guru Ravidas Jayanti';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, MAGHA, 1));
		t_holiday.description := 'Guru Ravidas Jayanti';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Valentine's Day
		-- Gregorian-Reckoned
		t_holiday.reference := 'Valentine''s Day';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 14);
		t_holiday.description := 'Valentine''s Day';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- Maharishi Dayanand Saraswati Jayanti
		t_holiday.reference := 'Maharishi Dayanand Saraswati Jayanti';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, MAGHA, 15)) + '9 Days'::INTERVAL;
		t_holiday.description := 'Maharishi Dayanand Saraswati Jayanti';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;
		
		-- Shivaji Jayanti
		-- Gregorian-Reconked
		t_holiday.reference := 'Shivaji Jayanti';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 19);
		t_holiday.description := 'Shivaji Jayanti';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Maha Shivaratri (February / March)
		t_holiday.reference := 'Maha Shivaratri';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, PHALGUNA, 1)) - '2 Days'::INTERVAL;
		t_holiday.description := 'Maha Shivaratri';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Hazarat Ali's Birthday
		t_holiday.reference := 'Hazarat Ali''s Birthday';
		t_holiday.description := 'Hazarat Ali''s Birthday';
		t_holiday.authority := 'optional';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RAJAB, 13)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Holika Dahana
		t_holiday.reference := 'Holika Dahana';
		t_holiday.datestamp := t_holi - '1 Day'::INTERVAL;
		t_holiday.description := 'Holika Dahana';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Holi
		t_holiday.reference := 'Holi';
		t_holiday.datestamp := t_holi;
		t_holiday.description := 'Holi';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Ugadi
		t_holiday.reference := 'Ugadi';
		t_holiday.datestamp := t_ugadi;
		t_holiday.description := 'Ugadi';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Rama Navami
		t_holiday.reference := 'Rama Navami';
		t_holiday.datestamp := t_ugadi + '8 Days'::INTERVAL;
		t_holiday.description := 'Rama Navami';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Mahavir Jayanti
		t_holiday.reference := 'Mahavir Jayanti';
		t_holiday.datestamp := t_ugadi + '12 Days'::INTERVAL;
		t_holiday.description := 'Mahavir Jayanti';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- First day of Passover
		t_holiday.reference := 'First day of Passover';
		t_holiday.datestamp := calendars.hebrew_to_possible_gregorian(t_year, NISAN, 15);
		t_holiday.description := 'First day of Passover';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- Apr 9
		-- Maundy Thursday
		-- Observance, Christian
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := t_easter - '3 Days'::INTERVAL;
		t_holiday.description := 'Maundy Thursday';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- Apr 10
		-- Good Friday
		-- Gazetted Holiday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_easter - '2 Days'::INTERVAL;
		t_holiday.description := 'Good Friday';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Apr 12
		-- Easter Day
		-- Restricted Holiday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_easter;
		t_holiday.description := 'Easter Day';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Vaisakhi
		-- Mesadi/Vaisakhadi (same thing, but different regions and a day later)
		-- TODO: Requires Vikram Samvat Calendar converter (unimplemented)
		--t_holiday.reference := 'Vaisakhi';
		--t_holiday.datestamp := calendars.hindu_to_possible_gregorian(t_year, VAISHAKHA, 1);
		--t_holiday.datestamp := make_date(t_year, APRIL, 13);
		--t_holiday.description := 'Vaisakhi';
		--t_holiday.authority := 'optional';
		--RETURN NEXT t_holiday;

		-- Ambedkar Jayanti
		-- Gregorian Reckoned
		t_holiday.reference := 'Ambedkar Jayanti';
		t_holiday.datestamp := make_date(t_year, APRIL, 14);
		t_holiday.description := 'Ambedkar Jayanti';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- Labour Day
		-- Gregorian Reckoned
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- Buddha Purnima / Vesak
		t_holiday.reference := 'Buddha Purnima / Vesak';
		t_holiday.description := 'Buddha Purnima / Vesak';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, VAISHAKHA, 1));
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;
		
		-- Birthday of Ravindranath
		-- Bengali 25 Baisakh
		-- TODO: Bengali calendar is unimplemented
		-- Falls on May 7, 8 or 9th
		-- Restricted Holiday
		
		-- Mother's Day
		-- May 10
		-- Observance

		-- Jamat Ul-Vida
		-- May 22
		-- Jumu'atul-Widaa' is the last Friday in the month of Ramadhan before Eid-ul-Fitr
		-- Restricted Holiday

		-- Ramzan Id/Eid-ul-Fitar
		-- May 25
		-- Hijri 1 Shawwal
		-- Gazetted Holiday

		-- Father's Day
		-- Jun 21
		-- Observance

		-- Rath Yatra
		-- Jun 23
		-- "Ashadha Shukla Dwitiya"
		-- Hindu Ashadha 2
		-- Restricted Holiday

		-- Guru Purnima
		-- Jul 5		
		-- Hindu Ashadha 1, full moon
		-- Observance

		-- Bakr Id/Eid ul-Adha
		-- Jul 31
		-- Hijri 1 Dhu al-Hijjah
		-- Gazetted Holiday

		-- Friendship Day
		-- First Sunday of August
		-- Aug 2
		-- Observance

		-- Raksha Bandhan (Rakhi) (July / August)
		t_holiday.reference := 'Raksha Bandhan (Rakhi)';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, SHRAVANA, 1));
		t_holiday.description := 'Raksha Bandhan (Rakhi)';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Janmashtami (Smarta) Eve?
		-- (August / September)
		t_datestamp := calendars.hindu_next_new_moon((t_year, SHRAVANA, 1));
		t_holiday.reference := 'Janmashtami (Smarta)';
		t_holiday.datestamp := t_datestamp - '1 Day'::INTERVAL;
		t_holiday.description := 'Janmashtami (Smarta)';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Janmashtami
		-- (August / September)
		t_holiday.reference := 'Janmashtami';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Janmashtami';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		IF t_year >= 1947 THEN
			-- Independence Day
			t_holiday.reference := 'Independence Day';
			t_holiday.datestamp := make_date(t_year, AUGUST, 15);
			t_holiday.description := 'Independence Day';
			t_holiday.authority := 'national';
			RETURN NEXT t_holiday;
		END IF;

		-- Aug 16
		-- Parsi New Year
		-- Nowruz
		-- Indian Parsi (Persians?) use the Shahenshahi calendar (not implemented)
		-- Restricted Holiday

		-- Ganesh Chaturthi / Vinayaka Chaturthi
		t_holiday.reference := 'Ganesh Chaturthi';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, BHADRAPADA, 1)) + '4 Days'::INTERVAL;
		t_holiday.description := 'Ganesh Chaturthi';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Aug 29
		-- Muharram/Ashura
		-- Jalali 10 Muharram
		-- Gazetted Holiday
		t_holiday.reference := 'Muharram / Ashura';
		t_holiday.description := 'Muharram / Ashura';
		t_holiday.authority := 'national';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, MUHARRAM, 10)
		LOOP
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END LOOP;

		-- Aug 31
		-- Onam
		-- 22nd nakshatra Thiruvonam in the Malayalam calendar month of Chingam
		-- Malayalam Calendar is not implemented
		-- Restricted Holiday

		-- Navaratri
		t_holiday.reference := 'Navaratri';
		t_holiday.datestamp := t_navaratri;
		t_holiday.description := 'Navaratri';
		t_holiday.authority := 'de_facto';
		RETURN NEXT t_holiday;

		-- Gandhi Jayanti
		-- Gregorian Reckoned
		t_holiday.reference := 'Mahatma Gandhi Jayanti';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 2);
		t_holiday.description := 'Mahatma Gandhi Jayanti';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Maha Saptami
		t_holiday.reference := 'Maha Saptami';
		t_holiday.datestamp := t_navaratri + '7 Days'::INTERVAL;
		t_holiday.description := 'Maha Saptami';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Maha Ashtami
		t_holiday.reference := 'Maha Ashtami';
		t_holiday.datestamp := t_navaratri + '8 Days'::INTERVAL;
		t_holiday.description := 'Maha Ashtami';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Maha Navami
		t_holiday.reference := 'Maha Navami';
		t_holiday.datestamp := t_navaratri + '9 Days'::INTERVAL;
		t_holiday.description := 'Maha Navami';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Dussehra
		-- Vijayadashami
		t_holiday.reference := 'Vijayadashami / Dussehra';
		t_holiday.datestamp := t_navaratri + '10 Days'::INTERVAL;
		t_holiday.description := 'Vijayadashami / Dussehra';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Milad un-Nabi/Id-e-Milad
		t_holiday.reference := 'Prophet Muhammad''s Birthday';
		FOR t_datestamp IN
			SELECT * FROM calendars.possible_gregorian_from_hijri(t_year, RABI_AL_AWWAL, 12)
		LOOP
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Milad un-Nabi / Id-e-Milad';
			RETURN NEXT t_holiday;
		END LOOP;

		-- Halloween
		-- Gregorian Oct 31
		-- Observance

		-- Oct 31
		-- Maharishi Valmiki Jayanti
		-- full moon (Purnima) of the month of Ashwin,
		-- Hindu Ashvin, Full Moon
		-- Restricted Holiday

		-- Nov 4
		-- Karaka Chaturthi (Karva Chauth)
		-- fourth day after the full moon, in the Hindu lunisolar calendar month of Kartik.
		-- Hindu Kartika, Full Moon +4
		-- Restricted Holiday

		-- Nov 14
		-- Naraka Chaturdasi
		-- TODO: Vikram Samvat Calendar
		-- Chaturdashi (14) of the Krishna Paksha (Second Fornight) in the Vikram Samvat Hindu calendar month of Kartik
		-- Hindu Kartika 29
		-- Restricted Holiday

		-- Diwali/Deepavali
		t_holiday.reference := 'Diwali/Deepavali';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, KARTIKA, 1));
		t_holiday.description := 'Diwali/Deepavali';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Nov 15
		-- Govardhan Puja
		-- Diwali +1
		-- Restricted Holiday

		-- Nov 16
		-- Bhai Duj
		-- Diwali +2
		-- Restricted Holiday

		-- Nov 20
		-- Chhat Puja (Pratihar Sashthi/Surya Sashthi)
		-- Vikram Samvat
		-- Hindu, Kartika, new moon + 5 days
		-- Restricted Holiday

		-- Nov 24
		-- Guru Tegh Bahadur's Martyrdom Day
		-- Gregorian Reckoned
		-- Restricted Holiday

		-- Guru Nanak Jayanti
		-- Nov 30
		-- Hindu, Kartika, Full Moon
		-- Gazetted Holiday

		-- First Day of Hanukkah
		-- Dec 11
		-- Hebrew Kislev 25
		-- Observance

		-- Last day of Hanukkah
		-- Dec 18
		-- Hanukkah +8
		-- Observance

		-- Christmas Eve
		-- Dec 24
		-- Gregorian Reckoned
		-- Restricted Holiday

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- New Year's Eve
		-- Dec 31
		-- Gregorian Reckoned
		-- Observance





		-- Provincial Holidays
		t_holiday.authority := 'provincial';

		-- GJ: Gujarat
		IF p_province = 'GJ' THEN
			t_holiday.reference := 'Uttarayan';
			t_holiday.datestamp := make_date(t_year, JANUARY, 14);
			t_holiday.description := 'Uttarayan';
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Gujarat Day';
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Gujarat Day';
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Sardar Patel Jayanti';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 31);
			t_holiday.description := 'Sardar Patel Jayanti';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'BR' THEN
			t_holiday.reference := 'Bihar Day';
			t_holiday.datestamp := make_date(t_year, MARCH, 22);
			t_holiday.description := 'Bihar Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'RJ' THEN
			t_holiday.reference := 'Rajasthan Day';
			t_holiday.datestamp := make_date(t_year, MARCH, 30);
			t_holiday.description := 'Rajasthan Day';
			RETURN NEXT t_holiday;

			t_holiday.reference := 'Maharana Pratap Jayanti';
			t_holiday.datestamp := make_date(t_year, JUNE, 15);
			t_holiday.description := 'Maharana Pratap Jayanti';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'OD' THEN
			t_holiday.reference := 'Odisha Day';
			t_holiday.datestamp := make_date(t_year, APRIL, 1);
			t_holiday.description := 'Odisha Day (Utkala Dibasa)';
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Maha Vishuva Sankranti / Pana Sankranti';
			t_holiday.datestamp := make_date(t_year, APRIL, 15);
			t_holiday.description := 'Maha Vishuva Sankranti / Pana Sankranti';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province IN ('OD', 'AP', 'BR', 'WB', 'KL', 'HR', 'MH', 'UP', 'UK', 'TN') THEN
			t_holiday.reference := 'Dr. B. R. Ambedkar''s Jayanti';
			t_holiday.datestamp := make_date(t_year, APRIL, 14);
			t_holiday.description := 'Dr. B. R. Ambedkar''s Jayanti';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'TN' THEN
			t_holiday.reference := 'Puthandu (Tamil New Year)';
			t_holiday.description := 'Puthandu (Tamil New Year)';
			t_holiday.datestamp := make_date(t_year, APRIL, 14);
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APRIL, 15);
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'WB' THEN
			t_holiday.reference := 'Pohela Boishakh';
			t_holiday.datestamp := make_date(t_year, APRIL, 14);
			t_holiday.description := 'Pohela Boishakh';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APRIL, 15);
			RETURN NEXT t_holiday;

			t_holiday.reference := 'Rabindra Jayanti';
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			t_holiday.description := 'Rabindra Jayanti';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'AS' THEN
			t_holiday.reference := 'Assamese New Year';
			t_holiday.datestamp := make_date(t_year, APRIL, 15);
			t_holiday.description := 'Bihu (Assamese New Year)';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'MH' THEN
			t_holiday.reference := 'Maharashtra Day';
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Maharashtra Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'SK' THEN
			t_holiday.reference := 'Annexation Day';
			t_holiday.datestamp := make_date(t_year, MAY, 16);
			t_holiday.description := 'Annexation Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'KA' THEN
			t_holiday.reference := 'Karnataka Rajyotsava';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Karnataka Rajyotsava';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'AP' THEN
			t_holiday.reference := 'Andhra Pradesh Foundation Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Andhra Pradesh Foundation Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'HR' THEN
			t_holiday.reference := 'Haryana Foundation Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Haryana Foundation Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'MP' THEN
			t_holiday.reference := 'Madhya Pradesh Foundation Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Madhya Pradesh Foundation Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'KL' THEN
			t_holiday.reference := 'Kerala Foundation Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Kerala Foundation Day';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'CG' THEN
			t_holiday.reference := 'Chhattisgarh Foundation Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Chhattisgarh Foundation Day';
			RETURN NEXT t_holiday;
		END IF;

		-- TS is Telangana State which was bifurcated in 2014 from AP
		-- (AndhraPradesh)
		IF p_province = 'TS' THEN
			t_holiday.reference := 'Bathukamma Festival';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 6);
			t_holiday.description := 'Bathukamma Festival';
			RETURN NEXT t_holiday;

			t_holiday.reference := 'Eid al-Fitr';
			t_holiday.datestamp := make_date(t_year, APRIL, 6);
			t_holiday.description := 'Eid al-Fitr';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;
