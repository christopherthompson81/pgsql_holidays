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
		'bank',
		'provincial',
		'state',
		'informal',
		'observance',
		'shortened_work_day',
		'optional',
		'de_facto',
		'religious',
		'extra_work_day',
		'municipal'
	);
EXCEPTION
	WHEN duplicate_object THEN null;
END $$;
