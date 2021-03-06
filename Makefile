
-include config.mak

PG_CONFIG ?= pg_config
PG_INCDIR = $(shell $(PG_CONFIG) --includedir)
PG_LIBDIR = $(shell $(PG_CONFIG) --libdir)

bin_PROGRAMS = pgqd

pgqd_SOURCES = src/pgqd.c src/maint.c src/ticker.c src/retry.c src/pgqd.h
nodist_pgqd_SOURCES = pgqd.ini.h
pgqd_CPPFLAGS = -I$(PG_INCDIR) -Isrc -I.
pgqd_LDFLAGS = -L$(PG_LIBDIR)
pgqd_LIBS = -lpq -lm

pgqd_EMBED_LIBUSUAL = 1
USUAL_DIR = lib
AM_FEATURES = libusual

EXTRA_DIST = pgqd.ini
CLEANFILES = pgqd.ini.h

CONFIG_H = $(USUAL_DIR)/lib/usual/config.h

include $(USUAL_DIR)/mk/antimake.mk

pgqd.ini.h: pgqd.ini
	sed -e 's/.*/"&\\n"/' $< > $@

install: install-conf
install-conf:
	mkdir -p '$(DESTDIR)$(docdir)/conf'
	$(INSTALL) -m 644 pgqd.ini '$(DESTDIR)$(docdir)/conf/pgqd.ini.templ'

tags:
	ctags src/*.[ch] lib/usual/*.[ch]

configure:
	./autogen.sh

#config.mak: configure
#	./configure

deb: configure
	debuild -us -uc -b

*.o: $(CONFIG_H)

$(CONFIG_H):
	$(error Please run ./configure first)

xclean: clean
	rm -f config.mak config.guess config.sub config.log config.sub config.status
	rm -f configure install-sh lib/usual/config.h
	rm -rf debian/.debhelper debian/pgqd
	rm -f debian/files debian/*-stamp debian/*.debhelper debian/*.log debian/*.substvars
