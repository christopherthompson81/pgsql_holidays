'''
Test the database functionality for SREDPrep

Test Common Functions
'''
# Standard Imports
import json
import unittest

# PyPi Imports
import psycopg2
import psycopg2.extras

# Local Imports
## None

# Constants
POSTGRESQL_CONFIG = 'postgresql_config.json'

COUNTRY_LIST = [
	'afghanistan',
	'andorra',
	'anguilla',
	'antigua_and_barbuda',
	'argentina',
	'aruba',
	'australia',
	'austria',
	'belarus',
	'belgium',
	'brazil',
	'bulgaria',
	'canada',
	'chile',
	'colombia',
	'croatia',
	'czechia',
	'denmark',
	'dominican_republic',
	'egypt',
	'estonia',
	'european_central_bank',
	'finland',
	'france',
	'germany',
	'greece',
	'honduras',
	#'hong_kong',
	'hungary',
	'iceland',
	'india',
	#'isreal',
	'italy',
	'japan',
	'kenya',
	'lithuania',
	'luxembourg',
	'mexico',
	'netherlands',
	'new_zealand',
	'nicaragua',
	'nigeria',
	'norway',
	'paraguay',
	'peru',
	'poland',
	'portugal',
	'russia',
	'serbia',
	#'singapore',
	'slovakia',
	'slovenia',
	'south_africa',
	'spain',
	'sweden',
	'switzerland',
	'ukraine',
	'united_kingdom',
	'united_states',
]

