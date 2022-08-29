-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Chinese calendar
-- Officially known as the Lunar Calendar
--
-- Spelling and Iconographic represendations:
-- * 陰曆
-- * 阴历
-- * Yīnlì
-- * 'yin calendar'
--
-- In simple latin charachters, we will be referring to this as the "Yinli"
-- calendar when coding to distinguish it from calendars such as Hijri, Julian,
-- Jalali, Gregorian, and Hebrew. (Neither "Lunar", or "Chinese" felt
-- sufficiently precise to me.)
--
-- Other Chinese calendars include:
-- * Agricultural Calendar [農曆; 农历; Nónglì; 'farming calendar'])
-- * Former Calendar (舊曆; 旧历; Jiùlì)
-- * Traditional Calendar (老曆; 老历; Lǎolì)
--
-- The combination of calendars represents a complete lunisolar calandar
-- composite.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Store the number of days per year from 1901 to 2099, and the number of
-- days from the 1st to the 13th to store the monthly (including the month
-- of the month), 1 means that the month is 30 days. 0 means the month is
-- 29 days. The 12th to 15th digits indicate the month of the next month.
-- If it is 0x0F, it means that there is no leap month.
CREATE OR REPLACE FUNCTION holidays.yinli_month_days_array()
RETURNS INTEGER[]
AS $$

