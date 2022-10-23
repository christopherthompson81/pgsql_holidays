-- Calculate the Gregorian date according to the lunar calendar
CREATE OR REPLACE FUNCTION holidays.nongli_to_gregorian(p_year INTEGER, p_month INTEGER, p_day INTEGER)
RETURNS DATE
AS $$

DECLARE
	START_YEAR CONSTANT INTEGER := 1901;
	GREGORIAN_START_DATE CONSTANT DATE := make_date(1901, 2, 19);
	
	span_days INTEGER := 0;
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(START_YEAR, p_year)));
	t_year INTEGER;
	t_leap_month INTEGER;
	month_limit INTEGER;
	t_months INTEGER[];
	t_month INTEGER;

	t_date DATE;

BEGIN
	IF p_year < START_YEAR THEN
		RAISE EXCEPTION 'Invalid Input Year --> %', p_year
		USING HINT = 'This converter only supports Gregorian dates between 1901-01-01 and 2099-12-30.';
	END IF;
	
	FOREACH t_year IN ARRAY t_years
	LOOP
		span_days := span_days + holidays.nongli_year_days(t_year);
	END LOOP;
	t_leap_month = holidays.get_leap_month(p_year);
	month_limit := p_month;
	IF p_month > t_leap_month THEN
		month_limit := month_limit + 1;
	END IF;
	t_months := (SELECT ARRAY(SELECT generate_series(1, month_limit)));
	FOREACH t_month IN ARRAY t_months
	LOOP
		span_days := span_days + holidays.nongli_month_days(p_year, t_month);
	END LOOP;
	span_days := span_days + p_day - 1;
	t_date := GREGORIAN_START_DATE + (span_days::TEXT || ' Days')::INTERVAL;
	RETURN t_date;
END;

$$ LANGUAGE plpgsql;