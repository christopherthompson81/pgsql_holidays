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
	PROVINCES = ['AG', 'AR', 'AI', 'BL', 'BS', 'BE', 'FR', 'GE', 'GL',
				 'GR', 'JU', 'LU', 'NE', 'NW', 'OW', 'SG', 'SH', 'SZ',
				 'SO', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH']
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

		-- public holidays
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Neujahrestag';
		RETURN NEXT t_holiday;

		if self.prov in ('AG', 'BE', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU',
						 'NE', 'OW', 'SH', 'SO', 'TG', 'VD', 'ZG', 'ZH'):
			t_holiday.datestamp := make_date(t_year, JANUARY, 2);
			t_holiday.description := 'Berchtoldstag';
			RETURN NEXT t_holiday;

		if self.prov in ('SZ', 'TI', 'UR'):
			t_holiday.datestamp := make_date(t_year, JANUARY, 6);
			t_holiday.description := 'Heilige Drei Könige';
			RETURN NEXT t_holiday;

		if self.prov == 'NE':
			t_holiday.datestamp := make_date(t_year, MAR, 1);
			t_holiday.description := 'Jahrestag der Ausrufung der Republik';
			RETURN NEXT t_holiday;

		if self.prov in ('NW', 'SZ', 'TI', 'UR', 'VS'):
			t_holiday.datestamp := make_date(t_year, MAR, 19);
			t_holiday.description := 'Josefstag';
			RETURN NEXT t_holiday;

		-- Näfelser Fahrt (first Thursday in April but not in Holy Week)
		if self.prov == 'GL' and year >= 1835:
			if ((date(year, APR, 1) + rd(weekday=FR)) !=
					(easter(year) - rd(days=2))):
				self[date(year, APR, 1) + rd(weekday=TH)] = 'Näfelser Fahrt'
			else:
				self[date(year, APR, 8) + rd(weekday=TH)] = 'Näfelser Fahrt'

		-- it's a Holiday on a Sunday
		self[easter(year)] = 'Ostern'

		-- VS don't have easter
		if self.prov != 'VS':
			self[easter(year) - rd(days=2)] = 'Karfreitag'
			self[easter(year) + rd(weekday=MO)] = 'Ostermontag'

		if self.prov in ('BL', 'BS', 'JU', 'NE', 'SH', 'SO', 'TG', 'TI',
						 'ZH'):
			t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Tag der Arbeit';
		RETURN NEXT t_holiday;

		self[easter(year) + rd(days=39)] = 'Auffahrt'

		-- it's a Holiday on a Sunday
		self[easter(year) + rd(days=49)] = 'Pfingsten'

		self[easter(year) + rd(days=50)] = 'Pfingstmontag'

		if self.prov in ('AI', 'JU', 'LU', 'NW', 'OW', 'SZ', 'TI', 'UR', 'VS', 'ZG'):
			self[easter(year) + rd(days=60)] = 'Fronleichnam'

		if self.prov == 'JU':
			t_holiday.datestamp := make_date(t_year, JUN, 23);
			t_holiday.description := 'Fest der Unabhängigkeit';
			RETURN NEXT t_holiday;

		if self.prov == 'TI':
			t_holiday.datestamp := make_date(t_year, JUN, 29);
			t_holiday.description := 'Peter und Paul';
			RETURN NEXT t_holiday;

		if year >= 1291:
			t_holiday.datestamp := make_date(t_year, AUG, 1);
			t_holiday.description := 'Nationalfeiertag';
			RETURN NEXT t_holiday;

		if self.prov in ('AI', 'JU', 'LU', 'NW', 'OW', 'SZ', 'TI', 'UR', 'VS', 'ZG'):
			t_holiday.datestamp := make_date(t_year, AUG, 15);
			t_holiday.description := 'Mariä Himmelfahrt';
			RETURN NEXT t_holiday;

		if self.prov == 'VD':
			-- Monday after the third Sunday of September
			dt = date(year, SEP, 1) + rd(weekday=SU(+3)) + rd(weekday=MO)
			self[dt] = 'Lundi du Jeûne'

		if self.prov == 'OW':
			t_holiday.datestamp := make_date(t_year, SEP, 25);
			t_holiday.description := 'Bruder Klaus';
			RETURN NEXT t_holiday;

		if self.prov in ('AI', 'GL', 'JU', 'LU', 'NW', 'OW', 'SG', 'SZ',
						 'TI', 'UR', 'VS', 'ZG'):
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Allerheiligen';
			RETURN NEXT t_holiday;

		if self.prov in ('AI', 'LU', 'NW', 'OW', 'SZ', 'TI', 'UR', 'VS',
						 'ZG'):
			t_holiday.datestamp := make_date(t_year, DEC, 8);
			t_holiday.description := 'Mariä Empfängnis';
			RETURN NEXT t_holiday;

		if self.prov == 'GE':
			t_holiday.datestamp := make_date(t_year, DEC, 12);
			t_holiday.description := 'Escalade de Genève';
			RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Weihnachten';
		RETURN NEXT t_holiday;

		if self.prov in ('AG', 'AR', 'AI', 'BL', 'BS', 'BE', 'FR', 'GL',
						 'GR', 'LU', 'NE', 'NW', 'OW', 'SG', 'SH', 'SZ',
						 'SO', 'TG', 'TI', 'UR', 'ZG', 'ZH'):
			t_holiday.datestamp := make_date(t_year, DEC, 26);
			t_holiday.description := 'Stephanstag';
			RETURN NEXT t_holiday;

		if self.prov == 'GE':
			t_holiday.datestamp := make_date(t_year, DEC, 31);
			t_holiday.description := 'Wiederherstellung der Republik';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;