------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Luxembourg
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

		-- Public holidays
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Neijoerschdag';
		RETURN NEXT t_holiday;
		self[easter(year) + rd(weekday=MO)] = 'Ouschterméindeg'
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dag vun der Aarbecht';
		RETURN NEXT t_holiday;
		IF t_year >= 2019 THEN
			-- Europe Day: not in legislation yet, but introduced starting 2019
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			t_holiday.description := 'Europadag';
			RETURN NEXT t_holiday;
		END IF;
		self[easter(year) + '39 Days'::INTERVAL] = 'Christi Himmelfaart'
		self[easter(year) + '50 Days'::INTERVAL] = 'Péngschtméindeg'
		t_holiday.datestamp := make_date(t_year, JUNE, 23);
		t_holiday.description := 'Nationalfeierdag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Léiffrawëschdag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Allerhellgen';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Chrëschtdag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Stiefesdag';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;