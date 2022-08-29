##############################################################################
#
# Makefile
#
###############################################################################

##
## V A R I A B L E S
##

EXTENSION    = $(shell grep -m 1 '"name":' META.json | \
               sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')
EXTVERSION   = $(shell grep -m 1 '[[:space:]]\{8\}"version":' META.json | \
               sed -e 's/[[:space:]]*"version":[[:space:]]*"\([^"]*\)",\{0,1\}/\1/')
DISTVERSION  = $(shell grep -m 1 '[[:space:]]\{3\}"version":' META.json | \
               sed -e 's/[[:space:]]*"version":[[:space:]]*"\([^"]*\)",\{0,1\}/\1/')

DATA         = $(wildcard sql/*--*.sql)
EXTRA_CLEAN  = sql/$(EXTENSION).sql sql/$(EXTENSION)--$(EXTVERSION).sql
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test

##
## Mandatory PGXS stuff
## see https://github.com/postgres/postgres/blob/master/src/makefiles/pgxs.mk
##

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

##
## BUILD
##

all: build_sql

.PHONY: build_sql
build_sql:
	./scripts/create_sql_file.sh
	cp sql/$(EXTENSION).sql sql/$(EXTENSION)--$(EXTVERSION).sql

dist:
	git archive --format zip --prefix=$(EXTENSION)-$(DISTVERSION)/ -o $(EXTENSION)-$(DISTVERSION).zip HEAD
