------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://es.wikipedia.org/wiki/Anexo:D%C3%ADas_festivos_en_Colombia
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

		-- Fixed date holidays!
		-- If observed=True and they fall on a weekend they are not observed.
		-- If observed=False there are 18 holidays

		-- New Year's Day
		if date(year, JANUARY, 1).weekday() in WEEKEND:
			pass
		else:
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Año Nuevo [New Year''s Day]';
			RETURN NEXT t_holiday;

		-- Labor Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Día del Trabajo [Labour Day]';
		RETURN NEXT t_holiday;

		-- Independence Day
		name = 'Día de la Independencia [Independence Day]'
		if date(year, JUL, 20).weekday() in WEEKEND:
			pass
		else:
			self[date(year, JUL, 20)] = name

		-- Battle of Boyaca
		t_holiday.datestamp := make_date(t_year, AUG, 7);
		t_holiday.description := 'Batalla de Boyacá [Battle of Boyacá]';
		RETURN NEXT t_holiday;

		-- Immaculate Conception
		if date(year, DEC, 8).weekday() in WEEKEND:
			pass
		else:
			t_holiday.datestamp := make_date(t_year, DEC, 8);
			t_holiday.description := 'La Inmaculada Concepción' ' [Immaculate Conception]';
			RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Navidad [Christmas]';
		RETURN NEXT t_holiday;

		-- Emiliani Law holidays!
		-- Unless they fall on a Monday they are observed the following monday

		--  Epiphany
		name = 'Día de los Reyes Magos [Epiphany]'
		if date(year, JANUARY, 6).weekday() == MON or not self.observed:
			self[date(year, JANUARY, 6)] = name
		else:
			self[date(year, JANUARY, 6) + rd(weekday=MO)] = name + '(Observed)'

		-- Saint Joseph's Day
		name = 'Día de San José [Saint Joseph''s Day]'
		if date(year, MAR, 19).weekday() == MON or not self.observed:
			self[date(year, MAR, 19)] = name
		else:
			self[date(year, MAR, 19) + rd(weekday=MO)] = name + '(Observed)'

		-- Saint Peter and Saint Paul's Day
		name = 'San Pedro y San Pablo [Saint Peter and Saint Paul]'
		if date(year, JUN, 29).weekday() == MON or not self.observed:
			self[date(year, JUN, 29)] = name
		else:
			self[date(year, JUN, 29) + rd(weekday=MO)] = name + '(Observed)'

		-- Assumption of Mary
		name = 'La Asunción [Assumption of Mary]'
		if date(year, AUG, 15).weekday() == MON or not self.observed:
			self[date(year, AUG, 15)] = name
		else:
			self[date(year, AUG, 15) + rd(weekday=MO)] = name + '(Observed)'

		-- Discovery of America
		name = 'Descubrimiento de América [Discovery of America]'
		if date(year, OCT, 12).weekday() == MON or not self.observed:
			self[date(year, OCT, 12)] = name
		else:
			self[date(year, OCT, 12) + rd(weekday=MO)] = name + '(Observed)'

		-- All Saints’ Day
		name = 'Dia de Todos los Santos [All Saint''s Day]'
		if date(year, NOV, 1).weekday() == MON or not self.observed:
			self[date(year, NOV, 1)] = name
		else:
			self[date(year, NOV, 1) + rd(weekday=MO)] = name + '(Observed)'

		-- Independence of Cartagena
		name = 'Independencia de Cartagena [Independence of Cartagena]'
		if date(year, NOV, 11).weekday() == MON or not self.observed:
			self[date(year, NOV, 11)] = name
		else:
			self[date(year, NOV, 11) + rd(weekday=MO)] = name + '(Observed)'

		-- Holidays based on Easter

		-- Maundy Thursday
		self[easter(year) + rd(weekday=TH(-1))] = 'Jueves Santo [Maundy Thursday]'

		-- Good Friday
		self[easter(year) + rd(weekday=FR(-1))] = 'Viernes Santo [Good Friday]'

		-- Holidays based on Easter but are observed the following monday
		-- (unless they occur on a monday)

		-- Ascension of Jesus
		name = 'Ascensión del señor [Ascension of Jesus]'
		hdate = easter(year) + rd(days=+39)
		if hdate.weekday() == MON or not self.observed:
			self[hdate] = name
		else:
			self[hdate + rd(weekday=MO)] = name + '(Observed)'

		-- Corpus Christi
		name = 'Corpus Christi [Corpus Christi]'
		hdate = easter(year) + rd(days=+60)
		if hdate.weekday() == MON or not self.observed:
			self[hdate] = name
		else:
			self[hdate + rd(weekday=MO)] = name + '(Observed)'

		-- Sacred Heart
		name = 'Sagrado Corazón [Sacred Heart]'
		hdate = easter(year) + rd(days=+68)
		if hdate.weekday() == MON or not self.observed:
			self[hdate] = name
		else:
			self[hdate + rd(weekday=MO)] = name + '(Observed)'

	END LOOP;
END;

$$ LANGUAGE plpgsql;