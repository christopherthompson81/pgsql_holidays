------------------------------------------
------------------------------------------
-- <country> Holidays
-- Official holidays for Germany in its current form.
-- 
-- This class doesn't return any holidays before 1990-10-03.
-- 
-- Before that date the current Germany was separated into the 'German
-- Democratic Republic' and the 'Federal Republic of Germany' which both had
-- somewhat different holidays. Since this class is called 'Germany' it
-- doesn't really make sense to include the days from the two former
-- countries.
-- 
-- Note that Germany doesn't have rules for holidays that happen on a
-- Sunday. Those holidays are still holiday days but there is no additional
-- day to make up for the 'lost' day.
-- 
-- Also note that German holidays are partly declared by each province there
-- are some weired edge cases:
-- 
-- - 'Mariä Himmelfahrt' is only a holiday in Bavaria (BY) if your
-- municipality is mostly catholic which in term depends on census data.
-- Since we don't have this data but most municipalities in Bavaria
-- *are* mostly catholic, we count that as holiday for whole Bavaria.
-- - There is an 'Augsburger Friedensfest' which only exists in the town
-- Augsburg. This is excluded for Bavaria.
-- - 'Gründonnerstag' (Thursday before easter) is not a holiday but pupils
-- don't have to go to school (but only in Baden Württemberg) which is
-- solved by adjusting school holidays to include this day. It is
-- excluded from our list.
-- - 'Fronleichnam' is a holiday in certain, explicitly defined
-- municipalities in Saxony (SN) and Thuringia (TH). We exclude it from
-- both provinces.
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
	PROVINCES = ['BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW',
				 'RP', 'SL', 'SN', 'ST', 'SH', 'TH']
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

		if year <= 1989:
			return

		if year > 1990:

			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Neujahr';
			RETURN NEXT t_holiday;

			if self.prov in ('BW', 'BY', 'ST'):
				t_holiday.datestamp := make_date(t_year, JANUARY, 6);
				t_holiday.description := 'Heilige Drei Könige';
				RETURN NEXT t_holiday;

			self[easter(year) - rd(days=2)] = 'Karfreitag'

			if self.prov == 'BB':
				-- will always be a Sunday and we have no 'observed' rule so
				-- this is pretty pointless but it's nonetheless an official
				-- holiday by law
				self[easter(year)] = 'Ostersonntag'

			self[easter(year) + rd(days=1)] = 'Ostermontag'

			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Erster Mai';
			RETURN NEXT t_holiday;

			if self.prov == 'BE' and year == 2020:
				t_holiday.datestamp := make_date(t_year, MAY, 8);
				t_holiday.description := '75. Jahrestag der Befreiung vom Nationalsozialismus und der Beendigung des Zweiten Weltkriegs in Europa';
				RETURN NEXT t_holiday;

			self[easter(year) + rd(days=39)] = 'Christi Himmelfahrt'

			if self.prov == 'BB':
				-- will always be a Sunday and we have no 'observed' rule so
				-- this is pretty pointless but it's nonetheless an official
				-- holiday by law
				self[easter(year) + rd(days=49)] = 'Pfingstsonntag'

			self[easter(year) + rd(days=50)] = 'Pfingstmontag'

			if self.prov in ('BW', 'BY', 'HE', 'NW', 'RP', 'SL'):
				self[easter(year) + rd(days=60)] = 'Fronleichnam'

			if self.prov in ('BY', 'SL'):
				t_holiday.datestamp := make_date(t_year, AUG, 15);
				t_holiday.description := 'Mariä Himmelfahrt';
				RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, OCT, 3);
		t_holiday.description := 'Tag der Deutschen Einheit';
		RETURN NEXT t_holiday;

		if self.prov in ('BB', 'MV', 'SN', 'ST', 'TH'):
			t_holiday.datestamp := make_date(t_year, OCT, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;

		if self.prov in ('HB', 'SH', 'NI', 'HH') and year >= 2018:
			t_holiday.datestamp := make_date(t_year, OCT, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;

		-- in 2017 all states got the Reformationstag (500th anniversary of
		-- Luther's thesis)
		if year == 2017:
			t_holiday.datestamp := make_date(t_year, OCT, 31);
			t_holiday.description := 'Reformationstag';
			RETURN NEXT t_holiday;

		if self.prov in ('BW', 'BY', 'NW', 'RP', 'SL'):
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Allerheiligen';
			RETURN NEXT t_holiday;

		if year <= 1994 or self.prov == 'SN':
			-- can be calculated as 'last wednesday before year-11-23' which is
			-- why we need to go back two wednesdays if year-11-23 happens to be
			-- a wednesday
			base_data = date(year, NOV, 23)
			weekday_delta = WE(-2) if base_data.weekday() == 2 else WE(-1)
			self[base_data + rd(weekday=weekday_delta)] = 'Buß- und Bettag'

		if year >= 2019:
			if self.prov == 'TH':
				t_holiday.datestamp := make_date(t_year, SEP, 20);
				t_holiday.description := 'Weltkindertag';
				RETURN NEXT t_holiday;

			if self.prov == 'BE':
				t_holiday.datestamp := make_date(t_year, MAR, 8);
				t_holiday.description := 'Internationaler Frauentag';
				RETURN NEXT t_holiday;

		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Erster Weihnachtstag';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := make_date(t_year, DEC, 26);
		t_holiday.description := 'Zweiter Weihnachtstag';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;