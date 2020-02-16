------------------------------------------
------------------------------------------
-- Convert a Gregorian date to a Gregorian Ordinal
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.gregorian_to_ordinal(p_year INTEGER, p_month INTEGER, p_day INTEGER)
RETURNS DATE AS $$

DECLARE
	t_month INTEGER := (p_month + 9) % 12;
	t_year INTEGER := p_year - (t_month / 10);
	t_ord INTEGER;

BEGIN
	t_ord := 365 * t_year;
	t_ord := t_ord + t_year / 4
	t_ord := t_ord - t_year / 100
	t_ord := t_ord + t_year / 400
	t_ord := t_ord + (t_month * 306 + 5) / 10
	t_ord := t_ord + (p_day - 1);

	RETURN t_ord;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
