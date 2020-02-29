-------------------------------------------------------------------------------
-- China Holidays
--
-- zh: 中华人民共和国
-- dayoff: sunday
-- languages: [zh, en]
-- timezones: [Asia/Shanghai, Asia/Urumqi]
--
-- Source: https://en.wikipedia.org/wiki/Public_holidays_in_China
--
-- The Chinese work schedule is set by proclaimation.
--
-- 2020:
-- http://www.gov.cn/zhengce/content/2019-11/21/content_5454164.htm
-- 2020 Special Addendum:
-- http://english.www.gov.cn/policies/latestreleases/202001/27/content_WS5e2e34e4c6d019625c603f9b.html
--
-- The primary holidays and golden weeks provide the framework for that work 
-- schedule, and the "extra working days" principle appears to use a rule-based
-- method to determine where they fall.
--
-- The Chinese government has "reshuffled" the work schedule mid-year (in 2019
-- and 2020, for example). So the rules may be a little loose.
--
-- Given this, all of the dates provided here are predictions of the work
-- schedule unless I have programmed a back-catalogue of holidays for past
-- years.
-------------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.china(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Provinces
	PROVINCES TEXT[] := ARRAY[
		'Beijing', 'Tianjin', 'Hebei', 'Shanxi', 'Inner Mongolia', 'Liaoning',
		'Jilin', 'Heilongjiang', 'Shanghai', 'Jiangsu', 'Zhejiang', 'Anhui',
		'Fujian', 'Jiangxi', 'Shandong', 'Henan', 'Hubei', 'Hunan',
		'Guangdong', 'Guangxi', 'Hainan', 'Chongqing', 'Sichuan', 'Guizhou',
		'Yunnan', 'Tibet', 'Shaanxi', 'Gansu', 'Qinghai', 'Ningxia',
		'Xinjiang', 'Taiwan', 'Hong Kong SAR China', 'Macau SAR China'
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

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := '元旦';
		RETURN NEXT t_holiday;

		-- Spring Festival and Golden Week
		-- Includes Spring Festival Eve (1 day prior)
		-- First day is also Chinese New Year
		--   * 3 paid days off
		--   * 7 (or 8) days of contiguous holiday
		--   * one day (Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday.
		t_holiday.reference := 'Spring Festival';
		t_holiday.datestamp := astronomia.jde_to_gregorian(
			calendars.find_chinese_date(
				jsonb_build_object(
					'g_year', t_year::TEXT,
					'c_lunar_month', 1::TEXT,
					'c_leap_month', FALSE::TEXT,
					'c_day', 1::TEXT
		)))::DATE;
		t_holiday.description := '春节';
		RETURN NEXT t_holiday;
		
		-- Feb 8 - Lantern Festival
		-- Observance

		-- Feb 24 - Zhonghe Festival
		-- Observance

		-- International Women's Day
		t_holiday.reference := 'International Women''s Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 8);
		t_holiday.description := '国际妇女节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;
		
		-- Mar 12 - Arbor Day
		-- Observance

		-- Qingming Festival
		-- Duration is 3 days
		t_holiday.reference := 'Qingming Festival';
		t_holiday.datestamp := astronomia.jde_to_gregorian(
			calendars.find_chinese_date(
				jsonb_build_object(
					'solarterm', TRUE::TEXT,
					'g_year', t_year::TEXT,
					'c_solarterm', 5::TEXT,
					'c_day', 1::TEXT
		)))::DATE;
		t_holiday.description := '清明节 清明節';
		RETURN NEXT t_holiday;

		-- Labour Day
		--   * 3 paid days off
		--   * 7 (or 8) days of contiguous holiday
		--   * one day (Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday.
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := '劳动节';
		RETURN NEXT t_holiday;

		-- Youth Day
		-- Youth from the age of 14 to 28
		-- Youth day can coincide with Labour Day
		t_holiday.reference := 'Youth Day';
		t_holiday.datestamp := make_date(t_year, MAY, 4);
		t_holiday.description := '青年节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;

		-- Children's Day
		-- Children below the age of 14
		t_holiday.reference := 'Children''s Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 1);
		t_holiday.description := '六一儿童节';
		RETURN NEXT t_holiday;
		
		-- Dragon Boat Festival
		--   * 1 paid day off
		--   * 3 days of contiguous holiday
		--   * one day (i.e.: Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday. A Sunday immediately following the holiday
		--     can be allocated as an extra work day.
		t_holiday.reference := 'Dragon Boat Festival';
		t_holiday.datestamp := astronomia.jde_to_gregorian(
			calendars.find_chinese_date(
				jsonb_build_object(
					'g_year', t_year::TEXT,
					'c_lunar_month', 5::TEXT,
					'c_leap_month', FALSE::TEXT,
					'c_day', 5::TEXT
		)))::DATE;
		t_holiday.description := '端午节';
		RETURN NEXT t_holiday;

		-- Jul 1 - CPC Founding Day
		-- Observance

		-- Jul 11 - Maritime Day
		-- Observance

		-- Army Day
		-- Military personnel in active service
		t_holiday.reference := 'Army Day';
		t_holiday.datestamp := make_date(t_year, AUGUST, 1);
		t_holiday.description := '建军节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;
		
		-- Aug 2 - Chinese Valentine's Day
		-- Observance

		-- Sep 2 - Spirit Festival
		-- Observance

		-- Sep 10 - Teachers' Day
		-- Observance

		-- National Day and Golden Week
		--   * 3 paid days off
		--   * 4 days paid off if National Day and Mid-Autumn Festival overlap
		--   * 7 (or 8) days of contiguous holiday
		--   * one day (Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday.
		t_holiday.reference := 'National Day';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 1);
		t_holiday.description := '国庆节';
		RETURN NEXT t_holiday;

		-- Mid-Autumn Festival
		t_holiday.reference := 'Mid-Autumn Festival';
		t_holiday.datestamp := astronomia.jde_to_gregorian(
			calendars.find_chinese_date(
				jsonb_build_object(
					'g_year', t_year::TEXT,
					'c_lunar_month', 8::TEXT,
					'c_leap_month', FALSE::TEXT,
					'c_day', 15::TEXT
		)))::DATE;
		t_holiday.description := '中秋节';
		RETURN NEXT t_holiday;

		-- Oct 25 - Double Ninth Festival
		-- Observance

		-- Nov 8 - Journalists' Day
		-- Observance

		-- Dec 25 - Christmas Day
		-- Observance

	END LOOP;
END;

$$ LANGUAGE plpgsql;
