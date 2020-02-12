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
	#'egypt',
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


	def template_test_holidays_function(
		self,
		country,
		start_year,
		end_year,
		province=None,
	):
		'''Template for testing a parameterless void function'''
		# No inputs
		# No Outputs
		# Just check that it works, scenarios are tested elsewhere
		if province:
			query = f"SELECT * FROM holidays.{country}({province}, {start_year}, {end_year})"
		else:
			query = f"SELECT * FROM holidays.{country}({start_year}, {end_year})"
		cursor = self.connection.cursor()
		# Retrieve the sum ensure it matches the expected value
		cursor.execute(query)
		rows = cursor.fetchall()
		self.assertTrue(len(rows) > 0)

	def template_test_by_country(
		self,
		country,
		start_year,
		end_year,
		province=None,
	):
		'''Template for testing a parameterless void function'''
		# No inputs
		# No Outputs
		# Just check that it works, scenarios are tested elsewhere
		if province:
			query = f"SELECT * FROM holidays.by_country('{country}', {start_year}, {end_year}, '{province}')"
		else:
			query = f"SELECT * FROM holidays.by_country('{country}', {start_year}, {end_year})"
		cursor = self.connection.cursor()
		# Retrieve the sum ensure it matches the expected value
		cursor.execute(query)
		rows = cursor.fetchall()
		self.assertTrue(len(rows) > 0)

	# Calculate forms
	def test_argentina(self):
		'''Test if calculate_ab_at1_sch9_pre functions correctly'''
		self.template_test_holidays_function("argentina", 2020, 2020)
		self.template_test_by_country("argentina", 2020, 2020)

	# Calculate forms
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
				self.assertIsNotNone(rows, 'View could not be queried')


#######################################
# Bare main unit test function
#######################################
if __name__ == '__main__':
	unittest.main()
