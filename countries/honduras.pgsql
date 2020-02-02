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
		if date(year, JANUARY, 1):
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Año Nuevo [New Year''s Day]';
			RETURN NEXT t_holiday;

		-- The Three Wise Men Day
		if date(year, JANUARY, 6):
			name = 'Día de los Reyes Magos [The Three Wise Men Day] (Observed)'
			self[date(year, JANUARY, 6)] = name

		-- The Three Wise Men Day
		if date(year, FEB, 3):
			name = 'Día de la virgen de Suyapa [Our Lady of Suyapa] (Observed)'
			self[date(year, FEB, 3)] = name

		-- The Father's Day
		if date(year, MAR, 19):
			name = 'Día del Padre [Father''s Day] (Observed)'
			self[date(year, MAR, 19)] = name

		-- Maundy Thursday
		self[easter(year) + rd(weekday=TH(-1))] = 'Jueves Santo [Maundy Thursday]'

		-- Good Friday
		self[easter(year) + rd(weekday=FR(-1))] = 'Viernes Santo [Good Friday]'

		-- Holy Saturday
		self[easter(year) + rd(weekday=SA(-1))] = 'Sábado de Gloria [Holy Saturday]'

		-- Easter Sunday
		self[easter(year) + rd(weekday=SU(-1))] = 'Domingo de Resurrección [Easter Sunday]'

		-- America Day
		if date(year, APR, 14):
			t_holiday.datestamp := make_date(t_year, APR, 14);
			t_holiday.description := 'Día de las Américas [America Day]';
			RETURN NEXT t_holiday;

		-- Labor Day
		if date(year, MAY, 1):
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Día del Trabajo [Labour Day]';
			RETURN NEXT t_holiday;

		-- Mother's Day
		may_first = date(int(year), 5, 1)
		weekday_seq = may_first.weekday()
		mom_day = (14 - weekday_seq)
		if date(year, MAY, mom_day):
			str_day = 'Día de la madre [Mother''s Day] (Observed)'
			self[date(year, MAY, mom_day)] = str_day

		-- Children's Day
		if date(year, SEP, 10):
			name = 'Día del niño [Children day] (Observed)'
			self[date(year, SEP, 10)] = name

		-- Independence Day
		if date(year, SEP, 15):
			name = 'Día de la Independencia [Independence Day]'
			self[date(year, SEP, 15)] = name

		-- Teacher's Day
		if date(year, SEP, 17):
			name = 'Día del Maestro [Teacher''s day] (Observed)'
			self[date(year, SEP, 17)] = name

		-- October Holidays are joined on 3 days starting at October 3 to 6.
		-- Some companies work medium day and take the rest on saturday.
		-- This holiday is variant and some companies work normally.
		-- If start day is weekend is ignored.
		-- The main objective of this is to increase the tourism.

		-- https://www.hondurastips.hn/2017/09/20/de-donde-nace-el-feriado-morazanico/

		if year <= 2014:
			-- Morazan's Day
			if date(year, OCT, 3):
				t_holiday.datestamp := make_date(t_year, OCT, 3);
				t_holiday.description := 'Día de Morazán [Morazan''s Day]';
				RETURN NEXT t_holiday;

			-- Columbus Day
			if date(year, OCT, 12):
				t_holiday.datestamp := make_date(t_year, OCT, 12);
				t_holiday.description := 'Día de la Raza [Columbus Day]';
				RETURN NEXT t_holiday;

			-- Amy Day
			if date(year, OCT, 21):
				str_day = 'Día de las Fuerzas Armadas [Army Day]'
				self[date(year, OCT, 21)] = str_day
		else:
			-- Morazan Weekend
			if date(year, OCT, 3):
				name = 'Semana Morazánica [Morazan Weekend]'
				self[date(year, OCT, 3)] = name

			-- Morazan Weekend
			if date(year, OCT, 4):
				name = 'Semana Morazánica [Morazan Weekend]'
				self[date(year, OCT, 4)] = name

			-- Morazan Weekend
			if date(year, OCT, 5):
				name = 'Semana Morazánica [Morazan Weekend]'
				self[date(year, OCT, 5)] = name

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;