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
		reference TEXT,
		description TEXT,
		authority holidays.jurisdictional_authority,
		day_off BOOLEAN,
		observation_shifted BOOLEAN,
		start_time TIME,
		end_time TIME
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
