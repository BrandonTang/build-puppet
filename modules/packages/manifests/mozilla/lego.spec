Summary:        lego rpm package
Name:           lego
Version:        0.3.1
Release:        28ead50ff1ca93acdb62734d3ed8da0206d036ff
License:        MIT
Source0:        https://github.com/xenolf/lego/archive/%{release}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-build
Group:          mozilla

%description
%{summary}

%prep
%setup -n lego

%build
export GOPATH=%{buildroot}/go
go get -v
env GOOS=linux GOARCH=amd64 go build

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
