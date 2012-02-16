#!/bin/bash

#################################################################
# @Author: Paolo Stivanin aka Polslinux
# @Name: Bash Password Manager
# @Copyright: 2012
# @Site: http://www.polslinux.it
# @License: GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
#################################################################

BACKIFS=$IFS
IFS=$'\n'
version="2.0-alpha1~experimental"
conf_file="/home/$USER/.config/bpwdman.conf"


function exit_script(){
if [ $? != 0 ] ; then
 type_of=$(file $file_db | cut -f2 -d':' | sed '/ /s/^ //' | cut -f1 -d' ')
 if [ "$type_of" = "ASCII" ]; then
  encrypt_db
 fi
 exit 0
fi
}

function check_gpg_openssl_pwd_encrypt(){
if [ $? != 0 ] ; then
 yad --title "Password Error" --text "You have entered a wrong password, try again!" --width=450 --height=150
 pass=$(yad --entry --hide-text --title "DB Password" --text "Type your database password" --image="dialog-password")
 encrypt_db
fi
}

function check_gpg_openssl_pwd_decrypt(){
if [ $? != 0 ] ; then
 yad --title "Password Error" --text "You have entered a wrong password, try again!" --width=450 --height=150
 pass=$(yad --entry --hide-text --title "DB Password" --text "Type your database password" --image="dialog-password")
 decrypt_db
fi
}

function retype_nchar(){
nchar=$(yad --entry --title="Character" --text="Write the number of password's characters (>= 8):" --numeric 8 65000 | cut -f1 -d',')
check_pwd_char
}

function check_pwd_char(){
if [ $nchar -lt 8 ] ; then
 yad --title "ERROR" --text "You have choosen few password's characters, please choose a number >=8"
 retype_nchar
fi
}

function check_db(){
path_to_db=$(cat $conf_file | grep database-path | cut -f2 -d'=')
if [ $path_to_db = 0 ]; then
 file_db=$(yad --file --title "Choose database" --width=800 --height=600)
else
 file_db=$(cat $conf_file | grep database-path | cut -f2 -d'=')
 exit_script
fi
crypto_algo=$(cat $conf_file | grep algo | cut -f2 -d'=')
path_db=$(dirname $file_db)
local permission=$(ls -l $file_db | cut -f2 -d'-')
if [ ! -f $file_db ] || [ "$permission" != "rw" ]; then
 yad --text "Database doesn't exist or hasn't read & write permissions." --title "Database Error"
 exit 1
fi
}

function decrypt_db(){
echo $pass | gpg --passphrase-fd 0 -o $path_db/out_db_gpg --cipher-algo=$crypto_algo -d $file_db
check_gpg_openssl_pwd_decrypt
mv $path_db/out_db_gpg $file_db
openssl aes-256-cbc -d -a -pass pass:$pass -in $file_db -out $path_db/out_db
check_gpg_openssl_pwd_decrypt
mv $path_db/out_db $file_db
}

function encrypt_db(){
openssl aes-256-cbc -a -salt -pass pass:$pass -in $file_db -out $path_db/enc_db_openssl
check_gpg_openssl_pwd_encrypt
mv $path_db/enc_db_openssl $file_db
echo $pass | gpg --passphrase-fd 0 -o $path_db/enc_db --cipher-algo=$crypto_algo -c $file_db
check_gpg_openssl_pwd_encrypt
mv $path_db/enc_db $file_db
}

function check_pwd_before_write(){
password_retype=$(yad --entry --hide-text --title "Password" --text "Retype your password" --image="dialog-password")
if [ "$password" !=  "$password_retype" ] ; then
 yad --title "Error" --text "Passwords are different. Please try again!"
 pwd_insert
fi
}

function input_info(){
title=$(yad --entry --title "Title" --text "Write Title")
exit_script
username=$(yad --entry --title "Username" --text "Write Username")
exit_script
} 

function pwd_insert(){
password=$(yad --entry --hide-text --title "Password" --text "Write password" --image="dialog-password")
exit_script
check_pwd_before_write
echo "TITLE: $title | USER: $username | PASSWORD: $password" >> $file_db
echo "-------------------------------------" >> $file_db
}

function delete_again(){
yad --title "Another?" --text "Do you want to delete another password?" --button=Yes --button=No
if [ $? = 0 ] ; then
 delete_pwd
fi
}

function delete_pwd(){
to_delete=$(yad --entry --title "Choose PWD" --text "Write the EXACT title of PWD to delete")
cat $file_db | grep $to_delete | yad --text-info --title "Click OK to delete this password" --width=400 --height=200
if [ $? = 0 ]; then
 sed -i '/\<'$to_delete'\>/d' $file_db
 delete_again
else
 yad --title "Warning" --text "No password has been deleted"
fi
}

