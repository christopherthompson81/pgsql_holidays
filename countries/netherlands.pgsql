------------------------------------------
------------------------------------------
-- <country> Holidays
-- http://www.iamsterdam.com/en/plan-your-trip/practical-info/public-holidays
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

		-- New years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Nieuwjaarsdag';
		RETURN NEXT t_holiday;

		easter_date = easter(year)

		-- Easter
		self[easter_date] = 'Eerste paasdag'

		-- Second easter day
		self[easter_date + '1 Days'::INTERVAL] = 'Tweede paasdag'

		-- Ascension day
		self[easter_date + '39 Days'::INTERVAL] = 'Hemelvaart'

		-- Pentecost
		self[easter_date + '49 Days'::INTERVAL] = 'Eerste Pinksterdag'

		-- Pentecost monday
		self[easter_date + '50 Days'::INTERVAL] = 'Tweede Pinksterdag'

		-- First christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Eerste Kerstdag';
		RETURN NEXT t_holiday;

		-- Second christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Tweede Kerstdag';
		RETURN NEXT t_holiday;

		-- Liberation day
		IF t_year >= 1945 AND t_year % 5 = 0 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 5);
			t_holiday.description := 'Bevrijdingsdag';
			RETURN NEXT t_holiday;
		END IF;

		-- Kingsday
		IF t_year >= 2014 THEN
			kings_day = date(year, APRIL, 27)
			IF kings_day.weekday() == SUN THEN
				kings_day = kings_day - '1 Days'::INTERVAL
			END IF;

			self[kings_day] = 'Koningsdag'
		END IF;

		-- Queen's day
		IF 1891 <= year <= 2013 THEN
			queens_day = date(year, APRIL, 30)
			IF t_year <= 1948 THEN
				queens_day = date(year, AUGUST, 31)
			END IF;

			IF queens_day.weekday() == SUN THEN
				IF t_year < 1980 THEN
					queens_day = queens_day + '1 Days'::INTERVAL
				ELSE
					queens_day = queens_day - '1 Days'::INTERVAL
				END IF;
			END IF;
			self[queens_day] = 'Koninginnedag'
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;