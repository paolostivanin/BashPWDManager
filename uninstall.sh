#!/bin/bash

################################################################
# @Author:    Paolo Stivanin aka Polslinux       
# @Name:      Bash Password Manager Uninstall Script
# @Copyright: 2012
# @Site:      http://www.polslinux.it                          
# @License:   AGNU GPL v3 http://www.gnu.org/licenses/agpl.html  
################################################################

distro=$(cat /etc/issue | cut -d' ' -f1 -s)

echo "--> Checking user's privileges..."
if [ $(id -u) != 0 ]; then 
  echo "--> ERROR: User $(whoami) is not root, and does not have sudo privileges"
  if [ "$distro" = "Debian" ] ; then echo "--> Type su in the terminal and re-run this script"
  elif [ "$distro" = "Ubuntu" ] ; then echo "--> Type sudo su in the terminal and re-run this script"
  elif [ "$distro" = "Arch" ] ; then echo "--> Type su in the terminal and re-run this script"
  fi
  exit 1
else
  while [ $check_user -eq 0 ]; do
    echo "--> Write your exact username:"
    read username
    id -u -r $username &> /dev/null
    if [ $? -eq 0 ]; then
      check_user="1"
    else
    echo "--> Username doesn't exist! Please write a valid username."
    fi
  done
fi

echo "--> Removing files..."
  if [ -d /usr/share/doc/bash-pwd-manager ] ; then
   rm -r /usr/share/doc/bash-pwd-manager
  fi
  if [ -f /usr/local/bin/bashpwdm.sh ] ; then
   rm -f /usr/local/bin/bashpwdm.sh
  fi
  if [ -f /usr/local/bin/bashpwdm-config.sh ] ; then
   rm -f /usr/local/bin/bashpwdm-config.sh
  fi
  if [ -f /usr/local/bin/bashpwdm-update.sh ] ; then
   rm -f /usr/local/bin/bashpwdm-update.sh
  fi
  if [ -f /usr/share/applications/bashpwdm.desktop ] ; then
   rm -f /usr/share/applications/bashpwdm.desktop
  fi
  if [ -f /usr/share/pixmaps/bpwdm.png ] ; then
   rm -f /usr/share/pixmaps/bpwdm.png
  fi
fi
echo -e "\n--> Uninstalling done. Thanks to have used my script! Bye bye :)"
exit 0
