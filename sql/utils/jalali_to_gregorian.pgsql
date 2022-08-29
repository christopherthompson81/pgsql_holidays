------------------------------------------
------------------------------------------
-- Convert Jalali date to Gregorian date.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.jalali_to_gregorian(p_year INTEGER, p_month INTEGER, p_day INTEGER)
RETURNS DATE AS $$

DECLARE
	-- Julian Days
	t_jd INTEGER := holidays.jalali_to_julian(p_year, p_month, p_day);
	t_ord INTEGER := holidays.julian_to_ordinal(t_jd);
	t_date DATE := holidays.ordinal_to_gregorian(t_ord);

BEGIN
	RETURN t_date;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
