------------------------------------------
------------------------------------------
-- Jurisdictional Authority Type
------------------------------------------
------------------------------------------
--
DO $$ BEGIN
	CREATE TYPE holidays.jurisdictional_authority AS ENUM (
		'federal',
		'national',
		'provincial',
		'state',
		'informal',
		'de_facto',
		'religious'
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
