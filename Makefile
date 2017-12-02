SHELL := /bin/bash

# Dependency Versions
VERSION?=3.4
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
	make -j$(CORES)

fpm_debian:
	echo "Packaging libnettle2 for Debian"

	cd /tmp/nettle-$(VERSION) && make install DESTDIR=/tmp/libnettle2-$(VERSION)-install

	fpm -s dir \
		-t deb \
		-n libnettle2 \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/libnettle2-$(VERSION)-install \
		-p libnettle2_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libnettle2-build \
		--description "libnettle2" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libnettle2 for RPM"

	cd /tmp/nettle-$(VERSION) && make install DESTDIR=/tmp/libnettle2-$(VERSION)-install

	fpm -s dir \
		-t rpm \
		-n libnettle2 \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/libnettle2-$(VERSION)-install \
		-p libnettle2_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libnettle2-build \
		--description "libnettle2" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip

package:
	cp $(SCRIPTPATH)/*-pak /tmp/nettle-$(VERSION)

	cd /tmp/nettle-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$(RELEASEVER)"-"$(RELEASE)" \
	    -pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
	    -pkgname "libnettle2" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "libnettle2" \
	    -pakdir /tmp \
	    -y
