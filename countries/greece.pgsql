------------------------------------------
------------------------------------------
-- Greece Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_Greece
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.greece(p_start_year INTEGER, p_end_year INTEGER)
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

		t_datestamp := holidays.easter(t_year, 'EASTER_ORTHODOX');

		-- New Years
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Πρωτοχρονιά [New Year''s Day]';
		RETURN NEXT t_holiday;
		
		-- Epiphany
		t_holiday.datestamp := make_date(t_year, JANUARY, 6);
		t_holiday.description := 'Θεοφάνεια [Epiphany]';
		RETURN NEXT t_holiday;

		-- Clean Monday
		t_holiday.datestamp := t_datestamp - '48 Days'::INTERVAL;
		t_holiday.description := 'Καθαρά Δευτέρα [Clean Monday]';
		RETURN NEXT t_holiday;

		-- Independence Day
		t_holiday.datestamp := make_date(t_year, MARCH, 25);
		t_holiday.description := 'Εικοστή Πέμπτη Μαρτίου [Independence Day]';
		RETURN NEXT t_holiday;

		-- Easter Monday
		t_holiday.datestamp := t_datestamp + '1 Days'::INTERVAL;
		t_holiday.description := 'Δευτέρα του Πάσχα [Easter Monday]';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Εργατική Πρωτομαγιά [Labour day]';
		RETURN NEXT t_holiday;

		-- Monday of the Holy Spirit
		t_holiday.datestamp := t_datestamp + '50 Days'::INTERVAL;
		t_holiday.description := 'Δευτέρα του Αγίου Πνεύματος [Monday of the Holy Spirit]';
		RETURN NEXT t_holiday;

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