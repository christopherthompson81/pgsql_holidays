------------------------------------------
------------------------------------------
-- date_parts type
------------------------------------------
------------------------------------------
--
DO $$ BEGIN
	CREATE TYPE holidays.date_parts AS
	(
		year_value INTEGER,
		month_value INTEGER,
		day_value INTEGER
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
