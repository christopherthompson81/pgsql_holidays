------------------------------------------
------------------------------------------
-- Egypt Holidays
--
-- Holidays here are estimates, it is common for the day to be pushed
-- if falls in a weekend, although not a rule that can be implemented.
--
-- Holidays after 2020: the following four moving date holidays whose exact
-- date is announced yearly are estimated (and so denoted):
-- - Eid El Fetr*
-- - Eid El Adha*
-- - Arafat Day*
-- - Moulad El Naby*
-- *only if hijri-converter library is installed, otherwise a warning is
--  raised that this holiday is missing. hijri-converter requires
--  Python >= 3.6
--
-- is_weekend function is there, however not activated for accuracy.
--
--def is_weekend(self, hol_date, hol_name):
--	--Function to store the holiday name in the appropriate
--	--date and to shift the Public holiday in case it happens
--	--on a Saturday(Weekend)
--	IF hol_date.weekday() == FRI THEN
--		self[hol_date] = hol_name + ' [Friday]'
--		self[hol_date + '+2 Days'::INTERVAL] = 'Sunday following ' + hol_name
--	ELSE
--		self[hol_date] = hol_name
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.egypt(p_start_year INTEGER, p_end_year INTEGER)
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
		t_holiday.description := 'New Year''s Day - Bank Holiday';
		RETURN NEXT t_holiday;

		-- Coptic Christmas
		t_holiday.datestamp := make_date(t_year, JANUARY, 7);
		t_holiday.description := 'Coptic Christmas';
		RETURN NEXT t_holiday;

		-- 25th of Jan
		IF t_year >= 2012 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 25);
			t_holiday.description := 'Revolution Day - January 25';
			RETURN NEXT t_holiday;
		ELSIF t_year >= 2009 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 25);
			t_holiday.description := 'Police Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Coptic Easter - Orthodox Easter
		self[easter(year, 'EASTER_ORTHODOX')] = 'Coptic Easter Sunday'

		-- Sham El Nessim - Spring Festival
		self[easter(year, 'EASTER_ORTHODOX') + '1 Days'::INTERVAL] = 'Sham El Nessim'

		-- Sinai Libration Day
		IF t_year > 1982 THEN
			t_holiday.datestamp := make_date(t_year, APRIL, 25);
			t_holiday.description := 'Sinai Liberation Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		RETURN NEXT t_holiday;

		-- Armed Forces Day
		t_holiday.datestamp := make_date(t_year, OCTOBER, 6);
		t_holiday.description := 'Armed Forces Day';
		RETURN NEXT t_holiday;

		-- 30 June Revolution Day
		IF t_year >= 2014 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 30);
			t_holiday.description := '30 June Revolution Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Revolution Day
		IF t_year > 1952 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 23);
			t_holiday.description := 'Revolution Day';
			RETURN NEXT t_holiday;
		END IF;

		-- Eid al-Fitr - Feast Festive
		-- date of observance is announced yearly, This is an estimate since
		-- having the Holiday on Weekend does change the number of days,
		-- deceided to leave it since marking a Weekend as a holiday
		-- wouldn't do much harm.
		for date_obs in self.get_gre_date(year, 10, 1):
			hol_date = date_obs
			self[hol_date] = 'Eid al-Fitr'
			self[hol_date + '1 Days'::INTERVAL] = 'Eid al-Fitr Holiday'
			self[hol_date + '2 Days'::INTERVAL] = 'Eid al-Fitr Holiday'

		-- Arafat Day & Eid al-Adha - Scarfice Festive
		-- date of observance is announced yearly
		for date_obs in self.get_gre_date(year, 12, 9):
			hol_date = date_obs
			self[hol_date] = 'Arafat Day'
			self[hol_date + '1 Days'::INTERVAL] = 'Eid al-Fitr'
			self[hol_date + '2 Days'::INTERVAL] = 'Eid al-Fitr Holiday'
			self[hol_date + '3 Days'::INTERVAL] = 'Eid al-Fitr Holiday'

		-- Islamic New Year - (hijari_year, 1, 1)
		for date_obs in self.get_gre_date(year, 1, 1):
			hol_date = date_obs
			self[hol_date] = 'Islamic New Year'

		-- Prophet Muhammad's Birthday - (hijari_year, 3, 12)
		for date_obs in self.get_gre_date(year, 3, 12):
			hol_date = date_obs
			self[hol_date] = 'Prophet Muhammad''s Birthday'

	END LOOP;
END;

$$ LANGUAGE plpgsql;