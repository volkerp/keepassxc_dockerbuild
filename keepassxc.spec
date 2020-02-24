Name:		keepassxc
Version:	%{_version}
Release:	1%{?dist}
Summary:	KeePassXC password manager

Group:		Unspecified
License:	GPL-2 or GPL-3
URL:		https://keepassxc.org/

#BuildRequires:	
#Requires:	

%description


%prep


%build


%install
cd /keepassxc-%{_version}/build
make DESTDIR=%{?buildroot} install 


%files
%{_destdir}

%doc

%changelog

