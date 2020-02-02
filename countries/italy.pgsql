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
		if year >= 1946:
			t_holiday.datestamp := make_date(t_year, APR, 25);
			t_holiday.description := 'Festa della Liberazione';
			RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Festa dei Lavoratori';
		RETURN NEXT t_holiday;
		if year >= 1948:
			t_holiday.datestamp := make_date(t_year, JUN, 2);
			t_holiday.description := 'Festa della Repubblica';
			RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, AUG, 15);
		t_holiday.description := 'Assunzione della Vergine';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, NOV, 1);
		t_holiday.description := 'Tutti i Santi';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 8);
		t_holiday.description := 'Immacolata Concezione';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Natale';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Santo Stefano';
		RETURN NEXT t_holiday;

		-- Provinces holidays
		if self.prov:
			if self.prov == 'AN':
				t_holiday.datestamp := make_date(t_year, MAY, 4);
				t_holiday.description := 'San Ciriaco';
				RETURN NEXT t_holiday;
			elif self.prov == 'AO':
				t_holiday.datestamp := make_date(t_year, SEP, 7);
				t_holiday.description := 'San Grato';
				RETURN NEXT t_holiday;
			elif self.prov in ('BA'):
				t_holiday.datestamp := make_date(t_year, DEC, 6);
				t_holiday.description := 'San Nicola';
				RETURN NEXT t_holiday;
			elif self.prov == 'BL':
				t_holiday.datestamp := make_date(t_year, NOV, 11);
				t_holiday.description := 'San Martino';
				RETURN NEXT t_holiday;
			elif self.prov in ('BO'):
				t_holiday.datestamp := make_date(t_year, OCT, 4);
				t_holiday.description := 'San Petronio';
				RETURN NEXT t_holiday;
			elif self.prov == 'BZ':
				t_holiday.datestamp := make_date(t_year, AUG, 15);
				t_holiday.description := 'Maria Santissima Assunta';
				RETURN NEXT t_holiday;
			elif self.prov == 'BS':
				t_holiday.datestamp := make_date(t_year, FEB, 15);
				t_holiday.description := 'Santi Faustino e Giovita';
				RETURN NEXT t_holiday;
			elif self.prov == 'CB':
				t_holiday.datestamp := make_date(t_year, APR, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			elif self.prov == 'CT':
				t_holiday.datestamp := make_date(t_year, FEB, 5);
				t_holiday.description := 'Sant''Agata';
				RETURN NEXT t_holiday;
			elif self.prov in ('FC', 'Cesena'):
				t_holiday.datestamp := make_date(t_year, JUN, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			if self.prov in ('FC', 'Forlì'):
				t_holiday.datestamp := make_date(t_year, FEB, 4);
				t_holiday.description := 'Madonna del Fuoco';
				RETURN NEXT t_holiday;
			elif self.prov == 'CH':
				t_holiday.datestamp := make_date(t_year, MAY, 11);
				t_holiday.description := 'San Giustino di Chieti';
				RETURN NEXT t_holiday;
			elif self.prov == 'CS':
				t_holiday.datestamp := make_date(t_year, FEB, 12);
				t_holiday.description := 'Madonna del Pilerio';
				RETURN NEXT t_holiday;
			elif self.prov == 'KR':
				t_holiday.datestamp := make_date(t_year, OCT, 9);
				t_holiday.description := 'San Dionigi';
				RETURN NEXT t_holiday;
			elif self.prov == 'EN':
				t_holiday.datestamp := make_date(t_year, JUL, 2);
				t_holiday.description := 'Madonna della Visitazione';
				RETURN NEXT t_holiday;
			elif self.prov == 'FE':
				t_holiday.datestamp := make_date(t_year, APR, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			elif self.prov == 'FI':
				t_holiday.datestamp := make_date(t_year, JUN, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elif self.prov == 'FR':
				t_holiday.datestamp := make_date(t_year, JUN, 20);
				t_holiday.description := 'San Silverio';
				RETURN NEXT t_holiday;
			elif self.prov == 'GE':
				t_holiday.datestamp := make_date(t_year, JUN, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elif self.prov == 'GO':
				t_holiday.datestamp := make_date(t_year, MAR, 16);
				t_holiday.description := 'Santi Ilario e Taziano';
				RETURN NEXT t_holiday;
			elif self.prov == 'IS':
				t_holiday.datestamp := make_date(t_year, MAY, 19);
				t_holiday.description := 'San Pietro Celestino';
				RETURN NEXT t_holiday;
			elif self.prov == 'SP':
				t_holiday.datestamp := make_date(t_year, MAR, 19);
				t_holiday.description := 'San Giuseppe';
				RETURN NEXT t_holiday;
			elif self.prov == 'LT':
				t_holiday.datestamp := make_date(t_year, APR, 25);
				t_holiday.description := 'San Marco evangelista';
				RETURN NEXT t_holiday;
			elif self.prov == 'ME':
				t_holiday.datestamp := make_date(t_year, JUN, 3);
				t_holiday.description := 'Madonna della Lettera';
				RETURN NEXT t_holiday;
			elif self.prov == 'MI':
				t_holiday.datestamp := make_date(t_year, DEC, 7);
				t_holiday.description := 'Sant''Ambrogio';
				RETURN NEXT t_holiday;
			elif self.prov == 'MN':
				t_holiday.datestamp := make_date(t_year, MAR, 18);
				t_holiday.description := 'Sant''Anselmo da Baggio';
				RETURN NEXT t_holiday;
			elif self.prov == 'MS':
				t_holiday.datestamp := make_date(t_year, OCT, 4);
				t_holiday.description := 'San Francesco d''Assisi';
				RETURN NEXT t_holiday;
			elif self.prov == 'MO':
				t_holiday.datestamp := make_date(t_year, JANUARY, 31);
				t_holiday.description := 'San Geminiano';
				RETURN NEXT t_holiday;
			elif self.prov == 'MB':
				t_holiday.datestamp := make_date(t_year, JUN, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elif self.prov == 'NA':
				t_holiday.datestamp := make_date(t_year, SEP, 19);
				t_holiday.description := 'San Gennaro';
				RETURN NEXT t_holiday;
			elif self.prov == 'PD':
				t_holiday.datestamp := make_date(t_year, JUN, 13);
				t_holiday.description := 'Sant''Antonio di Padova';
				RETURN NEXT t_holiday;
			elif self.prov == 'PA':
				t_holiday.datestamp := make_date(t_year, JUL, 15);
				t_holiday.description := 'San Giovanni';
				RETURN NEXT t_holiday;
			elif self.prov == 'PR':
				t_holiday.datestamp := make_date(t_year, JANUARY, 13);
				t_holiday.description := 'Sant''Ilario di Poitiers';
				RETURN NEXT t_holiday;
			elif self.prov == 'PG':
				t_holiday.datestamp := make_date(t_year, JANUARY, 29);
				t_holiday.description := 'Sant''Ercolano e San Lorenzo';
				RETURN NEXT t_holiday;
			elif self.prov == 'PC':
				t_holiday.datestamp := make_date(t_year, JUL, 4);
				t_holiday.description := 'Sant''Antonino di Piacenza';
				RETURN NEXT t_holiday;
			elif self.prov == 'RM':
				t_holiday.datestamp := make_date(t_year, JUN, 29);
				t_holiday.description := 'Santi Pietro e Paolo';
				RETURN NEXT t_holiday;
			elif self.prov == 'TO':
				t_holiday.datestamp := make_date(t_year, JUN, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			elif self.prov == 'TS':
				t_holiday.datestamp := make_date(t_year, NOV, 3);
				t_holiday.description := 'San Giusto';
				RETURN NEXT t_holiday;
			elif self.prov == 'VI':
				t_holiday.datestamp := make_date(t_year, APR, 25);
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