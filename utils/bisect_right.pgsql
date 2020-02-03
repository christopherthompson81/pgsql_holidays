------------------------------------------
------------------------------------------
-- Return the index where to insert item x in list a, assuming a is sorted.
-- The return value i is such that all e in a[:i] have e <= x, and all e in
-- a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
-- insert just after the rightmost x already there.
-- Optional args lo (default 0) and hi (default len(a)) bound the
-- slice of a to be searched.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.bisect_right(
	a INTEGER[],
	x INTEGER,
	lo INTEGER DEFAULT 0,
	hi INTEGER DEFAULT NULL
)
RETURNS INTEGER AS $$

DECLARE
	t_lo INTEGER := lo;
	t_hi INTEGER := hi;
	t_mid INTEGER;

BEGIN
	-- Check date range
	IF lo < 0 THEN
		RAISE EXCEPTION 'lo must be non-negative --> %', lo;
	END IF;
	IF t_hi IS NULL THEN
		t_hi := ARRAY_LENGTH(a, 1);
	END IF;
	-- Find the insertion point
	LOOP
		t_mid := (t_lo + t_hi) / 2;
		IF x < a[t_mid] THEN
			t_hi := t_mid;
		ELSE
			lo := t_mid + 1;
		END IF;
		EXIT WHEN t_lo < t_hi;
	END LOOP;
	-- Return the insertion point to the right
	RETURN t_lo;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
