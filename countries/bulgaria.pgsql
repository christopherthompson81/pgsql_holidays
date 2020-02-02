------------------------------------------
------------------------------------------
-- <country> Holidays
-- 
-- Official holidays in Bulgaria in their current form. This class does not
-- any return holidays before 1990, as holidays in the People's Republic of
-- Bulgaria and earlier were different.
-- 
-- Most holidays are fixed and if the date falls on a Saturday or a Sunday,
-- the following Monday is a non-working day. The exceptions are (1) the
-- Easter holidays, which are always a consecutive Friday, Saturday, and
-- Sunday; and (2) the National Awakening Day which, while an official holiday
-- and a non-attendance day for schools, is still a working day.
-- 
-- Sources (Bulgarian):
-- - http://lex.bg/laws/ldoc/1594373121
-- - https://www.parliament.bg/bg/24
-- 
-- Sources (English):
-- - https://en.wikipedia.org/wiki/Public_holidays_in_Bulgaria
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

		if year < 1990:
			return

		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Нова година';
		RETURN NEXT t_holiday;

		-- Liberation Day
		t_holiday.datestamp := make_date(t_year, MAR, 3);
		t_holiday.description := 'Ден на Освобождението на България от османско иго';
		RETURN NEXT t_holiday;

		-- International Workers' Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Ден на труда и на международната работническа солидарност';
		RETURN NEXT t_holiday;

		-- Saint George's Day
		t_holiday.datestamp := make_date(t_year, MAY, 6);
		t_holiday.description := 'Гергьовден, Ден на храбростта и Българската армия';
		RETURN NEXT t_holiday;

		-- Bulgarian Education and Culture and Slavonic Literature Day
		t_holiday.datestamp := make_date(t_year, MAY, 24);
		t_holiday.description := 'Ден на българската просвета и култура и на славянската писменост';
		RETURN NEXT t_holiday;

		-- Unification Day
		t_holiday.datestamp := make_date(t_year, SEP, 6);
		t_holiday.description := 'Ден на Съединението';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, SEP, 22);
		t_holiday.description := 'Ден на Независимостта на България';
		RETURN NEXT t_holiday;

		-- National Awakening Day
		t_holiday.datestamp := make_date(t_year, NOV, 1);
		t_holiday.description := 'Ден на народните будители';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 24);
		t_holiday.description := 'Бъдни вечер';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Рождество Христово';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Рождество Христово';
		RETURN NEXT t_holiday;

		-- Easter
		self[easter(year, method=EASTER_ORTHODOX) - rd(days=2)] = 'Велики петък'
		self[easter(year, method=EASTER_ORTHODOX) - rd(days=1)] = 'Велика събота'
		self[easter(year, method=EASTER_ORTHODOX)] = 'Великден'

	END LOOP;
END;

$$ LANGUAGE plpgsql;