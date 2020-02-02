------------------------------------------
------------------------------------------
-- <country> Holidays
-- https://en.wikipedia.org/wiki/Public_holidays_in_India
-- https://www.calendarlabs.com/holidays/india/
-- https://slusi.dacnet.nic.in/watershedatlas/list_of_state_abbreviation.htm
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_start_year INTEGER, p_end_year INTEGER)
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
	-- Provinces
	PROVINCES = ['AS', 'CG', 'SK', 'KA', 'GJ', 'BR', 'RJ', 'OD',
				 'TN', 'AP', 'WB', 'KL', 'HR', 'MH', 'MP', 'UP', 'UK', 'TS']
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

-- Pongal/ Makar Sankranti
		t_holiday.datestamp := make_date(t_year, JANUARY, 14);
		t_holiday.description := 'Makar Sankranti / Pongal';
		RETURN NEXT t_holiday;

		if year >= 1950:
			-- Republic Day
			t_holiday.datestamp := make_date(t_year, JANUARY, 26);
			t_holiday.description := 'Republic Day';
			RETURN NEXT t_holiday;

		if year >= 1947:
			-- Independence Day
			t_holiday.datestamp := make_date(t_year, AUG, 15);
			t_holiday.description := 'Independence Day';
			RETURN NEXT t_holiday;

		-- Gandhi Jayanti
		t_holiday.datestamp := make_date(t_year, OCT, 2);
		t_holiday.description := 'Gandhi Jayanti';
		RETURN NEXT t_holiday;

		-- Labour Day
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		t_holiday.description := 'Labour Day';
		RETURN NEXT t_holiday;

		-- Christmas
		t_holiday.datestamp := make_date(t_year, DEC, 25);
		t_holiday.description := 'Christmas';
		RETURN NEXT t_holiday;

		-- GJ: Gujarat
		if self.prov == 'GJ':
			t_holiday.datestamp := make_date(t_year, JANUARY, 14);
			t_holiday.description := 'Uttarayan';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Gujarat Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, OCT, 31);
			t_holiday.description := 'Sardar Patel Jayanti';
			RETURN NEXT t_holiday;

		if self.prov == 'BR':
			t_holiday.datestamp := make_date(t_year, MAR, 22);
			t_holiday.description := 'Bihar Day';
			RETURN NEXT t_holiday;

		if self.prov == 'RJ':
			t_holiday.datestamp := make_date(t_year, MAR, 30);
			t_holiday.description := 'Rajasthan Day';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, JUN, 15);
			t_holiday.description := 'Maharana Pratap Jayanti';
			RETURN NEXT t_holiday;

		if self.prov == 'OD':
			t_holiday.datestamp := make_date(t_year, APR, 1);
			t_holiday.description := 'Odisha Day (Utkala Dibasa)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APR, 15);
			t_holiday.description := 'Maha Vishuva Sankranti / Pana Sankranti';
			RETURN NEXT t_holiday;

		if self.prov in ('OD', 'AP', 'BR', 'WB', 'KL', 'HR', 'MH', 'UP', 'UK', 'TN'):
			t_holiday.datestamp := make_date(t_year, APR, 14);
			t_holiday.description := 'Dr. B. R. Ambedkar''s Jayanti';
			RETURN NEXT t_holiday;

		if self.prov == 'TN':
			t_holiday.datestamp := make_date(t_year, APR, 14);
			t_holiday.description := 'Puthandu (Tamil New Year)';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APR, 15);
			t_holiday.description := 'Puthandu (Tamil New Year)';
			RETURN NEXT t_holiday;

		if self.prov == 'WB':
			t_holiday.datestamp := make_date(t_year, APR, 14);
			t_holiday.description := 'Pohela Boishakh';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APR, 15);
			t_holiday.description := 'Pohela Boishakh';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			t_holiday.description := 'Rabindra Jayanti';
			RETURN NEXT t_holiday;

		if self.prov == 'AS':
			t_holiday.datestamp := make_date(t_year, APR, 15);
			t_holiday.description := 'Bihu (Assamese New Year)';
			RETURN NEXT t_holiday;

		if self.prov == 'MH':
			t_holiday.datestamp := make_date(t_year, MAY, 1);
			t_holiday.description := 'Maharashtra Day';
			RETURN NEXT t_holiday;

		if self.prov == 'SK':
			t_holiday.datestamp := make_date(t_year, MAY, 16);
			t_holiday.description := 'Annexation Day';
			RETURN NEXT t_holiday;

		if self.prov == 'KA':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Karnataka Rajyotsava';
			RETURN NEXT t_holiday;

		if self.prov == 'AP':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Andhra Pradesh Foundation Day';
			RETURN NEXT t_holiday;

		if self.prov == 'HR':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Haryana Foundation Day';
			RETURN NEXT t_holiday;

		if self.prov == 'MP':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Madhya Pradesh Foundation Day';
			RETURN NEXT t_holiday;

		if self.prov == 'KL':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Kerala Foundation Day';
			RETURN NEXT t_holiday;

		if self.prov == 'CG':
			t_holiday.datestamp := make_date(t_year, NOV, 1);
			t_holiday.description := 'Chhattisgarh Foundation Day';
			RETURN NEXT t_holiday;

		-- TS is Telangana State which was bifurcated in 2014 from AP
		-- (AndhraPradesh)
		if self.prov == 'TS':
			t_holiday.datestamp := make_date(t_year, OCT, 6);
			t_holiday.description := 'Bathukamma Festival';
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, APR, 6);
			t_holiday.description := 'Eid al-Fitr';
			RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;