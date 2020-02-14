------------------------------------------
------------------------------------------
-- Brazil Holidays
--
-- https://pt.wikipedia.org/wiki/Feriados_no_Brasil
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.brazil(p_state TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
	-- States
	STATES TEXT[] := ARRAY[
		'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT',
		'MS', 'MG', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RS', 'RO',
		'RR', 'SC', 'SP', 'SE', 'TO'];
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

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Ano novo';
		RETURN NEXT t_holiday;

		-- Tiradentes
		t_holiday.reference := 'Tiradentes';
		t_holiday.datestamp := make_date(t_year, APRIL, 21);
		t_holiday.description := 'Tiradentes';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia Mundial do Trabalho';
		RETURN NEXT t_holiday;

		-- Independance Day
		t_holiday.reference := 'Independance Day';
		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 7);
		t_holiday.description := 'Independência do Brasil';
		RETURN NEXT t_holiday;

		-- Our Lady of Aparecida
		t_holiday.reference := 'Our Lady of Aparecida';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
		t_holiday.description := 'Nossa Senhora Aparecida';
		RETURN NEXT t_holiday;

		-- Day of the Dead
		t_holiday.reference := 'Day of the Dead';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 2);
		t_holiday.description := 'Finados';
		RETURN NEXT t_holiday;

		-- Republic Proclamation Day
		t_holiday.reference := 'Republic Proclamation Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 15);
		t_holiday.description := 'Proclamação da República';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Natal';
		RETURN NEXT t_holiday;

		-- Easter Related Dates
		t_datestamp := holidays.easter(t_year);

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
		t_holiday.reference := 'Corpus Christi';
		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Corpus Christi';
		RETURN NEXT t_holiday;

		-- Lent (Quaresma) Related Dates
		-- Ash Wednesday
		t_holiday.reference := 'Ash Wednesday';
		t_datestamp := holidays.easter(t_year)  - '46 Days'::INTERVAL;
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Quarta-feira de cinzas (Início da Quaresma)';
		RETURN NEXT t_holiday;

		-- Carnival
		t_holiday.reference := 'Carnival';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Carnaval';
		RETURN NEXT t_holiday;

		-- State Holidays
		t_holiday.authority := 'state';

		-- Black Awareness Day
		IF p_state in ('AL', 'AP', 'AM', 'MT', 'RJ') THEN
			t_holiday.reference := 'Black Awareness Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			IF p_state = 'RJ' THEN
				t_holiday.description := 'Zumbi dos Palmares';
			ELSE
				t_holiday.description := 'Consciência Negra';
			END IF;
			RETURN NEXT t_holiday;
		END IF;

		-- Saint John's Day
		IF p_state IN ('AL', 'PE') THEN
			t_holiday.reference := 'Saint John''s Day';
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'São João';
			RETURN NEXT t_holiday;
		END IF;

		-- Saint Peter's Day
		IF p_state IN ('AL', 'RN') THEN
			t_holiday.reference := 'Saint Peter''s Day';
			t_holiday.datestamp := make_date(t_year, JUNE, 29);
			t_holiday.description := 'Dia de São Pedro';
			RETURN NEXT t_holiday;
		END IF;

		-- St. Joseph's Day
		IF p_state IN ('AP', 'CE') THEN
			t_holiday.reference := 'St. Joseph''s Day';
			t_holiday.datestamp := make_date(t_year, MARCH, 19);
			t_holiday.description := 'Dia de São José';
			RETURN NEXT t_holiday;
		END IF;

		-- Immaculate Conception
		IF p_state IN ('AM', 'MA') THEN
			t_holiday.reference := 'Immaculate Conception';
			t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
			t_holiday.description := 'Dia de Nossa Senhora da Conceição';
			RETURN NEXT t_holiday;
		END IF;

		-- Evangelical Day
		IF p_state IN ('AC', 'DF', 'RD') THEN
			t_holiday.reference := 'Evangelical Day';
			t_holiday.datestamp := make_date(t_year, JANUARY, 23);
			t_holiday.description := 'Dia do evangélico';
			RETURN NEXT t_holiday;
		END IF;

		-- Public Service Holiday
		IF p_state IN ('ES', 'GO', 'RJ') THEN
			t_holiday.reference := 'Public Service Holiday';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
			IF p_state = 'RJ' THEN
				t_holiday.description := 'Dia do Funcionário Público';
			ELSE
				t_holiday.description := 'Dia do Servidor Público';
			END IF;
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'AC' THEN
			-- Anniversary of Acre
			-- Statehood Day in Acre
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, JUNE, 15);
			t_holiday.description := 'Aniversário do Acre';
			RETURN NEXT t_holiday;

			-- Amazon Day
			t_holiday.reference := 'Amazon Day';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 5);
			t_holiday.description := 'Dia da Amazônia';
			RETURN NEXT t_holiday;

			-- Signature of the Petrópolis Treaty
			t_holiday.reference := 'Signature of the Petrópolis Treat';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 17);
			t_holiday.description := 'Assinatura do Tratado de Petrópolis';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Alagoas
		IF p_state = 'AL' THEN	
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 16);
			t_holiday.description := 'Emancipação política de Alagoas';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'AP' THEN
			-- Statehood Day in Amapá
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;

			-- St. James' Day
			t_holiday.datestamp := make_date(t_year, JULY, 25);
			t_holiday.description := 'São Tiago';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Amazonas
		IF p_state = 'AM' THEN	
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 5);
			t_holiday.description := 'Elevação do Amazonas à categoria de província';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Bahia
		IF p_state = 'BA' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, JULY, 2);
			t_holiday.description := 'Independência da Bahia';
			RETURN NEXT t_holiday;
		END IF;

		-- Abolition of Slavery in Ceará
		IF p_state = 'CE' THEN
			t_holiday.reference := 'Abolition of Slavery';
			t_holiday.datestamp := make_date(t_year, MARCH, 25);
			t_holiday.description := 'Data Magna do Ceará';
			RETURN NEXT t_holiday;
		END IF;

		-- Foundation of Brasília
		IF p_state = 'DF' THEN
			t_holiday.reference := 'Foundation of Brasília';
			t_holiday.datestamp := make_date(t_year, APRIL, 21);
			t_holiday.description := 'Fundação de Brasília';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Maranhão
		IF p_state = 'MA' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, JULY, 28);
			t_holiday.description := 'Adesão do Maranhão à independência do Brasil';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Mato Grosso do Sul
		IF p_state = 'MS' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 11);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
		END IF;

		-- Abolition of Slavery in Minas Gerais
		IF p_state = 'MG' THEN
			t_holiday.reference := 'Abolition of Slavery';
			t_holiday.datestamp := make_date(t_year, APRIL, 21);
			t_holiday.description := 'Data Magna de MG';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Pará
		IF p_state = 'PA' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, AUGUST, 15);
			t_holiday.description := 'Adesão do Grão-Pará à independência do Brasil';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Paraíba
		IF p_state = 'PB' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, AUGUST, 5);
			t_holiday.description := 'Fundação do Estado';
			RETURN NEXT t_holiday;
		END IF;

		-- Abolition of Slavery in Pernambuco
		IF p_state = 'PE' THEN
			t_holiday.reference := 'Abolition of Slavery';
			t_holiday.datestamp := make_date(t_year, MARCH, 6);
			t_holiday.description := 'Revolução Pernambucana (Data Magna)';
			RETURN NEXT t_holiday;
		END IF;

		-- Piauí
		IF p_state = 'PI' THEN
			-- Battle of Jenipapo Day
			t_holiday.reference := 'Battle of Jenipapo Day';
			t_holiday.datestamp := make_date(t_year, MARCH, 13);
			t_holiday.description := 'Dia da Batalha do Jenipapo';
			RETURN NEXT t_holiday;

			-- Statehood Day in Piauí
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 19);
			t_holiday.description := 'Dia do Piauí';
			RETURN NEXT t_holiday;
		END IF;

		-- Abolition of Slavery in Paraná
		IF p_state = 'PR' THEN
			t_holiday.reference := 'Abolition of Slavery';
			t_holiday.datestamp := make_date(t_year, DECEMBER, 19);
			t_holiday.description := 'Emancipação do Paraná';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RJ' THEN
			-- St. George's Day
			t_holiday.reference := 'St. George''s Day';
			t_holiday.datestamp := make_date(t_year, APRIL, 23);
			t_holiday.description := 'Dia de São Jorge';
			RETURN NEXT t_holiday;
		END IF;

		-- Martyrs of Cunhaú and Uruaçuu
		IF p_state = 'RN' THEN
			t_holiday.reference := 'Martyrs of Cunhaú and Uruaçuu';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			t_holiday.description := 'Mártires de Cunhaú e Uruaçuu';
			RETURN NEXT t_holiday;
		END IF;

		-- Commemeration of The Ragamuffin Revolution
		IF p_state = 'RS' THEN
			t_holiday.reference := 'Ragamuffin Revolution';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 20);
			t_holiday.description := 'Revolução Farroupilha';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Rondônia
		IF p_state = 'RO' THEN	
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, JANUARY, 4);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Roraima
		IF p_state = 'RR' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação de Roraima';
			RETURN NEXT t_holiday;
		END IF;

		-- Creation of the Santa Catarina Captiancy
		-- This is similar to a Statehood Day
		IF p_state = 'SC' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, AUGUST, 11);
			t_holiday.description := 'Criação da capitania, separando-se de SP';
			RETURN NEXT t_holiday;
		END IF;

		-- Constitutionalist Revolution of 1932
		-- Paulista War / Brazilian Civil War
		IF p_state = 'SP' THEN
			t_holiday.reference := 'Constitutionalist Revolution of 1932';
			t_holiday.datestamp := make_date(t_year, JULY, 9);
			t_holiday.description := 'Revolução Constitucionalista de 1932';
			RETURN NEXT t_holiday;
		END IF;

		-- Statehood Day in Sergipe
		IF p_state = 'SE' THEN
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, JULY, 8);
			t_holiday.description := 'Autonomia política de Sergipe';
			RETURN NEXT t_holiday;
		END IF;

		-- Tocantins
		IF p_state = 'TO' THEN
			-- Tocantins Installation
			t_holiday.reference := 'Tocantins Installation';
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Instalação de Tocantins';
			RETURN NEXT t_holiday;

			-- Our Lady of the Nativity
			t_holiday.reference := 'Our Lady of the Nativity';
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 8);
			t_holiday.description := 'Nossa Senhora da Natividade';
			RETURN NEXT t_holiday;

			-- Statehood Day in Tocantins
			t_holiday.reference := 'Statehood Day';
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação de Tocantins';
			RETURN NEXT t_holiday;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;