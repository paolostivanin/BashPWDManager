#!/bin/bash

###############################################################################
# @Author	:  Paolo Stivanin aka Polslinux
# @Name		:  Yad Install Script
# @Copyright	:  2012
# @Site		:  http://www.polslinux.it                        
# @License	:  GNU GPL v3 http://www.gnu.org/licenses/gpl.html 
###############################################################################

work_dir=$(mktemp -d --tmpdir=/tmp yad-install.XXXXXX)
yad_ver=0.17.1.1

echo "BEFORE INSTALLING YAD PLEASE INSTALL THESE DEPS:
automake
autoconf
intltool
libgtk2.0-dev"
echo "Have you already installed all of these? (Y or N)"
read ans
case "$ans" in
    [yY]|[yY][eE][sS]) echo "--> Ok, let's go :)";;
    [nN]|[nN][oO]) echo "The script will exit, please install required deps."
	      exit 1;;
	   *) echo "Exiting..."
	      exit 1;;
esac
echo "--> Downloading YAD, please wait..."
cd $work_dir
wget http://yad.googlecode.com/files/yad-${yad_ver}.tar.xz &>/dev/null
echo "--> Extracting archive..."
tar xJf yad-${yad_ver}.tar.xz
cd yad-${yad_ver}
echo "--> Now running configure..."
./configure --prefix=/usr
echo "--> Now runnning make..."
make || return 1
echo "--> Please enter your ROOT PASSWORD to install yad."
sudo make install || return 1
rm -r $work_dir
echo "--> All done :)"
exit 0
