------------------------------------------
------------------------------------------
-- Convert a Julian day count to a Gregorian Ordinal
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.julian_to_ordinal(p_jd INTEGER)
RETURNS INTEGER AS $$

DECLARE
	t_ord INTEGER := p_jd - 1721425;

BEGIN
	RETURN t_ord;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
