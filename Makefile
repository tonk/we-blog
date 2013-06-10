# Makefile for We-Blog, We Blog our hearts out
# $Id: Makefile 6 2012-07-12 12:19:47 tonk $

# Copyright (c) 2011-2012 Ton Kersten
# Copyright (c) 2009-2011 Jaromir Hradilek

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# General information:
NAME    = we-blog
VERSION = 0.9

########################################################

# General settings:
SHELL   = /bin/sh
INSTALL = /usr/bin/install -c
POD2MAN = /usr/bin/pod2man
MAN1    = src/we-blog-add.1 src/we-blog-config.1 src/we-blog-edit.1	\
          src/we-blog-init.1 src/we-blog-list.1 src/we-blog-log.1	\
          src/we-blog-make.1 src/we-blog-remove.1			\
          src/we-blog-smilies.1
SRCS    = src/we-blog-add.pl src/we-blog-config.pl src/we-blog-edit.pl	\
          src/we-blog-init.pl src/we-blog-list.pl src/we-blog-log.pl	\
          src/we-blog-make.pl src/we-blog-remove.pl			\
          src/we-blog-smilies.pl src/We.pm
SMLS	= smilies

RPMSPECDIR= packaging/rpm
RPMSPEC = $(RPMSPECDIR)/we-blog.spec
RPMDIST = $(shell rpm --eval '%{?dist}')
RPMRELEASE = 1
ifeq ($(OFFICIAL),)
    RPMRELEASE = 0.git$(DATE)
endif
RPMNVR = "$(NAME)-$(VERSION)-$(RPMRELEASE)$(RPMDIST)"

NOSETESTS := nosetests

# Installation directories:
config  = $(DESTDIR)/etc
prefix  = $(DESTDIR)/usr
bindir  = $(prefix)/bin
datadir = $(prefix)/share/$(NAME)
docsdir = $(prefix)/share/doc/$(NAME)-$(VERSION)
man1dir = $(prefix)/share/man/man1
compdir = $(config)/bash_completion.d

# Make rules;  please do not edit these unless you really know what you are
# doing:
.PHONY: all install_bin install_conf install_data install_docs \
        install_man install_smilies install uninstall clean

all: $(MAN1)

install_bin:
	@echo "Copying executables..."
	$(INSTALL) -d $(bindir)
	$(INSTALL) -m 755 src/we-blog-add.pl		$(bindir)/we-blog-add
	$(INSTALL) -m 755 src/we-blog-log.pl		$(bindir)/we-blog-log
	$(INSTALL) -m 755 src/we-blog-edit.pl		$(bindir)/we-blog-edit
	$(INSTALL) -m 755 src/we-blog-init.pl		$(bindir)/we-blog-init
	$(INSTALL) -m 755 src/we-blog-list.pl		$(bindir)/we-blog-list
	$(INSTALL) -m 755 src/we-blog-make.pl		$(bindir)/we-blog-make
	$(INSTALL) -m 755 src/we-blog-config.pl		$(bindir)/we-blog-config
	$(INSTALL) -m 755 src/we-blog-remove.pl		$(bindir)/we-blog-remove
	$(INSTALL) -m 755 src/we-blog-smilies.pl	$(bindir)/we-blog-smilies
	$(INSTALL) -m 755 src/We.pm			$(bindir)/We.pm
	$(INSTALL) -m 755 unix/we-blog.sh		$(bindir)/we-blog
	(cd $(bindir); ln -fs we-blog wb)

install_conf:
	@echo "Copying bash completion..."
	$(INSTALL) -d $(compdir)
	$(INSTALL) -m 644 unix/bash_completion $(compdir)/we-blog

install_data:
	@echo "Copying translations..."
	$(INSTALL) -d $(datadir)/lang
	$(INSTALL) -m 644 lang/cs_CZ $(datadir)/lang
	$(INSTALL) -m 644 lang/de_DE $(datadir)/lang
	$(INSTALL) -m 644 lang/en_GB $(datadir)/lang
	$(INSTALL) -m 644 lang/en_US $(datadir)/lang
	$(INSTALL) -m 644 lang/es_ES $(datadir)/lang
	$(INSTALL) -m 644 lang/eu_ES $(datadir)/lang
	$(INSTALL) -m 644 lang/fr_FR $(datadir)/lang
	$(INSTALL) -m 644 lang/ja_JP $(datadir)/lang
	$(INSTALL) -m 644 lang/nl_NL $(datadir)/lang
	$(INSTALL) -m 644 lang/pt_BR $(datadir)/lang
	$(INSTALL) -m 644 lang/ru_RU $(datadir)/lang
	$(INSTALL) -m 644 lang/uk_UK $(datadir)/lang

