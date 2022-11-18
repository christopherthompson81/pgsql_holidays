------------------------------------------
------------------------------------------
-- Holiday by country
------------------------------------------
------------------------------------------
--
-- Available Countries
--
--|------------------------|-----------|---------------------------------------
-- Country					ISO code	Provinces/States Available
--|------------------------|-----------|---------------------------------------
-- Afghanistan				AF/AFG		PROVINCES = 'BAL', 'BAM', 'BDG', 'BDS', 'BGL', 'DAY', 'FRA', 'FYB', 'GHA', 'GHO', 'HEL', 'HER', 'JOW', 'KAB', 'KAN', 'KAP', 'KDZ', 'KHO', 'KNR', 'LAG', 'LOG', 'NAN', 'NIM', 'NUR', 'PAN', 'PAR', 'PIA', 'PKA', 'SAM', 'SAR', 'TAK', 'URU', 'WAR', 'ZAB'
-- Andorra					AD/AND		PROVINCES = 'Canillo', 'Encamp', 'La Massana', 'Ordino', 'Sant Julià de Lòria', 'Andorra la Vella'
-- Argentina				AR/ARG		None
-- Aruba					AW/ABW		None
-- Australia				AU/AUS		prov = ACT (default), NSW, NT, QLD, SA, TAS, VIC, WA
-- Austria					AT/AUT		prov = B, K, N, O, S, ST, T, V, W (default)
-- Belarus					BY/BLR		None
-- Belgium					BE/BEL		None
-- Brazil					BR/BRA		state = AC, AL, AP, AM, BA, CE, DF, ES, GO (default), MA, MT, MS, MG, PA, PB, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO
-- Bulgaria					BG/BLG		None
-- Canada					CA/CAN		prov = AB, BC, MB, NB, NL, NS, NT, NU, ON (default), PE, QC, SK, YU
-- Chile					CL/CHL		None
-- Colombia					CO/COL		None
-- Croatia					HR/HRV		None
-- Czechia					CZ/CZE		None
-- Denmark					DK/DNK		None
-- Dominican Republic		DO/DOM		None
-- Egypt					EG/EGY		None
-- Estonia					EE/EST		None
-- European Central Bank	ECB/TAR		None
-- Finland					FI/FIN		None
-- France					FR/FRA			prov = Métropole (default), Alsace-Moselle, Guadeloupe, Guyane, Martinique, Mayotte, Nouvelle-Calédonie, La Réunion, Polynésie Française, Saint-Barthélémy, Saint-Martin, Wallis-et-Futuna
-- Germany					DE/DEU		prov = BW, BY, BE, BB (default), HB, HH, HE, MV, NI, NW, RP, SL, SN, ST, SH, TH
-- Greece					GR/GRC		None
-- Honduras					HN/HND		None
-- Hong Kong				HK/HKG		None
-- Hungary					HU/HUN		None
-- Iceland					IS/ISL		None
-- India					IN/IND		prov = AS, SK, CG, KA, GJ, BR, RJ, OD, TN, AP, WB, KL, HR (default), MH, MP, UP, UK, TN
-- Ireland					IE/IRL		None
-- Israel					IL/ISR		None
-- Italy					IT/ITA		prov = AN, AO, BA, BL, BO, BS, BZ, CB, Cesena, CH, CS, CT, EN, FC, FE, FI, Forlì, FR, GE, GO, IS, KR, LT, MB, MI, MO, MN, MS, NA, PA, PC, PD, PG, PR, RM, SP, TS, VI
-- Japan					JP/JPN		None
-- Kenya					KE/KEN		None
-- Lithuania				LT/LTU		None
-- Luxembourg				LU/LUX		None
-- Mexico					MX/MEX		None
-- Netherlands				NL/NLD		None
-- NewZealand				NZ/NZL		prov = NTL, AUK, TKI, HKB, WGN, MBH, NSN, CAN, STC, WTL, OTA, STL, CIT
-- Nicaragua				NI/NIC		prov = MN
-- Nigeria					NG/NGA		None
-- Norway					NO/NOR		None
-- Paraguay					PY/PRY		None
-- Peru						PE/PER		None
-- Poland					PL/POL		None
-- Portugal					PT/PRT		None
-- Russia					RU/RUS		None
-- Serbia					RS/SRB		None
-- Singapore				SG/SGP		None
-- Slovakia					SK/SVK		None
-- Slovenia					SI/SVN		None
-- South Africa				ZA/ZAF		None
-- Spain					ES/ESP		prov = AND, ARG, AST, CAN, CAM, CAL, CAT, CVA, EXT, GAL, IBA, ICA, MAD (default), MUR, NAV, PVA, RIO
-- Sweden					SE/SWE		None
-- Switzerland				CH/CHE		prov = AG, AR, AI, BL, BS, BE, FR, GE, GL, GR, JU, LU, NE, NW, OW, SG, SH, SZ, SO, TG, TI, UR, VD, VS, ZG, ZH
-- Ukraine					UA/UKR		None
-- United Kingdom			UK/GB/GBR	country = England, Isle Of Man, Northern Ireland, Scotland, Wales
-- United States			US/USA		state = AL, AK, AS, AZ, AR, CA, CO, CT, DE, DC, FL, GA, GU, HI, ID, IL, IN, IA, KS, KY, LA, ME, MD, MH, MA, MI, FM, MN, MS, MO, MT, NE, NV, NH, NJ, NM, NY, NC, ND, MP, OH, OK, OR, PW, PA, PR, RI, SC, SD, TN, TX, UT, VT, VA, VI, WA, WV, WI, WY
--|------------------------|-----------|---------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.by_country(
	p_country TEXT,
	p_start_year INTEGER,
	p_end_year INTEGER,
	p_sub_region TEXT DEFAULT NULL
)
RETURNS SETOF holidays.holiday
AS $$

