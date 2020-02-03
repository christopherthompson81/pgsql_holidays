
------------------------------------------
------------------------------------------
-- possible_gregorian_from_hijri
-- 
-- Returns the gregian date of the given gregorian calendar
-- yyyy year with Hijari Month & Day
--
-- Since this is for the holidays library, it also returns multiple dates when
-- the Hijri year is shorter than the Gregorian year and the Hijri day occurs
-- more than once in the same Gregorian year.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.possible_gregorian_from_hijri(p_year INTEGER, p_h_month INTEGER, p_h_day INTEGER
RETURNS SETOF DATE AS $$

DECLARE
	t_h_year INTEGER := (SELECT year_value FROM holidays.gregorian_to_hijri(p_year, 1, 1));
	t_datestamp DATE;

BEGIN
	t_datestamp := hijri_to_gregorian(t_h_year - 1, p_h_month, p_h_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
	t_datestamp := hijri_to_gregorian(t_h_year, p_h_month, p_h_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
	t_datestamp := hijri_to_gregorian(t_h_year + 1, p_h_month, p_h_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;



