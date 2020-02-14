------------------------------------------
------------------------------------------
-- Czechia Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_the_Czech_Republic
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.czechia(p_start_year INTEGER, p_end_year INTEGER)
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
		IF t_year >= 2000 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Den obnovy samostatného českého státu';
			RETURN NEXT t_holiday;
		ELSE
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Nový rok';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		IF t_year <= 1951 OR t_year >= 2016 THEN
			t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
			t_holiday.description := 'Velký pátek';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Velikonoční pondělí';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		IF t_year >= 1951 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Svátek práce';
			RETURN NEXT t_holiday;
		END IF;

		-- Day of victory
		-- Victory in Europe Day
		t_holiday.reference := 'Victory in Europe Day';
		IF t_year >= 1992 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 8);
			t_holiday.description := 'Den vítězství';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 1947 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			t_holiday.description := 'Den vítězství nad hitlerovským fašismem';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 1951 THEN
			-- Saints Cyril and Methodius
			t_holiday.reference := 'Saints Cyril and Methodius';
			t_holiday.datestamp := make_date(t_year, JULY, 5);
			t_holiday.description := 'Den slovanských věrozvěstů Cyrila a Metoděje';
			RETURN NEXT t_holiday;
			-- Jan Hus Day
			t_holiday.reference := 'Jan Hus Day';
			t_holiday.datestamp := make_date(t_year, JULY, 6);
			t_holiday.description := 'Den upálení mistra Jana Husa';
			RETURN NEXT t_holiday;
		END IF;

		-- St. Wenceslas Day (?)
		-- Czech Statehood Day
		t_holiday.reference := 'Statehood Day';
		IF t_year >= 2000 THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 28);
			t_holiday.description := 'Den české státnosti';
			RETURN NEXT t_holiday;
		END IF;

		-- The Day of Establishment of the Independent Czechoslovak State
		-- Independance Day
		t_holiday.reference := 'Independance Day';
		IF t_year >= 1951 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
			t_holiday.description := 'Den vzniku samostatného československého státu';
			RETURN NEXT t_holiday;
		END IF;

		-- Struggle for Freedom and Democracy Day
		t_holiday.reference := 'Struggle for Freedom and Democracy Day';
		IF t_year >= 1990 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 17);
			t_holiday.description := 'Den boje za svobodu a demokracii';
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Eve
		t_holiday.reference := 'Christmas Eve';
		IF t_year >= 1990 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
			t_holiday.description := 'Štědrý den';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 1951 THEN
			-- Christmas Day
			t_holiday.reference := 'Christmas Day';
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			t_holiday.description := '1. svátek vánoční';
			RETURN NEXT t_holiday;
			-- Second Day of Christmas
			t_holiday.reference := 'Second Day of Christmas';
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.description := '2. svátek vánoční';
			RETURN NEXT t_holiday;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;