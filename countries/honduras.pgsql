------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://www.timeanddate.com/holidays/honduras/
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

		-- New Year's Day
		IF date(year, JANUARY, 1) THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Año Nuevo [New Year''s Day]';
			RETURN NEXT t_holiday;

		-- The Three Wise Men Day
		IF date(year, JANUARY, 6) THEN
			t_holiday.description := 'Día de los Reyes Magos [The Three Wise Men Day] (Observed)';
			t_holiday.datestamp := make_date(t_year, JANUARY, 6);
			RETURN NEXT t_holiday;

		-- The Three Wise Men Day
		IF date(year, FEB, 3) THEN
			t_holiday.description := 'Día de la virgen de Suyapa [Our Lady of Suyapa] (Observed)';
			t_holiday.datestamp := make_date(t_year, FEB, 3);
			RETURN NEXT t_holiday;

		-- The Father's Day
		IF date(year, MAR, 19) THEN
			t_holiday.description := 'Día del Padre [Father''s Day] (Observed)';
			t_holiday.datestamp := make_date(t_year, MAR, 19);
			RETURN NEXT t_holiday;

		-- Maundy Thursday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), TH, -1);
		t_holiday.description := 'Jueves Santo [Maundy Thursday]';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FR, -1);
		t_holiday.description := 'Viernes Santo [Good Friday]';
		RETURN NEXT t_holiday;

		-- Holy Saturday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), SA, -1);
		t_holiday.description := 'Sábado de Gloria [Holy Saturday]';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), SU, -1);
		t_holiday.description := 'Domingo de Resurrección [Easter Sunday]';
		RETURN NEXT t_holiday;

		-- America Day
		IF date(year, APR, 14) THEN
			t_holiday.datestamp := make_date(t_year, APR, 14);
			t_holiday.description := 'Día de las Américas [America Day]';
			RETURN NEXT t_holiday;

		-- Labor Day
		IF date(year, MAY, 1) THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Día del Trabajo [Labour Day]';
			RETURN NEXT t_holiday;

		-- Mother's Day
		may_first = date(int(year), 5, 1)
		weekday_seq = may_first.weekday()
		mom_day = (14 - weekday_seq)
		IF date(year, MAY, mom_day) THEN
			str_day = 'Día de la madre [Mother''s Day] (Observed)'
			self[date(year, MAY, mom_day)] = str_day

		-- Children's Day
		IF date(year, SEPTEMBER, 10) THEN
			t_holiday.description := 'Día del niño [Children day] (Observed)';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 10);
			RETURN NEXT t_holiday;

		-- Independence Day
		IF date(year, SEPTEMBER, 15) THEN
			t_holiday.description := 'Día de la Independencia [Independence Day]';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
			RETURN NEXT t_holiday;

		-- Teacher's Day
		IF date(year, SEPTEMBER, 17) THEN
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
			IF date(year, OCTOBER, 3) THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
				t_holiday.description := 'Día de Morazán [Morazan''s Day]';
				RETURN NEXT t_holiday;

			-- Columbus Day
			IF date(year, OCTOBER, 12) THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
				t_holiday.description := 'Día de la Raza [Columbus Day]';
				RETURN NEXT t_holiday;

			-- Amy Day
			IF date(year, OCTOBER, 21) THEN
				str_day = 'Día de las Fuerzas Armadas [Army Day]'
				self[date(year, OCTOBER, 21)] = str_day
		ELSE
			-- Morazan Weekend
			IF date(year, OCTOBER, 3) THEN
				t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
				RETURN NEXT t_holiday;

			-- Morazan Weekend
			IF date(year, OCTOBER, 4) THEN
				t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
				RETURN NEXT t_holiday;

			-- Morazan Weekend
			IF date(year, OCTOBER, 5) THEN
				t_holiday.description := 'Semana Morazánica [Morazan Weekend]';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
				RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;