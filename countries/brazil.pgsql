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
		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Ano novo';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, APRIL, 21);
		t_holiday.description := 'Tiradentes';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia Mundial do Trabalho';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, SEPTEMBER, 7);
		t_holiday.description := 'Independência do Brasil';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
		t_holiday.description := 'Nossa Senhora Aparecida';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOVEMBER, 2);
		t_holiday.description := 'Finados';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOVEMBER, 15);
		t_holiday.description := 'Proclamação da República';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Natal';
		RETURN NEXT t_holiday;

		-- Easter Related Dates
		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
		t_holiday.description := 'Sexta-feira Santa';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Páscoa';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := t_datestamp + '60 Days'::INTERVAL;
		t_holiday.description := 'Corpus Christi';
		RETURN NEXT t_holiday;

		-- Quaresma related Dates
		t_datestamp := holidays.easter(t_year)  - '46 Days'::INTERVAL;
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Quarta-feira de cinzas (Início da Quaresma)';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
		t_holiday.description := 'Carnaval';
		RETURN NEXT t_holiday;

		IF p_state = 'AC' THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 23);
			t_holiday.description := 'Dia do evangélico';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUNE, 15);
			t_holiday.description := 'Aniversário do Acre';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 5);
			t_holiday.description := 'Dia da Amazônia';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 17);
			t_holiday.description := 'Assinatura do Tratado de Petrópolis';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'AL' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'São João';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUNE, 29);
			t_holiday.description := 'São Pedro';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 16);
			t_holiday.description := 'Emancipação política de Alagoas';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'AP' THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 19);
			t_holiday.description := 'Dia de São José';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JULY, 25);
			t_holiday.description := 'São Tiago';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'AM' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 5);
			t_holiday.description := 'Elevação do Amazonas à categoria de província';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
			t_holiday.description := 'Dia de Nossa Senhora da Conceição';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'BA' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 2);
			t_holiday.description := 'Independência da Bahia';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'CE' THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 19);
			t_holiday.description := 'São José';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MARCH, 25);
			t_holiday.description := 'Data Magna do Ceará';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'DF' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 21);
			t_holiday.description := 'Fundação de Brasília';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 30);
			t_holiday.description := 'Dia do Evangélico';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'ES' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
			t_holiday.description := 'Dia do Servidor Público';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'GO' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
			t_holiday.description := 'Dia do Servidor Público';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'MA' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 28);
			t_holiday.description := 'Adesão do Maranhão à independência do Brasil';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
			t_holiday.description := 'Dia de Nossa Senhora da Conceição';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'MT' THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'MS' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 11);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'MG' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 21);
			t_holiday.description := 'Data Magna de MG';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'PA' THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 15);
			t_holiday.description := 'Adesão do Grão-Pará à independência do Brasil';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'PB' THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 5);
			t_holiday.description := 'Fundação do Estado';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'PE' THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 6);
			t_holiday.description := 'Revolução Pernambucana (Data Magna)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'São João';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'PI' THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 13);
			t_holiday.description := 'Dia da Batalha do Jenipapo';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 19);
			t_holiday.description := 'Dia do Piauí';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'PR' THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 19);
			t_holiday.description := 'Emancipação do Paraná';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RJ' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 23);
			t_holiday.description := 'Dia de São Jorge';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
			t_holiday.description := 'Dia do Funcionário Público';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 20);
			t_holiday.description := 'Zumbi dos Palmares';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RN' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 29);
			t_holiday.description := 'Dia de São Pedro';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 3);
			t_holiday.description := 'Mártires de Cunhaú e Uruaçuu';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RS' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 20);
			t_holiday.description := 'Revolução Farroupilha';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RO' THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 4);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUNE, 18);
			t_holiday.description := 'Dia do Evangélico';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'RR' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação de Roraima';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'SC' THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 11);
			t_holiday.description := 'Criação da capitania, separando-se de SP';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'SP' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 9);
			t_holiday.description := 'Revolução Constitucionalista de 1932';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'SE' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 8);
			t_holiday.description := 'Autonomia política de Sergipe';
			RETURN NEXT t_holiday;
		END IF;

		IF p_state = 'TO' THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Instalação de Tocantins';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 8);
			t_holiday.description := 'Nossa Senhora da Natividade';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCTOBER, 5);
			t_holiday.description := 'Criação de Tocantins';
			RETURN NEXT t_holiday;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;