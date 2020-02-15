------------------------------------------
------------------------------------------
-- Italy Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.italy(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	PROVINCES TEXT[] := ARRAY[
		'AN', 'AO', 'BA', 'BL', 'BO', 'BZ', 'BS', 'CB', 'CT', 'Cesena', 'CH',
		'CS', 'KR', 'EN', 'FE', 'FI', 'FC', 'Forli', 'FR', 'GE', 'GO', 'IS',
		'SP', 'LT', 'MN', 'MS', 'MI', 'MO', 'MB', 'NA', 'PD', 'PA', 'PR', 'PG',
		'PE', 'PC', 'PI', 'PD', 'PT', 'RA', 'RE', 'RI', 'RN', 'RM', 'RO', 'SA',
		'SR', 'TE', 'TO', 'TS', 'Pesaro', 'PU', 'Urbino', 'VE', 'VC', 'VI'
	];
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
		t_holiday.description := 'Capodanno';
		RETURN NEXT t_holiday;

		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Epifania del Signore';
		RETURN NEXT t_holiday;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);
		
		-- Easter Sunday
		t_holiday.reference := 'Easter Sunday';
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Pasqua di Resurrezione';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
		t_holiday.description := 'Lunedì dell''Angelo';
		RETURN NEXT t_holiday;

		-- Liberation Day
		t_holiday.reference := 'Liberation Day';
		IF t_year >= 1946 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'Festa della Liberazione';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Festa dei Lavoratori';
		RETURN NEXT t_holiday;

		-- Republic Day
		t_holiday.reference := 'Republic Day';
		IF t_year >= 1948 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 2);
			t_holiday.description := 'Festa della Repubblica';
			RETURN NEXT t_holiday;
		END IF;

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Assunzione della Vergine';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Tutti i Santi';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'Immacolata Concezione';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Natale';
		RETURN NEXT t_holiday;

		-- St. Stephen's Day
		t_holiday.reference := 'St. Stephen''s Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Santo Stefano';
		RETURN NEXT t_holiday;

		-- Provinces holidays
		t_holiday.authority := 'provincial';
		IF p_province != '' THEN
			IF p_province = 'AN' THEN
				-- Judas Cyriacus
				t_holiday.reference := 'St. Judas Cyriacus';
				t_holiday.datestamp := make_date(t_year, MAY, 4);
				t_holiday.description := 'San Ciriaco';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'AO' THEN
				-- Gratus of Aosta
				t_holiday.reference := 'St. Gratus of Aosta';
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 7);
				t_holiday.description := 'San Grato';
				RETURN NEXT t_holiday;
			ELSIF p_province IN ('BA') THEN
				-- Saint Nicholas Day
				t_holiday.reference := 'Saint Nicholas Day';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
				t_holiday.description := 'San Nicola';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'BL' THEN
				-- Saint Martin Day
				t_holiday.reference := 'Saint Martin Day';
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
				t_holiday.description := 'San Martino';
				RETURN NEXT t_holiday;
			ELSIF p_province IN ('BO') THEN
				-- Saint Petronius Day
				t_holiday.reference := 'Saint Petronius Day';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
				t_holiday.description := 'San Petronio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'BZ' THEN
				-- Assumption
				t_holiday.reference := 'Assumption';
				t_holiday.datestamp := make_date(t_year, AUGUST, 15);
				t_holiday.description := 'Maria Santissima Assunta';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'BS' THEN
				-- Saints Faustino and Giovita
				t_holiday.reference := 'Saints Faustino and Giovita';
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 15);
				t_holiday.description := 'Santi Faustino e Giovita';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'CB' THEN
				-- St. George
				t_holiday.reference := 'St. George';
				t_holiday.datestamp := make_date(t_year, APRIL, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'CT' THEN
				-- Saint Agatha[
				t_holiday.reference := 'Saint Agatha[';
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 5);
				t_holiday.description := 'Sant''Agata';
				RETURN NEXT t_holiday;
			ELSIF p_province IN ('FC', 'Cesena') THEN
				-- John the Baptist
				t_holiday.reference := 'John the Baptist';
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			END IF;
			IF p_province IN ('FC', 'Forlì') THEN
				-- Our Lady of Fire
				t_holiday.reference := 'Our Lady of Fire';
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 4);
				t_holiday.description := 'Madonna del Fuoco';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'CH' THEN
				-- Saint Justin of Chieti
				t_holiday.reference := 'Saint Justin of Chieti';
				t_holiday.datestamp := make_date(t_year, MAY, 11);
				t_holiday.description := 'San Giustino di Chieti';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'CS' THEN
				-- Our Lady of the Pillar
				t_holiday.reference := 'Our Lady of the Pillar';
				t_holiday.datestamp := make_date(t_year, FEBRUARY, 12);
				t_holiday.description := 'Madonna del Pilerio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'KR' THEN
				-- Saint Denis
				t_holiday.reference := 'Saint Denis';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 9);
				t_holiday.description := 'San Dionigi';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'EN' THEN
				-- Our Lady of the Visitation
				t_holiday.reference := 'Our Lady of the Visitation';
				t_holiday.datestamp := make_date(t_year, JULY, 2);
				t_holiday.description := 'Madonna della Visitazione';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'FE' THEN
				-- Saint George
				t_holiday.reference := 'St. George';
				t_holiday.datestamp := make_date(t_year, APRIL, 23);
				t_holiday.description := 'San Giorgio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'FI' THEN
				-- John the Baptist
				t_holiday.reference := 'John the Baptist';
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'FR' THEN
				-- Pope Silverius
				t_holiday.reference := 'Pope Silverius';
				t_holiday.datestamp := make_date(t_year, JUNE, 20);
				t_holiday.description := 'San Silverio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'GE' THEN
				-- John the Baptist
				t_holiday.reference := 'John the Baptist';
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'GO' THEN
				-- Saint Hilarius of Aquileia and Tatianus
				t_holiday.reference := 'Saint Hilarius of Aquileia and Tatianus';
				t_holiday.datestamp := make_date(t_year, MARCH, 16);
				t_holiday.description := 'Santi Ilario e Taziano';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'IS' THEN
				-- Pope Celestine V
				t_holiday.reference := 'Pope Celestine V';
				t_holiday.datestamp := make_date(t_year, MAY, 19);
				t_holiday.description := 'San Pietro Celestino';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'SP' THEN
				-- Saint Joseph
				t_holiday.reference := 'Saint Joseph';
				t_holiday.datestamp := make_date(t_year, MARCH, 19);
				t_holiday.description := 'San Giuseppe';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'LT' THEN
				-- Mark the Evangelist
				t_holiday.reference := 'Mark the Evangelist';
				t_holiday.datestamp := make_date(t_year, APRIL, 25);
				t_holiday.description := 'San Marco evangelista';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'ME' THEN
				-- Our Lady of the Letter
				t_holiday.reference := 'Our Lady of the Letter';
				t_holiday.datestamp := make_date(t_year, JUNE, 3);
				t_holiday.description := 'Madonna della Lettera';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'MI' THEN
				-- Ambrose
				t_holiday.reference := 'Ambrose';
				t_holiday.datestamp := make_date(t_year, DECEMBER, 7);
				t_holiday.description := 'Sant''Ambrogio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'MN' THEN
				-- Saint Anselm of Lucca
				t_holiday.reference := 'Saint Anselm of Lucca';
				t_holiday.datestamp := make_date(t_year, MARCH, 18);
				t_holiday.description := 'Sant''Anselmo da Baggio';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'MS' THEN
				-- Saint Francis of Assisi
				t_holiday.reference := 'Saint Francis of Assisi';
				t_holiday.datestamp := make_date(t_year, OCTOBER, 4);
				t_holiday.description := 'San Francesco d''Assisi';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'MO' THEN
				-- Saint Geminianus
				t_holiday.reference := 'Saint Geminianus';
				t_holiday.datestamp := make_date(t_year, JANUARY, 31);
				t_holiday.description := 'San Geminiano';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'MB' THEN
				-- John the Baptist
				t_holiday.reference := 'John the Baptist';
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'NA' THEN
				-- Januarius
				t_holiday.reference := 'Januarius';
				t_holiday.datestamp := make_date(t_year, SEPTEMBER, 19);
				t_holiday.description := 'San Gennaro';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'PD' THEN
				-- Saint Anthony of Padua
				t_holiday.reference := 'Saint Anthony of Padua';
				t_holiday.datestamp := make_date(t_year, JUNE, 13);
				t_holiday.description := 'Sant''Antonio di Padova';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'PA' THEN
				-- Inscrutable - Not Translating
				t_holiday.reference := 'San Giovanni';
				t_holiday.datestamp := make_date(t_year, JULY, 15);
				t_holiday.description := 'San Giovanni';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'PR' THEN
				-- Hilary of Poitiers
				t_holiday.reference := 'Hilary of Poitiers';
				t_holiday.datestamp := make_date(t_year, JANUARY, 13);
				t_holiday.description := 'Sant''Ilario di Poitiers';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'PG' THEN
				-- Saint Constantius of Perugia
				-- Porting Notes: Day doesn't match sources; January 29th aligns with San Costanzo, not Sant''Ercolano e San Lorenzo
				-- Originally: Herculanus of Perugia; Sant''Ercolano e San Lorenzo
				-- Apparently only a third of Perugians observe this. Not sure if it's worth keeping.
				t_holiday.reference := 'Saint Constantius of Perugia';
				t_holiday.datestamp := make_date(t_year, JANUARY, 29);
				t_holiday.description := 'San Costanzo di Perugia';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'PC' THEN
				-- Saint Antoninus of Piacenza
				t_holiday.reference := 'Saint Antoninus of Piacenza';
				t_holiday.datestamp := make_date(t_year, JULY, 4);
				t_holiday.description := 'Sant''Antonino di Piacenza';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'RM' THEN
				-- Saints Peter and Paul
				t_holiday.reference := 'Saints Peter and Paul';
				t_holiday.datestamp := make_date(t_year, JUNE, 29);
				t_holiday.description := 'Santi Pietro e Paolo';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'TO' THEN
				-- John the Baptist
				t_holiday.reference := 'John the Baptist';
				t_holiday.datestamp := make_date(t_year, JUNE, 24);
				t_holiday.description := 'San Giovanni Battista';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'TS' THEN
				-- Justus of Trieste
				t_holiday.reference := 'Justus of Trieste';
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 3);
				t_holiday.description := 'San Giusto';
				RETURN NEXT t_holiday;
			ELSIF p_province = 'VI' THEN
				-- Mark the Evangelist
				t_holiday.reference := 'Mark the Evangelist';
				t_holiday.datestamp := make_date(t_year, APRIL, 25);
				t_holiday.description := 'San Marco';
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- TODO: add missing provinces' holidays:
		-- 'Pisa', 'Pordenone', 'Potenza', 'Ravenna',
		-- 'Reggio Emilia', 'Rieti', 'Rimini', 'Rovigo',
		-- 'Salerno', 'Siracusa', 'Teramo', 'Torino', 'Urbino',
		-- 'Venezia'

	END LOOP;
END;

$$ LANGUAGE plpgsql;