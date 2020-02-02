------------------------------------------
------------------------------------------
-- <country> Holidays
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
	PROVINCES = ['Métropole', 'Alsace-Moselle', 'Guadeloupe', 'Guyane',
				 'Martinique', 'Mayotte', 'Nouvelle-Calédonie', 'La Réunion',
				 'Polynésie Française', 'Saint-Barthélémy', 'Saint-Martin',
				 'Wallis-et-Futuna']
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

		-- Civil holidays
		if year > 1810:
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Jour de l''an';
			RETURN NEXT t_holiday;

		if year > 1919:
			name = 'Fête du Travail'
			if year <= 1948:
				name += ' et de la Concorde sociale'
			self[date(year, MAY, 1)] = name

		if (1953 <= year <= 1959) or year > 1981:
			t_holiday.datestamp := make_date(t_year, MAY, 8);
			t_holiday.description := 'Armistice 1945';
			RETURN NEXT t_holiday;

		if year >= 1880:
			t_holiday.datestamp := make_date(t_year, JUL, 14);
			t_holiday.description := 'Fête nationale';
			RETURN NEXT t_holiday;

		if year >= 1918:
			t_holiday.datestamp := make_date(t_year, NOV, 11);
			t_holiday.description := 'Armistice 1918';
			RETURN NEXT t_holiday;

		-- Religious holidays
		if self.prov in ['Alsace-Moselle', 'Guadeloupe', 'Guyane', 'Martinique', 'Polynésie Française']:
			self[easter(year) - rd(days=2)] = 'Vendredi saint'

		if self.prov == 'Alsace-Moselle':
			t_holiday.datestamp := make_date(t_year, DEC, 26);
			t_holiday.description := 'Deuxième jour de Noël';
			RETURN NEXT t_holiday;

		if year >= 1886:
			self[easter(year) + rd(days=1)] = 'Lundi de Pâques'
			self[easter(year) + rd(days=50)] = 'Lundi de Pentecôte'

		if year >= 1802:
			self[easter(year) + rd(days=39)] = 'Ascension'
			t_holiday.datestamp := make_date(t_year, AUG, 15);
			t_holiday.description := 'Assomption';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Toussaint';
			RETURN NEXT t_holiday;

			name = 'Noël'
			if self.prov == 'Alsace-Moselle':
				name = 'Premier jour de ' + name
			self[date(year, DEC, 25)] = name

		-- Non-metropolitan holidays (starting dates missing)
		if self.prov == 'Mayotte':
			t_holiday.datestamp := make_date(t_year, APR, 27);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

		if self.prov == 'Wallis-et-Futuna':
			t_holiday.datestamp := make_date(t_year, APR, 28);
			t_holiday.description := 'Saint Pierre Chanel';
			RETURN NEXT t_holiday;

		if self.prov == 'Martinique':
			t_holiday.datestamp := make_date(t_year, MAY, 22);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

		if self.prov in ['Guadeloupe', 'Saint-Martin']:
			t_holiday.datestamp := make_date(t_year, MAY, 27);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

		if self.prov == 'Guyane':
			t_holiday.datestamp := make_date(t_year, JUN, 10);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

		if self.prov == 'Polynésie Française':
			t_holiday.datestamp := make_date(t_year, JUN, 29);
			t_holiday.description := 'Fête de l''autonomie';
			RETURN NEXT t_holiday;

		if self.prov in ['Guadeloupe', 'Martinique']:
			t_holiday.datestamp := make_date(t_year, JUL, 21);
			t_holiday.description := 'Fête Victor Schoelcher';
			RETURN NEXT t_holiday;

		if self.prov == 'Wallis-et-Futuna':
			t_holiday.datestamp := make_date(t_year, JUL, 29);
			t_holiday.description := 'Fête du Territoire';
			RETURN NEXT t_holiday;

		if self.prov == 'Nouvelle-Calédonie':
			t_holiday.datestamp := make_date(t_year, SEP, 24);
			t_holiday.description := 'Fête de la Citoyenneté';
			RETURN NEXT t_holiday;

		if self.prov == 'Saint-Barthélémy':
			t_holiday.datestamp := make_date(t_year, OCT, 9);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

		if self.prov == 'La Réunion' and year >= 1981:
			t_holiday.datestamp := make_date(t_year, DEC, 20);
			t_holiday.description := 'Abolition de l''esclavage';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;