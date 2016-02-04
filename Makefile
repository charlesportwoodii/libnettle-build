SHELL := /bin/bash

# Dependency Versions
VERSION?=3.2
RELEASEVER?=1

# Bash data
SCRIPTPATH=$(shell pwd -P)
CORES=$(shell grep -c ^processor /proc/cpuinfo)
RELEASE=$(shell lsb_release --codename | cut -f2)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)
micro=$(shell echo $(VERSION) | cut -d. -f3)

build: clean nettle

clean:
	rm -rf /tmp/nettle-$(VERSION).tar.gz
	rm -rf /tmp/nettle-$(VERSION)

nettle:
	cd /tmp && \
	wget ftp://ftp.gnu.org/gnu/nettle/nettle-$(VERSION).tar.gz && \
	tar -xf nettle-$(VERSION).tar.gz && \
	cd nettle-$(VERSION) && \
	./configure --prefix=/usr && \
	make -j$(CORES) && \
	make install

package:
	cp $(SCRIPTPATH)/*-pak /tmp/nettle-$(VERSION)

	cd /tmp/nettle-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$RELEASEVER"-"$RELEASE" \
	    -pkgrelease "$RELEASEVER"~"$RELEASE" \
	    -pkgname "libnettle2" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "libnettle2" \
	    -pakdir /tmp \
	    -y
