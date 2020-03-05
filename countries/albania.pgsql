------------------------------------------
------------------------------------------
-- Albania Holidays
--
-- ISO 3166: Albania; AL; ALB;
--
-- Country names:
-- en: Albania
-- sq: Shqipëri
--
-- dayoff: sunday
--
-- langs: [sq]
--
-- Time zones:
-- - Europe/Tirane
--
-- regions:
-- '01':
--   name: Berat County
-- '02':
--   name: Durrës County
-- '03':
--   name: Elbasan County
-- '04':
--   name: Fier County
-- '05':
--   name: Gjirokastër County
-- '06':
--   name: Korçë County
-- '07':
--   name: Kukës County
-- '08':
--   name: Lezhë County
-- '09':
--   name: Dibër County
-- '10':
--   name: Shkodër County
-- '11':
--   name: Tirana County
-- '12':
--   name: Vlorë County
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Albania
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.albania(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Month Constants
	JANUARY INTEGER := 1;
	FEBRUARY INTEGER := 2;
	MARCH INTEGER := 3;
	APRIL INTEGER := 4;
	MAY INTEGER := 5;
	JUNE INTEGER := 6;
	JULY INTEGER := 7;
	AUGUST INTEGER := 8;
	SEPTEMBER INTEGER := 9;
	OCTOBER INTEGER := 10;
	NOVEMBER INTEGER := 11;
	DECEMBER INTEGER := 12;
	-- Weekday Constants
	SUNDAY INTEGER := 0;
	MONDAY INTEGER := 1;
	TUESDAY INTEGER := 2;
	WEDNESDAY INTEGER := 3;
	THURSDAY INTEGER := 4;
	FRIDAY INTEGER := 5;
	SATURDAY INTEGER := 6;
	WEEKEND INTEGER[] := ARRAY[0, 6];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		t_holiday.start_time := '00:00:00'::TIME;
		t_holiday.end_time := '24:00:00'::TIME;

		t_datestamp := holidays.easter(t_year, 'EASTER_ORTHODOX');

		-- New Years
		t_holiday.reference := 'New Year''s Day';
		t_holiday.datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.description := 'Viti i Ri';
		RETURN NEXT t_holiday;

		-- en: New Year's Day
		-- sq: Viti i Ri
		-- 01-01 and if sunday then next tuesday:
		-- substitute: true

		-- en: New Year Holiday
		-- sq: Festa e Vitit të Ri
		-- 01-02 and if sunday then next monday:
		-- substitute: true

		-- en: League of Lezhë day
		-- sq: Dita e Besëlidhjes së Lezhës
		-- 03-02:
		-- type: observance

		-- en: Teacher's Day
		-- sq: Dita e Mësuesit
		-- 03-07:
		-- type: observance

		-- 03-08:
		-- _name: Mothers Day
		-- type: observance

		-- 03-14 and if sunday then next monday:
		-- name:
		-- sq: Dita e Verës
		-- en: Summer Day
		-- substitute: true

		-- 03-22 and if sunday then next monday:
		-- name:
		-- sq: Dita e Sulltan Nevruzit
		-- en: Sultan Nevruz's Day
		-- substitute: true

		-- 04-01:
		-- _name: 04-01 -- sq: Dita e Gënjeshtrave; en: April Fools' Day
		-- type: observance
		-- easter:
		-- name:
		-- sq: Pashkët Katolike
		-- en: Catholic Easter

		-- easter 1:
		-- name:
		-- sq: Pashkët Katolike
		-- en: Catholic Easter

		-- orthodox:
		-- name:
		-- sq: Pashkët Ortodokse
		-- en: Orthodox Easter

		-- orthodox 1:
		-- name:
		-- sq: Pashkët Ortodokse
		-- en: Orthodox Easter

		-- 05-01 and if sunday then next monday:
		-- _name: 05-01
		-- sq: Dita Ndërkombëtare e Punonjësve
		-- en: Labour Day
		-- substitute: true

		-- 06-01:
		-- name:
		-- sq: Dita Ndërkombëtare e Fëmijëve
		-- en: Children's Day
		-- type: observance

		-- 10-19 and if sunday then next monday:
		-- name:
		-- sq: Dita e Nënë Terezës
		-- en: Mother Teresa Day
		-- substitute: true
		-- active:
		-- - from: 2004

		-- 11-22:
		-- name:
		-- sq: Dita e Alfabetit
		-- en: Alphabet Day
		-- type: observance

		-- 11-28 and if sunday then next monday:
		-- _name: Independence Day -- sq: Dita e Pavarësisë
		-- substitute: true

		-- 11-29 and if sunday then next monday:
		-- _name: Liberation Day -- sq: Dita e Çlirimit
		-- substitute: true

		-- 12-08 and if sunday then next monday:
		-- name:
		-- sq: Dita Kombëtare e Rinisë
		-- en: Youth Day
		-- substitute: true
		-- active:
		-- - from: 2010

		-- 12-24:
		-- _name: 12-24 
		-- sq: Nata e Krishtlindjes; en: Christmas Eve
		-- type: bank

		-- 12-25 and if sunday then next monday:
		-- _name: 12-25 
		-- sq: Krishtlindja; en: Christmas Day
		-- substitute: true

		-- 1 Shawwal:
		-- _name: 1 Shawwal 
		-- sq: Fitër Bajrami; en: End of Ramadan (Eid al-Fitr)

		-- 10 Dhu al-Hijjah:
		-- _name: 10 Dhu al-Hijjah 
		-- sq: Kurban Bajrami; en: Feast of the Sacrifice (Eid al-Adha)

	END LOOP;
END;

$$ LANGUAGE plpgsql;