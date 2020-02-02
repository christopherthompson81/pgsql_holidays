------------------------------------------
------------------------------------------
-- <country> Holidays
-- http://ojd.org.do/Normativas/LABORAL/Leyes/Ley%20No.%20%20139-97.pdf
	-- https://es.wikipedia.org/wiki/Rep%C3%BAblica_Dominicana--D%C3%ADas_festivos_nacionales

-- possible idea for temporary function
-- create or replace function pg_temp.testfunc() returns text as $$ select 'hello'::text $$ language sql;
-- Consider using a prepared statement

@staticmethod
	def __change_day_by_law(holiday, latest_days=(3, 4)):
		-- Law No. 139-97 - Holidays Dominican Republic - Jun 27, 1997
		if holiday >= date(1997, 6, 27):
			if holiday.weekday() in [1, 2]:
				holiday -= rd(weekday=MO(-1))
			elif holiday.weekday() in latest_days:
				holiday += rd(weekday=MO(1))
		return holiday
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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- Epiphany
		epiphany_day = self.__change_day_by_law(date(year, JANUARY, 6))
		self[epiphany_day] = 'Día de los Santos Reyes [Epiphany]'

		-- Lady of Altagracia
		t_holiday.datestamp := make_date(t_year, JANUARY, 21);
		t_holiday.description := 'Día de la Altagracia [Lady of Altagracia]';
		RETURN NEXT t_holiday;

		-- Juan Pablo Duarte Day
		duarte_day = self.__change_day_by_law(date(year, JANUARY, 26))
		self[duarte_day] = 'Día de Duarte [Juan Pablo Duarte Day]'

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, FEB, 27);
		t_holiday.description := 'Día de Independencia [Independence Day]';
		RETURN NEXT t_holiday;

		-- Good Friday
		self[easter(year) + rd(weekday=FR(-1))] = 'Viernes Santo [Good Friday]'

		-- Labor Day
		labor_day = self.__change_day_by_law(date(year, MAY, 1), (3, 4, 6))
		self[labor_day] = 'Día del Trabajo [Labor Day]'

		-- Feast of Corpus Christi
		t_holiday.datestamp := make_date(t_year, JUN, 11);
		t_holiday.description := 'Corpus Christi [Feast of Corpus Christi]';
		RETURN NEXT t_holiday;

		-- Restoration Day
		-- Judgment No. 14 of Feb 20, 2008 of the Supreme Court of Justice
		restoration_day = date(year, AUG, 16) if ((year - 2000) % 4 == 0) and year < 2008 else self.__change_day_by_law(date(year, AUG, 16))
		self[restoration_day] = 'Día de la Restauración [Restoration Day]'

		-- Our Lady of Mercedes Day
		t_holiday.datestamp := make_date(t_year, SEP, 24);
		t_holiday.description := 'Día de las Mercedes [Our Lady of Mercedes Day]';
		RETURN NEXT t_holiday;

		-- Constitution Day
		constitution_day = self.__change_day_by_law(date(year, NOV, 6))
		self[constitution_day] = 'Día de la Constitución [Constitution Day]'

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Día de Navidad [Christmas Day]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;