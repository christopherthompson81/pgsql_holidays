------------------------------------------
------------------------------------------
-- Andorra Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Andorra
--
-- Country Code: AD, AND
-- Country Names: { ca: Andorra, es: Andorra, en: Andorra }
-- dayoff: [sunday]
-- langs: [ca, es]
-- Timezones: Europe/Andorra
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.andorra(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- Sub-Regions
	regions TEXT[] := ARRAY['Canillo', 'Encamp', 'La Massana', 'Ordino', 'Sant Julià de Lòria', 'Andorra la Vella'];
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
		t_holiday.description := 'Any nou';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Dia dels Reis Mags';
		RETURN NEXT t_holiday;

		-- Constitution Day
		t_holiday.reference := 'Constitution Day';
		t_holiday.datestamp := make_date(t_year, MARCH, 14);
		t_holiday.description := 'Dia de la Constitució';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Festa de la feina';
		RETURN NEXT t_holiday;

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Assumpci';
		RETURN NEXT t_holiday;

		-- Our Lady of Meritxell / Nuestra Sra. De Meritxell
		t_holiday.reference := 'Our Lady of Meritxell';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 8);
		t_holiday.description := 'Mare de Déu de Meritxell';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
		t_holiday.description := 'Tots Sants';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'La immaculada concepció';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		-- type: bank
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Nit de Nadal';
		t_holiday.authority := 'bank';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Nadal';
		RETURN NEXT t_holiday;

		-- Boxing Day / San Esteban
		t_holiday.reference := 'Boxing Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Sant Esteve';
		RETURN NEXT t_holiday;

		-- Easter Related days
		t_datestamp := holidays.easter(t_year);

		-- Carnival
		t_holiday.reference := 'Carnival';
		t_holiday.datestamp := t_datestamp - '47 Days'::INTERVAL;
		t_holiday.description := 'Carnaval';
		RETURN NEXT t_holiday;
		
		-- Maundy Thursday
		-- type: bank
		-- Shortened work day - 14:00
		t_holiday.reference := 'Maundy Thursday';
		t_holiday.datestamp := t_datestamp - '3 Days'::INTERVAL;
		t_holiday.description := 'Dijous Sant';
		t_holiday.day_off := FALSE;
		t_holiday.authority := 'shortened_work_day';
		t_holiday.start_time := '14:00:00'::TIME;
		RETURN NEXT t_holiday;
		t_holiday.day_off := TRUE;
		t_holiday.authority := 'national';
		t_holiday.start_time := '00:00:00'::TIME;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Divendres Sant';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Pasqua';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Dilluns de Pasqua';
		RETURN NEXT t_holiday;

		-- Pentecost
		t_holiday.reference := 'Pentecost';
		t_holiday.datestamp := t_datestamp + '49 Days'::INTERVAL;
		t_holiday.description := 'Pentecosta';
		RETURN NEXT t_holiday;

		-- Whit Monday
		t_holiday.reference := 'Whit Monday';
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Dilluns de Pentecosta';
		RETURN NEXT t_holiday;

		-- Andorra La Vella Festival
		IF p_province = 'Andorra la Vella' THEN
			t_holiday.reference := 'Andorra La Vella Festival';
			t_holiday.authority := 'provincial';
			t_datestamp = holidays.find_nth_weekday_date(make_date(t_year, AUGUST, 1), SATURDAY, 1);
			t_holiday.datestamp := t_datestamp; 
			t_holiday.description := 'Andorra La Vella Festival (1)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Andorra La Vella Festival (2)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := t_datestamp + '2 Days'::INTERVAL;
			t_holiday.description := 'Andorra La Vella Festival (3)';
			RETURN NEXT t_holiday;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;