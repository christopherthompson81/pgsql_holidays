------------------------------------------
------------------------------------------
-- Return the index where to insert item x in list a, assuming a is sorted.
-- The return value i is such that all e in a[:i] have e <= x, and all e in
-- a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
-- insert just after the rightmost x already there.
-- Optional args lo (default 0) and hi (default len(a)) bound the
-- slice of a to be searched.
--
-- Arrays in PL/pgSQL are 1 indexed;
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.get_vernal_equinox(p_year INTEGER)
RETURNS DATE AS $$

DECLARE
	t_date DATE;
	t_day INTEGER := 20;

BEGIN
	-- Vernal Equinox Day
	IF p_year % 4 = 0 THEN
		IF p_year <= 1956 THEN
			t_day := 21;
		ELSIF t_year >= 2092 THEN
			t_day := 19;
		END IF;
	ELSIF p_year % 4 = 1 THEN
		IF p_year <= 1989 THEN
			t_day := 21;
		END IF;
	ELSIF p_year % 4 = 2 THEN
		IF p_year <= 2022 THEN
			t_day := 21;
		END IF;
	ELSIF p_year % 4 = 3 THEN
		IF p_year <= 2055 THEN
			t_day := 21;
		END IF;
	END IF;
	t_date := make_date(t_year, MARCH, t_day);
	RETURN t_date;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;


		