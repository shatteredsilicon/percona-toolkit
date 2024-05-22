%define debug_package   %{nil}
%define _GOPATH         %{_builddir}/go

%global provider                github
%global provider_tld            com
%global project                 percona
%global repo                    percona-toolkit
%global import_path             %{provider}.%{provider_tld}/%{project}/%{repo}

Name:           %{repo}
Summary:        Percona Toolkit (Shattered Silicon Build)
%if "0%{?_version}" == "0"
Version:        3.5.7
%else
Version:        %{_version}
%endif
%if "0%{?_release}" == "0"
Release:        2%{?dist}
%else
Release:        %{_release}
%endif
License:        GPL-2.0
Vendor:         Percona LLC
URL:            https://percona.com
Source0:        https://%{import_path}/archive/v%{version}/%{repo}-v%{version}.tar.gz
BuildRequires:  golang

Requires: perl-DBI, perl-DBD-MySQL, MariaDB-shared

%description
Percona Toolkit (Shattered Silicon Build)

%prep
%setup -q -n %{repo}-%{version}

%build
mkdir -p %{_GOPATH}/bin
export GOPATH=%{_GOPATH}

go install -ldflags="-s -w" ./src/go/...
%{__cp} bin/* %{_GOPATH}/bin

strip %{_GOPATH}/bin/* || true

%install
install -m 0755 -d $RPM_BUILD_ROOT/usr/bin
install -m 0755 %{_GOPATH}/bin/pt-* $RPM_BUILD_ROOT/usr/bin/

%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/bin/pt-*
