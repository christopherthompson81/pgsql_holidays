------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://pt.wikipedia.org/wiki/Feriados_no_Brasil
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
	-- States
	STATES = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT',
			  'MS', 'MG', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RS', 'RO',
			  'RR', 'SC', 'SP', 'SE', 'TO']
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

		t_holiday.datestamp := make_date(t_year, APR, 21);
		t_holiday.description := 'Tiradentes';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia Mundial do Trabalho';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, SEP, 7);
		t_holiday.description := 'Independência do Brasil';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, OCT, 12);
		t_holiday.description := 'Nossa Senhora Aparecida';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOV, 2);
		t_holiday.description := 'Finados';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOV, 15);
		t_holiday.description := 'Proclamação da República';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Natal';
		RETURN NEXT t_holiday;

		self[easter(year) - rd(days=2)] = 'Sexta-feira Santa'

		self[easter(year)] = 'Páscoa'

		self[easter(year) + rd(days=60)] = 'Corpus Christi'

		quaresma = easter(year) - rd(days=46)
		self[quaresma] = 'Quarta-feira de cinzas (Início da Quaresma)'

		self[quaresma - rd(weekday=TU(-1))] = 'Carnaval'

		if self.state == 'AC':
			t_holiday.datestamp := make_date(t_year, JANUARY, 23);
			t_holiday.description := 'Dia do evangélico';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 15);
			t_holiday.description := 'Aniversário do Acre';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEP, 5);
			t_holiday.description := 'Dia da Amazônia';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 17);
			t_holiday.description := 'Assinatura do Tratado de Petrópolis';
			RETURN NEXT t_holiday;

		if self.state == 'AL':
			t_holiday.datestamp := make_date(t_year, JUN, 24);
			t_holiday.description := 'São João';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 29);
			t_holiday.description := 'São Pedro';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEP, 16);
			t_holiday.description := 'Emancipação política de Alagoas';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;

		if self.state == 'AP':
			t_holiday.datestamp := make_date(t_year, MAR, 19);
			t_holiday.description := 'Dia de São José';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUL, 25);
			t_holiday.description := 'São Tiago';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 5);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;

		if self.state == 'AM':
			t_holiday.datestamp := make_date(t_year, SEP, 5);
			t_holiday.description := 'Elevação do Amazonas à categoria de província';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, DEC, 8);
			t_holiday.description := 'Dia de Nossa Senhora da Conceição';
			RETURN NEXT t_holiday;

		if self.state == 'BA':
			t_holiday.datestamp := make_date(t_year, JUL, 2);
			t_holiday.description := 'Independência da Bahia';
			RETURN NEXT t_holiday;

		if self.state == 'CE':
			t_holiday.datestamp := make_date(t_year, MAR, 19);
			t_holiday.description := 'São José';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAR, 25);
			t_holiday.description := 'Data Magna do Ceará';
			RETURN NEXT t_holiday;

		if self.state == 'DF':
			t_holiday.datestamp := make_date(t_year, APR, 21);
			t_holiday.description := 'Fundação de Brasília';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 30);
			t_holiday.description := 'Dia do Evangélico';
			RETURN NEXT t_holiday;

		if self.state == 'ES':
			t_holiday.datestamp := make_date(t_year, OCT, 28);
			t_holiday.description := 'Dia do Servidor Público';
			RETURN NEXT t_holiday;

		if self.state == 'GO':
			t_holiday.datestamp := make_date(t_year, OCT, 28);
			t_holiday.description := 'Dia do Servidor Público';
			RETURN NEXT t_holiday;

		if self.state == 'MA':
			t_holiday.datestamp := make_date(t_year, JUL, 28);
			t_holiday.description := 'Adesão do Maranhão à independência do Brasil';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, DEC, 8);
			t_holiday.description := 'Dia de Nossa Senhora da Conceição';
			RETURN NEXT t_holiday;

		if self.state == 'MT':
			t_holiday.datestamp := make_date(t_year, NOV, 20);
			t_holiday.description := 'Consciência Negra';
			RETURN NEXT t_holiday;

		if self.state == 'MS':
			t_holiday.datestamp := make_date(t_year, OCT, 11);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;

		if self.state == 'MG':
			t_holiday.datestamp := make_date(t_year, APR, 21);
			t_holiday.description := 'Data Magna de MG';
			RETURN NEXT t_holiday;

		if self.state == 'PA':
			t_holiday.datestamp := make_date(t_year, AUG, 15);
			t_holiday.description := 'Adesão do Grão-Pará à independência do Brasil';
			RETURN NEXT t_holiday;

		if self.state == 'PB':
			t_holiday.datestamp := make_date(t_year, AUG, 5);
			t_holiday.description := 'Fundação do Estado';
			RETURN NEXT t_holiday;

		if self.state == 'PE':
			t_holiday.datestamp := make_date(t_year, MAR, 6);
			t_holiday.description := 'Revolução Pernambucana (Data Magna)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 24);
			t_holiday.description := 'São João';
			RETURN NEXT t_holiday;

		if self.state == 'PI':
			t_holiday.datestamp := make_date(t_year, MAR, 13);
			t_holiday.description := 'Dia da Batalha do Jenipapo';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 19);
			t_holiday.description := 'Dia do Piauí';
			RETURN NEXT t_holiday;

		if self.state == 'PR':
			t_holiday.datestamp := make_date(t_year, DEC, 19);
			t_holiday.description := 'Emancipação do Paraná';
			RETURN NEXT t_holiday;

		if self.state == 'RJ':
			t_holiday.datestamp := make_date(t_year, APR, 23);
			t_holiday.description := 'Dia de São Jorge';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 28);
			t_holiday.description := 'Dia do Funcionário Público';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 20);
			t_holiday.description := 'Zumbi dos Palmares';
			RETURN NEXT t_holiday;

		if self.state == 'RN':
			t_holiday.datestamp := make_date(t_year, JUN, 29);
			t_holiday.description := 'Dia de São Pedro';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 3);
			t_holiday.description := 'Mártires de Cunhaú e Uruaçuu';
			RETURN NEXT t_holiday;

		if self.state == 'RS':
			t_holiday.datestamp := make_date(t_year, SEP, 20);
			t_holiday.description := 'Revolução Farroupilha';
			RETURN NEXT t_holiday;

		if self.state == 'RO':
			t_holiday.datestamp := make_date(t_year, JANUARY, 4);
			t_holiday.description := 'Criação do estado';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 18);
			t_holiday.description := 'Dia do Evangélico';
			RETURN NEXT t_holiday;

		if self.state == 'RR':
			t_holiday.datestamp := make_date(t_year, OCT, 5);
			t_holiday.description := 'Criação de Roraima';
			RETURN NEXT t_holiday;

		if self.state == 'SC':
			t_holiday.datestamp := make_date(t_year, AUG, 11);
			t_holiday.description := 'Criação da capitania, separando-se de SP';
			RETURN NEXT t_holiday;

		if self.state == 'SP':
			t_holiday.datestamp := make_date(t_year, JUL, 9);
			t_holiday.description := 'Revolução Constitucionalista de 1932';
			RETURN NEXT t_holiday;

		if self.state == 'SE':
			t_holiday.datestamp := make_date(t_year, JUL, 8);
			t_holiday.description := 'Autonomia política de Sergipe';
			RETURN NEXT t_holiday;

		if self.state == 'TO':
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Instalação de Tocantins';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEP, 8);
			t_holiday.description := 'Nossa Senhora da Natividade';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 5);
			t_holiday.description := 'Criação de Tocantins';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;