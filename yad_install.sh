#!/bin/bash

###############################################################################
# @Author & Main Developer:  Paolo Stivanin aka Polslinux
# @Name			  :  Yad Install Script
# @Copyright		  :  2012
# @Site			  :  http://www.polslinux.it                        
# @License		  :  GNU AGPL v3 http://www.gnu.org/licenses/agpl.html 
###############################################################################

work_dir=$(mktemp -d --tmpdir=/tmp yad-install.XXXXXX)

echo "--> BEFORE INSTALLING YAD PLEASE INSTALL THESE DEPS:
automake
autoconf
intltool"
echo "--> Have you already installed all of these? (Y or N)"
read ans
case "$ans" in
    [yY]|[eE]|[sS]) echo "--> Ok, let's go :)" ;;
	 [nN]|[oO]) echo "--> The script will exit, please install required deps."
		    exit 1 ;;
		 *) echo "--> Exiting..."
	      exit 1 ;;
esac
echo "--> Downloading YAD, please wait..."
cd $work_dir
wget http://yad.googlecode.com/files/yad-0.17.1.1.tar.xz &>/dev/null
echo "--> Extracting archive..."
tar xJf yad-0.17.1.1.tar.xz
cd yad-0.17.1.1
echo "--> Now running configure..."
./configure --prefix=/usr
echo "--> Now runnning make..."
make || return 1
echo "--> Now installing..."
echo "--> Please enter your ROOT PASSWORD to install yad."
sudo make install || return 1
rm -r $work_dir
echo "--> All done :)"
exit 0
