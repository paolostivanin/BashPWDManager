#!/bin/bash

#################################################################
# @Author: Paolo Stivanin aka Polslinux
# @Name: Bash Password Manager Configuration Script
# @Copyright: 2012
# @Site: http://www.polslinux.it
# @License: GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
#################################################################

BACKIFS=$IFS
IFS=$'\n'
conf_file="/home/$USER/.config/bpwdman.conf"

function exit_script(){
if [ $? != "0" ] ; then
 if [ -f /$conf_file ] ; then
  rm $conf_file
 fi
exit 0
fi
}

function disable_useagent(){
if [ -f /home/$USER/.gnupg/gpg.conf ]; then
 local first_char=$(cat /home/$USER/.gnupg/gpg.conf | grep use-agent | cut -f1 -d ' ')
 if [ "$first_char" != "#" ] ; then
  echo "using-agent=yes" >> $conf_file
 fi
fi
}

function retype_pass(){
pass=$(yad --entry --hide-text --title "DB Password" --text "Type your database password" --image="dialog-password")
check_pwd_char
}

function check_pwd_char(){
if [ ${#pass} -lt 8 ] ; then
 yad --title "Error" --text "Your password characters are ${#pass}.
You MUST choose a password equal or greater than 8 charactes. 
Thanks :)"
 retype_pass
fi
}

function first_encryption(){
local typ_algo=$(echo $typ | tr '[A-Z]' '[a-z]')
openssl aes-256-cbc -a -salt -pass pass:$pass -in $db_dir/$db_name.bpm -out $db_dir/enc_db_openssl
mv $db_dir/enc_db_openssl $db_dir/$db_name.bpm
echo $pass | gpg --passphrase-fd 0 -o $db_dir/enc_db --cipher-algo=$typ -c $db_dir/$db_name.bpm
mv $db_dir/enc_db $db_dir/$db_name.bpm
}

function save_db_path(){
yad --text "Do you want to save the path of the DB so every time you
start the script you won't have to select it?" --title "Save DB path?" --width=410 --button=Yes --button=No
if [ $? = 0 ] ; then
 echo "database-path=$db_dir/$db_name.bpm" >> $conf_file   
else
 echo "database-path=0" >> $conf_file
fi
}

function fine_prog(){
IFS=$BACKIFS
exit 0
}

if [ $(id -u) = 0 ] ; then
 yad --title "Error" --text "You can't start this script as root."
 exit 0
fi

if [ ! -f $conf_file ] ; then
 typ=$(yad --list --column="Cipher Algo" cast5 3des aes256 twofish blowfish --separator="" --height=200 --width=180)
 exit_script
 echo "algo=$typ" >> $conf_file
 db_dir=$(yad --file --directory --title "Choose database directory" --width=800 --height=600)
 exit_script
 db_name=$(yad --entry --title "Database name" --text "Write the name of your database")
 exit_script
 db_name_tmp=$(echo $db_name | sed 's/ //g')
 if [ -z "$db_name_tmp" ]; then
   yad --title "Error" --text "You cannot create DB with no name"
   rm -f $conf_file
   exit 1
 fi
 echo "database-name=$db_name.bpm" >> $conf_file
 touch $db_dir/$db_name.bpm
 pass=$(yad --entry --hide-text --title "DB Password" --text "Type your database password" --image="dialog-password")
 check_pwd_char
 echo "db_created=1" >> $conf_file
 save_db_path
 disable_useagent
 first_encryption
 yad --text "Bash Password Manager has been configured :)" --title "Finish" --width=310
 fine_prog
 elif [ -f $conf_file ] ; then
 yad --text "Bash Password Manager has already been configured :)" --title "Finish" --width=310
fi
