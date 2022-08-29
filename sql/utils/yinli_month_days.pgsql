CREATE OR REPLACE FUNCTION holidays.nongli_month_days(p_lunar_year INTEGER, p_lunar_month INTEGER)
RETURNS INTEGER
AS $$

DECLARE
	START_YEAR CONSTANT INTEGER := 1901;
	t_nongli_month_days INTEGER[] := holidays.nongli_month_days_array();

BEGIN
	RETURN 29 + ((t_nongli_month_days[p_lunar_year - START_YEAR] >> p_lunar_month) & 1);
END;

$$ LANGUAGE plpgsql;