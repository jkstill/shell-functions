#!/bin/bash

export FUNCTIONS_FILE=$HOME/scripts/orafunctions.sh
. $FUNCTIONS_FILE

echo ===== hardpath function =======
echo many commonly used programs are automatically
echo fully pathed as variables when $FUNCTIONS_FILE is loaded
echo
echo the variable will be the name of the command but in upper case and preceded by an underscore
echo eg. cat will be \$_CAT
echo 

echo additional programs are easily added to $FUNCTIONS_FILE
echo 
echo in addition, if the program has a "'.'" in the name, it will be converted to an underscore
echo in the variable name, as "'.'" is not a legal variable name character
echo
echo eg.  the variable for runInstaller.sh will be \$_RUNINSTALLER_SH
echo 
echo these variables are all exported as well
echo 
displayCmdVar LS
displayCmdVar CAT
displayCmdVar RMAN
displayCmdVar CP
echo
echo Custom commands can be added by setting the CMD_CUSTOM_PATH and CMD_CUSTOM_CMDS
echo values in a configuration script - see template.sh for an example
echo 

echo 
echo === verify some variables exported
# verify that values are exported
./otest2.sh 

echo 
echo ===== debug funtion ==========
DEBUG=1
# the debug function
debug ORACLE_HOME: $ORACLE_HOME
DEBUG=0

echo
echo ===== timestamp funtion ==========
TIMESTAMP=$(timestamp)
displayVar TIMESTAMP

echo
echo ===== timestamp_nano funtion ==========
TIMESTAMP_NANO=$(timestamp_nano)
displayVar TIMESTAMP_NANO

echo 
echo ====== function getFile ======
echo use to get filename of pathed file
PATHED_FILE=$($_WHICH bash)
displayVar PATHED_FILE
FILE=$(getFile $PATHED_FILE)
displayVar FILE

echo
echo ====== funtion getFilePath ======
echo Get path to file even if symlink
echo $_TOUCH /var/tmp/source_file.txt
echo $_LN -s /var/tmp/source_file.txt /tmp/symlink.txt
echo resolve the source file of the symlink

$_RM -f /var/tmp/source_file.txt /tmp/symlink.txt
$_TOUCH /var/tmp/source_file.txt
$_LN -s /var/tmp/source_file.txt /tmp/symlink.txt

echo 'SOURCE_FILE=$(getFilePath "/tmp/symlink.txt")'
SOURCE_FILE=$(getFilePath "/tmp/symlink.txt")
displayVar SOURCE_FILE

echo 
echo ===== getPath ======
echo uses dirname to get path to file
echo 'PATH_TO_FILE=$(getPath "/var/tmp/source_file.txt")'
PATH_TO_FILE=$(getPath "/var/tmp/source_file.txt")
displayVar PATH_TO_FILE

echo
echo ===== getRelPath
echo get the relative path
echo this is useful for locating a directory 
echo by the relative location of the script, even if called
echo by a symbolic link
echo 
echo script/var/tmp/otest_relpath.sh will be created
echo the SQLDIR for this script is /var/tmp/sql
echo even when a symobolic link is made to the script
echo by a different name in /tmp, the correct directory
echo for the SQLDIR will be found
echo

$_RM -f /var/tmp/otest_relpath.sh /tmp/otest_symlink.sh

echo creating the test script /var/tmp/otest_relpath.sh
echo 

$_CAT > /var/tmp/otest_relpath.sh <<EOF
echo this is otest_relpath.sh
export FUNCTIONS_FILE=$HOME/scripts/orafunctions.sh
. \$FUNCTIONS_FILE
CALLED_SCRIPT=\$0
CALLED_DIRNAME=\$(getPath \$CALLED_SCRIPT);
SCRIPT_FQN=\$(getFilePath \$CALLED_SCRIPT)
FQN_DIRNAME=\$(getPath \$SCRIPT_FQN)
SCRIPT_HOME=\$(getRelPath \$CALLED_DIRNAME \$FQN_DIRNAME)
SQLDIR=\$SCRIPT_HOME/sql
echo SQLDIR: \$SQLDIR
EOF

echo \#\# contents of test script
$_CAT /var/tmp/otest_relpath.sh
echo \#\#\#\#
echo 

$_CHMOD u+x /var/tmp/otest_relpath.sh

echo \#\# Now linking /var/tmp/otest_relpath.sh to /tmp/otest_symlink.sh
echo "$_LN -s /var/tmp/otest_relpath.sh /tmp/otest_symlink.sh"
echo

$_LN -s /var/tmp/otest_relpath.sh /tmp/otest_symlink.sh

echo \#\# Now executing /tmp/otest_symlink.sh

/tmp/otest_symlink.sh

echo
echo notice that the correct path to SQLDIR was found
echo even though the called script was a symlink in
echo a different directory
echo


echo ===== getPassword =====
echo prompt for password
echo pass the name of the password variable
echo eg. getPassword PASSWORD

getPassword PASSWORD

displayVar PASSWORD
echo

echo ===== Case functions
echo use uc,upperCase, lc and lowerCase to change case of a string

TESTSTRING='This Is A Test'
displayVar TESTSTRING

echo \#\# uc
echo "UPPER=\$(uc \$TESTSTRING)"
UPPER=$(uc $TESTSTRING)
displayVar UPPER

echo \#\# upperCase
echo "UPPER=\$(upperCase \$TESTSTRING)"
UPPER=$(upperCase $TESTSTRING)
displayVar UPPER

echo \#\# lc
echo "LOWER=\$(lc \$TESTSTRING)"
LOWER=$(lc $TESTSTRING)
displayVar LOWER

echo \#\# lowerCase
echo "LOWER=\$(lc \$TESTSTRING)"
LOWER=$(lowerCase $TESTSTRING)
displayVar LOWER
echo 


echo ===== currshell ======
echo determine which shell is currently being used
echo
echo "CURRSHELL=\$(currshell)"
CURRSHELL=$(currshell)
displayVar CURRSHELL


echo ===== validate_args and chkForEmptyArgs =====
echo 
echo these will be explained at another time
echo they are for validating combinations of cmdline arguments. 
echo an explanation will take an entire article
echo 


echo ===== scriptLock and scriptUnlock
echo use to set a lock so that only one copy of a script
echo can run at a a time
echo use scriptUnlock when the program exits
echo
echo scriptLock sets a trap, so keep that in mind
echo if you set traps in your scripts
echo
echo 
echo contents of the test script locktest.sh
echo ======= locktest.sh ===============
$_CAT locktest.sh
echo ====================================
echo
echo now we will run the first copy of locktesh.sh in the background
echo
echo the second attempt to run locktest.sh will fail to acquire the lock
echo

echo running first copy of locktest.sh
$SHELL ./locktest.sh &
echo running second copy of locktest.sh
$SHELL ./locktest.sh

