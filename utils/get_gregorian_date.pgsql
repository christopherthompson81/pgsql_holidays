
------------------------------------------
------------------------------------------
--Returns the gregian date of the given gregorian calendar
--yyyy year with Hijari Month & Day
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.get_gregorian_date(p_year INTEGER, p_h_month INTEGER, p_h_day INTEGER
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



