CREATE OR REPLACE FUNCTION holidays.yinli_leap_month(p_lunar_year INTEGER)
RETURNS INTEGER
AS $$

DECLARE
	START_YEAR INTEGER CONSTANT := 1901;
	t_yinli_month_days INTEGER[] := holidays.yinli_month_days_array();

BEGIN
	RETURN (t_yinli_month_days[p_lunar_year - START_YEAR] >> 16) & 15;
END;

$$ LANGUAGE plpgsql;