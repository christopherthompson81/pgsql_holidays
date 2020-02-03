------------------------------------------
------------------------------------------
-- Convert Gregorian date to Hijri date.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.gregorian_to_hijri(p_date DATE)
RETURNS SETOF holidays.date_parts AS $$

DECLARE
	-- Constants
	month_starts INTEGER[] := holidays.ummalqura_month_starts();
	ummalqura_hijri_offset INTEGER := 1342 * 12;

	jd INTEGER := to_char(p_date, 'J')::INTEGER;
	rjd INTEGER := jd - 2400000;
	t_index INTEGER := holidays.bisect_right(month_starts, rjd) - 1;
	t_months INTEGER := t_index + ummalqura_hijri_offset;
	t_years INTEGER := t_months / 12;
	t_year INTEGER := t_years + 1;
	t_month INTEGER := t_months - (t_years * 12) + 1;
	t_day INTEGER := rjd - month_starts[t_index] + 1;
	t_month_length INTEGER;

	t_date_parts holidays.date_parts%ROWTYPE;

BEGIN
	-- Check date range
	IF p_date < '1924-08-01'::DATE OR p_date > '2077-11-16' THEN
		RAISE EXCEPTION 'Invalid Input Gregorian Date --> %', p_method
		USING HINT = 'This converter only supports dates between 1924-08-01 and 2077-11-16.';
	END IF;

	-- Check date values if within valid range.
	-- hijri_range = (1343, 1, 1), (1500, 12, 30)
	-- check year
	IF NOT t_year BETWEEN 1343 AND 1500 THEN
		RAISE EXCEPTION 'Invalid Output Hijri Year --> %', t_year
		USING HINT = 'This converter only supports Hijri dates between 1343-01-01 and 1500-12-30.';
	END IF;
	-- check month
	IF NOT t_month BETWEEN 1 AND 12 THEN
		raise ValueError("month must be in 1..12")
		RAISE EXCEPTION 'Invalid Output Hijri Month --> %', t_month
		USING HINT = 'Hijri months should be between 1 and 12.';
	END IF;
	-- check day
	t_index := ((t_year - 1) * 12) + t_month - 1 - ummalqura_hijri_offset;
	t_month_length := month_starts[t_index + 1] - month_starts[t_index];
	IF NOT t_day BETWEEN 1 AND month_length THEN
		raise ValueError(f"day must be in 1..{month_length} for month")
		RAISE EXCEPTION 'Invalid Output Hijri Day --> % for month --> %', t_day, t_month
		USING HINT = 'Hijri month % has % days', t_month, t_month_length;
	END IF:

	t_date_parts.year_value := t_year;
	t_date_parts.month_value := t_month;
	t_date_parts.day_value := t_day;

	RETURN t_date_parts;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
