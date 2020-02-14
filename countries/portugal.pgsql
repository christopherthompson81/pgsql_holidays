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
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Ano Novo';
		RETURN NEXT t_holiday;

		-- Easter related holidays
		t_datestamp := holidays.easter(t_year);

		-- carnival is no longer a holiday, but some companies let workers off.
		-- @todo recollect the years in which it was a public holiday
		-- self[e - rd(days=47)] = 'Carnaval'

		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Sexta-feira Santa';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Páscoa';
		RETURN NEXT t_holiday;

		-- Revoked holidays in 2013–2015
		IF t_year < 2013 OR t_year > 2015 THEN
			t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
			t_holiday.description := 'Corpo de Deus';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Implantação da República';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Dia de Todos os Santos';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 1);
			t_holiday.description := 'Restauração da Independência';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, APRIL, 25);
		t_holiday.description := 'Dia da Liberdade';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia do Trabalhador';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JUNE, 10);
		t_holiday.description := 'Dia de Portugal';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Assunção de Nossa Senhora';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Imaculada Conceição';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Christmas Day';
		RETURN NEXT t_holiday;

		-- Adds extended days that most people have as a bonus from their companies:
		-- - Carnival
		-- - the day before and after xmas
		-- - the day before the new year
		-- - Lisbon's city holiday
		-- Porting Note: Exclude from select if you desire these to be omitted
		t_holiday.datestamp := t_datestamp - '47 Days'::INTERVAL;
		t_holiday.description := 'Carnaval';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Vespera de Natal';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := '26 de Dezembro';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
		t_holiday.description := 'Vespera de Ano novo';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JUNE, 13);
		t_holiday.description := 'Dia de Santo António';
		RETURN NEXT t_holiday;

		-- TODO add bridging days
		-- - get Holidays that occur on Tuesday  and add Monday (-1 day)
		-- - get Holidays that occur on Thursday and add Friday (+1 day)

	END LOOP;
END;

$$ LANGUAGE plpgsql;