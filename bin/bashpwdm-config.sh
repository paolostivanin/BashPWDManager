#!/bin/bash

#################################################################
# @Author: Paolo Stivanin aka Polslinux
# @Name: Bash Password Manager Configuration Script
# @Copyright: 2012
# @Site: http://www.polslinux.it
# @License: GNU GPL v3 http://www.gnu.org/licenses/gpl.html
#################################################################

BACKIFS=$IFS
IFS=$'\n'
conf_file="/home/$USER/.config/bpwdman.conf"

function exit_script(){
if [ $? != "0" ] ; then
	if [ -f $conf_file ] ; then
		rm $conf_file
	fi
	exit 0
fi
}

function retype_pass(){
pass=$(yad --form --field "Password:H" --field "Retype Password:H" --separator="@1212@" --title "Password" --image="dialog-password")
exit_script
if [ $(echo $pass | awk -F"@1212@" '{print $1}') != $(echo $pass | awk -F"@1212@" '{print $2}') ];then
	yad --title "Error" --text "Passwords are different. Please try again"
	retype_pass
fi
check_pwd_char
}

function retype_double_pass(){
double_pass=$(yad --form --field "Password:H" --field "Retype Password:H" --separator="@1212@" --title "Password" --image="dialog-password")
exit_script
if [ $(echo $double_pass | awk -F"@1212@" '{print $1}') = $(echo $double_pass | awk -F"@1212@" '{print $2}') ];then
	yad --title "Error" --text "Passwords are the same. Please <b>use different passwords</b>"
	retype_double_pass
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
if [ $num_of_enc = 2 ]; then
	pass_1=$(echo $double_pass | awk -F"@1212@" '{print $1}')
	pass_2=$(echo $double_pass | awk -F"@1212@" '{print $2}')
	local typ_algo=$(echo $typ | tr '[A-Z]' '[a-z]')
	openssl aes-256-cbc -a -salt -pass pass:$pass_2 -in ${db_dir}/${db_name}.sl3 -out ${db_dir}/enc_db_openssl
	mv ${db_dir}/enc_db_openssl ${db_dir}/${db_name}.sl3
	echo $pass_1 | gpg --passphrase-fd 0 -o ${db_dir}/enc_db --cipher-algo=$typ -c ${db_dir}/${db_name}.sl3
	mv ${db_dir}/enc_db ${db_dir}/${db_name}.sl3
elif [ $num_of_enc = 1 ]; then
	local typ_algo=$(echo $typ | tr '[A-Z]' '[a-z]')
	echo $pass | gpg --passphrase-fd 0 -o ${db_dir}/enc_db --cipher-algo=$typ -c ${db_dir}/${db_name}.sl3
	mv ${db_dir}/enc_db ${db_dir}/${db_name}.sl3
fi
}

function save_db_path(){
yad --text "Do you want to save the path of your DB so every time you
will start the script you won't have to select it?" --title "Save DB path?" --width=410 --button=Yes --button=No
if [ $? = 0 ] ; then
	echo "database-path=${db_dir}/${db_name}.sl3" >> $conf_file   
else
	echo "database-path=0" >> $conf_file
fi
}

function create_db(){
STRUCTURE="CREATE TABLE main (title TEXT,username TEXT,password TEXT,expdate TEXT);";
cat /dev/null > ${db_dir}/${db_name}.sl3
echo $STRUCTURE > /tmp/tmpstruct
sqlite3 ${db_dir}/${db_name}.sl3 < /tmp/tmpstruct;
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

if [ -f $conf_file ] ; then
	rm $conf_file
fi

typ=$(yad --list --column="Cipher Algo" cast5 3des aes256 twofish blowfish --separator="" --height=200 --width=180)
exit_script
echo "algo=$typ" >> $conf_file
num_of_enc=$(yad --list --column="Number of encryption" "1 (GPG)" "2 (GPG+OpenSSL)" --separator="" --height 150 --width 50)
echo "num_enc=$(echo $num_of_enc | cut -f1 -d' ')" >> $conf_file
db_dir=$(yad --file --directory --title "Choose database directory" --width=800 --height=600)
exit_script
db_name=$(yad --entry --title "Database name" --text "Write the name of your database")
exit_script
if [ -z "$db_name" ]; then
	yad --title "Error" --text "You cannot create DB with no name, exiting..."
   	if [ -f $conf_file ]; then
   		rm $conf_file
   	fi
   	exit 1
fi
echo "database-name=${db_name}.sl3" >> $conf_file
create_db
if [ $num_of_enc = 1 ]; then
	pass=$(yad --form --field "Password:H" --field "Retype Password:H" --separator="@1212@" --title "Password" --image="dialog-password")
	exit_script
	if [ $(echo $pass | awk -F"@1212@" '{print $1}') != $(echo $pass | awk -F"@1212@" '{print $2}') ];then
		yad --title "Error" --text "Passwords are different. Please try again"
  		retype_pass
	fi
else
	double_pass=$(yad --form --field "Password 1 (GPG):H" --field "Password 2 (OpenSSL):H" --separator="@1212@" --title "Password" --image="dialog-password")
	exit_script
	if [ $(echo $double_pass | awk -F"@1212@" '{print $1}') = $(echo $double_pass | awk -F"@1212@" '{print $2}') ];then
		yad --title "Error" --text "Passwords are the same. Please <b>use different passwords</b>"
  		retype_double_pass
	fi
fi

check_pwd_char
echo "db_created=1" >> $conf_file
save_db_path
first_encryption
yad --text "Bash Password Manager has been configured :)" --title "Finish" --width=310
fine_prog
