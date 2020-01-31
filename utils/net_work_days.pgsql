------------------------------------------
------------------------------------------
-- Find the number of work days (non-weekend days) between two dates, allow a holidays array
--
-- Example:
--
-- SELECT
--	holidays.net_work_days(
--		'2018-01-01'::DATE,
--		'2018-12-31'::DATE,
--		(
--			SELECT ARRAY(SELECT datestamp FROM holidays.canada('QC', 2018, 2018))
--		)
--	)
--
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.net_work_days(p_start_date DATE, p_end_date DATE, p_holidays DATE[]) RETURNS INTEGER AS $$

DECLARE
	t_return_value INTEGER;

BEGIN
	SELECT
		count(*)
	INTO
		t_return_value
	FROM
		generate_series(p_start_date, p_end_date, '1 day'::INTERVAL) datestamp
	WHERE
		DATE_PART('dow', datestamp) = ANY(ARRAY[1,2,3,4,5])
	AND NOT
		(datestamp = ANY(p_holidays));
	RETURN t_return_value;
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
