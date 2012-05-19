BASH PASSWORD MANAGER
=====================

Bash Password Manager is a script that create a database in which you can store your passwords in a total secure way!<br>
The database is double encrypted with GPG and OpenSSL so you can be sure that nobody can hack/view/compromise your database without your permission :)

Requirements
------------

* bash   : v4.0 and above (may work with v3 but not tested)
* yad	 : message dialogs
* gpg    : to encrypt/decrypt db
* openssl: to encrypt/decrypt db
* wget   : to download newest Bash PWD Manager version
* sqlite3: to store your username and passwords

How it works
------------

The script will create and encrypt the DB (sqlite3 db).<br> 
After that you can add, delete, view or store new passwords.<br>
This script has lot of features such:<br>

- double encryption <b>(ATTENTION: if you use double encryption you must respect the order of the 2 passwords)</b>
- possibility to choose your favourite cipher-algo (aes256, blowfish, twofish, ecc)
- possibility to generate strong random password
- possibility to add, view, delete or change password
- possibility to backup your database
- possibility to upgrade to lastest version thanks to the updater script
- password expiration date
- lot of other customization are possible (see Extra Options)

How to use
----------

Go to Applications -> Accessories -> BashPWDman<br>
or<br>
Open a terminal and type: `bashpwdm [OPTIONS]`

How to install
--------------

Download the archive and after you have extract it, open the terminal and type:<br>
`chmod +x PATH_TO_EXTRACTED_FOLDER/install.sh`<br>
`sudo bash PATH_TO_EXTRACTED_FOLDER/install.sh`

Extra options
-------------

Open the terminal and type:<br>

- `bashpwdm --version` or `bashpwdm -v`<pre>-> to view the version of Bash PWD Manager</pre>
- `bashpwdm --change-algo` or `bashpwdm -c`<pre>-> to change the cipher-algo of db</pre>
- `bashpwdm --generate-pwd` or `bashpwdm -p`<pre>-> to create a strong password</pre>
- `bashpwdm --change-dir` or `bashpwdm -d`<pre>-> to change db directory (if you have saved it)</pre>
- `bashpwdm --change-name` or `bashpwdm -n`<pre>-> to change db name (if you have saved it)</pre>
- `bashpwdm --update` or `bashpwdm -u`<pre>-> to automatically update Bash PWD Manager to lastest version</pre>
- `bashpwdm --backup` or `bashpwdm -b`<pre>-> backup your current database and generate the md5sum of the backupped file</pre>
- `bashpwdm --uninstall`<pre>-> to uninstall Bash PWD Manager</pre>

Notes
-----

For more information see:<br>
<http://www.polslinux.it/category/projects/>
