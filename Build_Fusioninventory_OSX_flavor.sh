#!/bin/bash

# Version 1.1 by Sylvain La Gravière
# Twitter : @darkomen78
# Mail : darkomen@me.com

# Change with the latest stable version 
FI_VERSION="2.3.15"

# Source base URL
FUSIONSRC="https://cpan.metacpan.org/authors/id/G/GR/GROUSSE/"
PACKAGESSRC="http://s.sudre.free.fr/Software/files/Packages.dmg"
GITSRC="https://raw.github.com/Darkomen78/Fusioninventory/master/source"

# Perl Version : Lion 5.12.3 - Mountain Lion 5.12.4 - Maverick 5.16.2 - Yosemite 5.18.2
# Install this version in perlbrew, must work on 10.8+
OSXPERLVER=5.16.2

# Temporary local source folder
FI_DIR="FusionInventory-Agent-$FI_VERSION"

# Temporary Packages files
PROJ="Proj_FusionInventory_$FI_VERSION.zip"
DEPLOYPROJ="Proj_FusionInventory_deploy_$FI_VERSION.zip"

# Default paths for OSX
INSTALL_PATH='/usr/local/fusioninventory'
CONFDIR_PATH='/Library/Preferences/fusioninventory'
DATADIR_PATH='/usr/local/fusioninventory/share'
# Current dir
ROOTDIR="`pwd`"
# Local final folder 
SRCDST="$ROOTDIR/Source_$FI_VERSION"


# Perlbrew install path and mandatory variables
PERLBREWROOTDST=$INSTALL_PATH
PERLBREW_ROOT=$PERLBREWROOTDST/perlbrew
export PERLBREW_ROOT=$PERLBREWROOTDST/perlbrew
PERLBREW_HOME=/tmp/.perlbrew
if [ -f $PERLBREW_ROOT/etc/bashrc ]; then
	source $PERLBREW_ROOT/etc/bashrc
fi

if [ ! -d /Library/Developer/CommandLineTools ]; then
	clear
	echo "Xcode command line tools not found, install it..."
	xcode-select --install
	read -p "When Xcode command line tools install is finish, relaunch this script" -t 5
	echo
	exit 0
fi

if [ ! -d $PERLBREWROOTDST ]; then
	clear
	echo "Perlbrew not found, install it..."
	curl -L 'http://install.perlbrew.pl' | bash
	read -p "Perlbrew install is OK. Quit and restart Terminal, then relaunch this script" -t 5
	echo
	exit 0
fi

if [ ! -d "$PERLBREW_ROOT"/perls/perl-"$OSXPERLVER" ]; then
	clear
	echo "Perl $OSXPERLVER in Perlbrew not found, install it... take a cup of tea or coffee"
	perlbrew install perl-$OSXPERLVER
	read -p "Perl $OSXPERLVER install is finish, relaunch this script" -t 5
	echo
	exit 0
fi

if [ -d $PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER ]; then
	clear
	echo "################## Switch to Perl version $OSXPERLVER #######################"
	perlbrew switch "$OSXPERLVER"
fi

if [ ! -f $PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER/bin/cpanm ]; then
	clear
	echo "cpanm in Perlbrew not found, install it..."
	cpan -i App::cpanminus
fi


read -p "----------------> Update required modules... ? [Y] " -n 1 -r UPDMOD
echo
if [[ $UPDMOD =~ ^[Nn]$ ]]; then
	echo "...skip update modules"
else
	"$PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER/bin/cpanm" -i --force File::Which LWP Net::IP Text::Template UNIVERSAL::require XML::TreePP Compress::Zlib HTTP::Daemon IO::Socket::SSL Parse::EDID Proc::Daemon Proc::PID::File HTTP::Proxy HTTP::Server::Simple::Authen IPC::Run JSON Net::SNMP POE::Component::Client::Ping POSIX IO::Capture::Stderr LWP::Protocol::https Test::Compile Test::Deep Test::Exception Test::HTTP::Server::Simple Test::MockModule Test::MockObject Test::NoWarnings
fi

if [ ! -f /tmp/$FI_VERSION.tar.gz ]; then
	cd /tmp/
	curl -O -L $FUSIONSRC$FI_DIR.tar.gz && echo "Download $FI_DIR"
fi

echo "Empty destination folder"
rm -Rf $INSTALL_PATH/bin
rm -Rf $INSTALL_PATH/share
tar xzf $FI_DIR.tar.gz && rm $FI_DIR.tar.gz
cd /tmp/$FI_DIR

echo "Temporary install..."
export SYSCONFDIR="$CONFDIR_PATH" 
export DATADIR="$DATADIR_PATH"
perl Makefile.PL -I lib SYSCONFDIR="$CONFDIR_PATH" DATADIR="$DATADIR_PATH"
make
make install PREFIX="$INSTALL_PATH"
cpanm --installdeps -L extlib --notest .

echo "Rename default agent.cfg file to use later with OSX package postinstall script"
mv $CONFDIR_PATH/agent.cfg $CONFDIR_PATH/agent.cfg.default
echo "######################################"
echo "Modify agent.cfg.default"
echo "######################################"
echo "Add 127.0.0.1 in httpd-trust"
sed -i "" "s/httpd-trust =/httpd-trust = 127.0.0.1/g" $CONFDIR_PATH/agent.cfg.default
echo "######################################"
echo "Change backend timeout from 30 to 180"
sed -i "" "s/backend-collect-timeout = 30/backend-collect-timeout = 180/g" $CONFDIR_PATH/agent.cfg.default
echo "######################################"