BEGIN
	CASE
		WHEN upper(p_country) IN ('AFGHANISTAN', 'AF', 'AFG') THEN
			RETURN QUERY (SELECT * FROM holidays.afghanistan(COALESCE(p_sub_region, ''), p_start_year, p_end_year));
		WHEN upper(p_country) IN ('ANDORRA', 'AN', 'AND') THEN
			RETURN QUERY (SELECT * FROM holidays.andorra(COALESCE(p_sub_region, ''), p_start_year, p_end_year));
		WHEN upper(p_country) IN ('ANGUILLA', 'AI', 'AIA') THEN
			RETURN QUERY (SELECT * FROM holidays.anguilla(p_start_year, p_end_year));
		WHEN upper(p_country) IN ('ANTIGUAANDBARBUDA', 'ANTIGUA AND BARBUDA', 'ANTIGUA_AND_BARBUDA', 'AG', 'ATG') THEN
			RETURN QUERY (SELECT * FROM holidays.antigua_and_barbuda(COALESCE(p_sub_region, ''), p_start_year, p_end_year));
		WHEN upper(p_country) IN ('ARGENTINA', 'AR', 'ARG') THEN
			RETURN QUERY (SELECT * FROM holidays.argentina(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ARUBA', 'AW', 'ABW') THEN
			RETURN QUERY (SELECT * FROM holidays.aruba(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('AUSTRALIA', 'AU', 'AUS') THEN
			RETURN QUERY (SELECT * FROM holidays.australia(COALESCE(p_sub_region, 'ACT'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('AUSTRIA', 'AT', 'AUT') THEN
			RETURN QUERY (SELECT * FROM holidays.austria(COALESCE(p_sub_region, 'W'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('BELARUS', 'BY', 'BLR') THEN
			RETURN QUERY (SELECT * FROM holidays.belarus(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('BELGIUM', 'BE', 'BEL') THEN
			RETURN QUERY (SELECT * FROM holidays.belgium(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('BRAZIL', 'BR', 'BRA') THEN
			RETURN QUERY (SELECT * FROM holidays.brazil(COALESCE(p_sub_region, 'GO'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('BULGARIA', 'BG', 'BLG') THEN
			RETURN QUERY (SELECT * FROM holidays.bulgaria(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('CANADA', 'CA', 'CAN') THEN
			RETURN QUERY (SELECT * FROM holidays.canada(COALESCE(p_sub_region, 'ON'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('CHILE', 'CL', 'CHL') THEN
			RETURN QUERY (SELECT * FROM holidays.chile(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('CHINA', 'CN', 'CHN') THEN
			RETURN QUERY (SELECT * FROM holidays.china(COALESCE(p_sub_region, 'Beijing'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('COLOMBIA', 'CO', 'COL') THEN
			RETURN QUERY (SELECT * FROM holidays.colombia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('CROATIA', 'HR', 'HRV') THEN
			RETURN QUERY (SELECT * FROM holidays.croatia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('CZECHIA', 'CZ', 'CZE', 'CZECH') THEN
			RETURN QUERY (SELECT * FROM holidays.czechia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('DENMARK', 'DK', 'DNK') THEN
			RETURN QUERY (SELECT * FROM holidays.denmark(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('DOMINICANREPUBLIC', 'DOMINICAN REPUBLIC', 'DOMINICAN_REPUBLIC', 'DO', 'DOM') THEN
			RETURN QUERY (SELECT * FROM holidays.dominican_republic(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('EGYPT', 'EG', 'EGY') THEN
			RETURN QUERY (SELECT * FROM holidays.egypt(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ENGLAND') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('England', p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ESTONIA', 'EE', 'EST') THEN
			RETURN QUERY (SELECT * FROM holidays.estonia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('EUROPEANCENTRALBANK', 'EUROPEAN CENTRAL BANK', 'EUROPEAN_CENTRAL_BANK', 'ECB', 'TAR') THEN
			RETURN QUERY (SELECT * FROM holidays.european_central_bank(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('FINLAND', 'FI', 'FIN') THEN
			RETURN QUERY (SELECT * FROM holidays.finland(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('FRANCE', 'FR', 'FRA') THEN
			RETURN QUERY (SELECT * FROM holidays.france(COALESCE(p_sub_region, 'Métropole'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('GERMANY', 'DE', 'DEU') THEN
			RETURN QUERY (SELECT * FROM holidays.germany(COALESCE(p_sub_region, 'BB'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('GREECE', 'GR', 'GRC') THEN
			RETURN QUERY (SELECT * FROM holidays.greece(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('HONDURAS', 'HN', 'HND') THEN
			RETURN QUERY (SELECT * FROM holidays.honduras(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('HONGKONG', 'HONG KONG', 'HONG_KONG', 'HK', 'HKG') THEN
			RETURN QUERY (SELECT * FROM holidays.hong_kong(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('HUNGARY', 'HU', 'HUN') THEN
			RETURN QUERY (SELECT * FROM holidays.hungary(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ICELAND', 'IS', 'ISL') THEN
			RETURN QUERY (SELECT * FROM holidays.iceland(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('INDIA', 'IN', 'IND') THEN
			RETURN QUERY (SELECT * FROM holidays.india(COALESCE(p_sub_region, 'HR'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('INDONESIA', 'ID', 'IDN') THEN
			RETURN QUERY (SELECT * FROM holidays.indonesia(COALESCE(p_sub_region, 'Bali'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('IRELAND', 'IE', 'IRL') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('Ireland', p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ISLE OF MAN', 'ISLE OF MAN', 'ISLE_OF_MAN') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('Isle Of Man', p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ISRAEL', 'IL', 'ISR') THEN
			RETURN QUERY (SELECT * FROM holidays.israel(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('ITALY', 'IT', 'ITA') THEN
			RETURN QUERY (SELECT * FROM holidays.italy(COALESCE(p_sub_region, 'RM'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('JAPAN', 'JP', 'JPN') THEN
			RETURN QUERY (SELECT * FROM holidays.japan(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('KENYA', 'KE', 'KEN') THEN
			RETURN QUERY (SELECT * FROM holidays.kenya(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('LITHUANIA', 'LT', 'LTU') THEN
			RETURN QUERY (SELECT * FROM holidays.lithuania(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('LUXEMBOURG', 'LU', 'LUX') THEN
			RETURN QUERY (SELECT * FROM holidays.Luxembourg(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('MEXICO', 'MX', 'MEX') THEN
			RETURN QUERY (SELECT * FROM holidays.mexico(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NETHERLANDS', 'NL', 'NLD') THEN
			RETURN QUERY (SELECT * FROM holidays.netherlands(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NEWZEALAND', 'NEW ZEALAND', 'NEW_ZEALAND', 'NZ', 'NZL') THEN
			RETURN QUERY (SELECT * FROM holidays.new_zealand(COALESCE(p_sub_region, 'WTL'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NICARAGUA', 'NI', 'NIC') THEN
			RETURN QUERY (SELECT * FROM holidays.nicaragua(p_sub_region, p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NIGERIA', 'NG', 'NGA') THEN
			RETURN QUERY (SELECT * FROM holidays.nigeria(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NORTHERNIRELAND', 'NORTHERN IRELAND', 'NORTHERN_IRELAND') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('Northern Ireland', p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('NORWAY', 'NO', 'NOR') THEN
			RETURN QUERY (SELECT * FROM holidays.norway(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('PARAGUAY', 'PY', 'PRY') THEN
			RETURN QUERY (SELECT * FROM holidays.paraguay(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('PERU', 'PE', 'PER') THEN
			RETURN QUERY (SELECT * FROM holidays.peru(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('POLAND', 'PL', 'POL') THEN
			RETURN QUERY (SELECT * FROM holidays.poland(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('PORTUGAL', 'PT', 'PRT') THEN
			RETURN QUERY (SELECT * FROM holidays.portugal(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('RUSSIA', 'RU', 'RUS') THEN
			RETURN QUERY (SELECT * FROM holidays.russia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SCOTLAND') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('Scotland', p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SERBIA', 'RS', 'SRB') THEN
			RETURN QUERY (SELECT * FROM holidays.serbia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SINGAPORE', 'SG', 'SGP') THEN
			RETURN QUERY (SELECT * FROM holidays.singapore(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SLOVAKIA', 'SK', 'SVK', 'SLOVAK') THEN
			RETURN QUERY (SELECT * FROM holidays.slovakia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SLOVENIA', 'SI', 'SVN') THEN
			RETURN QUERY (SELECT * FROM holidays.slovenia(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SOUTHAFRICA', 'SOUTH AFRICA', 'SOUTH_AFRICA', 'ZA', 'ZAF') THEN
			RETURN QUERY (SELECT * FROM holidays.south_africa(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SOUTHKOREA', 'SOUTH KOREA', 'SOUTH_KOREA', 'KR', 'KOR') THEN
			RETURN QUERY (SELECT * FROM holidays.south_korea(COALESCE(p_sub_region, ''), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SPAIN', 'ES', 'ESP') THEN
			RETURN QUERY (SELECT * FROM holidays.spain(COALESCE(p_sub_region, 'MAD'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SWEDEN', 'SE', 'SWE') THEN
			RETURN QUERY (SELECT * FROM holidays.sweden(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('SWITZERLAND', 'CH', 'CHE') THEN
			RETURN QUERY (SELECT * FROM holidays.switzerland(COALESCE(p_sub_region, 'ZH'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('UKRAINE', 'UA', 'UKR') THEN
			RETURN QUERY (SELECT * FROM holidays.ukraine(p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('UNITEDARABEMIRATES', 'UNITED ARAB EMIRATES', 'UNITED_ARAB_EMIRATES', 'AE', 'ARE', 'UAE') THEN
			RETURN QUERY (SELECT * FROM holidays.united_arab_emirates(COALESCE(p_sub_region, ''), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('UNITEDKINGDOM', 'UNITED KINGDOM', 'UNITED_KINGDOM', 'UK', 'GB', 'GBR') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom(COALESCE(p_sub_region, 'UK'), p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('UNITEDSTATES', 'UNITED STATES', 'UNITED_STATES', 'US', 'USA') THEN
			RETURN QUERY (SELECT * FROM holidays.usa(p_sub_region, p_start_year, p_end_year));
		WHEN UPPER(p_country) IN ('WALES') THEN
			RETURN QUERY (SELECT * FROM holidays.united_kingdom('Wales', p_start_year, p_end_year));
		ELSE
			RAISE EXCEPTION 'Unsupported Country --> %', p_country;
	END CASE;
END;

$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION holidays.by_country(
	p_country TEXT,
	p_start_date date,
	p_end_date date,
	p_sub_region TEXT DEFAULT NULL
)
RETURNS SETOF holidays.holiday
AS $$
	SELECT
		datestamp,
		reference,
		description,
		authority,
		day_off,
		observation_shifted,
		start_time,
		end_time
	FROM holidays.by_country(
		p_country,
		extract('year' from p_start_date)::int,
		extract('year' from p_end_date)::int,
		p_sub_region
	)
	WHERE datestamp >= p_start_date AND datestamp <= p_end_date
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION holidays.by_country(
	p_country TEXT,
	p_daterange daterange,
	p_sub_region TEXT DEFAULT NULL
)
RETURNS SETOF holidays.holiday
AS $$
	SELECT holidays.by_country(
		p_country,
		lower(p_daterange),
		upper(p_daterange),
		p_sub_region
	);
$$ LANGUAGE sql;