function new_pwd_and_check(){
newpwd=$(yad --entry --hide-text --title "Password" --text "Write password your new password" --image="dialog-password")
exit_script
newpwd_2=$(yad --entry --hide-text --title "Password" --text "Retype your password" --image="dialog-password")
exit_script
if [ "$newpwd" != "$newpwd_2" ]; then
 yad --title "Error" --text "Passwords are different. Please try again"
 exit_script
 new_pwd_and_check
fi
}

function change_again(){
yad --title "Another?" --text "Do you want to change another password?" --button=Yes --button=No
if [ $? = 0 ] ; then
 change_pwd
fi
}

function change_pwd(){
new_pwd_and_check
to_change=$(yad --entry --title "Choose PWD" --text "Write the EXACT title of PWD to change")
cat $file_db | grep $to_change | yad --text-info --title "Click OK to change this password" --width=400 --height=200
if [ $? = 0 ]; then
 sed -i '/^TITLE: '$to_change'/s/PASSWORD:.*/PASSWORD: '$newpwd'/' $file_db
 change_again
else
 yad --title "Warning" --text "No password has been changed"
fi
}

function input_again(){
yad --title "Another?" --text "Do you want to add another password?" --button=Yes --button=No
if [ "$?" = 0 ] ; then
 input_info
 pwd_insert
 input_again
fi
}

function fine_prog(){
IFS=$BACKIFS
if [ -f /home/$USER/.gnupg/gpg.conf ]; then
 if [ "$is_using" = "yes" ] ; then
  sed -i '/use-agent/s/^#//' /home/$USER/.gnupg/gpg.conf
 fi
fi
exit 0
}

function fine_prog_from_view(){
IFS=$BACKIFS
if [ -f /home/$USER/.gnupg/gpg.conf ]; then
 if [ "$is_using" = "yes" ] ; then
  sed -i '/use-agent/s/^#//' /home/$USER/.gnupg/gpg.conf
 fi
fi
exit 0
}

#################
#Funzioni per YAD
function help_gui(){
yad --title "Bash PWD Manager Help" --text "
You are using Bash PWD Manager <b>v${version}</b> developed by:
<b>Paolo Stivanin</b> aka Polslinux <http://www.polslinux.it>
Possible options are:
<b>-c</b> or <b>--change-algo</b> to change your DB cipher-algo
<b>-p</b> or <b>--generate-pwd</b> to generate a strong password
<b>-d</b> or <b>--change-dir</b> to change the directory where your DB is saved
<b>-n</b> or <b>--change-name</b> to change your DB name
<b>-u</b> or <b>--update</b> to update the script to lastest version" --width=300 --height=200
}
export -f help_gui

function add_pwd(){
check_db
decrypt_db
input_info
pwd_insert
input_again
encrypt_db
fine_prog
}
export -f add_pwd

function ch_pwd(){
check_db
decrypt_db
change_pwd
change_again
encrypt_db
fine_prog_from_view
}
export -f ch_pwd

function del_pwd(){
check_db
decrypt_db
delete_pwd
delete_again
encrypt_db
fine_prog_from_view
}
export -f del_pwd

function view_another(){
local titlepass=$(yad --entry --title="Title" --text="Write the TITLE (ex Facebook, Gmail, ecc):")
cat $file_db | grep -i $titlepass | yad --text-info
view_again
}

function view_again(){
yad --title "Another?" --text "Do you want to see another password?" --button=Yes --button=No
if [ $? = 0 ] ; then
 view_another
fi
}

function viewall_pwd(){
check_db
decrypt_db
cat $file_db | yad --text-info --width=800 --height=600
encrypt_db
fine_prog_from_view
}
export -f viewall_pwd

function viewone_pwd(){
check_db
decrypt_db
local titlepass=$(yad --entry --title="Title" --text="Write the TITLE (ex Facebook, Gmail, ecc):")
cat $file_db | grep -i $titlepass | yad --text-info
view_again
encrypt_db
fine_prog_from_view
}
export -f viewone_pwd
#################

function check_before_start(){
if [ ! -f $conf_file ] ; then
yad --text "You have to open the terminal and write
'bashpwdm-config' before use this script.
Do you want to do this now?" --title "Configuration Needed" --width=350 --height=200 --button=Yes --button=No
 if [ $? = 0 ] ; then
 source bashpwdm-config.sh
 else 
   exit 0
 fi
else
 if [ -f /home/$USER/.gnupg/gpg.conf ]; then
  is_using=$(cat $conf_file | grep "using-agent" | cut -f2 -d'=')
  if [ "$is_using" = "yes" ] ; then
   sed -i '/use-agent/s/^/#/' /home/$USER/.gnupg/gpg.conf
  fi
 fi
fi
}

