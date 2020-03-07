------------------------------------------
------------------------------------------
-- India Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_India
-- https://www.calendarlabs.com/holidays/india/
-- https://slusi.dacnet.nic.in/watershedatlas/list_of_state_abbreviation.htm
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
	-- Provinces
	PROVINCES TEXT[] := ARRAY['AS', 'CG', 'SK', 'KA', 'GJ', 'BR', 'RJ', 'OD',
				 'TN', 'AP', 'WB', 'KL', 'HR', 'MH', 'MP', 'UP', 'UK', 'TS'];
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
		t_holiday.reference := 'Pongal / Makar Sankranti';
		t_holiday.datestamp := make_date(t_year, JANUARY, 15);
		t_holiday.description := 'Makar Sankranti / Pongal';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

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
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, PHALGUNA, 1)) - '40 Days'::INTERVAL;
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
		t_holiday.datestamp := calendars.hindu_next_waning_moon((t_year, PHALGUNA, 1));
		t_holiday.description := 'Maha Shivaratri';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Mar 9
		-- Holika Dahana
		-- Restricted Holiday

		-- Mar 9
		-- Hazarat Ali's Birthday
		-- Restricted Holiday

		-- Holi
		t_holiday.reference := 'Holi';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, PHALGUNA, 1));
		t_holiday.description := 'Holi';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Mar 25
		-- Chaitra Sukhladi
		-- Restricted Holiday

		-- Rama Navami
		t_holiday.reference := 'Rama Navami';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, CHAITRA, 1)) + '8 Days'::INTERVAL;
		t_holiday.description := 'Rama Navami';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Mahavir Jayanti
		t_holiday.reference := 'Mahavir Jayanti';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, CHAITRA, 1)) + '12 Days'::INTERVAL;
		t_holiday.description := 'Mahavir Jayanti';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Apr 9
		-- First day of Passover
		-- Observance

		-- Apr 9
		-- Maundy Thursday
		-- Observance, Christian

		-- Apr 10
		-- Good Friday
		-- Gazetted Holiday

		-- Apr 12
		-- Easter Day
		-- Restricted Holiday

		-- Apr 13
		-- Vaisakhi
		-- Restricted Holiday

		-- Apr 14
		-- Mesadi/Vaisakhadi
		-- Restricted Holiday

		-- Apr 14
		-- Ambedkar Jayanti
		-- Observance

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;

		-- May 7
		-- Buddha Purnima/Vesak
		-- Gazetted Holiday

		-- May 7
		-- Birthday of Ravindranath
		-- Restricted Holiday

		-- May 10
		-- Mother's Day
		-- Observance

		-- May 22
		-- Jamat Ul-Vida
		-- Restricted Holiday

		-- May 25
		-- Ramzan Id/Eid-ul-Fitar
		-- Gazetted Holiday

		-- May 25
		-- Ramzan Id/Eid-ul-Fitar
		-- Muslim, Common local holiday

		-- Jun 21
		-- Father's Day
		-- Observance

		-- Jun 23
		-- Rath Yatra
		-- Restricted Holiday

		-- Jul 5
		-- Guru Purnima
		-- Observance

		-- Jul 31
		-- Bakr Id/Eid ul-Adha
		-- Gazetted Holiday

		-- Aug 2
		-- Friendship Day
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
		-- Restricted Holiday

		-- Ganesh Chaturthi / Vinayaka Chaturthi
		t_holiday.reference := 'Ganesh Chaturthi';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, BHADRAPADA, 1)) + '4 Days'::INTERVAL;
		t_holiday.description := 'Ganesh Chaturthi';
		t_holiday.authority := 'optional';
		RETURN NEXT t_holiday;

		-- Aug 29
		-- Muharram/Ashura
		-- Gazetted Holiday

		-- Aug 31
		-- Onam
		-- Restricted Holiday

		-- Navaratri
		t_holiday.reference := 'Navaratri';
		t_holiday.datestamp := calendars.hindu_next_full_moon((t_year, ASHVIN, 1));
		t_holiday.description := 'Navaratri';
		t_holiday.authority := 'de_facto';
		RETURN NEXT t_holiday;

		-- Gandhi Jayanti
		t_holiday.reference := 'Mahatma Gandhi Jayanti';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 2);
		t_holiday.description := 'Mahatma Gandhi Jayanti';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Oct 22
		-- Maha Saptami
		-- Restricted Holiday

		-- Oct 23
		-- Maha Ashtami
		-- Restricted Holiday

		-- Oct 24
		-- Maha Navami
		-- Restricted Holiday

		-- Dussehra
		-- Vijayadashami
		t_holiday.reference := 'Vijayadashami / Dussehra';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, ASHVIN, 1)) + '10 Days'::INTERVAL;
		t_holiday.description := 'Vijayadashami / Dussehra';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Oct 29
		-- Milad un-Nabi/Id-e-Milad
		-- Gazetted Holiday

		-- Oct 31
		-- Halloween
		-- Observance

		-- Oct 31
		-- Maharishi Valmiki Jayanti
		-- Restricted Holiday

		-- Nov 4
		-- Karaka Chaturthi (Karva Chauth)
		-- Restricted Holiday

		-- Nov 14
		-- Naraka Chaturdasi
		-- Restricted Holiday

		-- Diwali/Deepavali
		t_holiday.reference := 'Diwali/Deepavali';
		t_holiday.datestamp := calendars.hindu_next_new_moon((t_year, KARTIKA, 1));
		t_holiday.description := 'Diwali/Deepavali';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Nov 15
		-- Govardhan Puja
		-- Restricted Holiday

		-- Nov 16
		-- Bhai Duj
		-- Restricted Holiday

		-- Nov 20
		-- Chhat Puja (Pratihar Sashthi/Surya Sashthi)
		-- Restricted Holiday

		-- Nov 24
		-- Guru Tegh Bahadur's Martyrdom Day
		-- Restricted Holiday

		-- Nov 30
		-- Guru Nanak Jayanti
		-- Gazetted Holiday

		-- Dec 11
		-- First Day of Hanukkah
		-- Observance

		-- Dec 18
		-- Last day of Hanukkah
		-- Observance

		-- Dec 24
		-- Christmas Eve
		-- Restricted Holiday

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas';
		t_holiday.authority := 'national';
		RETURN NEXT t_holiday;

		-- Dec 31
		-- New Year's Eve
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
