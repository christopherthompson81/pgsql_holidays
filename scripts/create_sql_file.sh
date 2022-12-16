#!/bin/bash

cd "$(dirname "$0")/../sql"

cat > holidays.sql << EOF
/* contrib/holidays/holidays--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION holidays" to load this file. \quit

EOF

DBSETUP_FILES=(
  "db_setup/jurisditctional_authority_type.pgsql"
  "db_setup/holiday_type.pgsql"
  "db_setup/date_parts_type.pgsql"
)

UTILS_FILES=(
  "utils/easter.pgsql"
  "utils/days_before_year.pgsql"
  "utils/bisect_right.pgsql"
  "utils/find_nth_weekday_date.pgsql"
  "utils/net_work_days.pgsql"
  "utils/ummalqura_month_starts.pgsql"
  "utils/get_vernal_equinox.pgsql"
  "utils/gregorian_to_hijri.pgsql"
  "utils/gregorian_to_jalali.pgsql"
  "utils/gregorian_to_ordinal.pgsql"
  "utils/hijri_to_gregorian.pgsql"
  "utils/jalali_to_gregorian.pgsql"
  "utils/jalali_to_julian.pgsql"
  "utils/julian_to_ordinal.pgsql"
  "utils/ordinal_to_gregorian.pgsql"
  "utils/possible_gregorian_from_hijri.pgsql"
  "utils/possible_gregorian_from_jalali.pgsql"
  "utils/yinli_leap_month.pgsql"
  "utils/yinli_month_days_array.pgsql"
  "utils/yinli_month_days.pgsql"
  "utils/yinli_to_gregorian.pgsql"
  "utils/yinli_year_days.pgsql"
)

COUNTRIES_FILES=(
  "countries/afghanistan.pgsql"
  "countries/albania.pgsql"
  "countries/andorra.pgsql"
  "countries/anguilla.pgsql"
  "countries/antigua_and_barbuda.pgsql"
  "countries/argentina.pgsql"
  "countries/aruba.pgsql"
  "countries/australia.pgsql"
  "countries/austria.pgsql"
  "countries/belarus.pgsql"
  "countries/belgium.pgsql"
  "countries/brazil.pgsql"
  "countries/bulgaria.pgsql"
  "countries/canada.pgsql"
  "countries/chile.pgsql"
  "countries/china.pgsql"
  "countries/colombia.pgsql"
  "countries/croatia.pgsql"
  "countries/czechia.pgsql"
  "countries/denmark.pgsql"
  "countries/dominican_republic.pgsql"
  "countries/egypt.pgsql"
  "countries/estonia.pgsql"
  "countries/european_central_bank.pgsql"
  "countries/finland.pgsql"
  "countries/france.pgsql"
  "countries/germany.pgsql"
  "countries/greece.pgsql"
  "countries/honduras.pgsql"
  "countries/hong_kong.pgsql"
  "countries/hungary.pgsql"
  "countries/iceland.pgsql"
  "countries/india.pgsql"
  "countries/indonesia.pgsql"
  "countries/israel.pgsql"
  "countries/italy.pgsql"
  "countries/japan.pgsql"
  "countries/kenya.pgsql"
  "countries/lithuania.pgsql"
  "countries/luxembourg.pgsql"
  "countries/mexico.pgsql"
  "countries/netherlands.pgsql"
  "countries/new_zealand.pgsql"
  "countries/nicaragua.pgsql"
  "countries/nigeria.pgsql"
  "countries/norway.pgsql"
  "countries/pakistan.pgsql"
  "countries/paraguay.pgsql"
  "countries/peru.pgsql"
  "countries/poland.pgsql"
  "countries/portugal.pgsql"
  "countries/russia.pgsql"
  "countries/serbia.pgsql"
  "countries/singapore.pgsql"
  "countries/slovakia.pgsql"
  "countries/slovenia.pgsql"
  "countries/south_africa.pgsql"
  "countries/south_korea.pgsql"
  "countries/spain.pgsql"
  "countries/sweden.pgsql"
  "countries/switzerland.pgsql"
  "countries/ukraine.pgsql"
  "countries/united_arab_emirates.pgsql"
  "countries/united_kingdom.pgsql"
  "countries/united_states.pgsql"
  "by_country.pgsql"
)

for sql_file in ${DBSETUP_FILES[*]} ${UTILS_FILES[*]} ${COUNTRIES_FILES[*]}; do
	(cat "${sql_file}"; echo; echo) >> holidays_orig.sql
done

sed -e 's#\([ (\t]\)holidays\.#\1@extschema@.#g' -e 's#--\([ \t]*\)@extschema@\.#--\1holidays.#g' holidays_orig.sql > holidays.sql
rm -f holidays_orig.sql