DECLARE
	-- Most of the consants declared here are not used anywhere, but are
	-- artifacts of the porting process

	-- The derived data
	t_yinli_month_days INTEGER[] := ARRAY[
		x'F0EA4'::INTEGER, x'F1D4A'::INTEGER, x'52C94'::INTEGER, x'F0C96'::INTEGER, x'F1536'::INTEGER,
		x'42AAC'::INTEGER, x'F0AD4'::INTEGER, x'F16B2'::INTEGER, x'22EA4'::INTEGER, x'F0EA4'::INTEGER,  -- 1901-1910
		x'6364A'::INTEGER, x'F164A'::INTEGER, x'F1496'::INTEGER, x'52956'::INTEGER, x'F055A'::INTEGER,
		x'F0AD6'::INTEGER, x'216D2'::INTEGER, x'F1B52'::INTEGER, x'73B24'::INTEGER, x'F1D24'::INTEGER,  -- 1911-1920
		x'F1A4A'::INTEGER, x'5349A'::INTEGER, x'F14AC'::INTEGER, x'F056C'::INTEGER, x'42B6A'::INTEGER,
		x'F0DA8'::INTEGER, x'F1D52'::INTEGER, x'23D24'::INTEGER, x'F1D24'::INTEGER, x'61A4C'::INTEGER,  -- 1921-1930
		x'F0A56'::INTEGER, x'F14AE'::INTEGER, x'5256C'::INTEGER, x'F16B4'::INTEGER, x'F0DA8'::INTEGER,
		x'31D92'::INTEGER, x'F0E92'::INTEGER, x'72D26'::INTEGER, x'F1526'::INTEGER, x'F0A56'::INTEGER,  -- 1931-1940
		x'614B6'::INTEGER, x'F155A'::INTEGER, x'F0AD4'::INTEGER, x'436AA'::INTEGER, x'F1748'::INTEGER,
		x'F1692'::INTEGER, x'23526'::INTEGER, x'F152A'::INTEGER, x'72A5A'::INTEGER, x'F0A6C'::INTEGER,  -- 1941-1950
		x'F155A'::INTEGER, x'52B54'::INTEGER, x'F0B64'::INTEGER, x'F1B4A'::INTEGER, x'33A94'::INTEGER,
		x'F1A94'::INTEGER, x'8152A'::INTEGER, x'F152E'::INTEGER, x'F0AAC'::INTEGER, x'6156A'::INTEGER,  -- 1951-1960
		x'F15AA'::INTEGER, x'F0DA4'::INTEGER, x'41D4A'::INTEGER, x'F1D4A'::INTEGER, x'F0C94'::INTEGER,
		x'3192E'::INTEGER, x'F1536'::INTEGER, x'72AB4'::INTEGER, x'F0AD4'::INTEGER, x'F16D2'::INTEGER,  -- 1961-1970
		x'52EA4'::INTEGER, x'F16A4'::INTEGER, x'F164A'::INTEGER, x'42C96'::INTEGER, x'F1496'::INTEGER,
		x'82956'::INTEGER, x'F055A'::INTEGER, x'F0ADA'::INTEGER, x'616D2'::INTEGER, x'F1B52'::INTEGER,  -- 1971-1980
		x'F1B24'::INTEGER, x'43A4A'::INTEGER, x'F1A4A'::INTEGER, x'A349A'::INTEGER, x'F14AC'::INTEGER,
		x'F056C'::INTEGER, x'60B6A'::INTEGER, x'F0DAA'::INTEGER, x'F1D92'::INTEGER, x'53D24'::INTEGER,  -- 1981-1990
		x'F1D24'::INTEGER, x'F1A4C'::INTEGER, x'314AC'::INTEGER, x'F14AE'::INTEGER, x'829AC'::INTEGER,
		x'F06B4'::INTEGER, x'F0DAA'::INTEGER, x'52D92'::INTEGER, x'F0E92'::INTEGER, x'F0D26'::INTEGER,  -- 1991-2000
		x'42A56'::INTEGER, x'F0A56'::INTEGER, x'F14B6'::INTEGER, x'22AB4'::INTEGER, x'F0AD4'::INTEGER,
		x'736AA'::INTEGER, x'F1748'::INTEGER, x'F1692'::INTEGER, x'53526'::INTEGER, x'F152A'::INTEGER,  -- 2001-2010
		x'F0A5A'::INTEGER, x'4155A'::INTEGER, x'F156A'::INTEGER, x'92B54'::INTEGER, x'F0BA4'::INTEGER,
		x'F1B4A'::INTEGER, x'63A94'::INTEGER, x'F1A94'::INTEGER, x'F192A'::INTEGER, x'42A5C'::INTEGER,  -- 2011-2020
		x'F0AAC'::INTEGER, x'F156A'::INTEGER, x'22B64'::INTEGER, x'F0DA4'::INTEGER, x'61D52'::INTEGER,
		x'F0E4A'::INTEGER, x'F0C96'::INTEGER, x'5192E'::INTEGER, x'F1956'::INTEGER, x'F0AB4'::INTEGER,  -- 2021-2030
		x'315AC'::INTEGER, x'F16D2'::INTEGER, x'B2EA4'::INTEGER, x'F16A4'::INTEGER, x'F164A'::INTEGER,
		x'63496'::INTEGER, x'F1496'::INTEGER, x'F0956'::INTEGER, x'50AB6'::INTEGER, x'F0B5A'::INTEGER,  -- 2031-2040
		x'F16D4'::INTEGER, x'236A4'::INTEGER, x'F1B24'::INTEGER, x'73A4A'::INTEGER, x'F1A4A'::INTEGER,
		x'F14AA'::INTEGER, x'5295A'::INTEGER, x'F096C'::INTEGER, x'F0B6A'::INTEGER, x'31B54'::INTEGER,  -- 2041-2050
		x'F1D92'::INTEGER, x'83D24'::INTEGER, x'F1D24'::INTEGER, x'F1A4C'::INTEGER, x'614AC'::INTEGER,
		x'F14AE'::INTEGER, x'F09AC'::INTEGER, x'40DAA'::INTEGER, x'F0EAA'::INTEGER, x'F0E92'::INTEGER,  -- 2051-2060
		x'31D26'::INTEGER, x'F0D26'::INTEGER, x'72A56'::INTEGER, x'F0A56'::INTEGER, x'F14B6'::INTEGER,
		x'52AB4'::INTEGER, x'F0AD4'::INTEGER, x'F16CA'::INTEGER, x'42E94'::INTEGER, x'F1694'::INTEGER,  -- 2061-2070
		x'8352A'::INTEGER, x'F152A'::INTEGER, x'F0A5A'::INTEGER, x'6155A'::INTEGER, x'F156A'::INTEGER,
		x'F0B54'::INTEGER, x'4174A'::INTEGER, x'F1B4A'::INTEGER, x'F1A94'::INTEGER, x'3392A'::INTEGER,  -- 2071-2080
		x'F192C'::INTEGER, x'7329C'::INTEGER, x'F0AAC'::INTEGER, x'F156A'::INTEGER, x'52B64'::INTEGER,
		x'F0DA4'::INTEGER, x'F1D4A'::INTEGER, x'41C94'::INTEGER, x'F0C96'::INTEGER, x'8192E'::INTEGER,  -- 2081-2090
		x'F0956'::INTEGER, x'F0AB6'::INTEGER, x'615AC'::INTEGER, x'F16D4'::INTEGER, x'F0EA4'::INTEGER,
		x'42E4A'::INTEGER, x'F164A'::INTEGER, x'F1516'::INTEGER, x'22936'::INTEGER           -- 2090-2099
	];

	-- Define range of years
	START_YEAR CONSTANT INTEGER := 1901;
	END_YEAR INTEGER = 1900 + ARRAY_LENGTH(yinli_month_days);

	-- 1901 The 1st day of the 1st month of the Gregorian calendar is 1901/2/19
	LUNAR_START_DATE DATE := (1901, 1, 1);
	SOLAR_START_DATE DATE := make_date(1901, 2, 19);

	-- The Gregorian date for December 30, 2099 is 2100/2/8
	LUNAR_END_DATE INTEGER := (2099, 12, 30);
	SOLAR_END_DATE INTEGER := make_date(2100, 2, 18);

BEGIN
	RETURN t_yinli_month_days;
END;

$$ LANGUAGE plpgsql;


















