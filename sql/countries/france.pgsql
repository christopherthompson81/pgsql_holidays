------------------------------------------
------------------------------------------
-- France Holidays
--
-- Official French holidays.
--
-- Some provinces have specific holidays, only those are included in the
-- PROVINCES, because these provinces have different administrative status,
-- which makes it difficult to enumerate.
--
-- For religious holidays usually happening on Sundays (Easter, Pentecost),
-- only the following Monday is considered a holiday.
--
-- Primary sources:
-- https://fr.wikipedia.org/wiki/Fêtes_et_jours_fériés_en_France
-- https://www.service-public.fr/particuliers/vosdroits/F2405
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.france(p_province TEXT, p_start_year INTEGER, p_end_year INTEGER)
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
		'Métropole', 'Alsace-Moselle', 'Guadeloupe', 'Guyane', 'Martinique',
		'Mayotte', 'Nouvelle-Calédonie', 'La Réunion', 'Polynésie Française',
		'Saint-Barthélémy', 'Saint-Martin', 'Wallis-et-Futuna'
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

		-- Civil holidays

		-- New Year's Day
		t_holiday.reference := 'New Year''s Day';
		IF t_year > 1810 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Jour de l''an';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.reference := 'Labour Day';
		IF t_year > 1919 THEN
			t_holiday.description := 'Fête du Travail';
			IF t_year <= 1948 THEN
				t_holiday.description := 'Fête du Travail et de la Concorde sociale';
			END IF;
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			RETURN NEXT t_holiday;
		END IF;

		-- Victory in Europe Day
		t_holiday.reference := 'Victory in Europe Day';
		IF (t_year BETWEEN 1953 AND 1959) OR t_year > 1981 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 8);
			t_holiday.description := 'Armistice 1945';
			RETURN NEXT t_holiday;
		END IF;

		-- Bastille Day
		t_holiday.reference := 'Bastille Day';
		IF t_year >= 1880 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 14);
			t_holiday.description := 'Fête nationale';
			RETURN NEXT t_holiday;
		END IF;

		-- Remembrance Day
		t_holiday.reference := 'Remembrance Day';
		IF t_year >= 1918 THEN
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 11);
			t_holiday.description := 'Armistice 1918';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter Based Holidays
		t_datestamp := holidays.easter(t_year);

		-- Good Friday
		t_holiday.reference := 'Good Friday';
		IF p_province IN ('Alsace-Moselle', 'Guadeloupe', 'Guyane', 'Martinique', 'Polynésie Française') THEN
			t_holiday.datestamp := t_datestamp - '2 Days'::INTERVAL;
			t_holiday.description := 'Vendredi saint';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 1886 THEN
			-- Easter Monday
			t_holiday.reference := 'Easter Monday';
			t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
			t_holiday.description := 'Lundi de Pâques';
			RETURN NEXT t_holiday;

			-- Pentecost
			t_holiday.reference := 'Pentecost';
			t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
			t_holiday.description := 'Lundi de Pentecôte';
			RETURN NEXT t_holiday;
		END IF;

		IF t_year >= 1802 THEN
			-- Ascension Day
			t_holiday.reference := 'Ascension';
			t_holiday.datestamp := t_datestamp + '39 Days'::INTERVAL;
			t_holiday.description := 'Ascension';
			RETURN NEXT t_holiday;

			-- Assumption
			t_holiday.reference := 'Assumption';
			t_holiday.datestamp := make_date(t_year, AUGUST, 15);
			t_holiday.description := 'Assomption';
			RETURN NEXT t_holiday;

			-- All Saints' Day
			t_holiday.reference := 'All Saints'' Day';
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 1);
			t_holiday.description := 'Toussaint';
			RETURN NEXT t_holiday;

			-- Christmas Day
			t_holiday.reference := 'Christmas Day';
			t_holiday.description := 'Noël';
			IF p_province = 'Alsace-Moselle' THEN
				t_holiday.description := 'Premier jour de Noël';
			END IF;
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			RETURN NEXT t_holiday;
		END IF;

		-- Non-metropolitan holidays (starting dates missing)

		-- Second Day of Christmas
		t_holiday.reference := 'Second Day of Christmas';
		IF p_province = 'Alsace-Moselle' THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
			t_holiday.description := 'Deuxième jour de Noël';
			RETURN NEXT t_holiday;
		END IF;
		
		-- Citizenship Day
		t_holiday.reference := 'Citizenship Day';
		IF p_province = 'Nouvelle-Calédonie' THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 24);
			t_holiday.description := 'Fête de la Citoyenneté';
			RETURN NEXT t_holiday;
		END IF;

		-- Independance Day
		t_holiday.reference := 'Independance Day';
		IF p_province = 'Polynésie Française' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 29);
			t_holiday.description := 'Fête de l''autonomie';
			RETURN NEXT t_holiday;
		END IF;

		IF p_province = 'Wallis-et-Futuna' THEN
			-- Saint Pierre Chanel
			t_holiday.reference := 'Saint Pierre Chanel';
			t_holiday.datestamp := make_date(t_year, APRIL, 28);
			t_holiday.description := 'Saint Pierre Chanel';
			RETURN NEXT t_holiday;

			-- Territory Day
			t_holiday.reference := 'Territory Day';
			t_holiday.datestamp := make_date(t_year, JULY, 29);
			t_holiday.description := 'Fête du Territoire';
			RETURN NEXT t_holiday;
		END IF;

		-- Abolition of Slavery
		t_holiday.reference := 'Abolition of Slavery';
		t_holiday.description := 'Abolition de l''esclavage';
		IF p_province IN ('Guadeloupe', 'Saint-Martin') THEN
			t_holiday.datestamp := make_date(t_year, MAY, 27);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province = 'Guyane' THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 10);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province = 'La Réunion' AND t_year >= 1981 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 20);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province = 'Martinique' THEN
			t_holiday.datestamp := make_date(t_year, MAY, 22);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province = 'Mayotte' THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 27);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province = 'Saint-Barthélémy' THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 9);
			RETURN NEXT t_holiday;
		END IF;
		IF p_province IN ('Guadeloupe', 'Martinique') THEN
			t_holiday.datestamp := make_date(t_year, JULY, 21);
			t_holiday.description := 'Fête Victor Schoelcher';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;