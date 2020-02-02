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
	PROVINCES = ['AND', 'ARG', 'AST', 'CAN', 'CAM', 'CAL', 'CAT', 'CVA',
				 'EXT', 'GAL', 'IBA', 'ICA', 'MAD', 'MUR', 'NAV', 'PVA', 'RIO']
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
		if self.prov and self.prov in ['CVA', 'MUR', 'MAD', 'NAV', 'PVA']:
			t_holiday.datestamp := make_date(t_year, MAR, 19);
			t_holiday.description := 'San José';
			RETURN NEXT t_holiday;
		if self.prov and self.prov != 'CAT':
			self[easter(year) + rd(weeks=-1, weekday=TH)] = 'Jueves Santo'
		self[easter(year) + rd(weeks=-1, weekday=FR)] = 'Viernes Santo'
		if self.prov and self.prov in ['CAT', 'PVA', 'NAV', 'CVA', 'IBA']:
			self[easter(year) + rd(weekday=MO)] = 'Lunes de Pascua'
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajador';
		RETURN NEXT t_holiday;
		if self.prov and self.prov in ['CAT', 'GAL']:
			t_holiday.datestamp := make_date(t_year, JUN, 24);
		t_holiday.description := 'San Juan';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, AUG, 15);
		t_holiday.description := 'Asunción de la Virgen';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, OCT, 12);
		t_holiday.description := 'Día de la Hispanidad';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, NOV, 1);
		t_holiday.description := 'Todos los Santos';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 6);
		t_holiday.description := 'Día de la constitución Española';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 8);
		t_holiday.description := 'La Inmaculada Concepción';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;
		if self.prov and self.prov in ['CAT', 'IBA']:
			t_holiday.datestamp := make_date(t_year, DEC, 26);
			t_holiday.description := 'San Esteban';
			RETURN NEXT t_holiday;
		-- Provinces festive day
		if self.prov:
			if self.prov == 'AND':
				t_holiday.datestamp := make_date(t_year, FEB, 28);
				t_holiday.description := 'Día de Andalucia';
				RETURN NEXT t_holiday;
			elif self.prov == 'ARG':
				t_holiday.datestamp := make_date(t_year, APR, 23);
				t_holiday.description := 'Día de San Jorge';
				RETURN NEXT t_holiday;
			elif self.prov == 'AST':
				t_holiday.datestamp := make_date(t_year, SEP, 8);
				t_holiday.description := 'Día de Asturias';
				RETURN NEXT t_holiday;
			elif self.prov == 'CAN':
				t_holiday.datestamp := make_date(t_year, FEB, 28);
				t_holiday.description := 'Día de la Montaña';
				RETURN NEXT t_holiday;
			elif self.prov == 'CAM':
				t_holiday.datestamp := make_date(t_year, FEB, 28);
				t_holiday.description := 'Día de Castilla - La Mancha';
				RETURN NEXT t_holiday;
			elif self.prov == 'CAL':
				t_holiday.datestamp := make_date(t_year, APR, 23);
				t_holiday.description := 'Día de Castilla y Leon';
				RETURN NEXT t_holiday;
			elif self.prov == 'CAT':
				t_holiday.datestamp := make_date(t_year, SEP, 11);
				t_holiday.description := 'Día Nacional de Catalunya';
				RETURN NEXT t_holiday;
			elif self.prov == 'CVA':
				t_holiday.datestamp := make_date(t_year, OCT, 9);
				t_holiday.description := 'Día de la Comunidad Valenciana';
				RETURN NEXT t_holiday;
			elif self.prov == 'EXT':
				t_holiday.datestamp := make_date(t_year, SEP, 8);
				t_holiday.description := 'Día de Extremadura';
				RETURN NEXT t_holiday;
			elif self.prov == 'GAL':
				t_holiday.datestamp := make_date(t_year, JUL, 25);
				t_holiday.description := 'Día Nacional de Galicia';
				RETURN NEXT t_holiday;
			elif self.prov == 'IBA':
				t_holiday.datestamp := make_date(t_year, MAR, 1);
				t_holiday.description := 'Día de las Islas Baleares';
				RETURN NEXT t_holiday;
			elif self.prov == 'ICA':
				t_holiday.datestamp := make_date(t_year, MAY, 30);
				t_holiday.description := 'Día de Canarias';
				RETURN NEXT t_holiday;
			elif self.prov == 'MAD':
				t_holiday.datestamp := make_date(t_year, MAY, 2);
				t_holiday.description := 'Día de Comunidad De Madrid';
				RETURN NEXT t_holiday;
			elif self.prov == 'MUR':
				t_holiday.datestamp := make_date(t_year, JUN, 9);
				t_holiday.description := 'Día de la Región de Murcia';
				RETURN NEXT t_holiday;
			elif self.prov == 'NAV':
				t_holiday.datestamp := make_date(t_year, SEP, 27);
				t_holiday.description := 'Día de Navarra';
				RETURN NEXT t_holiday;
			elif self.prov == 'PVA':
				t_holiday.datestamp := make_date(t_year, OCT, 25);
				t_holiday.description := 'Día del Páis Vasco';
				RETURN NEXT t_holiday;
			elif self.prov == 'RIO':
				t_holiday.datestamp := make_date(t_year, JUN, 9);
				t_holiday.description := 'Día de La Rioja';
				RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;