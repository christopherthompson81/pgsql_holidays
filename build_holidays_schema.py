"""
pgsql_holidays

Script for building the holidays schema in a configured PostgreSQL database
from source SQL files
"""
# Standard Imports
import json
import os
import re

# PyPi Imports
import psycopg2
import psycopg2.extras

# Local Imports
## None

###############################################################################
#
# Constants
#
###############################################################################

POSTGRESQL_CONFIG = 'postgresql_config.json'

COUNTRIES_LOAD_ORDER = [
	'afghanistan.pgsql',
	'andorra.pgsql',
	'argentina.pgsql',
	'aruba.pgsql',
	'australia.pgsql',
	'austria.pgsql',
	'belarus.pgsql',
	'belgium.pgsql',
	'brazil.pgsql',
	'bulgaria.pgsql',
	'canada.pgsql',
	'chile.pgsql',
	'colombia.pgsql',
	'croatia.pgsql',
	'czechia.pgsql',
	'denmark.pgsql',
	'dominican_republic.pgsql',
	'egypt.pgsql',
	'estonia.pgsql',
	'european_central_bank.pgsql',
	'finland.pgsql',
	'france.pgsql',
	'germany.pgsql',
	'greece.pgsql',
	'honduras.pgsql',
	#'hong_kong.pgsql',
	'hungary.pgsql',
	'iceland.pgsql',
	'india.pgsql',
	#'isreal.pgsql',
	'italy.pgsql',
	'japan.pgsql',
	'kenya.pgsql',
	'lithuania.pgsql',
	'luxembourg.pgsql',
	'mexico.pgsql',
	'netherlands.pgsql',
	'new_zealand.pgsql',
	'nicaragua.pgsql',
	'nigeria.pgsql',
	'norway.pgsql',
	'paraguay.pgsql',
	'peru.pgsql',
	'poland.pgsql',
	'portugal.pgsql',
	'russia.pgsql',
	'serbia.pgsql',
	#'singapore.pgsql',
	'slovakia.pgsql',
	'slovenia.pgsql',
	'south_africa.pgsql',
	'spain.pgsql',
	'sweden.pgsql',
	'switzerland.pgsql',
	'ukraine.pgsql',
	'united_kingdom.pgsql',
	'united_states.pgsql',
]

###############################################################################
#
# General Functions
#
###############################################################################
class PqDbController():
	'''Top Level PostgreSQL database controller for SREDPrep'''
	def __init__(self):
		self.connection = None
		with open(POSTGRESQL_CONFIG) as config:
			self.pq_params = json.load(config)

	def connect_db(self):
		"""Connects to the specific database."""
		try:
			self.connection = psycopg2.connect(**self.pq_params)
		except psycopg2.DatabaseError as error:
			print(error)

	#Applies an SQL file to a database connection
	def apply_sql_file_to_db(self, sql_file):
		"""Applies an SQL file to a database connection"""
		query = open(sql_file, 'r', encoding='utf-8').read()
		cursor = self.connection.cursor()
		cursor.execute(query)
		self.connection.commit()
		return

	#Applies an SQL file to a database connection
	def apply_sql_folder_to_db(self, sql_folder):
		"""Applies an SQL file to a database connection"""
		sql_files = list()
		t_sql_folder = os.path.join(sql_folder)
		for filename in os.listdir(t_sql_folder):
			if os.path.isfile(os.path.join(t_sql_folder, filename)) and re.search(r'\.(pg)*sql$', filename):
				sql_files.append(os.path.join(t_sql_folder, filename))
			elif os.path.isdir(os.path.join(t_sql_folder, filename)):
				self.apply_sql_folder_to_db(os.path.join(sql_folder, filename))
		for sql_file in sql_files:
			print('Applying ' + sql_file)
			self.apply_sql_file_to_db(sql_file)
		return

	#Applies an SQL file to a database connection
	def apply_sql_folder_and_list_to_db(self, sql_folder, sql_list):
		"""Applies an SQL file to a database connection"""
		for filename in sql_list:
			sql_file = os.path.join(sql_folder, filename)
			print('Applying ' + sql_file)
			self.apply_sql_file_to_db(sql_file)
		return

###############################################################################
#
# Main Function
#
###############################################################################

# Builds the client database
def build_client_db():
	"""Builds the client database"""

	db = PqDbController()
	db.connect_db()
	print(db.connection)
	db.apply_sql_folder_and_list_to_db('db_setup', [
		'holidays_schema.pgsql',
		'jurisditctional_authority_type.pgsql',
		'holiday_type.pgsql',
		'date_parts_type.pgsql',
	])
	db.apply_sql_folder_and_list_to_db('utils',	[
		'easter.pgsql',
		'find_nth_weekday_date.pgsql',
		'bisect_right.pgsql',
		'days_before_year.pgsql',
		'ummalqura_month_starts.pgsql',
		'gregorian_to_hijri.pgsql',
		'julian_to_ordinal.pgsql',
		'ordinal_to_gregorian.pgsql',
		'hijri_to_gregorian.pgsql',
		'possible_gregorian_from_hijri.pgsql',
		'jalali_to_julian.pgsql',
		'gregorian_to_jalali.pgsql',
		'jalali_to_gregorian.pgsql',
		'possible_gregorian_from_jalali.pgsql',
	])
	db.apply_sql_folder_and_list_to_db('countries', COUNTRIES_LOAD_ORDER)
	print('Applying by_country.pgsql')
	db.apply_sql_file_to_db('by_country.pgsql')

###############################################################################
#
# Main
#
###############################################################################

build_client_db()
