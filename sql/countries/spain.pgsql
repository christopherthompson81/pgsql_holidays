------------------------------------------
------------------------------------------
-- Spain Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.spain(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Año nuevo';
		RETURN NEXT t_holiday;
		
		-- Epiphany
		t_holiday.reference := 'Epiphany';
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Epifanía del Señor';
		RETURN NEXT t_holiday;
		
		-- San Jose
		t_holiday.reference := 'San Jose';
		IF p_province IN ('CVA', 'MUR', 'MAD', 'NAV', 'PVA') THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 19);
			t_holiday.description := 'San José';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Related Holidays
		t_datestamp := holidays.easter(t_year);

		-- Maundy Thursday
		t_holiday.reference := 'Maundy Thursday';
		IF p_province != 'CAT' THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, THURSDAY, -1);
			t_holiday.description := 'Jueves Santo';
			RETURN NEXT t_holiday;
		END IF;
		
		-- Good Friday
		t_holiday.reference := 'Good Friday';
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Viernes Santo';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.reference := 'Easter Monday';
		IF p_province IN ('CAT', 'PVA', 'NAV', 'CVA', 'IBA') THEN
			t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, 1);
			t_holiday.description := 'Lunes de Pascua';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajador';
		RETURN NEXT t_holiday;

		-- Saint John the Baptist Day
		t_holiday.reference := 'Saint John the Baptist Day';
		IF p_province IN ('CAT', 'GAL') THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 24);
			t_holiday.description := 'San Juan';
			RETURN NEXT t_holiday;
		END IF;

		-- Assumption
		t_holiday.reference := 'Assumption';
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Asunción de la Virgen';
		RETURN NEXT t_holiday;

		-- Hispanic Day
		t_holiday.reference := 'Hispanic Day';
		t_holiday.datestamp := make_date(t_year, OCTOBER, 12);
		t_holiday.description := 'Día de la Hispanidad';
		RETURN NEXT t_holiday;

		-- All Saints' Day
		t_holiday.reference := 'All Saints'' Day';
		t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
		t_holiday.description := 'Todos los Santos';
		RETURN NEXT t_holiday;

		-- Constitution Day
		t_holiday.reference := 'Constitution Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 6);
		t_holiday.description := 'Día de la constitución Española';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		t_holiday.reference := 'Immaculate Conception';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 8);
		t_holiday.description := 'La Inmaculada Concepción';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.reference := 'Christmas Day';
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Navidad';
		RETURN NEXT t_holiday;

		-- St Stephen's Day
		t_holiday.reference := 'St Stephen''s Day';
		IF p_province IN ('CAT', 'IBA') THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.description := 'San Esteban';
			RETURN NEXT t_holiday;
		END IF;

		-- Provinces festive day
		t_holiday.reference := 'Provincial Holiday';
		t_holiday.authority := 'provincial';
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