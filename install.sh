#!/bin/bash

################################################################
# @Author:      Paolo Stivanin aka Polslinux       
# @Name:        Bash Password Manager Install Script
# @Copyright:   2012
# @Site:        http://projects.polslinux.it                          
# @License:     GNU AGPL v3 http://www.gnu.org/licenses/agpl.html  
################################################################

distro=$(cat /etc/issue | cut -d' ' -f1 -s)
check_user=0
check_app=0
app_install=""
username=""
declare -A application
application=(
	   ["bash"]="$(which bash 2>/dev/null)"
	   ["wget"]="$(which wget 2>/dev/null)"
	   ["gpg"]="$(which gpg 2>/dev/null)"
	   ["yad"]="$(which yad 2>/dev/null)"
	   ["openssl"]="$(which openssl 2>/dev/null)")
app_yad="$(which yad 2>/dev/null)"

echo -e "* Checking user's privileges...\n"
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
    echo "--> Username don't exists! Please insert a valid username."
    fi
  done
fi

echo -e "\n* Checking type of your linux distros..."
if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ] || [ "$distro" = "Arch" ] || [ "$(cat /etc/issue | cut -d' ' -f2 -s)" = "Linux Mint" ]; then
	echo "   Ok, you're running a compatible distro :)"
else
	echo  "   WARNING: Secure Delete is tested to work with Debian, Ubuntu, Linux Mint and Archlinux,"
	echo  "   try it on your system and tell me if there is something wrong!"
fi

echo -e "\n* Checking deps..."
for key in "bash" "wget" "gpg" "openssl" "yad"; do
  if [ -n "${application[$key]}" ]; then
    echo "   -  Package [ $key ] => [ OK ]"
  else
    echo "   -  Package [ $key ] => [ Not Found ]"
    check_app=1
    app_install="$key $app_install"
  fi
done
if [ $check_app -eq 1 ]; then
  echo -e "\n* ERROR: you have to install yad curl wget bash and wipe before you"
  echo "  can you this script!"
  echo -e "\n* Please open a terminal and write:"
  if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ] || [ "$(cat /etc/issue | cut -d' ' -f2 -s)" = "Linux Mint" ];then
    echo "--> sudo apt-get install $app_install"
    if [ ! -n "${app_yad}" ];then
      echo "Ubuntu/Debian/Mint ecc doesn't have yad into their"
      echo "official repo. You have to manually install yad or"
      echo "you can use my script that will do this for you :)"
      echo "Type Y if you want to auto-install yad or type N"
      echo "if you want to do this manually."
      echo "Please write Y or N:"
      read ans_yad
      case "$ans_yad" in
	  [yY]|[eE]|[sS]) chmod +x $PWD/yad_install.sh
			  source yad_install.sh ;;
	       [nN]|[oO]) echo "You have choose to MANUALLY install yad" ;;
		       *) echo "You have choose to AUTO-INSTALL yad, please wait..."
		          chmod +x $PWD/yad_install.sh
		          source yad_install.sh ;;
      esac
    fi
    elif [ "$distro" = "Arch" ];then
      echo "--> sudo (or su) pacman -S $app_install"
      if [ ! -n "${app_yad}" ];then
	echo "yad is present into AUR so type into a terminal:"
	echo "--> yaourt -S yad"
      fi
  fi
  exit 1
fi

echo "* Installing files..."
if [ ! -d /usr/share/doc/bash-pwd-manager ] ; then
 mkdir /usr/share/doc/bash-pwd-manager
fi
cp LICENSE README uninstall.sh yad_install.sh docs/* /usr/share/doc/bash-pwd-manager
cp bin/bashpwdm.sh /usr/local/bin/bashpwdm
cp bin/bashpwdm-config.sh /usr/local/bin/bashpwdm-config
cp bin/bashpwdm_update.sh /usr/local/bin/bashpwdm_update
cp docs/bashpwdm.desktop /usr/share/applications/
cp docs/bpwdm.png /usr/share/pixmaps/
chown $username /usr/local/bin/bashpwdm
chown $username /usr/local/bin/bashpwdm-config
chown $username /usr/local/bin/bashpwdm_update
chmod +x /usr/local/bin/bashpwdm
chmod +x /usr/local/bin/bashpwdm-config
chmod +x /usr/local/bin/bashpwdm_update
echo -e "\n ** --> Please note that if you want better KDE integration you have to install oxygen-gtk <-- **"
echo -e "\n* Ok, all done! Now you can use Bash PWD Manager :)"
exit 0
