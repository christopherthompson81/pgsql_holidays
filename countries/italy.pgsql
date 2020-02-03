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
	-- Provinces
	PROVINCES = ['AN', 'AO', 'BA', 'BL', 'BO',
				 'BZ', 'BS', 'CB', 'CT', 'Cesena',
				 'CH', 'CS', 'KR', 'EN', 'FE', 'FI',
				 'FC', 'Forli', 'FR', 'GE', 'GO', 'IS',
				 'SP', 'LT', 'MN', 'MS', 'MI',
				 'MO', 'MB', 'NA', 'PD', 'PA',
				 'PR', 'PG', 'PE', 'PC', 'PI',
				 'PD', 'PT', 'RA', 'RE',
				 'RI', 'RN', 'RM', 'RO', 'SA',
				 'SR', 'TE', 'TO', 'TS', 'Pesaro', 'PU',
				 'Urbino', 'VE', 'VC', 'VI']
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
		t_holiday.description := 'Capodanno';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Epifania del Signore';
		RETURN NEXT t_holiday;
		self[easter(year)] = 'Pasqua di Resurrezione'
		self[easter(year) + rd(weekday=MO)] = 'Lunedì dell''Angelo'
		IF t_year >= 1946 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'Festa della Liberazione';
			RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Festa dei Lavoratori';
		RETURN NEXT t_holiday;
		IF t_year >= 1948 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 2);
			t_holiday.description := 'Festa della Repubblica';
			RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Assunzione della Vergine';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Tutti i Santi';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Immacolata Concezione';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Natale';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Santo Stefano';
		RETURN NEXT t_holiday;

		-- Provinces holidays
		IF self.prov THEN
			IF self.prov == 'AN' THEN
				t_holiday.datestamp := make_date(t_year, MAY, 4);
				t_holiday.description := 'San Ciriaco';
				RETURN NEXT t_holiday;
			elIF self.prov == 'AO' THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 7);
				t_holiday.description := 'San Grato';
				RETURN NEXT t_holiday;
			elIF self.prov in ('BA') THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
				t_holiday.description := 'San Nicola';
				RETURN NEXT t_holiday;
			elIF self.prov == 'BL' THEN
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
				t_holiday.description := 'San Martino';
				RETURN NEXT t_holiday;
			elIF self.prov in ('BO') THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
				t_holiday.description := 'San Petronio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'BZ' THEN
				t_holiday.datestamp := make_date(t_year, AUGUST, 15);
				t_holiday.description := 'Maria Santissima Assunta';
				RETURN NEXT t_holiday;
			elIF self.prov == 'BS' THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 15);
				t_holiday.description := 'Santi Faustino e Giovita';
				RETURN NEXT t_holiday;
			elIF self.prov == 'CB' THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'CT' THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 5);
				t_holiday.description := 'Sant''Agata';
				RETURN NEXT t_holiday;
			elIF self.prov in ('FC', 'Cesena') THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			IF self.prov in ('FC', 'Forlì') THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 4);
				t_holiday.description := 'Madonna del Fuoco';
				RETURN NEXT t_holiday;
			elIF self.prov == 'CH' THEN
				t_holiday.datestamp := make_date(t_year, MAY, 11);
				t_holiday.description := 'San Giustino di Chieti';
				RETURN NEXT t_holiday;
			elIF self.prov == 'CS' THEN
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 12);
				t_holiday.description := 'Madonna del Pilerio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'KR' THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 9);
				t_holiday.description := 'San Dionigi';
				RETURN NEXT t_holiday;
			elIF self.prov == 'EN' THEN
				t_holiday.datestamp := make_date(t_year, JULY, 2);
				t_holiday.description := 'Madonna della Visitazione';
				RETURN NEXT t_holiday;
			elIF self.prov == 'FE' THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'FI' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elIF self.prov == 'FR' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 20);
				t_holiday.description := 'San Silverio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'GE' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elIF self.prov == 'GO' THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 16);
				t_holiday.description := 'Santi Ilario e Taziano';
				RETURN NEXT t_holiday;
			elIF self.prov == 'IS' THEN
				t_holiday.datestamp := make_date(t_year, MAY, 19);
				t_holiday.description := 'San Pietro Celestino';
				RETURN NEXT t_holiday;
			elIF self.prov == 'SP' THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 19);
				t_holiday.description := 'San Giuseppe';
				RETURN NEXT t_holiday;
			elIF self.prov == 'LT' THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 25);
				t_holiday.description := 'San Marco evangelista';
				RETURN NEXT t_holiday;
			elIF self.prov == 'ME' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 3);
				t_holiday.description := 'Madonna della Lettera';
				RETURN NEXT t_holiday;
			elIF self.prov == 'MI' THEN
				t_holiday.datestamp := make_date(t_year, DECEMBER, 7);
				t_holiday.description := 'Sant''Ambrogio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'MN' THEN
				t_holiday.datestamp := make_date(t_year, MARCH, 18);
				t_holiday.description := 'Sant''Anselmo da Baggio';
				RETURN NEXT t_holiday;
			elIF self.prov == 'MS' THEN
				t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
				t_holiday.description := 'San Francesco d''Assisi';
				RETURN NEXT t_holiday;
			elIF self.prov == 'MO' THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 31);
				t_holiday.description := 'San Geminiano';
				RETURN NEXT t_holiday;
			elIF self.prov == 'MB' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elIF self.prov == 'NA' THEN
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 19);
				t_holiday.description := 'San Gennaro';
				RETURN NEXT t_holiday;
			elIF self.prov == 'PD' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 13);
				t_holiday.description := 'Sant''Antonio di Padova';
				RETURN NEXT t_holiday;
			elIF self.prov == 'PA' THEN
				t_holiday.datestamp := make_date(t_year, JULY, 15);
				t_holiday.description := 'San Giovanni';
				RETURN NEXT t_holiday;
			elIF self.prov == 'PR' THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 13);
				t_holiday.description := 'Sant''Ilario di Poitiers';
				RETURN NEXT t_holiday;
			elIF self.prov == 'PG' THEN
				t_holiday.datestamp := make_date(t_year, JANUARY, 29);
				t_holiday.description := 'Sant''Ercolano e San Lorenzo';
				RETURN NEXT t_holiday;
			elIF self.prov == 'PC' THEN
				t_holiday.datestamp := make_date(t_year, JULY, 4);
				t_holiday.description := 'Sant''Antonino di Piacenza';
				RETURN NEXT t_holiday;
			elIF self.prov == 'RM' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 29);
				t_holiday.description := 'Santi Pietro e Paolo';
				RETURN NEXT t_holiday;
			elIF self.prov == 'TO' THEN
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elIF self.prov == 'TS' THEN
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 3);
				t_holiday.description := 'San Giusto';
				RETURN NEXT t_holiday;
			elIF self.prov == 'VI' THEN
				t_holiday.datestamp := make_date(t_year, APRIL, 25);
				t_holiday.description := 'San Marco';
				RETURN NEXT t_holiday;

		-- TODO: add missing provinces' holidays:
		-- 'Pisa', 'Pordenone', 'Potenza', 'Ravenna',
		-- 'Reggio Emilia', 'Rieti', 'Rimini', 'Rovigo',
		-- 'Salerno', 'Siracusa', 'Teramo', 'Torino', 'Urbino',
		-- 'Venezia'

	END LOOP;
END;

$$ LANGUAGE plpgsql;