------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Hungary
	-- observed days off work around national holidays in the last 10 years:
	-- https://www.munkaugyiforum.hu/munkaugyi-segedanyagok/
	--	 2018-evi-munkaszuneti-napok-koruli-munkarend-9-2017-ngm-rendelet
	-- codification dates:
	-- - https://hvg.hu/gazdasag/
	--	  20170307_Megszavaztak_munkaszuneti_nap_lett_a_nagypentek
	-- - https://www.tankonyvtar.hu/hu/tartalom/historia/
	--	  92-10/ch01.html--id496839
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

		-- New years
		self._add_with_observed_day_off(date(year, JANUARY, 1), 'Újév', since=2014)

		-- National Day
		IF 1945 <= year <= 1950 or 1989 <= year THEN
			self._add_with_observed_day_off(date(year, MARCH, 15), 'Nemzeti ünnep')

		-- Soviet era
		IF 1950 <= year <= 1989 THEN
			-- Proclamation of Soviet socialist governing system
			t_holiday.datestamp := make_date(t_year, MARCH, 21);
			t_holiday.description := 'A Tanácsköztársaság kikiáltásának ünnepe';
			RETURN NEXT t_holiday;
			-- Liberation Day
			t_holiday.datestamp := make_date(t_year, APRIL, 4);
			t_holiday.description := 'A felszabadulás ünnepe';
			RETURN NEXT t_holiday;
			-- Memorial day of The Great October Soviet Socialist Revolution
			IF t_year not in (1956, 1989) THEN
				t_holiday.datestamp := make_date(t_year, NOVEMBER, 7);
				t_holiday.description := 'A nagy októberi szocialista forradalom ünnepe';
				RETURN NEXT t_holiday;

		easter_date = easter(year)

		-- Good Friday
		IF 2017 <= year THEN
			self[easter_date + rd(weekday=FR(-1))] = 'Nagypéntek'

		-- Easter
		self[easter_date] = 'Húsvét'

		-- Second easter day
		IF 1955 != year THEN
			self[easter_date + '1 Days'::INTERVAL] = 'Húsvét Hétfő'

		-- Pentecost
		self[easter_date + '49 Days'::INTERVAL] = 'Pünkösd'

		-- Pentecost monday
		IF t_year <= 1952 or 1992 <= year THEN
			self[easter_date + '50 Days'::INTERVAL] = 'Pünkösdhétfő'

		-- International Workers' Day
		IF 1946 <= year THEN
			self._add_with_observed_day_off(
				date(year, MAY, 1), 'A Munka ünnepe')
		IF 1950 <= year <= 1953 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'A Munka ünnepe';
			RETURN NEXT t_holiday;

		-- State Foundation Day (1771-????, 1891-)
		IF 1950 <= year < 1990 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 20);
		t_holiday.description := 'A kenyér ünnepe';
		RETURN NEXT t_holiday;
		ELSE
			self._add_with_observed_day_off(
				date(year, AUGUST, 20), 'Az államalapítás ünnepe')

		-- National Day
		IF 1991 <= year THEN
			self._add_with_observed_day_off(
				date(year, OCTOBER, 23), 'Nemzeti ünnep')

		-- All Saints' Day
		IF 1999 <= year THEN
			self._add_with_observed_day_off(
				date(year, NOVEMBER, 1), 'Mindenszentek')

		-- Christmas Eve is not endorsed officially
		-- but nowadays it is usually a day off work
		IF 2010 <= year and date(year, DECEMBER, 24).weekday() not in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 24);
			t_holiday.description := 'Szenteste';
			RETURN NEXT t_holiday;

		-- First christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Karácsony';
		RETURN NEXT t_holiday;

		-- Second christmas
		IF 1955 != year THEN
			self._add_with_observed_day_off(
				date(year, DECEMBER, 26), 'Karácsony másnapja', since=2013,
				before=False, after=True)

		-- New Year's Eve
		IF 2014 <= year and date(year, DECEMBER, 31).weekday() == MON THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 31);
			t_holiday.description := 'Szilveszter';
			RETURN NEXT t_holiday;

	def _add_with_observed_day_off(self, day, desc, since=2010, before=True, after=True):
		-- Swapped days off were in place earlier but
		-- I haven't found official record yet.
		self[day] = desc
		-- TODO: should it be a separate flag?
		IF since <= day.year THEN
			IF day.weekday() == TUE and before THEN
				self[day - '1 Days'::INTERVAL] = desc + ' előtti pihenőnap'
			elIF day.weekday() == THU and after THEN
				self[day + '1 Days'::INTERVAL] = desc + ' utáni pihenőnap'

	END LOOP;
END;

$$ LANGUAGE plpgsql;