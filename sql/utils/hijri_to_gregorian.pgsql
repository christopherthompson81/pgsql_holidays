------------------------------------------
------------------------------------------
-- Convert Hijri date to Gregorian date.
-- ord2ymd
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.hijri_to_gregorian(p_year INTEGER, p_month INTEGER, p_day INTEGER)
RETURNS DATE AS $$

DECLARE
	-- Constants
	month_starts INTEGER[] := holidays.ummalqura_month_starts();
	ummalqura_hijri_offset INTEGER := 1342 * 12;

	t_index INTEGER := ((p_year - 1) * 12) + p_month - ummalqura_hijri_offset;
	t_rjd INTEGER := month_starts[t_index] + p_day - 1;
	t_jd INTEGER := t_rjd + 2400000;
	
	t_ord INTEGER := holidays.julian_to_ordinal(t_jd);
	t_date DATE := holidays.ordinal_to_gregorian(t_ord);

BEGIN
	RETURN t_date;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
