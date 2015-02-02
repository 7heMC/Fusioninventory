Fusioninventory
==========

Everything you need to use and deploy FusionInventory-agent on OSX 
Tested on 10.8.x / 10.9.X / 10.10.x

####In daemon mode the "Force Inventory" link ( http://127.0.0.1:62354 ) not work well in Safari. Please use Firefox or Chrome to use this link.####

More info at http://www.fusioninventory.org

• Build_Fusioninventory_OSX_Flavor.sh

1. Copy script in a folder on your "build machine"
2. Launch terminal and type : `cd path_to_the_folder`
3. then type `sudo ./Build_FusionInventory_OSX_Flavor.sh`
4. Follow script instructions and wait a little

Major step :

-> Install Xcode command line tools

-> Install Perlbrew

-> Install Perl 5.16.2 in Perlbrew

-> Install CPANM in Perl 5.16.2 (in Perlbrew)

-> Install or update modules in Perl 5.16.2 (in Perlbrew)

-> Download FusionInventory-agent sources from https://cpan.metacpan.org/authors/id/G/GR/GROUSSE/

-> Tweak default agent.cfg for OSX

-> Create "source folder" with files ready to copy or package

-> Optional : create a simple package for test, after your package install copy /Library/Preferences/fusioninventory/agent.cfg.default to /Library/Preferences/fusioninventory/agent.cfg and edit with your settings

-> Optional : create an ARD-ready package (with autostart at login) 

-> Optional : edit TAG and server URL for your first deployment package. You can run configure.command later (in Deploy folder) to configure new deploy package
