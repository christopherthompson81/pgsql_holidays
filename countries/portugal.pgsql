------------------------------------------
------------------------------------------
-- Portugal Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Portugal
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.portugal(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'Ano Novo';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- Carnival
		-- Shrove Tuesday
		-- Optional
		t_holiday.reference := 'Shrove Tuesday';
		t_holiday.datestamp := t_datestamp - '47 Days'::INTERVAL;
		t_holiday.description := 'Carnaval';
		t_holiday.authority := 'optional';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Sexta-feira Santa';
		RETURN NEXT t_holiday;

		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Páscoa';
		RETURN NEXT t_holiday;

		-- Corpus Christi
		-- Revoked holiday in 2013–2015
		t_holiday.reference := 'Corpus Christi';
		IF t_year < 2013 OR t_year > 2015 THEN
			t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
			t_holiday.description := 'Corpo de Deus';
			RETURN NEXT t_holiday;
		END IF;

		-- Liberty Day
		t_holiday.reference := 'Liberty Day';
		t_holiday.datestamp := make_date(t_year, APRIL, 25);
		t_holiday.description := 'Dia da Liberdade';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia do Trabalhador';
		RETURN NEXT t_holiday;

		-- Portugal Day
		t_holiday.reference := 'Portugal Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 10);
		t_holiday.description := 'Dia de Portugal';
		RETURN NEXT t_holiday;

		-- St. Anthony's Day
		-- Municipal Holiday
		-- Lisbon, Vila Real
		t_holiday.reference := 'St. Anthony''s Day';
		t_holiday.datestamp := make_date(t_year, JUNE, 13);
		t_holiday.description := 'Dia de Santo António';
		t_holiday.authority := 'municipal';
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Assunção de Nossa Senhora';
		RETURN NEXT t_holiday;

		-- Republic Implantation
		-- Revoked holiday in 2013–2015
		t_holiday.reference := 'Republic Implantation';
		IF t_year < 2013 OR t_year > 2015 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Implantação da República';
			RETURN NEXT t_holiday;
		END IF;

		-- All Saints' Day
		-- Revoked holiday in 2013–2015
		t_holiday.reference := 'All Saints'' Day';
		IF t_year < 2013 OR t_year > 2015 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Dia de Todos os Santos';
			RETURN NEXT t_holiday;
		END IF;

		-- Restoration of Independence
		-- Revoked holiday in 2013–2015
		t_holiday.reference := 'Restoration of Independence';
		IF t_year < 2013 OR t_year > 2015 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 1);
			t_holiday.description := 'Restauração da Independência';
			RETURN NEXT t_holiday;
		END IF;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Imaculada Conceição';
		RETURN NEXT t_holiday;

		-- Christmas Eve
		-- Observance
		t_holiday.reference := 'Christmas Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Vespera de Natal';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		
		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		RETURN NEXT t_holiday;
		
		-- Second Day of Christmas
		-- Optional (?)
		-- [Madeira] - en: 1st Octave; pt: Primeira Oitava
		t_holiday.reference := 'Second Day of Christmas';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := '26 de Dezembro';
		t_holiday.authority := 'optional';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- New Year's Eve
		-- Observance
		t_holiday.reference := 'New Year''s Eve';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Vespera de Ano novo';
		t_holiday.authority := 'observance';
		t_holiday.day_off := FALSE;
		RETURN NEXT t_holiday;
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;

		-- TODO add bridging days
		-- - get Holidays that occur on Tuesday  and add Monday (-1 day)
		-- - get Holidays that occur on Thursday and add Friday (+1 day)
		-- Porting Note: I can't find a source that confirms this is law

	END LOOP;
END;

$$ LANGUAGE plpgsql;