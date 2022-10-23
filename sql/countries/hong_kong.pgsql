------------------------------------------
------------------------------------------
-- Hong Kong Holidays (Porting Unfinished)
--
-- https://www.gov.hk/en/about/abouthk/holiday/2020.htm
-- https://en.wikipedia.org/wiki/Public_holidays_in_Hong_Kong
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.hong_kong(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Extended Holiday Days Notation
	HOLIDAY_PERIOD TEXT := '假期';
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_qingming DATE;
	t_mid_autumn DATE;
	t_easter DATE;
	t_holiday holidays.holiday%rowtype;
	t_shifting_holidays holidays.holiday[];

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
		t_holiday.description := '元旦';
		t_holiday.datestamp = make_date(t_year, JANUARY, 1);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Lunar New Year
		-- Sundays are not eligible for the holiday.
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		t_holiday.reference := 'Chinese New Year''s Day';
		t_holiday.description := '春節';
		IF DATE_PART('dow', t_datestamp) IN (MONDAY, TUESDAY, WEDNESDAY, THURSDAY) THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Chinese New Year Holiday';
			t_holiday.description := t_holiday.description || HOLIDAY_PERIOD;
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			RETURN NEXT t_holiday;
		ELSIF DATE_PART('dow', t_datestamp) = FRIDAY THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Chinese New Year Holiday';
			t_holiday.description := t_holiday.description || HOLIDAY_PERIOD;
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
			RETURN NEXT t_holiday;
		ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
			t_holiday.reference := 'Chinese New Year Holiday';
			t_holiday.description := t_holiday.description || HOLIDAY_PERIOD;
			t_holiday.datestamp := t_datestamp + '2 Day'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
			RETURN NEXT t_holiday;
		ELSIF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			IF t_year IN (2006, 2007, 2010) THEN
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.reference := 'Chinese New Year Holiday';
				t_holiday.description := t_holiday.description || HOLIDAY_PERIOD;
				t_holiday.datestamp := t_datestamp - '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.reference := 'Chinese New Year Holiday';
				t_holiday.description := t_holiday.description || HOLIDAY_PERIOD;
				t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '2 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '3 Days'::INTERVAL;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Ching Ming Festival (Qingming Festival?)
		t_qingming := calendars.find_chinese_date(
			solarterm => TRUE,
			g_year => t_year,
			c_solarterm => 5,
			c_day => 1
		);
		t_holiday.reference := 'Qingming Festival';
		t_holiday.description := '清明節';
		IF DATE_PART('dow', t_qingming) = SUNDAY THEN
			t_qingming := t_qingming + '1 Days'::INTERVAL;
			t_holiday.datestamp := t_qingming;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.datestamp := t_qingming;
			RETURN NEXT t_holiday;
		END IF;
		
		-- Easter Related Dates
		t_easter := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.description := '耶穌受難節';
		t_holiday.datestamp := t_easter - '2 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.reference := 'Holy Saturday';
		t_holiday.description := '耶穌受難節翌日';
		t_holiday.datestamp := t_easter - '1 Days'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.description := '復活節星期一';
		t_holiday.datestamp := t_easter + '1 Days'::INTERVAL;
		IF t_qingming = t_holiday.datestamp THEN
			t_holiday.datestamp := t_easter + '2 Days'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
		END IF;
		RETURN NEXT t_holiday;
		t_holiday.observation_shifted := FALSE;

		-- Birthday of the Buddha
		t_holiday.reference := 'Birthday of the Buddha';
		t_holiday.description := '佛誕';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 4,
			c_leap_month => FALSE,
			c_day => 8
		);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.description := '勞動節';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Tuen Ng Festival
		-- Dragon Boat Festival
		t_holiday.reference := 'Tuen Ng Festival';
		t_holiday.description := '端午節';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 5,
			c_leap_month => FALSE,
			c_day => 5
		);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Hong Kong Special Administrative Region Establishment Day
		t_holiday.reference := 'Hong Kong Special Administrative Region Establishment Day';
		t_holiday.description := '香港特別行政區成立紀念日';
		t_holiday.datestamp := make_date(t_year, JULY, 1);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Special holiday on 2015 - The 70th anniversary day of the victory
		-- of the Chinese people's war of resistance against Japanese aggression
		IF t_year = 2015 THEN
			t_holiday.reference := 'The 70th anniversary day of the victory of the Chinese people''s war of resistance against Japanese aggression';
			t_holiday.description := '中國人民抗日戰爭勝利70週年';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 3);
			RETURN NEXT t_holiday;
		END IF;

		-- Chinese Mid-Autumn Festival
		t_mid_autumn := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 8,
			c_leap_month => FALSE,
			c_day => 15
		);
		t_holiday.reference := 'Chinese Mid-Autumn Festival';
		t_holiday.description := '中秋節翌日';
		t_holiday.datestamp := t_mid_autumn;
		IF DATE_PART('dow', t_mid_autumn) = SATURDAY THEN
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := t_mid_autumn + '1 Day'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;
		t_mid_autumn := t_mid_autumn + '1 Day'::INTERVAL;

		-- National Day
		t_datestamp := make_date(t_year, OCTOBER, 1);
		t_holiday.reference := 'National Day';
		t_holiday.description := '中華人民共和國國慶日';
		IF DATE_PART('dow', t_datestamp) = SUNDAY OR t_datestamp = t_mid_autumn THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.datestamp := t_datestamp;
			RETURN NEXT t_holiday;
		END IF;

		-- Chung Yeung Festival
		t_holiday.reference := 'Chung Yeung Festival';
		t_holiday.description := '重陽節';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 9,
			c_leap_month => FALSE,
			c_day => 9
		);
		t_shifting_holidays := ARRAY_APPEND(t_shifting_holidays, t_holiday);

		-- Christmas Day
		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.reference := 'Christmas Day';
		t_holiday.description := '聖誕節';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.reference := 'Christmas Holiday';
			t_holiday.description := '聖誕假期';
			t_holiday.observation_shifted := TRUE;
			t_holiday.datestamp := t_datestamp + '+1 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '+2 Days'::INTERVAL;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSIF DATE_PART('dow', t_datestamp) = SATURDAY THEN
			t_holiday.reference := 'Christmas Holiday';
			t_holiday.description := '聖誕假期';
			t_holiday.datestamp := t_datestamp + '+2 Days'::INTERVAL;
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		ELSE
			t_holiday.reference := 'Christmas Holiday';
			t_holiday.description := '聖誕假期';
			t_holiday.datestamp := t_datestamp + '+1 Days'::INTERVAL;
			RETURN NEXT t_holiday;
		END IF;

		-- Shifting Holidays
		FOREACH t_holiday IN ARRAY t_shifting_holidays LOOP
			t_datestamp := t_holiday.datestamp;
			IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
				t_holiday.observation_shifted := FALSE;
			ELSE
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;