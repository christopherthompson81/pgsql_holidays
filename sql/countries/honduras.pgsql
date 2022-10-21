------------------------------------------
------------------------------------------
-- Honduras Holidays
--
-- https://www.timeanddate.com/holidays/honduras/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.honduras(p_start_year INTEGER, p_end_year INTEGER)
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- Epiphany (The Three Wise Men Day)
		t_holiday.reference := 'Epiphany';
		t_holiday.description := 'Día de los Reyes Magos';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Our Lady of Suyapa
		t_holiday.reference := 'Our Lady of Suyapa';
		t_holiday.description := 'Día de la virgen de Suyapa';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 3);
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- The Father's Day
		t_holiday.reference := 'Father''s Day';
		t_holiday.description := 'Día del Padre';
		t_holiday.datestamp := make_date(t_year, MARCH, 19);
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Jueves Santo';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Viernes Santo';
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.reference := 'Holy Saturday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
		t_holiday.description := 'Sábado de Gloria';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SUNDAY, -1);
		t_holiday.description := 'Domingo de Resurrección';
		RETURN NEXT t_holiday;

		-- America Day
		t_holiday.reference := 'America Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 14);
		t_holiday.description := 'Día de las Américas';
		RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.reference := 'Labor Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo';
		RETURN NEXT t_holiday;

		-- Mother's Day
		-- (porting note - Appears to be two Sundays forward from May 1st)
		t_holiday.reference := 'Mother''s Day';
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), SUNDAY, 2);
		t_holiday.description := 'Día de la madre';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Children's Day
		t_holiday.reference := 'Children''s Day';
		t_holiday.description := 'Día del niño';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 10);
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Independence Day
		t_holiday.reference := 'Independence Day';
		t_holiday.description := 'Día de la Independencia';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
		RETURN NEXT t_holiday;

		-- Teacher's Day
		t_holiday.reference := 'Teacher''s day';
		t_holiday.description := 'Día del Maestro';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 17);
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- October Holidays are joined on 3 days starting at October 3 to 6.
		-- Some companies work medium day and take the rest on saturday.
		-- This holiday is variant and some companies work normally.
		-- If start day is weekend is ignored.
		-- The main objective of this is to increase the tourism.

		-- https://www.hondurastips.hn/2017/09/20/de-donde-nace-el-feriado-morazanico/

		IF t_year <= 2014 THEN
			-- Morazan's Day
			t_holiday.reference := 'Morazan''s Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			t_holiday.description := 'Día de Morazán';
			RETURN NEXT t_holiday;

			-- Columbus Day
			t_holiday.reference := 'Columbus Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día de la Raza';
			RETURN NEXT t_holiday;

			-- Amy Day
			t_holiday.reference := 'Army Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 21);
			t_holiday.description := 'Día de las Fuerzas Armadas';
			RETURN NEXT t_holiday;
		ELSE
			-- Morazan Weekend
			t_holiday.reference := 'Morazan Weekend';
			t_holiday.description := 'Semana Morazánica';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;