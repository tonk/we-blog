Name:           we-blog
Version:        1.0
Release:        1%{?dist}
Summary:        A simple to use but capable CMS for the command line

Group:          Applications/Publishing
# The application is GPLv3 while the man pages are GFDL
License:        GPLv3 and GFDL
Source0:	%{name}-%{version}.tgz
URL:            http://www.tonkersten.com/%{name}
BuildRoot:       %{_buildroot}
BuildArch:      noarch

%description
Written in Perl as a cross-platform application and producing
the static content without the need of database servers or
server side scripting, We-Blog is literally a CMS without
boundaries suitable for a wide variety of web presentations,
from personal weblog to a project page or even a company presentation.

%prep
%setup -q


%build


%install
rm -rf %{buildroot}
make install prefix=%{buildroot}/usr config=%{buildroot}/etc


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc AUTHORS ChangeLog COPYING FDL
%{_bindir}/we-blog*
%{_bindir}/wb
%{_bindir}/We.pm
%{_datadir}/we-blog/
%{_mandir}/man1/we-blog*.1*
%{_sysconfdir}/bash_completion.d/we-blog


%changelog
* Mon Jun 10 2013 First RPM build <github@tonkersten.com>
- Initial RPM build
