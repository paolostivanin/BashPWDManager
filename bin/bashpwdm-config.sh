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

function retype_pass(){
pass=$(yad --form --field "Password:H" --field "Retype Password:H" --separator="@_@" --title "Password" --image="dialog-password")
exit_script
if [ $(echo $password | awk -F"@_@" '{print $1}') != $(echo $password | awk -F"@_@" '{print $2}') ];then
 yad --title "Error" --text "Passwords are different. Please try again"
 retype_pass
fi
check_pwd_char
}

function check_pwd_char(){
if [ ${#pass} -lt 8 ] ; then
 yad --title "Error" --text "Your password characters are ${#pass}.
You <b>MUST</b> choose a password <b>equal or greater than 8 charactes</b>. 
Thanks :)"
 retype_pass
fi
}

function first_encryption(){
local typ_algo=$(echo $typ | tr '[A-Z]' '[a-z]')
openssl aes-256-cbc -a -salt -pass pass:$pass -in $db_dir/${db_name}.bpm -out $db_dir/enc_db_openssl
mv $db_dir/enc_db_openssl $db_dir/${db_name}.bpm
echo $pass | gpg --passphrase-fd 0 -o $db_dir/enc_db --cipher-algo=$typ -c $db_dir/${db_name}.bpm
mv $db_dir/enc_db $db_dir/${db_name}.bpm
}

function save_db_path(){
yad --text "Do you want to save the path of the DB so every time you
start the script you won't have to select it?" --title "Save DB path?" --width=410 --button=Yes --button=No
if [ $? = 0 ] ; then
 echo "database-path=$db_dir/${db_name}.bpm" >> $conf_file   
else
 echo "database-path=0" >> $conf_file
fi
}

function create_db(){
STRUCTURE="CREATE TABLE main (title TEXT,username TEXT,password TEXT);";
cat /dev/null > ${db_dir}/${db_name}.bpm
echo $STRUCTURE > /tmp/tmpstruct
sqlite3 ${db_dir}/${db_name}.bpm < /tmp/tmpstruct;
rm -f /tmp/tmpstruct
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
   yad --title "Error" --text "You cannot create DB with no name, exiting..."
   rm -f $conf_file
   exit 1
 fi
 echo "database-name=${db_name}.bpm" >> $conf_file
 create_db
 pass=$(yad --form --field "Password:H" --field "Retype Password:H" --separator="@_@" --title "Password" --image="dialog-password")
 exit_script
 if [ $(echo $password | awk -F"@_@" '{print $1}') != $(echo $password | awk -F"@_@" '{print $2}') ];then
  yad --title "Error" --text "Passwords are different. Please try again"
  retype_pass
 fi
 check_pwd_char
 echo "db_created=1" >> $conf_file
 save_db_path
 first_encryption
 yad --text "Bash Password Manager has been configured :)" --title "Finish" --width=310
 fine_prog
 elif [ -f $conf_file ] ; then
 yad --text "Bash Password Manager has already been configured :)" --title "Finish" --width=310
fi
