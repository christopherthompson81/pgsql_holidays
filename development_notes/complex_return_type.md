# Complex Return Type for pgsql_holidays

The original package used a simple (datestamp, description) pair return type to describe holidays. However, it's apparent that business intelligence applications rely on more parameters surrounding holidays to function properly. In particular, businesses need to know if employees should be off and if they should be paid. Additionally, jurisdictionality can be complex for larger companies with people resident in multiple jurisdictions who expect to have differing holidays. Also, companies may only wish to honour federal holidays for pay or scheduling purposes.

I am proposing adding new fields to the holiday type to provide better filtering.

	jurisdictional_authority
		ENUM('federal', 'provincial', 'state', 'national', 'informal', 'de_facto', 'unobserved_religious')
	day_off
		BOOLEAN
	observation_shifted
		BOOLEAN

Please post feedback if a different return type would be more suitable for a region you're interested in.

---

Some additional parameters are unnecessary to be included in the extended parameters because they are available from the DATE data type itself. For example, if the canonical date falls on a weekend and this should be excluded from the return because you are only interested in observed dates, this can be handled in your query.

	SELECT
		*
	FROM
		holidays.by_country('canada', 2020, 2020)
	WHERE
		DATE_PART('dow', datestamp) NOT IN (0,6)