SUBREGION_LIST = {
	'andorra': ['Canillo', 'Encamp', 'La Massana', 'Ordino',
		'Sant Julià de Lòria', 'Andorra la Vella'
	],
	'antigua_and_barbuda': ['Saint George', 'Saint John', 'Saint Mary',
		'Saint Paul', 'Saint Peter', 'Saint Philip', 'Barbuda', 'Redonda'
	],
	'australia': ['ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA'],
	'austria': ['B', 'K', 'N', 'O', 'S', 'ST', 'T', 'V', 'W'],
	'brazil': [
		'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
		'MG', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
		'SP', 'SE', 'TO'],
	'canada': [
		'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK',
		'YK'],
	'france': [
		'Métropole', 'Alsace-Moselle', 'Guadeloupe', 'Guyane', 'Martinique',
		'Mayotte', 'Nouvelle-Calédonie', 'La Réunion', 'Polynésie Française',
		'Saint-Barthélémy', 'Saint-Martin', 'Wallis-et-Futuna'
	],
	'germany': [
		'BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW', 'RP', 'SL',
		'SN', 'ST', 'SH', 'TH'],
	'india': [
		'AS', 'CG', 'SK', 'KA', 'GJ', 'BR', 'RJ', 'OD', 'TN', 'AP', 'WB', 'KL',
		'HR', 'MH', 'MP', 'UP', 'UK', 'TS'],
	'italy': [
		'AN', 'AO', 'BA', 'BL', 'BO', 'BZ', 'BS', 'CB', 'CT', 'Cesena', 'CH',
		'CS', 'KR', 'EN', 'FE', 'FI', 'FC', 'Forli', 'FR', 'GE', 'GO', 'IS',
		'SP', 'LT', 'MN', 'MS', 'MI', 'MO', 'MB', 'NA', 'PD', 'PA', 'PR', 'PG',
		'PE', 'PC', 'PI', 'PD', 'PT', 'RA', 'RE', 'RI', 'RN', 'RM', 'RO', 'SA',
		'SR', 'TE', 'TO', 'TS', 'Pesaro', 'PU', 'Urbino', 'VE', 'VC', 'VI'],
	'new_zealand': [
		'NTL', 'AUK', 'TKI', 'HKB', 'WGN', 'MBH', 'NSN', 'CAN', 'STC', 'WTL',
		'OTA', 'STL', 'CIT'],
	'spain': [
		'AND', 'ARG', 'AST', 'CAN', 'CAM', 'CAL', 'CAT', 'CVA', 'EXT', 'GAL',
		'IBA', 'ICA', 'MAD', 'MUR', 'NAV', 'PVA', 'RIO'],
	'switzerland': [
		'AG', 'AR', 'AI', 'BL', 'BS', 'BE', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU',
		'NE', 'NW', 'OW', 'SG', 'SH', 'SZ', 'SO', 'TG', 'TI', 'UR', 'VD', 'VS',
		'ZG', 'ZH'
	],
	'united_kingdom': [
		'England', 'Ireland', 'Isle of Man', 'Northern Ireland', 'Scotland',
		'UK', 'Wales'],
	'united_states': [
		'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA',
		'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MH',
		'MA', 'MI', 'FM', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM',
		'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW', 'PA', 'PR', 'RI', 'SC',
		'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'VI', 'WA', 'WV', 'WI', 'WY'],
}


##############################################################################
# Testing class
##############################################################################
class TestTaxFormFunctions(unittest.TestCase):
	'''Test Validator Functions'''
	def __init__(self, *args, **kwargs):
		super(TestTaxFormFunctions, self).__init__(*args, **kwargs)
		with open(POSTGRESQL_CONFIG) as config:
			self.pq_params = json.load(config)
		self.pq_connect()

	def pq_connect(self):
		""" Connect to the PostgreSQL database server """
		try:
			self.connection = psycopg2.connect(**self.pq_params)
		except psycopg2.DatabaseError as error:
			print(error)

	def __del__(self):
		self.connection.close()


	def setUp(self):
		pass


	def tearDown(self):
		self.connection.rollback()

	
	# Template for specific country tests
	def template_test_holidays_function(
		self,
		country,
		start_year,
		end_year,
		province=None,
	):
		'''Template for testing a country-specific holiday function'''
		if province:
			query = f"SELECT * FROM holidays.{country}({province}, {start_year}, {end_year})"
		else:
			query = f"SELECT * FROM holidays.{country}({start_year}, {end_year})"
		cursor = self.connection.cursor()
		cursor.execute(query)
		rows = cursor.fetchall()
		self.assertTrue(len(rows) > 0)

	# Template for specific country tests via by_country
	def template_test_by_country(
		self,
		country,
		start_year,
		end_year,
		province=None,
	):
		'''Template for testing the by_country holiday function'''
		if province:
			query = f"SELECT * FROM holidays.by_country('{country}', {start_year}, {end_year}, '{province}')"
		else:
			query = f"SELECT * FROM holidays.by_country('{country}', {start_year}, {end_year})"
		cursor = self.connection.cursor()
		cursor.execute(query)
		rows = cursor.fetchall()
		self.assertTrue(len(rows) > 0)

	# Test a specific country
	def test_argentina(self):
		'''Test if calculate_ab_at1_sch9_pre functions correctly'''
		self.template_test_holidays_function("argentina", 2020, 2020)
		self.template_test_by_country("argentina", 2020, 2020)

	# Test functions work via the "by_country" function
	def test_countries(self):
		'''Test if all supported countries return data'''
		for country in COUNTRY_LIST:
			with self.subTest(country=country):
				self.connection.rollback()
				cursor = self.connection.cursor()
				query = f"SELECT * FROM holidays.by_country('{country}', 2020, 2020)"
				cursor.execute(query)
				rows = cursor.fetchall()
				cursor.close()
				self.assertIsNotNone(rows, 'Country could not be queried')

	# Test all sub-regions for countries with sub-regions
	def test_sub_regions(self):
		'''Test if all supported countries and sub-regions return data'''
		for country in SUBREGION_LIST:
			for subregion in SUBREGION_LIST[country]:
				with self.subTest(country=country, subregion=subregion):
					self.connection.rollback()
					cursor = self.connection.cursor()
					query = f"SELECT * FROM holidays.by_country('{country}', 2020, 2020, '{subregion}')"
					cursor.execute(query)
					rows = cursor.fetchall()
					cursor.close()
					self.assertIsNotNone(rows, 'Country could not be queried')


#######################################
# Bare main unit test function
#######################################
if __name__ == '__main__':
	unittest.main()
