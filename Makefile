BUILDDIR	?= /tmp/ssmbuild

ARCH	:= $(shell rpm --eval "%{_arch}")
VERSION	?= $(shell rpmspec -q --queryformat="%{version}" percona-toolkit.spec)
RELEASE	?= $(shell rpmspec -q --queryformat="%{release}" percona-toolkit.spec)

SRPM_FILE	:= $(BUILDDIR)/results/SRPMS/percona-toolkit-$(VERSION)-$(RELEASE).src.rpm
RPM_FILE	:= $(BUILDDIR)/results/RPMS/percona-toolkit-$(VERSION)-$(RELEASE).$(ARCH).rpm

.PHONY: all
all: srpm rpm

.PHONY: srpm
srpm: $(SRPM_FILE)

$(SRPM_FILE):
	mkdir -vp $(BUILDDIR)/rpmbuild/{SOURCES,SPECS,BUILD,SRPMS,RPMS}
	mkdir -vp $(shell dirname $(SRPM_FILE))

	cp percona-toolkit.spec $(BUILDDIR)/rpmbuild/SPECS/percona-toolkit.spec
	sed -i -E 's/%\{\??_version\}/$(VERSION)/g' $(BUILDDIR)/rpmbuild/SPECS/percona-toolkit.spec
	sed -i -E 's/%\{\??_release\}/$(RELEASE)/g' $(BUILDDIR)/rpmbuild/SPECS/percona-toolkit.spec
	spectool -C $(BUILDDIR)/rpmbuild/SOURCES -g $(BUILDDIR)/rpmbuild/SPECS/percona-toolkit.spec

	tar -C $(BUILDDIR)/rpmbuild/SOURCES/ -zxf $(BUILDDIR)/rpmbuild/SOURCES/percona-toolkit-v$(VERSION).tar.gz
	cd $(BUILDDIR)/rpmbuild/SOURCES/percona-toolkit-$(VERSION) && go mod vendor && tar -czf $(BUILDDIR)/rpmbuild/SOURCES/percona-toolkit-v$(VERSION).tar.gz -C $(BUILDDIR)/rpmbuild/SOURCES percona-toolkit-$(VERSION)

	rpmbuild -bs --define "debug_package %{nil}" --define "_topdir $(BUILDDIR)/rpmbuild" $(BUILDDIR)/rpmbuild/SPECS/percona-toolkit.spec
	mv $(BUILDDIR)/rpmbuild/SRPMS/$(shell basename $(SRPM_FILE)) $(SRPM_FILE)

.PHONY: rpm
rpm: $(RPM_FILE)

$(RPM_FILE): $(SRPM_FILE)
	mkdir -vp $(BUILDDIR)/mock $(shell dirname $(RPM_FILE))
	mock -r ssm-9-$(ARCH) --resultdir $(BUILDDIR)/mock --rebuild $(SRPM_FILE)
	mv $(BUILDDIR)/mock/$(shell basename $(RPM_FILE)) $(RPM_FILE)

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)/{rpmbuild,mock,results}
