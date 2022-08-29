
------------------------------------------
------------------------------------------
-- possible_gregorian_from_jalali
-- 
-- Returns the gregian date of the given gregorian calendar
-- yyyy year with Jalali Month & Day
--
-- Since this is for the holidays library, it also returns multiple dates when
-- the Jalali year is shorter than the Gregorian year and the Jalali day occurs
-- more than once in the same Gregorian year.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.possible_gregorian_from_jalali(p_year INTEGER, p_j_month INTEGER, p_j_day INTEGER)
RETURNS SETOF DATE AS $$

DECLARE
	t_h_year INTEGER := (SELECT year_value FROM holidays.gregorian_to_jalali(make_date(p_year, 1, 1)));
	t_datestamp DATE;

BEGIN
	t_datestamp := holidays.jalali_to_gregorian(t_h_year - 1, p_j_month, p_j_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
	t_datestamp := holidays.jalali_to_gregorian(t_h_year, p_j_month, p_j_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
	t_datestamp := holidays.jalali_to_gregorian(t_h_year + 1, p_j_month, p_j_day);
	IF DATE_PART('year', t_datestamp) = p_year THEN
		RETURN NEXT t_datestamp;
	END IF;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
