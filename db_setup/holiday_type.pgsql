------------------------------------------
------------------------------------------
-- Holiday type
------------------------------------------
------------------------------------------
--
DO $$ BEGIN
	CREATE TYPE holidays.holiday AS
	(
		datestamp DATE,
		description TEXT
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
