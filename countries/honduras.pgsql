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
		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- The Three Wise Men Day
		t_holiday.description := 'Día de los Reyes Magos [The Three Wise Men Day] (Observed)';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		RETURN NEXT t_holiday;

		-- The Three Wise Men Day
		t_holiday.description := 'Día de la virgen de Suyapa [Our Lady of Suyapa] (Observed)';
		t_holiday.datestamp := make_date(t_year, FEBRUARY, 3);
		RETURN NEXT t_holiday;

		-- The Father's Day
		t_holiday.description := 'Día del Padre [Father''s Day] (Observed)';
		t_holiday.datestamp := make_date(t_year, MARCH, 19);
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Maundy Thursday
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Jueves Santo [Maundy Thursday]';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Viernes Santo [Good Friday]';
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SATURDAY, -1);
		t_holiday.description := 'Sábado de Gloria [Holy Saturday]';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, SUNDAY, -1);
		t_holiday.description := 'Domingo de Resurrección [Easter Sunday]';
		RETURN NEXT t_holiday;

		-- America Day
		t_holiday.datestamp := make_date(t_year, APRIL, 14);
		t_holiday.description := 'Día de las Américas [America Day]';
		RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		RETURN NEXT t_holiday;

		-- Mother's Day
		-- (porting note - Appears to be two Sundays forward from May 1st)
		t_holiday.datestamp := holidays.find_nth_weekday_date(make_date(t_year, MAY, 1), SUNDAY, 2);
		t_holiday.description := 'Día de la madre [Mother''s Day] (Observed)'
		RETURN NEXT t_holiday;

		-- Children's Day
		t_holiday.description := 'Día del niño [Children day] (Observed)';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 10);
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
		RETURN NEXT t_holiday;

		-- Teacher's Day
		t_holiday.description := 'Día del Maestro [Teacher''s day] (Observed)';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 17);
		RETURN NEXT t_holiday;

		-- October Holidays are joined on 3 days starting at October 3 to 6.
		-- Some companies work medium day and take the rest on saturday.
		-- This holiday is variant and some companies work normally.
		-- If start day is weekend is ignored.
		-- The main objective of this is to increase the tourism.

		-- https://www.hondurastips.hn/2017/09/20/de-donde-nace-el-feriado-morazanico/

		IF t_year <= 2014 THEN
			-- Morazan's Day
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			t_holiday.description := 'Día de Morazán [Morazan''s Day]';
			RETURN NEXT t_holiday;

			-- Columbus Day
			t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
			t_holiday.description := 'Día de la Raza [Columbus Day]';
			RETURN NEXT t_holiday;

			-- Amy Day
			t_holiday.datestamp := make_date(t_year, OCTOBER, 21);
			t_holiday.description := 'Día de las Fuerzas Armadas [Army Day]';
			RETURN NEXT t_holiday;
		ELSE
			-- Morazan Weekend
			t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			RETURN NEXT t_holiday;

			-- Morazan Weekend
			t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
			RETURN NEXT t_holiday;

			-- Morazan Weekend
			t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;