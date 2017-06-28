Summary:        lego rpm package
Name:           lego
Version:        0.3.1
Release:        1
# License is a compulsory field so you have to put something there.
License:        MIT
Source0:        lego_linux_amd64.tar.xz
BuildRoot:      %{_tmppath}/%{name}-build
Group:          mozilla

%description
%{summary}

%prep
%setup -n lego

%build
# nothing

%install
base=$RPM_BUILD_ROOT/tools/lego
mkdir -p $base
install -m 755 lego $base

%post
# nothing

%clean
rm -rf $RPM_BUILD_ROOT
rm -rf %{_tmppath}/%{name}
rm -rf %{_topdir}/BUILD/%{name}

# list files owned by the package here
%files
%defattr(-,root,root)
/tools/%{name}/lego
