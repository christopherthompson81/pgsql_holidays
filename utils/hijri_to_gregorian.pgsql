------------------------------------------
------------------------------------------
-- Convert Hijri date to Gregorian date.
-- ord2ymd
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.hijri_to_gregorian(p_year INTEGER, p_month INTEGER, p_day INTEGER)
RETURNS DAYE AS $$

DECLARE
	-- Constants
	month_starts INTEGER[] := holidays.ummalqura_month_starts();
	ummalqura_hijri_offset INTEGER := 1342 * 12;
	_DI400Y INTEGER := holidays.days_before_year(401);	-- number of days in 400 years
	_DI100Y INTEGER := holidays.days_before_year(101);	--    "    "   "   " 100   "
	_DI4Y INTEGER := holidays.days_before_year(5);		--    "    "   "   "   4   "

	_DAYS_IN_MONTH = [-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	_DAYS_BEFORE_MONTH = [-1, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

	t_index INTEGER := ((p_year - 1) * 12) + p_month - 1 - ummalqura_hijri_offset;
	rjd INTEGER := month_starts[t_index] + p_day - 1;
	jd INTEGER := rjd + 2400000;
	
	n INTEGER;
	n400 INTEGER;
	n100 INTEGER;
	n4 INTEGER;
	n1 INTEGER;
	t_year INTEGER;
	t_leapyear1 BOOLEAN;
	t_leapyear2 BOOLEAN;
	t_month INTEGER;
	t_preceding INTEGER;
	t_day INTEGER;

BEGIN
	-- Convert Julian Day (JD) number to ordinal number.
	n := jd - 1721425;

	---------------------------------------------------------------------------
	-- Convert Ordinal value to date parts
	---------------------------------------------------------------------------

	-- ordinal -> (year, month, day), considering 01-Jan-0001 as day 1.
	--
	-- n is a 1-based index, starting at 1-Jan-1.  The pattern of leap years
	-- repeats exactly every 400 years.  The basic strategy is to find the
	-- closest 400-year boundary at or before n, then work with the offset
	-- from that boundary to n.  Life is much clearer if we subtract 1 from
	-- n first -- then the values of n at 400-year boundaries are exactly
	-- those divisible by _DI400Y:
	--
	--	 D  M   Y			n				n-1
	--	 -- --- ----		----------		----------------
	--	 31 Dec -400		-_DI400Y		-_DI400Y -1
	--	  1 Jan -399		-_DI400Y +1		-_DI400Y			400-year boundary
	--	 ...
	--	 30 Dec  000		-1			 	-2
	--	 31 Dec  000		0			 	-1
	--	  1 Jan  001		1			  	0					400-year boundary
	--	  2 Jan  001		2				1
	--	  3 Jan  001		3				2
	--	 ...
	--	 31 Dec  400		_DI400Y			_DI400Y -1
	--	  1 Jan  401		_DI400Y +1		_DI400Y				400-year boundary
	n := n - 1;
	n400 := div(n, _DI400Y);
	n := n % _DI400Y;

	-- Now n is the (non-negative) offset, in days, from January 1 of year, to
	-- the desired date.  Now compute how many 100-year cycles precede n.
	-- Note that it's possible for n100 to equal 4!  In that case 4 full
	-- 100-year cycles precede the desired day, which implies the desired
	-- day is December 31 at the end of a 400-year cycle.
	n100 := div(n, _DI100Y);
	n := n % _DI100Y;

	-- Now compute how many 4-year cycles precede it.
	n4 := div(n, _DI4Y);
	n := n % _DI4Y;

	-- And now how many single years.  Again n1 can be 4, and again meaning
	-- that the desired day is December 31 at the end of the 4-year cycle.
	n1 = div(n, 365);
	n = n % 365;

	t_year := (n400 * 400 + 1) + (n100 * 100) + (n4 * 4) + n1;
	IF n1 = 4 OR n100 = 4 THEN
		ASSERT n == 0;
		RETURN make_date(t_year-1, 12, 31);
	END IF;

	-- Now the year is correct, and n is the offset from January 1.  We find
	-- the month via an estimate that's either exact or one too large.
	t_leapyear1 := n1 = 3 AND (n4 != 24 OR n100 = 3);
	t_leapyear2 := t_year % 4 = 0 AND (t_year % 100 != 0 OR t_year % 400 = 0);
	ASSERT t_leapyear1 = t_leapyear2;
    
	t_month := (n + 50) >> 5;
	t_preceding = _DAYS_BEFORE_MONTH[month] + (CASE WHEN t_month > 2 AND t_leapyear1 THEN 1 ELSE 0 END);
	IF t_preceding > n THEN
		-- estimate is too large
		t_month := t_month - 1;
		t_preceding := t_preceding - _DAYS_IN_MONTH[month] + (CASE WHEN t_month = 2 AND t_leapyear1 THEN 1 ELSE 0 END);
	END IF;
	n := n - t_preceding;
	ASSERT 0 <= n < CASE WHEN t_month = 2 and (t_year % 100 != 0 OR t_year % 400 = 0) THEN 29 ELSE _DAYS_IN_MONTH[t_month] END;

	-- Now the year and month are correct, and n is the offset from the
	-- start of that month:  we're done!
	t_day := n + 1;

	RETURN make_date(t_year, t_month, t_day);
END;

$$ LANGUAGE plpgsql STRICT IMMUTABLE;
