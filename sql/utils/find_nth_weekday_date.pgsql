------------------------------------------
------------------------------------------
-- Find the nth weekday forward or backward from a day.
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.find_nth_weekday_date(p_date DATE, p_dow INTEGER, p_nth INTEGER) RETURNS DATE AS $$

DECLARE
	t_divisor INTEGER;
	t_interval INTERVAL;

BEGIN
	-- Deal with the same day scenario (just return the same date)
	IF p_nth IN (1, -1) AND DATE_PART('dow', p_date)::INTEGER = p_dow THEN
		RETURN p_date;
	END IF;
	-- Deal with all other cases
	t_divisor := 7 + p_dow;
	IF p_nth > 0 THEN	
		t_interval := (((t_divisor - DATE_PART('dow', p_date)::INTEGER)%7)::TEXT || ' days')::INTERVAL;
		IF p_nth > 1 THEN
			t_interval := t_interval + (((p_nth - 1) * 7)::TEXT || ' days')::INTERVAL;
		END IF;
	ELSIF p_nth < 0 THEN
		t_interval :=  ((-1 * (7 - (t_divisor - DATE_PART('dow', p_date)::INTEGER)%7))::TEXT || ' days')::INTERVAL;
		IF p_nth < -1 THEN
			t_interval := t_interval + (((p_nth + 1) * 7)::TEXT || ' days')::INTERVAL;
		END IF;
	END IF;
	RETURN p_date + t_interval;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