echo "Move files to source folder for packages..."
if [ ! -d $SRCDST ]; then
	mkdir $SRCDST
else 
	if [ -d "$SRCDST""_previous" ]; then
		rm -Rf "$SRCDST""_previous"
	fi
	mv "$SRCDST" "$SRCDST""_previous"
	mkdir $SRCDST
fi
cd $SRCDST
mkdir -p ."$CONFDIR_PATH"
mkdir -p ."$INSTALL_PATH"
read -p "----------------> Delete temporary files ? [N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "...remove temporary files"
	rm -Rf /tmp/$FI_DIR
	cp -R "$CONFDIR_PATH/"* ."$CONFDIR_PATH/" && rm -Rf "$CONFDIR_PATH"
	cp -R "$INSTALL_PATH/"* ."$INSTALL_PATH/" && rm -Rf "$INSTALL_PATH"
else
	cp -R "$CONFDIR_PATH/"* ."$CONFDIR_PATH/"
	cp -R "$INSTALL_PATH/"* ."$INSTALL_PATH/"
fi
chmod -R 775 "$SRCDST"

# Remove heavy useless files
rm -Rf .$PERLBREW_ROOT/build
rm -Rf .$PERLBREW_ROOT/dists
rm -Rf .$PERLBREW_ROOT"/perls/perl-"$OSXPERLVER/man

chmod -R 775 "$ROOTDIR"
cd "$ROOTDIR"
echo "Files copied in $SRCDST"
echo
read -p "----------------> Create standard package ? [Y] " -n 1 -r PKG
echo
if [[ $PKG =~ ^[Nn]$ ]]; then
	echo "...skip create standard package"
else	
	if [ ! -d /Applications/Packages.app ]; then
		echo "No Packages install found, install it..."
		cd /tmp/
		curl -O -L $PACKAGESSRC && echo "Download Stéphane Sudre's Packages install"
		hdiutil mount /tmp/Packages.dmg && echo "Mount Packages install"
		/usr/sbin/installer -dumplog -verbose -pkg "/Volumes/Packages/packages/Packages.pkg" -target / && echo "Install Packages" && hdiutil unmount /Volumes/Packages/ && echo "Unmount Packages install"
		cd "$ROOTDIR"
	fi
	if [ ! -f "FusionInventory_$FI_VERSION.pkgproj" ]; then	
		echo "FusionInventory_$FI_VERSION.pkgproj not found, download it..."
		curl -O -L "$GITSRC$PROJ"
		unzip "$PROJ" && rm "$PROJ"
	fi
/usr/local/bin/packagesbuild -v "FusionInventory_$FI_VERSION.pkgproj" && rm "FusionInventory_$FI_VERSION.pkgproj"
chmod -R 775 ./build
open ./build
fi
read -p "----------------> Create vanilla deployment package ? [Y] " -n 1 -r DEPLOY
echo
if [[ $DEPLOY =~ ^[Nn]$ ]]; then
	echo "...skip create deployment package"
	echo
	exit 0
else	
	if [ ! -d /Applications/Packages.app ]; then
		echo "No Packages install found, install it..."
		cd /tmp/
		curl -O -L $PACKAGESSRC && echo "Download Stéphane Sudre's Packages install"
		hdiutil mount /tmp/Packages.dmg && echo "Mount Packages install"
		/usr/sbin/installer -dumplog -verbose -pkg "/Volumes/Packages/packages/Packages.pkg" -target / && echo "Install Packages" && hdiutil unmount /Volumes/Packages/ && echo "Unmount Packages install"
		cd "$ROOTDIR"
	fi
	if [ ! -f "FusionInventory_deploy_$FI_VERSION.pkgproj" ]; then	
		echo "FusionInventory_deploy_$FI_VERSION.pkgproj not found, download it..."
		curl -O -L "$GITSRC$DEPLOYPROJ"
		unzip "$DEPLOYPROJ" && rm "$DEPLOYPROJ"
	fi
	if [ ! -d "./Deploy" ]; then
		curl -O -L "$GITSRC"Deploy.zip
		unzip "Deploy.zip" && rm "Deploy.zip"
	fi
	if [ ! -d "./source_deploy" ]; then
		curl -O -L "$GITSRC"source_deploy.zip
		unzip "source_deploy.zip" && rm "source_deploy.zip"
	fi
	rm -R ./__MACOSX
	/usr/local/bin/packagesbuild -v "FusionInventory_deploy_$FI_VERSION.pkgproj" && rm "FusionInventory_deploy_$FI_VERSION.pkgproj" && rm -R ./source_deploy
	chown -R root:staff ./Deploy && chmod -R 775 ./Deploy && open ./Deploy
	read -p "----------------> Configure your first deployment package ? [Y] " -n 1 -r CONF
	echo
	if [[ $CONF =~ ^[Nn]$ ]]; then
		echo "...skip configure deployment package"
		echo	
		exit 0
	else
		open ./Deploy/"Configure.command"	
	fi
fi
echo
exit 0	