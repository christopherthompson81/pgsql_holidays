------------------------------------------
------------------------------------------
-- Spain Holidays (Porting Unfinished)
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.spain(p_start_year INTEGER, p_end_year INTEGER)
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
		'AND', 'ARG', 'AST', 'CAN', 'CAM', 'CAL', 'CAT', 'CVA', 'EXT', 'GAL',
		'IBA', 'ICA', 'MAD', 'MUR', 'NAV', 'PVA', 'RIO'
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

		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año nuevo';
		RETURN NEXT t_holiday;
		
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Epifanía del Señor';
		RETURN NEXT t_holiday;
		
		IF self.prov and p_province IN ['CVA', 'MUR', 'MAD', 'NAV', 'PVA'] THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 19);
			t_holiday.description := 'San José';
			RETURN NEXT t_holiday;
		END IF;
		
		IF p_province != 'CAT' THEN
			self[easter(year) + rd(weeks=-1, weekday=TH)] = 'Jueves Santo'
		END IF;
		
		self[easter(year) + rd(weeks=-1, weekday=FR)] = 'Viernes Santo'

		IF p_province IN ['CAT', 'PVA', 'NAV', 'CVA', 'IBA'] THEN
			self[easter(year) + rd(weekday=MO)] = 'Lunes de Pascua'
		END IF;

		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajador';
		RETURN NEXT t_holiday;

		IF self.prov and p_province IN ['CAT', 'GAL'] THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'San Juan';
			RETURN NEXT t_holiday;
		END IF;

		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Asunción de la Virgen';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
		t_holiday.description := 'Día de la Hispanidad';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Todos los Santos';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
		t_holiday.description := 'Día de la constitución Española';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'La Inmaculada Concepción';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;

		IF p_province IN ['CAT', 'IBA'] THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.description := 'San Esteban';
			RETURN NEXT t_holiday;
		END IF;

		-- Provinces festive day
		IF p_province = 'AND' THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 28);
			t_holiday.description := 'Día de Andalucia';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'ARG' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 23);
			t_holiday.description := 'Día de San Jorge';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'AST' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 8);
			t_holiday.description := 'Día de Asturias';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'CAN' THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 28);
			t_holiday.description := 'Día de la Montaña';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'CAM' THEN
			t_holiday.datestamp := make_date(t_year, FEBRUARY, 28);
			t_holiday.description := 'Día de Castilla - La Mancha';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'CAL' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 23);
			t_holiday.description := 'Día de Castilla y Leon';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'CAT' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 11);
			t_holiday.description := 'Día Nacional de Catalunya';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'CVA' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 9);
			t_holiday.description := 'Día de la Comunidad Valenciana';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'EXT' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 8);
			t_holiday.description := 'Día de Extremadura';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'GAL' THEN
			t_holiday.datestamp := make_date(t_year, JULY, 25);
			t_holiday.description := 'Día Nacional de Galicia';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'IBA' THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 1);
			t_holiday.description := 'Día de las Islas Baleares';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'ICA' THEN
			t_holiday.datestamp := make_date(t_year, MAY, 30);
			t_holiday.description := 'Día de Canarias';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'MAD' THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'Día de Comunidad De Madrid';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'MUR' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 9);
			t_holiday.description := 'Día de la Región de Murcia';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'NAV' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 27);
			t_holiday.description := 'Día de Navarra';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'PVA' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 25);
			t_holiday.description := 'Día del Páis Vasco';
			RETURN NEXT t_holiday;
		ELSIF p_province = 'RIO' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 9);
			t_holiday.description := 'Día de La Rioja';
			RETURN NEXT t_holiday;
		END IF;
	END LOOP;
END;

$$ LANGUAGE plpgsql;