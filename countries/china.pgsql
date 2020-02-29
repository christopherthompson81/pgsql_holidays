-------------------------------------------------------------------------------
-- China Holidays
--
-- zh: 中华人民共和国
-- dayoff: sunday
-- langs: [zh, en]
-- timezones: [Asia/Shanghai, Asia/Urumqi]
--
-- Source: https://en.wikipedia.org/wiki/Public_holidays_in_China
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

		-- Jan 19 - Special Working Day
		-- Working day on weekend (Sunday)

		-- Jan 24 - Spring Festival Eve
		-- Spring Festival / Chinese New Year
		-- Spring Festival Golden Week holiday (3 paid days off, 7 - 8 days of continuous holiday)
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

		
		-- Jan 25 - Chinese New Year
		
		
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

		-- Apr 4 - Qing Ming Jie
		-- Apr 5 - Qing Ming Jie holiday
		-- Apr 6 - Qing Ming Jie holiday

		-- Apr 26 - Special Working Day
		-- Working day on weekend (Sunday)

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := '劳动节';
		RETURN NEXT t_holiday;

		-- May 1 - Labour Day
		-- May 2 - Labour Day Holiday
		-- May 3 - Labour Day Holiday
		-- May 4 - Labour Day Holiday
		-- May 5 - Labour Day Holiday
		-- Youth day can coincide with these
		
		-- Youth Day
		-- Youth from the age of 14 to 28
		t_holiday.reference := 'Youth Day';
		t_holiday.datestamp := make_date(t_year, MAY, 4);
		t_holiday.description := '青年节';
		t_holiday.start_time := '12:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.start_time := '00:00:00'::TIME;
		
		-- May 9 - Special Working Day
		-- Working day on weekend (Saturday)

		-- Children's Day
		-- Children below the age of 14
		t_holiday.reference := 'Children''s Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 1);
		t_holiday.description := '六一儿童节';
		RETURN NEXT t_holiday;
		
		-- Dragon Boat Festival
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
		
		-- Jun 25 - Dragon Boat Festival
		-- Jun 26 - Dragon Boat Festival holiday
		-- Jun 27 - Dragon Boat Festival holiday

		-- Jun 28 - Special Working Day
		-- Working day on weekend (Sunday)

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
		
		-- Sep 27 - Special Working Day
		-- Working day on weekend (Sunday)

		-- National Day
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

		-- Oct 1 - National Day
		-- Oct 1 - Mid-Autumn Festival
		-- Oct 2 - National Day Golden Week holiday
		-- Oct 3 - National Day Golden Week holiday
		-- Oct 4 - National Day Golden Week holiday
		-- Oct 5 - National Day Golden Week holiday
		-- Oct 6 - National Day Golden Week holiday
		-- Oct 7 - National Day Golden Week holiday
		-- Oct 8 - National Day Golden Week holiday

		-- Oct 10 - Special Working Day
		-- Working day on weekend (Saturday)

		-- Oct 25 - Double Ninth Festival
		-- Observance

		-- Nov 8 - Journalists' Day
		-- Observance

		-- Dec 25 - Christmas Day
		-- Observance

	END LOOP;
END;

$$ LANGUAGE plpgsql;
