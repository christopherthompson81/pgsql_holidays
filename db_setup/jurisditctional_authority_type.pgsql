------------------------------------------
------------------------------------------
-- Jurisdictional Authority Type
------------------------------------------
------------------------------------------
--
DO $$ BEGIN
	CREATE TYPE holidays.jurisdictional_authority AS ENUM (
		'federal',
		'provincial',
		'state',
		'national',
		'informal',
		'de_facto'
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
