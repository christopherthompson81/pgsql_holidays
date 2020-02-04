------------------------------------------
------------------------------------------
-- Slovakia Holidays
--
-- https://sk.wikipedia.org/wiki/Sviatok
-- https://www.slov-lex.sk/pravne-predpisy/SK/ZZ/1993/241/20181011.html
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.slovakia(p_start_year INTEGER, p_end_year INTEGER)
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

		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Deň vzniku Slovenskej republiky';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Zjavenie Pána (Traja králi a vianočnýsviatok pravoslávnych kresťanov)';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);
		
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Veľký piatok';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Veľkonočný pondelok';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Sviatok práce';
		RETURN NEXT t_holiday;

		IF t_year >= 1997 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 8);
			t_holiday.description := 'Deň víťazstva nad fašizmom';
			RETURN NEXT t_holiday;
		END IF;
		
		t_holiday.datestamp := make_date(t_year, JULY, 5);
		t_holiday.description := 'Sviatok svätého Cyrila a svätého Metoda';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, AUGUST, 29);
		t_holiday.description := 'Výročie Slovenského národného povstania';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 1);
		t_holiday.description := 'Deň Ústavy Slovenskej republiky';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 15);
		t_holiday.description := 'Sedembolestná Panna Mária';
		RETURN NEXT t_holiday;
		
		IF t_year = 2018 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 30);
			t_holiday.description := '100. výročie prijatia Deklarácie slovenského národa';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Sviatok Všetkých svätých';
		RETURN NEXT t_holiday;

		IF t_year >= 2001 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 17);
			t_holiday.description := 'Deň boja za slobodu a demokraciu';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
		t_holiday.description := 'Štedrý deň';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Prvý sviatok vianočný';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Druhý sviatok vianočný';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;