if [ $(id -u) = 0 ] ; then
 yad --title "Error" --text "You can't start this script as root."
 exit 0
fi

if [ "$1" = "-v" ] || [ "$1" = "--version" ]; then
 echo "Bash Password Manager v$version developed by Polslinux <http://www.polslinux.it>"
 exit 0
elif [ "$1" = "--generate-pwd" ] || [ "$1" = "-p" ]; then
 nchar=$(yad --entry --title="Characters" --text="Write number of password characters:" --numeric | cut -f1 -d',')
 check_pwd_char
 echo $(</dev/urandom tr -dc '[:graph:]' | head -c $nchar) | yad --text-info --title "Your password is:" --height=150 --width=300
 exit 0
elif [ "$1" = "--change-algo" ] || [ "$1" = "-c" ] ; then
 file_db=$(yad --file --title "Choose database" --height=600 --width=800)
 exit_script
 if [ -d $file_db ]; then
  yad --title "ERROR" --text "You have choose a directory instead of a file."
  exit 1
 fi
 crypto_algo=$(cat $conf_file | cut -f1 -d' ')
 path_db=$(dirname $file_db)
 gpg -o $path_db/out_db_gpg --cipher-algo=$crypto_algo -d $file_db
 openssl aes-256-cbc -d -a -in $path_db/out_db_gpg -out $path_db/out_db
 mv $path_db/out_db $file_db
 typ=$(yad --list --separator="" --height=220 --width=250 --text "Choose the new cipher algo" --column "Type" CAST5 3DES AES256 TWOFISH BLOWFISH | tr '[A-Z]' '[a-z]')
 exit_script
 sed -i "/algo/c algo=$typ" $conf_file
 openssl aes-256-cbc -a -salt -in $file_db -out $path_db/enc_db_openssl
 gpg -o $path_db/enc_db --cipher-algo=$crypto_algo -c $path_db/enc_db_openssl
 mv $path_db/enc_db $file_db
 exit 0
elif [ "$1" = "--change-dir" ] || [ "$1" = "-d" ]; then
 newdir=$(yad --file --directory --title "New DB direcory" --text "Choose your new database directory" --height=600 --width=800)
 sed -i '/database-path*/d' $conf_file
 db_name=$(cat $conf_file | grep "database-name" | cut -f2 -d'=')
 echo "database-path=$newdir/$db_name" >> $conf_file
 exit 0
elif [ "$1" = "--change-name" ] || [ "$1" = "-n" ] ; then
 new_db_name=$(yad --entry --title "Database name" --text "Write the new name of your database" --separator="")
 sed -i '/database-name*/d' $conf_file
 echo $new_db_name >> $conf_file
 exit 0
elif [ "$1" = "-u" ] || [ "$1" = "--update" ] ; then
 source bashpwdm_update
 exit 0
elif [ "$1" = "--uninstall" ] ; then
  if [ $(id -u) != 0 ] ;then
    echo -e "** ERROR: you have to run the uninstaller as root.\n   Become root and try again. **"
    exit 1
  else
    chmod +x /usr/share/doc/bash-pwd-manager/uninstall.sh
    source /usr/share/doc/bash-pwd-manager/uninstall.sh
  fi  
elif [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
 echo -e "You are using Bash PWD Manager v$version.\nTo start using the script just search for 'BashPWDManager' into your app menu\nor type 'bashpwdm' into the terminal.
The syntax for the following options is: bashpwdm [OPTIONS]\nwhere [OPTIONS] can be:\n
(-c) --change-algo  -> change your DB cipher-algo
(-p) --generate-pwd -> generate a strong password
(-d) --change-dir   -> change the directory where your DB is saved
(-n) --change-name  -> change your DB name
(-u) --update       -> update the script to lastest version
(-h) --help         -> this help ;)\n"
 exit 0
fi

check_before_start
pass=$(yad --class="GSu" --title="Password" --text="Write your DB password" --image="dialog-password" --entry --hide-text --separator="")
yad --title "Choose Action" --form --field "Add Password:BTN" --field "Change Password:BTN" --field "Delete Password:BTN" --field "View All Password:BTN" --field "View One Password:BTN" --field "Help & About:BTN" "bash -c add_pwd" "bash -c ch_pwd" "bash -c del_pwd" "bash -c viewall_pwd" "bash -c viewone_pwd" "bash -c help_gui" --height=200 --width=220

