------------------------------------------
------------------------------------------
-- This module offers a generic easter computing method for any given year, using
-- Western, Orthodox or Julian algorithms.
------------------------------------------
-----------------------------------------
--
-- This method was ported from the work done by GM Arts,
-- on top of the algorithm by Claus Tondering, which was
-- based in part on the algorithm of Ouding (1940), as
-- quoted in "Explanatory Supplement to the Astronomical
-- Almanac", P. Kenneth Seidelmann, editor.
-- 
-- This algorithm implements three different easter
-- calculation methods:
-- 
-- 1 - Original calculation in Julian calendar, valid in
--     dates after 326 AD
-- 2 - Original method, with date converted to Gregorian
--     calendar, valid in years 1583 to 4099
-- 3 - Revised method, in Gregorian calendar, valid in
--     years 1583 to 4099 as well
--
-- These methods are represented by the constants:
-- 
-- * ``EASTER_JULIAN   = 1``
-- * ``EASTER_ORTHODOX = 2``
-- * ``EASTER_WESTERN  = 3``
-- 
-- The default method is method 3.
-- 
-- More about the algorithm may be found at:
-- 
-- `GM Arts: Easter Algorithms <http://www.gmarts.org/index.php?go=415>`_
-- 
-- and
-- 
-- `The Calendar FAQ: Easter <https://www.tondering.dk/claus/cal/easter.php>`_
--
CREATE OR REPLACE FUNCTION holidays.easter(p_year INTEGER, p_method TEXT DEFAULT 'EASTER_WESTERN') RETURNS DATE AS $$

DECLARE
	-- y - Year parameter
	y INTEGER := p_year;
	-- g - Golden year - 1
	g INTEGER := y % 19;
	-- e - Extra days to add for method 2 (converting Julian
    --     date to Gregorian date)
	e INTEGER := 0;
    -- c - Century
	c INTEGER := y / 100;
    -- h - (23 - Epact) mod 30
	h INTEGER := (c - c/4 - (8*c + 13)/25 + 19*g + 15) % 30;
    -- i - Number of days from March 21 to Paschal Full Moon
	i INTEGER;
	-- j - Weekday for PFM (0=Sunday, etc)
	j INTEGER;
    -- p - Number of days from March 21 to Sunday on or before PFM
    --     (-6 to 28 methods 1 & 3, to 56 for method 2)
	p INTEGER;
	-- Month
	easter_month INTEGER;
	-- Day of Month
	easter_day INTEGER;

BEGIN
	IF p_method NOT IN ('EASTER_JULIAN', 'EASTER_ORTHODOX', 'EASTER_WESTERN') THEN
		RAISE EXCEPTION 'Invalid Easter Calculation Method Specified --> %', p_method
		USING HINT = 'Please use one of "EASTER_JULIAN", "EASTER_ORTHODOX", or "EASTER_WESTERN"';
	END IF;

	IF p_method in ('EASTER_JULIAN', 'EASTER_ORTHODOX') THEN
        -- Old method
        i := (19*g + 15) % 30;
        j := (y + y/4 + i) % 7;
        IF p_method = 'EASTER_ORTHODOX' THEN
            -- Extra dates to convert Julian to Gregorian date
            e := 10;
            IF y > 1600 THEN
                e := e + y/100 - 16 - (y/100 - 16)/4;
			END IF;
		END IF;
    ELSE
        -- New method
        i := h - (h/28)*(1 - (h/28)*(29/(h + 1))*((21 - g)/11));
		j := (y + y/4 + i + 2 - c + c/4) % 7;
	END IF;

	-- p can be from -6 to 56 corresponding to dates 22 March to 23 May
    -- (later dates apply to method 2, although 23 May never actually occurs)
	p := i - j + e;

	-- Calendar Values
	easter_month := 3 + (p + 26)/30;
	easter_day := 1 + (p + 27 + (p + 6)/40) % 31;

	RETURN make_date(p_year, easter_month, easter_day);
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
