BASH PASSWORD MANAGER
=====================

Bash Password Manager is a script that create a database in which you can store your passwords in a total secure way!<br>
The database is double encrypted with GPG and OpenSSL so you can be sure that nobody can hack/view/compromise your database without your permission :)

Requirements
------------

* bash   : v4.0 and above (may work with v3 but not tested)
* yad	 : message dialogs
* gpg    : encrypt/decrypt db
* openssl: encrypt/decrypt db
* wget   : download newest Bash PWD Manager version

How it works
------------

The script will create and encrypt the DB.<br> 
After that you can add, delete, view or store new passwords.<br>
This script has lot of features such:<br>

- double encryption
- possibility to choose your favourite cipher-algo (aes256, blowfish, twofish, ecc)
- possibility to generate strong random password
- possibility to add, view, delete or change password
- lot of customization are possible (see Extra Options)

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
- `bashpwdm --update` or `bashpwdm -u`<pre>-> to automatically update BashPWDManager to lastest version</pre>

Notes
-----

For more information see:<br>
<http://www.polslinux.it/category/projects/>
