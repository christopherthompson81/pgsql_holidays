------------------------------------------
------------------------------------------
-- <country> Holidays
--
-- http://zakon1.rada.gov.ua/laws/show/322-08/paran454--n454
-- 
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_start_year INTEGER, p_end_year INTEGER)
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

		-- The current set of holidays came into force in 1991
		-- But most holiday days was inplemented in 1981
		if year < 1918:
			return

		-- New Year's Day
		if year >= 1898:
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Новий рік';
			RETURN NEXT t_holiday;

		-- Christmas Day (Orthodox)
		if year >= 1991:
			t_holiday.datestamp := make_date(t_year, JANUARY, 7);
			t_holiday.description := 'Різдво Христове (православне)';
			RETURN NEXT t_holiday;

		-- Women's Day
		if year > 1965:
			t_holiday.datestamp := make_date(t_year, MAR, 8);
			t_holiday.description := 'Міжнародний жіночий день';
			RETURN NEXT t_holiday;

		-- Easter
		if year >= 1991:
			self[easter(year, method=EASTER_ORTHODOX)] = 'Пасха (Великдень)'

		-- Holy trinity
		if year >= 1991:
			self[easter(year, method=EASTER_ORTHODOX) + rd(days=49)] = 'Трійця'

		-- Labour Day
		if year > 2017:
			name = 'День праці'
		elif 1917 < year <= 2017:
			name = 'День міжнародної солідарності трудящих'
		self[date(year, MAY, 1)] = name

		-- Labour Day in past
		if 1928 < year < 2018:
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'День міжнародної солідарності трудящих';
			RETURN NEXT t_holiday;

		-- Victory Day
		name = 'День перемоги'
		if year >= 1965:
			self[date(year, MAY, 9)] = name
		if 1945 <= year < 1947:
			self[date(year, MAY, 9)] = name
			t_holiday.datestamp := make_date(t_year, SEP, 3);
			t_holiday.description := 'День перемоги над Японією';
			RETURN NEXT t_holiday;

		-- Constitution Day
		if year >= 1997:
			t_holiday.datestamp := make_date(t_year, JUN, 28);
			t_holiday.description := 'День Конституції України';
			RETURN NEXT t_holiday;

		-- Independence Day
		name = 'День незалежності України'
		if year > 1991:
			self[date(year, AUG, 24)] = name
		ELSIF t_year == 1991 THEN
			self[date(year, JUL, 16)] = name

		-- Day of the defender of Ukraine
		if year >= 2015:
			t_holiday.datestamp := make_date(t_year, OCT, 14);
			t_holiday.description := 'День захисника України';
			RETURN NEXT t_holiday;

		-- USSR Constitution day
		name = 'День Конституції СРСР'
		if 1981 <= year < 1991:
			self[date(year, OCT, 7)] = name
		elif 1937 <= year < 1981:
			self[date(year, DEC, 5)] = name

		-- October Revolution
		if 1917 < year < 2000:
			if year <= 1991:
				name = 'Річниця Великої Жовтневої соціалістичної революції'
			else:
				name = 'Річниця жовтневого перевороту'
			self[date(year, NOV, 7)] = name
			self[date(year, NOV, 8)] = name

		-- Christmas Day (Catholic)
		if year >= 2017:
			t_holiday.datestamp := make_date(t_year, DEC, 25);
			t_holiday.description := 'Різдво Христове (католицьке)';
			RETURN NEXT t_holiday;

		-- USSR holidays
		-- Bloody_Sunday_(1905)
		if 1917 <= year < 1951:
			t_holiday.datestamp := make_date(t_year, JANUARY, 22);
			t_holiday.description := 'День пам''яті 9 січня 1905 року';
			RETURN NEXT t_holiday;

		-- Paris_Commune
		if 1917 < year < 1929:
			t_holiday.datestamp := make_date(t_year, MAR, 18);
			t_holiday.description := 'День паризької комуни';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;