CREATE OR REPLACE FUNCTION holidays.nongli_year_days(p_year INTEGER)
RETURNS INTEGER
AS $$

DECLARE
	START_YEAR INTEGER CONSTANT := 1901;
	t_nongli_month_days INTEGER[] := holidays.nongli_month_days_array();

	t_days INTEGER := 0;
	t_months_day := t_nongli_month_days[p_year - START_YEAR];
	t_month INTEGER;
	t_months INTEGER[];
	t_day INTEGER;
	month_limit INTEGER := 14;

BEGIN
	IF holidays.nongli_leap_month(p_year) = 15 THEN
		month_limit := 13;
	END IF;
	t_months INTEGER[] := (SELECT ARRAY(SELECT generate_series(1, month_limit)));
	
	FOREACH t_month IN ARRAY t_months
	LOOP
		t_day := 29 + ((t_months_day >> t_month) & 1);
		t_days := t_days + t_day;
	END LOOP;
	RETURN t_days;
END;

$$ LANGUAGE plpgsql;