install_smilies:
	@echo "Copying smilies..."
	$(INSTALL) -d -p -m 755 smilies $(datadir)/smilies
	$(INSTALL) -p -m 644 smilies/* $(datadir)/smilies

install_docs:
	@echo "Copying documentation..."
	$(INSTALL) -d $(docsdir)
	$(INSTALL) -m 644 FDL $(docsdir)
	$(INSTALL) -m 644 TODO $(docsdir)
	$(INSTALL) -m 644 README $(docsdir)
	$(INSTALL) -m 644 AUTHORS $(docsdir)
	$(INSTALL) -m 644 COPYING $(docsdir)
	$(INSTALL) -m 644 INSTALL $(docsdir)
	-$(INSTALL) -m 644 ChangeLog $(docsdir)

install_man: $(MAN1)
	@echo "Copying manual pages..."
	$(INSTALL) -d $(man1dir)
	$(INSTALL) -m 644 src/we-blog-add.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-log.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-edit.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-init.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-list.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-make.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-config.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-remove.1 $(man1dir)
	$(INSTALL) -m 644 src/we-blog-smilies.1 $(man1dir)
	$(INSTALL) -m 644 unix/man/man1/we-blog.1 $(man1dir)

install: install_bin install_conf install_data install_docs install_man install_smilies

uninstall:
	@echo "Removing executables..."
	-rm -f $(bindir)/we-blog-add
	-rm -f $(bindir)/we-blog-log
	-rm -f $(bindir)/we-blog-edit
	-rm -f $(bindir)/we-blog-init
	-rm -f $(bindir)/we-blog-list
	-rm -f $(bindir)/we-blog-make
	-rm -f $(bindir)/we-blog-config
	-rm -f $(bindir)/we-blog-remove
	-rm -f $(bindir)/we-blog-smilies
	-rm -f $(bindir)/We.pm
	-rm -f $(bindir)/we-blog
	-rm -f $(bindir)/wb
	-rmdir $(bindir)
	@echo "Removing bash completion..."
	-rm -f $(compdir)/we-blog
	-rmdir $(compdir)
	@echo "Removing smilies..."
	-rm -f $(datadir)/smilies/*
	-rmdir $(datadir)/smilies
	@echo "Removing translations..."
	-rm -f $(datadir)/lang/cs_CZ
	-rm -f $(datadir)/lang/de_DE
	-rm -f $(datadir)/lang/en_GB
	-rm -f $(datadir)/lang/en_US
	-rm -f $(datadir)/lang/es_ES
	-rm -f $(datadir)/lang/eu_ES
	-rm -f $(datadir)/lang/fr_FR
	-rm -f $(datadir)/lang/ja_JP
	-rm -f $(datadir)/lang/nl_NL
	-rm -f $(datadir)/lang/pt_BR
	-rm -f $(datadir)/lang/ru_RU
	-rm -f $(datadir)/lang/uk_UK
	-rmdir $(datadir)/lang $(datadir)
	@echo "Removing documentation..."
	-rm -f $(docsdir)/FDL
	-rm -f $(docsdir)/TODO
	-rm -f $(docsdir)/README
	-rm -f $(docsdir)/AUTHORS
	-rm -f $(docsdir)/COPYING
	-rm -f $(docsdir)/INSTALL
	-rm -f $(docsdir)/ChangeLog
	-rmdir $(docsdir)
	@echo "Removing manual pages..."
	-rm -f $(man1dir)/we-blog-add.1
	-rm -f $(man1dir)/we-blog-log.1
	-rm -f $(man1dir)/we-blog-edit.1
	-rm -f $(man1dir)/we-blog-init.1
	-rm -f $(man1dir)/we-blog-list.1
	-rm -f $(man1dir)/we-blog-make.1
	-rm -f $(man1dir)/we-blog-config.1
	-rm -f $(man1dir)/we-blog-remove.1
	-rm -f $(man1dir)/we-blog-smilies.1
	-rm -f $(man1dir)/we-blog.1
	-rmdir $(man1dir)

clean:
	-rm -f $(MAN1)

%.1: %.pl
	$(POD2MAN) --section=1 --release="Version $(VERSION)" \
	                       --center="We-Blog Documentation" $^ $@

sdist:
	@rm -rf dist/$(NAME)-$(VERSION).tgz packaging/rpm/$(NAME)-$(VERSION)
	@mkdir /tmp/$(NAME)-$(VERSION)
	@cp -rp * /tmp/$(NAME)-$(VERSION)
	@mkdir -p dist packaging/rpm
	@mv /tmp/$(NAME)-$(VERSION) packaging/rpm
	@cd packaging/rpm; tar -czf ../../dist/$(NAME)-$(VERSION).tgz $(NAME)-$(VERSION)

rpmcommon: sdist
	@mkdir -p rpm-build
	@cp dist/*.tgz rpm-build/
	@sed -e 's#^Version:.*#Version: $(VERSION)#' -e 's#^Release:.*#Release: $(RPMRELEASE)%{?dist}#' $(RPMSPEC) >rpm-build/$(NAME).spec

srpm: rpmcommon
	@rpmbuild --define "_topdir %(pwd)/rpm-build" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_specdir $(RPMSPECDIR)" \
	--define "_sourcedir %{_topdir}" \
	-bs rpm-build/$(NAME).spec
	@rm -f rpm-build/$(NAME).spec
	@echo "#############################################"
	@echo "we-blog SRPM is built:"
	@echo "    rpm-build/$(RPMNVR).src.rpm"
	@echo "#############################################"

rpm: rpmcommon
	@rpmbuild --define "_topdir %(pwd)/rpm-build" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_specdir $(RPMSPECDIR)" \
	--define "_sourcedir %{_topdir}" \
	--define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
	-ba rpm-build/$(NAME).spec
	@rm -f rpm-build/$(NAME).spec
	@echo "#############################################"
	@echo "Ansible RPM is built:"
	@echo "    rpm-build/$(RPMNVR).noarch.rpm"
	@echo "#############################################"

debian: sdist
deb: debian
	cp -r packaging/debian ./
	chmod 755 debian/rules
	fakeroot debian/rules clean
	fakeroot dh_install
	fakeroot debian/rules binary
