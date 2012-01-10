#!/bin/bash

#################################################################
# @Author: Paolo Stivanin aka Polslinux
# @Name: Bash Password Manager Configuration Script
# @Copyright: 2011
# @Site: http://projects.polslinux.it
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
pass=$(zenity --entry --title "DB Password" --text "Choose your DB password" --hide-text)
check_pwd_char
}

function check_pwd_char(){
if [ ${#pass} -lt 8 ] ; then
 zenity --error --title "Password characters" --text "Your password characters are ${#pass}.
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
zenity --question --text "Do you want to save the path of the DB so every time you
start the script you won't have to select it?" --title "Save DB path?" --width=410 --ok-label=Yes --cancel-label=No
if [ "$?" = 0 ] ; then
 echo "database-path=$db_dir/$db_name.bpm" >> $conf_file   
else
 echo "database-path=0" >> $conf_file
fi
}

function fine_prog(){
IFS=$BACKIFS
exit 0
}

if [ "$user" = 0 ] ; then
 zenity --error --title "Error" --text "You can't start this script as root."
 exit 0
fi

if [ ! -f $conf_file ] ; then
 typ=$(zenity  --list  --text "What type of cipher algo do you want to use?" --radiolist  --column "Choice" --column "Type" TRUE CAST5 FALSE 3DES FALSE AES256 FALSE TWOFISH FALSE BLOWFISH)
 exit_script
 echo "algo=$typ"  | tr '[A-Z]' '[a-z]' >> $conf_file
 db_dir=$(zenity --file-selection --directory --title "Choose database directory")
 exit_script
 db_name=$(zenity --entry --title "Database name" --text "Write the name of your database")
 exit_script
 db_name_tmp=$(echo $db_name | sed 's/ //g')
 if [ -z "$db_name_tmp" ]; then
   zenity --error --title "Error" --text "You cannot create DB with no name"
   rm -f $conf_file
   exit 1
 fi
 echo "database-name=$db_name.bpm" >> $conf_file
 touch $db_dir/$db_name.bpm
 pass=$(zenity --entry --title "DB Password" --text "Choose your DB password" --hide-text)
 check_pwd_char
 echo "db_created=1" >> $conf_file
 save_db_path
 disable_useagent
 first_encryption
 zenity --info --text "Bash Password Manager has been configured!" --title "All done!" --width=400
 fine_prog
 elif [ -f $conf_file ] ; then
 zenity --info --text "Bash Password Manager has already been configured!" --title "All done!" --width=400
fi
