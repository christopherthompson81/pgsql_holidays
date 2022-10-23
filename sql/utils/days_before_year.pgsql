------------------------------------------
------------------------------------------
-- number of days before January 1st of year.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.days_before_year(p_year INTEGER) RETURNS INTEGER AS $$

DECLARE
	t_year INTEGER := p_year - 1;

BEGIN
	RETURN t_year*365 + t_year/4 - t_year/100 + t_year/400;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
