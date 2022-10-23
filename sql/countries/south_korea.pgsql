-------------------------------------------------------------------------------
-- South Korea Holidays
--
-- ko: 대한민국
-- dayoff: sunday
-- langs: ko
-- Timezones: Asia/Seoul
--
-- Attrib https://en.wikipedia.org/wiki/List_of_public_holidays_in_South_Korea
-------------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.south_korea(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	PROVINCES TEXT[] := ARRAY [
		'Seoul',
		'Busan',
		'Daegu',
		'Incheon',
		'Gwangju City',
		'Daejeon',
		'Ulsan',
		'Gyeonggi',
		'Gangwon',
		'North Chungcheong',
		'South Chungcheong',
		'North Jeolla',
		'South Jeolla',
		'North Gyeongsang',
		'South Gyeongsang',
		'Jeju',
		'Sejong'
	];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
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
		t_holiday.reference := 'New Year''s Day (Sinjeong)';
		t_holiday.description := '신정 (新正)';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		RETURN NEXT t_holiday;

		-- Lunar New Year
		-- Also called Seol (설) or Gujeong (Korean: 구정; Hanja: 舊正)
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 1,
			c_leap_month => FALSE,
			c_day => 1
		);
		t_holiday.reference := 'Lunar New Year (Seolnal)';
		t_holiday.description := '설날';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		RETURN NEXT t_holiday;
		t_holiday.datestamp := t_datestamp + '2 Day'::INTERVAL;
		RETURN NEXT t_holiday;

		-- Independence Movement Day
		t_holiday.reference := 'Independence Movement Day (Samiljeol)';
		t_holiday.description := '3·1절 (三一節)';
		t_holiday.datestamp := make_date(t_year, MARCH, 1);
		RETURN NEXT t_holiday;

		-- Children's Day
		t_holiday.reference := 'Children''s Day (Eorininal)';
		t_holiday.description := '어린이날';
		t_holiday.datestamp := make_date(t_year, MAY, 5);
		RETURN NEXT t_holiday;

		-- Buddha's Birthday
		-- Formerly called:
		-- * Seokgatansinil (Korean: 석가탄신일; Hanja: 釋迦誕辰日);
		-- * Sawol Chopail (Korean: 사월 초파일; Hanja: 四月初八日)
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 4,
			c_leap_month => FALSE,
			c_day => 8
		);
		t_holiday.reference := 'Buddha''s Birthday (Bucheonnim Osinnal)';
		t_holiday.description := '부처님 오신 날';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- Memorial Day
		t_holiday.reference := 'Memorial Day (Hyeonchung-il)';
		t_holiday.description := '현충일 (顯忠日)';
		t_holiday.datestamp := make_date(t_year, JUNE, 6);
		RETURN NEXT t_holiday;

		-- Constitution Day
		t_holiday.reference := 'Constitution Day (Jeheonjeol)';
		t_holiday.description := '제헌절 (制憲節)';
		t_holiday.datestamp := make_date(t_year, JULY, 17);
		RETURN NEXT t_holiday;

		-- Liberation Day
		t_holiday.reference := 'Liberation Day (Gwangbokjeol)';
		t_holiday.description := '광복절 (光復節)';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		RETURN NEXT t_holiday;

		-- Chuseok
		-- Also called Han-gawi (Korean: 한가위). Korean traditional harvest festival.
		t_datestamp := calendars.find_chinese_date(
			g_year => t_year,
			c_lunar_month => 8,
			c_leap_month => FALSE,
			c_day => 15
		);
		t_holiday.reference := 'Chuseok';
		t_holiday.description := '추석 (秋夕)';
		t_holiday.datestamp := t_datestamp;
		RETURN NEXT t_holiday;

		-- National Foundation Day
		t_holiday.reference := 'National Foundation Day (Gaecheonjeol)';
		t_holiday.description := '개천절 (開天節)';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
		RETURN NEXT t_holiday;

		-- Hangul Day
		t_holiday.reference := 'Hangul Day (Hangeulnal)';
		t_holiday.description := '한글날';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 9);
		RETURN NEXT t_holiday;

		-- Christmas
		-- Commonly called Seongtanjeol (Korean: 성탄절; Hanja: 聖誕節)
		t_holiday.reference := 'Christmas (Gidoktansinil)';
		t_holiday.description := '기독탄신일';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;
