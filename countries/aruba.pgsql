------------------------------------------
------------------------------------------
-- Aruba Holidays
-- http://www.gobierno.aw/informacion-tocante-servicio/vakantie-y-dia-di-fiesta_43437/item/dia-di-fiesta_14809.html
-- https://www.visitaruba.com/about-aruba/national-holidays-and-celebrations/
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.aruba(p_start_year INTEGER, p_end_year INTEGER)
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
		-- New Year's Day
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Aña Nobo [New Year''s Day]';
		RETURN NEXT t_holiday;

		-- Dia di Betico
		t_holiday.datestamp := make_date(t_year, JANUARY, 25);
		t_holiday.description := 'Dia Di Betico [Betico Day]';
		RETURN NEXT t_holiday;

		-- Carnaval Monday
		t_holiday.datestamp := holidays.easter(t_year) - '48 Days'::INTERVAL;
		t_holiday.description := 'Dialuna di Carnaval [Carnaval Monday]';
		RETURN NEXT t_holiday;

		-- Dia di Himno y Bandera
		t_holiday.datestamp := make_date(t_year, MARCH, 18);
		t_holiday.description := 'Dia di Himno y Bandera [National Anthem & Flag Day]';
		RETURN NEXT t_holiday;

		-- Good Friday
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FRIDAY, -1);
		t_holiday.description := 'Bierna Santo [Good Friday]';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.datestamp := holidays.easter(t_year) + '1 Day'::INTERVAL;
		t_holiday.description := 'Di Dos Dia di Pasco di Resureccion [Easter Monday]';
		RETURN NEXT t_holiday;

		-- King's Day
		IF t_year >= 2014 THEN
			t_datestamp := make_date(t_year, APRIL, 27);
			t_holiday.description := 'Aña di Rey [King''s Day]';
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				t_holiday.datestamp := t_datestamp - '1 Day'::INTERVAL;
				RETURN NEXT t_holiday;
			ELSE
				t_holiday.datestamp := t_datestamp;
				RETURN NEXT t_holiday;
			END IF;
		END IF;

		-- Queen's Day
		IF t_year BETWEEN 1891 AND 2013 THEN
			t_datestamp := make_date(t_year, APRIL, 30);
			IF t_year <= 1948 THEN
				t_datestamp := make_date(t_year, AUGUST, 31);
			END IF;
			IF DATE_PART('dow', t_datestamp) = SATURDAY THEN
				IF t_year < 1980 THEN
					t_datestamp := t_datestamp + '1 Day'::INTERVAL;
				ELSE
					t_datestamp := t_datestamp - '1 Day'::INTERVAL;
				END IF;
			END IF;
			t_holiday.datestamp := t_datestamp;
			t_holiday.description := 'Aña di La Reina [Queen''s Day]';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Dia di Obrero [Labour Day]';
		RETURN NEXT t_holiday;

		-- Ascension Day
		t_holiday.datestamp := holidays.easter(t_year) + '39 Days'::INTERVAL;
		t_holiday.description := 'Dia di Asuncion [Ascension Day]';
		RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Pasco di Nacemento [Christmas]';
		RETURN NEXT t_holiday;

		-- Second Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Di Dos Dia di Pasco di Nacemento [Second Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;