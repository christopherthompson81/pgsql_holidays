------------------------------------------
------------------------------------------
-- Convert Gregorian date to Hijri date.
--
-- Ported From:
-- https://github.com/pylover/khayyam/tree/master/khayyam
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.gregorian_to_jalali(p_date DATE)
RETURNS holidays.date_parts AS $$

DECLARE
	t_jd INTEGER := TO_CHAR(p_date, 'J')::INTEGER;

	t_offset INTEGER;
	t_cycle INTEGER;
	t_days_in_year INTEGER;
	t_remaining INTEGER;
	t_year_cycle INTEGER;
	t_a1 INTEGER;
	t_a2 INTEGER;
	
	t_year INTEGER;
	t_month INTEGER;
	t_day INTEGER;
	t_date_parts holidays.date_parts%ROWTYPE;

BEGIN
	t_offset := (t_jd::NUMERIC + 0.5) - 2121445.5;

	t_cycle := t_offset / 1029983;
	t_remaining := t_offset % 1029983;

	IF t_remaining = 1029982 THEN
		t_year_cycle = 2820;
	ELSE
		t_a1 := t_remaining / 366;
		t_a2 := t_remaining % 366;
		t_year_cycle := ((2134*t_a1 + 2816*t_a2 + 2815) / 1028522)::INTEGER + t_a1 + 1;
	END IF;

	t_year := t_year_cycle + 2820*t_cycle + 474;

	IF t_year <= 0 THEN
		t_year := t_year - 1;
	END IF;

	t_days_in_year := (t_jd - holidays.jalali_to_julian(t_year, 1, 1)) + 1;

	IF t_days_in_year <= 186 THEN
		t_month := CEILING(t_days_in_year::NUMERIC / 31.0)::INTEGER;
	ELSE
		t_month := CEILING((t_days_in_year - 6)::NUMERIC / 30.0)::INTEGER;
	END IF;

	t_day := (t_jd - holidays.jalali_to_julian(t_year, t_month, 1)) + 1;

	t_date_parts.year_value := t_year;
	t_date_parts.month_value := t_month;
	t_date_parts.day_value := t_day;

	RETURN t_date_parts;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
