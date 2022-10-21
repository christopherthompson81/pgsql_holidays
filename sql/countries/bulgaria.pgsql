------------------------------------------
------------------------------------------
-- Bulgaria Holidays
-- bg: България
--
-- Official holidays in Bulgaria in their current form. This class does not
-- return any holidays before 1990, as holidays in the People's Republic of
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
CREATE OR REPLACE FUNCTION holidays.bulgaria(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Month Constants
	JANUARY CONSTANT INTEGER := 1;
	FEBRUARY CONSTANT INTEGER := 2;
	MARCH CONSTANT INTEGER := 3;
	APRIL CONSTANT INTEGER := 4;
	MAY CONSTANT INTEGER := 5;
	JUNE CONSTANT INTEGER := 6;
	JULY CONSTANT INTEGER := 7;
	AUGUST CONSTANT INTEGER := 8;
	SEPTEMBER CONSTANT INTEGER := 9;
	OCTOBER CONSTANT INTEGER := 10;
	NOVEMBER CONSTANT INTEGER := 11;
	DECEMBER CONSTANT INTEGER := 12;
	-- Weekday Constants
	SUNDAY CONSTANT INTEGER := 0;
	MONDAY CONSTANT INTEGER := 1;
	TUESDAY CONSTANT INTEGER := 2;
	WEDNESDAY CONSTANT INTEGER := 3;
	THURSDAY CONSTANT INTEGER := 4;
	FRIDAY CONSTANT INTEGER := 5;
	SATURDAY CONSTANT INTEGER := 6;
	WEEKEND CONSTANT INTEGER[] := ARRAY[0, 6];
	-- Localication
	OBSERVED CONSTANT TEXT := ' (компенсация)'; -- Bulgarian
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;
	t_holiday_list holidays.holiday[];

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Return an empty list prior to the current country existing
		IF t_year < 1990 THEN
			RETURN;
		END IF;

		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Нова година';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Day of Remembrance and Respect to Victims of the Communist Regime in Bulgaria
		-- bg: Ден, да си спомня жертвите на комунистическия режим
		-- Feb 1
		-- Observance
		t_holiday.reference := 'Remembrance Day';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 1);
		t_holiday.description := 'Ден, да си спомня жертвите на комунистическия режим';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';

		-- Baba Marta
		-- bg: Баба Марта
		-- Mar 1
		-- Observance
		t_holiday.reference := 'Baba Marta';
		t_holiday.datestamp := make_date(t_year, MARCH, 1);
		t_holiday.description := 'Баба Марта';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';

		-- Liberation Day
		t_holiday.reference := 'Liberation Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 3);
		t_holiday.description := 'Ден на Освобождението на България от османско иго';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Easter
		t_datestamp := holidays.easter(t_year, 'EASTER_ORTHODOX');

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Велики петък';
		RETURN NEXT t_holiday;

		-- Easter Saturday
		t_holiday.reference := 'Easter Saturday';
		t_holiday.datestamp := t_datestamp - '1 Days'::INTERVAL;
		t_holiday.description := 'Велика събота';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Великден';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Велики понеделник';
		RETURN NEXT t_holiday;

		-- International Workers' Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Ден на труда и на международната работническа солидарност';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Saint George's Day
		t_holiday.reference := 'St. George''s Day';
		t_holiday.datestamp := make_date(t_year, MAY, 6);
		t_holiday.description := 'Гергьовден, Ден на храбростта и Българската армия';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Bulgarian Education and Culture and Slavonic Literature Day
		t_holiday.reference := 'Culture and Literacy Day';
		t_holiday.datestamp := make_date(t_year, MAY, 24);
		t_holiday.description := 'Ден на българската просвета и култура и на славянската писменост';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- July Morning
		-- bg: 	Джулай
		-- Jul 1
		-- Observance

		-- Unification Day
		t_holiday.reference := 'Unification Day';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 6);
		t_holiday.description := 'Ден на Съединението';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 22);
		t_holiday.description := 'Ден на Независимостта на България';
		RETURN NEXT t_holiday;
		t_holiday_list := array_append(t_holiday_list, t_holiday);

		-- Apply observation shifting rules to the above.
		FOREACH t_holiday IN ARRAY t_holiday_list
		LOOP
			IF DATE_PART('dow', t_holiday.datestamp) = ANY(WEEKEND) THEN
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_holiday.datestamp, MONDAY, 1);
				t_holiday.description := t_holiday.description || OBSERVED;
				t_holiday.observation_shifted := TRUE;
				RETURN NEXT t_holiday;
			END IF;
		END LOOP;
		t_holiday.observation_shifted := FALSE;

		-- National Awakening Day
		t_holiday.reference := 'National Awakening Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Ден на народните будители';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'observance';
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Бъдни вечер';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Рождество Христово, Коледа';
		RETURN NEXT t_holiday;

		-- Boxing Day
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Втори ден на Коледа';
		RETURN NEXT t_holiday;

		-- Christmas Holiday(s)
		t_datestamp := make_date(t_year, DECEMBER, 24);
		IF DATE_PART('dow', t_datestamp) IN (THURSDAY, FRIDAY, SATURDAY, SUNDAY) THEN
			t_holiday.reference := 'Christmas Holiday';
			t_holiday.observation_shifted := TRUE;
			t_holiday.description := 'Рождество Христово';
			CASE DATE_PART('dow', t_datestamp)
			WHEN THURSDAY THEN
				-- Christmas Eve on Thursday -> Monday Holiday
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
			WHEN FRIDAY THEN
				-- Christmas Eve on Friday -> Monday, Tuesday Holiday
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
				RETURN NEXT t_holiday;
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, TUESDAY, 1);
				RETURN NEXT t_holiday;
			WHEN SATURDAY THEN
				-- Christmas Eve on Saturday -> Tuesday, Wednesday Holiday
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, TUESDAY, 1);
				RETURN NEXT t_holiday;
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, WEDNESDAY, 1);
				RETURN NEXT t_holiday;
			WHEN SUNDAY THEN
				-- Christmas Eve on Sunday -> Wednesday Holiday
				t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, WEDNESDAY, 1);
				RETURN NEXT t_holiday;
			END CASE;
			t_holiday.observation_shifted := FALSE;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;