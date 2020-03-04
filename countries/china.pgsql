-------------------------------------------------------------------------------
-- China Holidays
--
-- zh: 中华人民共和国
-- dayoff: sunday
-- languages: [zh, en]
-- timezones: [Asia/Shanghai, Asia/Urumqi]
--
-- Source: https://en.wikipedia.org/wiki/Public_holidays_in_China
-------------------------------------------------------------------------------
-- The Chinese work schedule is set by proclaimation.
--
-- 2020:
-- http://www.gov.cn/zhengce/content/2019-11/21/content_5454164.htm
-- 2020 Special Addendum:
-- http://english.www.gov.cn/policies/latestreleases/202001/27/content_WS5e2e34e4c6d019625c603f9b.html
--
-- The Chinese government has "reshuffled" the work schedule mid-year (in 2019
-- and 2020, for example). So the rules may be a little loose.
--
-- Given this, all of the dates provided here are predictions of the work
-- schedule unless I have programmed a back-catalogue of holidays for past
-- years.
-------------------------------------------------------------------------------
-- Weekend shifting scheme (since 2014)
--
-- Spring Festival
-- Shift the Saturdays and Sundays nearby to make a 7-day holiday. People may
-- need to work for 6 or 7 continuous days before or after the holiday.
--
-- National Day (not near Mid-Autumn Festival)
-- Shift the Saturdays and Sundays nearby to make a 7-day holiday. The holiday
-- is from 1 to 7 October. People may need to work for 6 or 7 continuous days
-- before or after the holiday.
--
-- New Year, Tomb-Sweeping Day, Labour Day, Dragon Boat Festival and Mid-Autumn Festival (not near National Day)
-- Wednesday: No weekend shifting. The holiday is only 1 day long. This is to
--            prevent people from working for 7 continuous days since 2014.
--            Sometimes shift the Sundays nearby to make a 4-day holiday.
--            People may need to work for 6 continuous days after the holiday.
-- Tuesday or Thursday: Shift the Saturdays and Sundays nearby to make a 3-day
--            holiday. People may need to work for 6 continuous days before or
--            after the holiday.
-- Saturday or Sunday: The public holiday is transferred to Monday.
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
	t_datestamp2 DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_three_day_holidays holidays.holiday[];
	t_national_day_duration INTEGER;
	i INTEGER;

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
		-- Three-day type
		t_holiday.reference := 'New Year''s Day';
		t_holiday.description := '元旦';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_three_day_holidays := ARRAY_APPEND(t_three_day_holidays, t_holiday);

		-- Spring Festival and Golden Week (黄金周)
		-- Includes Spring Festival Eve (1 day prior)
		-- First day is also Chinese New Year
		--   * 3 paid days off
		--   * 7 (or 8) days of contiguous holiday
		--   * one day (Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday.
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		-- Sunday prior (or the day if it is a Sunday) to the day before Spring Festival Eve is a work day
		-- If the day prior to Spring Festival Eve is a Sunday, the Saturday is the extra work day.
		-- If the day prior to Spring Festival Eve is a Saturday, that Saturday is the extra work day.
		t_holiday.reference := 'Special Working Day';
		IF DATE_PART('dow', (t_datestamp - '2 day'::INTERVAL)::DATE) = ANY(WEEKEND) THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date((t_datestamp - '2 day'::INTERVAL)::DATE, SATURDAY, -1);
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date((t_datestamp - '2 day'::INTERVAL)::DATE, SUNDAY, -1);
		END IF;
		t_holiday.description := '特殊工作日';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'extra_work_day';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';
		-- Spring Festival Eve
		t_holiday.reference := 'Spring Festival Eve';
		t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
		t_holiday.description := '春节前夕';
		RETURN NEXT t_holiday;
		-- Chinese New Year
		t_holiday.reference := 'Chinese New Year';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := '春节';
		RETURN NEXT t_holiday;
		-- Golden Week (5 Days)
		t_holiday.reference := 'Golden Week';
		t_holiday.description := '黄金周';
		t_holiday.datestamp := t_datestamp + '1 day'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '2 days'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '3 days'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '4 days'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '5 days'::INTERVAL;
		RETURN NEXT t_holiday;
		-- The Saturday after (or the day of if it is a Saturday) Golden Week Ends is a work day
		-- If the day after Golden Week ends is a Saturday, the Sunday is the extra work day.
		-- If the day after Golden Week ends is a Sunday, that Sunday is the extra work day.
		t_holiday.reference := 'Special Working Day';
		IF DATE_PART('dow', (t_datestamp + '6 days'::INTERVAL)::DATE) = ANY(WEEKEND) THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date((t_datestamp + '6 days'::INTERVAL)::DATE, SUNDAY, 1);
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date((t_datestamp + '6 days'::INTERVAL)::DATE, SATURDAY, 1);
		END IF;
		t_holiday.description := '特殊工作日';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'extra_work_day';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';
		
		-- Lantern Festival
		t_holiday.reference := 'Lantern Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 15
		);
		t_holiday.description := '元宵节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Zhonghe Festival
		t_holiday.reference := 'Zhonghe Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 2,
			c_leap_month => FALSE,
			c_day => 2
		);
		t_holiday.description := '中和节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- International Women's Day
		t_holiday.reference := 'International Women''s Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 8);
		t_holiday.description := '国际妇女节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;
		
		-- Mar 12 - Arbor Day
		-- Observance
		t_holiday.reference := 'Arbor Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 12);
		t_holiday.description := '植树节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Qingming Festival
		-- Three-day type
		t_holiday.reference := 'Qingming Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			solarterm => TRUE,
			g_year => t_year,
			c_solarterm => 5,
			c_day => 1
		);
		t_holiday.description := '清明节 清明節';
		t_three_day_holidays := ARRAY_APPEND(t_three_day_holidays, t_holiday);

		-- Labour Day
		-- Three-day type
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := '劳动节';
		t_three_day_holidays := ARRAY_APPEND(t_three_day_holidays, t_holiday);

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
		-- Three-day type
		t_holiday.reference := 'Dragon Boat Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 5,
			c_leap_month => FALSE,
			c_day => 5
		);
		t_holiday.description := '端午节';
		t_three_day_holidays := ARRAY_APPEND(t_three_day_holidays, t_holiday);

		-- Jul 1 - CPC Founding Day
		t_holiday.reference := 'CPC Founding Day';
		t_holiday.datestamp := make_date(t_year, JULY, 1);
		t_holiday.description := '建党节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Jul 11 - Maritime Day
		t_holiday.reference := 'Maritime Day';
		t_holiday.datestamp := make_date(t_year, JULY, 11);
		t_holiday.description := '中国航海日';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Army Day
		-- Military personnel in active service
		t_holiday.reference := 'Army Day';
		t_holiday.datestamp := make_date(t_year, AUGUST, 1);
		t_holiday.description := '建军节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;
		
		-- Chinese Valentine's Day / Double Seven Festival
		t_holiday.reference := 'Chinese Valentine''s Day';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 7,
			c_leap_month => FALSE,
			c_day => 7
		);
		t_holiday.description := '七夕';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Spirit Festival
		t_holiday.reference := 'Spirit Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 7,
			c_leap_month => FALSE,
			c_day => 15
		);
		t_holiday.description := '中元节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Teachers' Day
		t_holiday.reference := 'Teachers'' Day';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 10);
		t_holiday.description := '教师节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- National Day, Golden Week and Mid-Autumn Festival
		--   * 3 paid days off
		--   * 4 days paid off if National Day and Mid-Autumn Festival overlap or abut
		--   * 7 (or 8) days of contiguous holiday
		--   * one day (Sunday prior, Saturday after) from the surrounding
		--     weekends can be allocated as an extra work day to provide that
		--     contiguous holiday.
		t_datestamp := make_date(t_year, OCTOBER, 1);
		-- Find out how National Day and Golden Week relate to Mid-Autumn Festival
		t_datestamp2 := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 8,
			c_leap_month => FALSE,
			c_day => 15
		);
		IF t_datestamp2 >= make_date(t_year, SEPTEMBER, 25) AND t_datestamp2 <= make_date(t_year, OCTOBER, 7) THEN
			-- Holidays are too close, Mid-Autumn cannot use three-day holiday rules but does not overlap
			-- Turns it into a sort of observance and holiday days are given to National Day
			t_holiday.datestamp := t_datestamp2;
			t_holiday.reference := 'Mid-Autumn Festival';
			t_holiday.description := '中秋节';
			RETURN NEXT t_holiday;
			t_national_day_duration := 7;
		ELSE
			-- Not near each other, Three-day holiday rules apply to Mid-Autumn Festival
			t_holiday.datestamp := t_datestamp2;
			t_holiday.reference := 'Mid-Autumn Festival';
			t_holiday.description := '中秋节';
			t_three_day_holidays := ARRAY_APPEND(t_three_day_holidays, t_holiday);
			t_national_day_duration := 6;
		END IF;
		-- Sunday prior (or the day of if it is a Sunday) to the day before National Day is a work day
		-- If the day prior to Spring Festival Eve is a Sunday, the Saturday is the extra work day.
		-- If the day prior to Spring Festival Eve is a Saturday, that Saturday is the extra work day.
		t_holiday.reference := 'Special Working Day';
		IF DATE_PART('dow', (t_datestamp - '1 day'::INTERVAL)::DATE) = SUNDAY THEN
			-- The Saturday is the working day
			t_holiday.datestamp := t_datestamp - '2 day'::INTERVAL;
			t_holiday.description := '特殊工作日';
			t_holiday.day_off := FALSE;
			t_holiday.authority := 'extra_work_day';
			RETURN NEXT t_holiday;
			t_holiday.day_off := TRUE;
			t_holiday.authority := 'national';
			-- and the Sunday is an early part of the National Day Golden Week
			t_holiday.reference := 'Golden Week';
			t_holiday.description := '黄金周';
			t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
			RETURN NEXT t_holiday;
			t_national_day_duration := t_national_day_duration - 1;
		ELSIF DATE_PART('dow', (t_datestamp - '1 day'::INTERVAL)::DATE) = SATURDAY THEN
			-- That Saturday is the working day
			t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
			t_holiday.description := '特殊工作日';
			t_holiday.day_off := FALSE;
			t_holiday.authority := 'extra_work_day';
			RETURN NEXT t_holiday;
			t_holiday.day_off := TRUE;
			t_holiday.authority := 'national';
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date((t_datestamp - '1 day'::INTERVAL)::DATE, SUNDAY, -1);
			t_holiday.description := '特殊工作日';
			t_holiday.day_off := FALSE;
			t_holiday.authority := 'extra_work_day';
			RETURN NEXT t_holiday;
			t_holiday.day_off := TRUE;
			t_holiday.authority := 'national';
		END IF;
		-- National Day
		t_datestamp := make_date(t_year, OCTOBER, 1);
		t_holiday.reference := 'National Day';
		t_holiday.description := '国庆节';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		-- Golden Week
		t_holiday.reference := 'Golden Week';
		t_holiday.description := '黄金周';
		FOR i IN 1..t_national_day_duration LOOP
			t_holiday.datestamp := t_datestamp + (i::TEXT || ' day')::INTERVAL;
			RETURN NEXT t_holiday;
		END LOOP;
		-- The Saturday after (or the day of if it is a Saturday) Golden Week Ends is a work day
		-- If the day after Golden Week ends is a Saturday, the Sunday is the extra work day.
		-- If the day after Golden Week ends is a Sunday, that Sunday is the extra work day.
		t_datestamp := t_datestamp + (t_national_day_duration::TEXT || ' day')::INTERVAL;
		t_holiday.reference := 'Special Working Day';
		IF DATE_PART('dow', t_datestamp) = ANY(WEEKEND) THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SUNDAY, 1);
		ELSE
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, 1);
		END IF;
		t_holiday.description := '特殊工作日';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'extra_work_day';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';

		-- Double Ninth Festival / Chongyang Festival
		-- Observance
		t_holiday.reference := 'Chongyang Festival';
		t_holiday.datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 9,
			c_leap_month => FALSE,
			c_day => 9
		);
		t_holiday.description := '重阳节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Nov 8 - Journalists' Day
		-- Observance
		t_holiday.reference := 'Journalists'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 8);
		t_holiday.description := '新闻工作者日';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Dec 25 - Christmas Day
		-- Observance
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := '圣诞节';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Handle three-day type holidays.
		FOREACH t_holiday IN ARRAY t_three_day_holidays
		LOOP
			t_datestamp := t_holiday.datestamp;
			IF DATE_PART('dow', t_datestamp) = TUESDAY THEN
				-- Monday is a holiday, Sunday is part of the holiday and Saturday is an extra working day
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp - '1 day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp - '2 day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.reference := 'Special Working Day';
				t_holiday.datestamp := t_datestamp - '3 day'::INTERVAL;
				t_holiday.description := '特殊工作日';
				t_holiday.day_off := FALSE;
				t_holiday.authority := 'extra_work_day';
				RETURN NEXT t_holiday;
				t_holiday.day_off := TRUE;
				t_holiday.authority := 'national';
			ELSIF DATE_PART('dow', t_datestamp) = THURSDAY THEN
				-- Friday is a holiday, Satuday is part of the holiday and Sunday is an extra working day
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '1 day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '2 day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.reference := 'Special Working Day';
				t_holiday.datestamp := t_datestamp + '3 day'::INTERVAL;
				t_holiday.description := '特殊工作日';
				t_holiday.day_off := FALSE;
				t_holiday.authority := 'extra_work_day';
				RETURN NEXT t_holiday;
				t_holiday.day_off := TRUE;
				t_holiday.authority := 'national';
			ELSIF DATE_PART('dow', t_datestamp) IN (FRIDAY, SATURDAY) THEN
				-- Weekend plus Monday
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp + '2 Day'::INTERVAL;
				RETURN NEXT t_holiday;
			ELSIF DATE_PART('dow', t_datestamp) IN (SUNDAY, MONDAY) THEN
				-- Weekend plus Monday
				t_datestamp2 := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
				t_holiday.datestamp := t_datestamp2;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp2 + '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
				t_holiday.datestamp := t_datestamp2 + '2 Day'::INTERVAL;
				RETURN NEXT t_holiday;
			ELSE
				-- Wednesday -> Just one day
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
	END LOOP;
END;

$$ LANGUAGE plpgsql;
