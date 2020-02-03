------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Greece
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

eday = easter(year, method=EASTER_ORTHODOX)

		-- New Years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Πρωτοχρονιά [New Year''s Day]';
		RETURN NEXT t_holiday;
		-- Epiphany
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Θεοφάνεια [Epiphany]';
		RETURN NEXT t_holiday;

		-- Clean Monday
		self[eday - '48 Days'::INTERVAL] = 'Καθαρά Δευτέρα [Clean Monday]'

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, MARCH, 25);
		t_holiday.description := 'Εικοστή Πέμπτη Μαρτίου [Independence Day]';
		RETURN NEXT t_holiday;

		-- Easter Monday
		self[eday + '1 Days'::INTERVAL] = 'Δευτέρα του Πάσχα [Easter Monday]'

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Εργατική Πρωτομαγιά [Labour day]';
		RETURN NEXT t_holiday;

		-- Monday of the Holy Spirit
		self[eday + '50 Days'::INTERVAL] = 'Δευτέρα του Αγίου Πνεύματος [Monday of the Holy Spirit]'

		-- Assumption of Mary
		t_holiday.datestamp := make_date(t_year, AUGUST, 15);
		t_holiday.description := 'Κοίμηση της Θεοτόκου [Assumption of Mary]';
		RETURN NEXT t_holiday;

		-- Ochi Day
		t_holiday.datestamp := make_date(t_year, OCTOBER, 28);
		t_holiday.description := 'Ημέρα του Όχι [Ochi Day]';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.description := 'Χριστούγεννα [Christmas]';
		RETURN NEXT t_holiday;

		-- Day after Christmas
		t_holiday.datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.description := 'Επόμενη ημέρα των Χριστουγέννων [Day after Christmas]';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;