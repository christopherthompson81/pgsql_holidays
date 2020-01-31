------------------------------------------
------------------------------------------
-- Find Easter Sunday
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.easter(p_year INTEGER) RETURNS DATE AS $$

DECLARE
	epact_calc INTEGER := (24 + 19 * (p_year % 19)) % 30;
	paschal_days_calc INTEGER := epact_calc - (epact_calc / 28);
	num_of_days_to_sunday INTEGER := paschal_days_calc - ((p_year + p_year / 4 + paschal_days_calc - 13) % 7);
	easter_month INTEGER := 3 + (num_of_days_to_sunday + 40) / 44;
	easter_day INTEGER := num_of_days_to_sunday + 28 - (31 * (easter_month / 4));

BEGIN
	RETURN make_date(p_year, easter_month, easter_day);
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
