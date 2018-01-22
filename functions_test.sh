:

FUNCTIONS_FILE=/home/jkstill/bin/functions.sh; export FUNCTIONS_FILE

. $FUNCTIONS_FILE

export DEBUG=0

# functions used to display tests

function testTitle {
	typeset titleText=$1
	titleBlank='============================================================'
	$PRINTF "$titleBlank" # that is a literal CR at the end of the line
	# now overlay the line with the title
	$PRINTF "== $titleText =\n"
}

function printResult {
	typeset varName=$*
	#echo varName: $varName
	eval "RESULT=\$${varName}"
	#echo RESULT: $RESULT
	$PRINTF "%20s = %s\n" $varName "$RESULT"
}

# get full pathname  to script
# resolve symlinks
# use getPath and getScriptPath to get the directory 
# and full path name to the current script

CALLED_SCRIPT=$0
CALLED_DIRNAME=$(getPath $CALLED_SCRIPT);
SCRIPT_FQN=$(getScriptPath $CALLED_SCRIPT)
FQN_DIRNAME=$(getPath $SCRIPT_FQN)

testTitle getPath
testTitle getScriptPath
for v in  CALLED_SCRIPT CALLED_DIRNAME SCRIPT_FQN FQN_DIRNAME
do
	printResult $v
done

# get the relative path
# if one path is rooted ( '/xx/xx/...') then use it
# this is the real location of the script
# even if called with symlink
# otherwise concatenate 
# check path
SCRIPT_HOME=$(getRelPath $CALLED_DIRNAME $FQN_DIRNAME)
testTitle getRelPath
#$PRINTF "%20s = %s\n" 'SCRIPT_HOME' $SCRIPT_HOME
printResult SCRIPT_HOME

# test the lowercase and uppercase functions
MIXED_CASE_TEXT='This Quick Brown Fox Jumped Over The Lazy Dog'
LC_TEXT=$(lc $MIXED_CASE_TEXT)
UC_TEXT=$(uc $MIXED_CASE_TEXT)

testTitle 'uc-uppercase text'
testTitle 'lc-lowercase text'
for v in  MIXED_CASE_TEXT LC_TEXT UC_TEXT
do
	printResult $v
done

# used to validate the type of database statistics
# returns a blank string if unknown, otherwise 
# returns the passed value
testTitle verifyStatsType
for statsType in DICTIONARY_STATS BADSTAT FIXED_OBJECTS_STATS SYSTEM_STATS SCHEMA
do
	STATS_TYPE=$(verifyStatsType $statsType)
	printResult STATS_TYPE
done

# determine what the shell is being used to run a script
CURR_SHELL=$(currshell)
testTitle 'current shell'
printResult CURR_SHELL

# get the password interacticely
# pass the name of the password variable, not the variable itself
# getPasswordInteractive 'MY_PASSWORD'
# if the password already has a value, nothing will be done
# this allows calling the function without first testing 
# to see if the password variable has a value
testTitle getPasswordInteractive 
getPasswordInteractive 'IC_PASSWORD' N
printResult IC_PASSWORD 

# uses pwc.pl from the PDBA Toolkit
# supply your own method to retrieve
# passwords if needed - this is set via the PWC variable in functions.sh
# if PWC is not found, then getPasswordInteractive will be called
PASSWORD=$(getPassword system dv11)
testTitle getPassword 
printResult PASSWORD

# simulate getting password when password repository is unavailable
unset PWC
PASSWORD=$(getPassword system dv11)
testTitle 'getPassword - fall back on interactive'
printResult PASSWORD

