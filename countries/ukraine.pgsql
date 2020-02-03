------------------------------------------
------------------------------------------
-- <country> Holidays
--
-- http://zakon1.rada.gov.ua/laws/show/322-08/paran454--n454
-- 
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

		-- The current set of holidays came into force in 1991
		-- But most holiday days was inplemented in 1981
		IF t_year < 1918 THEN
			return
		END IF;

		-- New Year's Day
		IF t_year >= 1898 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 1);
			t_holiday.description := 'Новий рік';
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Day (Orthodox)
		IF t_year >= 1991 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 7);
			t_holiday.description := 'Різдво Христове (православне)';
			RETURN NEXT t_holiday;
		END IF;

		-- Women's Day
		IF t_year > 1965 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 8);
			t_holiday.description := 'Міжнародний жіночий день';
			RETURN NEXT t_holiday;
		END IF;

		-- Easter
		IF t_year >= 1991 THEN
			self[easter(year, method=EASTER_ORTHODOX)] = 'Пасха (Великдень)'
		END IF;

		-- Holy trinity
		IF t_year >= 1991 THEN
			self[easter(year, method=EASTER_ORTHODOX) + '49 Days'::INTERVAL] = 'Трійця'
		END IF;

		-- Labour Day
		IF t_year > 2017 THEN
			t_holiday.description := 'День праці';
		ELSIF 1917 < year <= 2017 THEN
			t_holiday.description := 'День міжнародної солідарності трудящих';
		END IF;
		t_holiday.datestamp := make_date(t_year, MAY, 1);
		RETURN NEXT t_holiday;

		-- Labour Day in past
		IF 1928 < year < 2018 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 2);
			t_holiday.description := 'День міжнародної солідарності трудящих';
			RETURN NEXT t_holiday;
		END IF;

		-- Victory Day
		t_holiday.description := 'День перемоги';
		IF t_year >= 1965 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			RETURN NEXT t_holiday;
		END IF;
		IF 1945 <= year < 1947 THEN
			t_holiday.datestamp := make_date(t_year, MAY, 9);
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 3);
			t_holiday.description := 'День перемоги над Японією';
			RETURN NEXT t_holiday;
		END IF;

		-- Constitution Day
		IF t_year >= 1997 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 28);
			t_holiday.description := 'День Конституції України';
			RETURN NEXT t_holiday;
		END IF;

		-- Independence Day
		t_holiday.description := 'День незалежності України';
		IF t_year > 1991 THEN
			t_holiday.datestamp := make_date(t_year, AUGUST, 24);
			RETURN NEXT t_holiday;
		ELSIF t_year == 1991 THEN
			t_holiday.datestamp := make_date(t_year, JULY, 16);
			RETURN NEXT t_holiday;
		END IF;

		-- Day of the defender of Ukraine
		IF t_year >= 2015 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 14);
			t_holiday.description := 'День захисника України';
			RETURN NEXT t_holiday;
		END IF;

		-- USSR Constitution day
		t_holiday.description := 'День Конституції СРСР';
		IF 1981 <= year < 1991 THEN
			t_holiday.datestamp := make_date(t_year, OCTOBER, 7);
			RETURN NEXT t_holiday;
		ELSIF 1937 <= year < 1981 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 5);
			RETURN NEXT t_holiday;
		END IF;

		-- October Revolution
		IF 1917 < year < 2000 THEN
			IF t_year <= 1991 THEN
				t_holiday.description := 'Річниця Великої Жовтневої соціалістичної революції';
			ELSE
				t_holiday.description := 'Річниця жовтневого перевороту';
			END IF;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 7);
			RETURN NEXT t_holiday;
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 8);
			RETURN NEXT t_holiday;
		END IF;

		-- Christmas Day (Catholic)
		IF t_year >= 2017 THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 25);
			t_holiday.description := 'Різдво Христове (католицьке)';
			RETURN NEXT t_holiday;
		END IF;

		-- USSR holidays
		-- Bloody_Sunday_(1905)
		IF 1917 <= year < 1951 THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 22);
			t_holiday.description := 'День пам''яті 9 січня 1905 року';
			RETURN NEXT t_holiday;
		END IF;

		-- Paris_Commune
		IF 1917 < year < 1929 THEN
			t_holiday.datestamp := make_date(t_year, MARCH, 18);
			t_holiday.description := 'День паризької комуни';
			RETURN NEXT t_holiday;
		END IF;

	END LOOP;
END;

$$ LANGUAGE plpgsql;