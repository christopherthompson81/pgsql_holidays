------------------------------------------
------------------------------------------
-- <country> Holidays
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
		t_holiday.description := 'Año Nuevo [New Year''s Day]';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		RETURN NEXT t_holiday;
		t_datestamp := make_date(t_year, JANUARY, 1);
		IF DATE_PART('dow', t_datestamp) == SUN:
			t_holiday.datestamp := make_date(t_year, JANUARY, 1) + '+1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
		ELSIF date(year, JANUARY, 1).weekday() == SAT THEN
			-- Add Dec 31st from the previous year without triggering
			-- the entire year to be added
			expand = self.expand
			self.expand = False
			t_holiday.datestamp := make_date(t_year, JANUARY, 1) + '-1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
			self.expand = expand
		END IF;
		-- The next year's observed New Year's Day can be in this year
		-- when it falls on a Friday (Jan 1st is a Saturday)
		t_datestamp := make_date(t_year, DECEMBER, 31);
		IF DATE_PART('dow', t_datestamp) == FRI:
			t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
			RETURN NEXT t_holiday; + ' (Observed)'
		END IF;

		-- Constitution Day
		t_holiday.description := 'Día de la Constitución [Constitution Day]';
		IF 2006 >= year >= 1917 THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 5);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, FEBRUARY, 1), MO, +1);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Benito Juárez's birthday
		t_holiday.description := 'Natalicio de Benito Juárez [Benito Juárez''s birthday]';
		IF 2006 >= year >= 1917 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MARCH, 1), MO, +3);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Labor Day
		IF t_year >= 1923 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Día del Trabajo [Labour Day]';
			RETURN NEXT t_holiday;
			t_datestamp := make_date(t_year, MAY, 1);
			IF DATE_PART('dow', t_datestamp) == SAT:
				t_holiday.datestamp := make_date(t_year, MAY, 1) + '-1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			ELSIF date(year, MAY, 1).weekday() == SUN THEN
				t_holiday.datestamp := make_date(t_year, MAY, 1) + '+1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			END IF;
		END IF;

		-- Independence Day
		t_holiday.description := 'Día de la Independencia [Independence Day]';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 16);
		RETURN NEXT t_holiday;
		t_datestamp := make_date(t_year, SEPTEMBER, 16);
		IF DATE_PART('dow', t_datestamp) == SAT:
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 16) + '-1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
		ELSIF date(year, SEPTEMBER, 16).weekday() == SUN THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 16) + '+1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
		END IF;

		-- Revolution Day
		t_holiday.description := 'Día de la Revolución [Revolution Day]';
		IF 2006 >= year >= 1917 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2007 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, NOVEMBER, 1), MO, +3);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		END IF;

		-- Change of Federal Government
		-- Every six years--next observance 2018
		t_holiday.description := 'Transmisión del Poder Ejecutivo Federal';
		name += ' [Change of Federal Government]'
		IF (2018 - year) % 6 == 0 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 1);
			RETURN NEXT t_holiday;
			t_datestamp := make_date(t_year, DECEMBER, 1);
			IF DATE_PART('dow', t_datestamp) == SAT:
				t_holiday.datestamp := make_date(t_year, DECEMBER, 1) + '-1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			ELSIF date(year, DECEMBER, 1).weekday() == SUN THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 1) + '+1 Days'::INTERVAL;
				RETURN NEXT t_holiday; + ' (Observed)'
			END IF;
		END IF;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;
		t_datestamp := make_date(t_year, DECEMBER, 25);
		IF DATE_PART('dow', t_datestamp) == SAT:
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25) + '-1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
		ELSIF date(year, DECEMBER, 25).weekday() == SUN THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25) + '+1 Days'::INTERVAL;
			RETURN NEXT t_holiday; + ' (Observed)'
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;