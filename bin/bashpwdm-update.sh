#!/bin/bash

#################################################################
# @Author:    Paolo Stivanin aka Polslinux
# @Name:      Bash PWD Manager Update Script      
# @Copyright: 2012
# @Site:      http://www.polslinux.it
# @License:   GNU GPL v3 http://www.gnu.org/licenses/gpl.html 
#################################################################

BACKIFS=$IFS
check_user=0
IFS=$'\n'
distro=$(cat /etc/issue | cut -d' ' -f1 -s)

function end_update(){
rm -f /tmp/version
rm -r /tmp/bashpwdm_tmp
rm -f bashpwdm_v$last_version.tar.bz2
IFS=$BACKIFS
exit 0
}

function no_update(){
echo "--> Bash Password Manager is already up-to-date :)"
exit 0
}

function check_bsdtar(){
status=$(which bsdtar)
if [ -z "$status" ];then
 yad --title "Error" --text "** You have to install BSDTAR before continue **"
 exit 0
fi
}

function check_update(){
 last_version=$(cd /tmp && wget --no-check-certificate https://raw.github.com/polslinux/Secure-Delete/master/docs/version &>/dev/null && cat version | grep -Eo '[0-9\.]+')
 echo "--> Checking Secure Delete version..."
 echo "--> Your version is $version
--> Newest version is $last_version"
if [ "$version" != "$last_version" ] ; then
 update_bashpwdm
else
 no_update
fi
}

function update_bashpwdm(){
while [ $check_user -eq 0 ]; do
 echo "--> Write your exact username:"
 read username
 id -u -r $username &> /dev/null
 if [ $? -eq 0 ]; then
  check_user="1"
 else
  echo "** Username don't exists! Please insert a valid username **"
 fi
done
echo "--> Updating Bash Password Manager, please wait..."
cd /tmp && mkdir bashpwdm_tmp
cd bashpwdm_tmp && wget https://github.com/downloads/polslinux/BashPWDManager/bashpwdm_v$last_version.tar.bz2 &>/dev/null
tar -xjf bashpwdm_v$last_version.tar.bz2
cp LICENSE uninstall docs/* /usr/share/doc/bash-pwd-manager
cp bin/bashpwdm.sh /usr/local/bin
cp bin/bashpwdm-config.sh /usr/local/bin
cp bin/bashpwdm-udpate.sh /usr/local/bin
chown $username /usr/local/bin/bashpwdm.sh
chown $username /usr/local/bin/bashpwdm-config.sh
chown $username /usr/local/bin/bashpwdm-update.sh
chmod +x /usr/local/bin/bashpwdm.sh
chmod +x /usr/local/bin/bashpwdm-config.sh
chmod +x /usr/local/bin/bashpwdm-update.sh
echo "--> All done, Bash PWD Manager has been updated :)"
}

if [ $(id -u) != 0 ]; then 
 echo "** ERROR: please run update script as ROOT **"
 exit 1
fi
check_bsdtar
check_update
end_update
