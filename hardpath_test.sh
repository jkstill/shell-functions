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


