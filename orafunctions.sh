
#######################################
# the Oracle environment must already
# be setup if you want variables for 
# oracle binaries
# such as  sqlplus, rman, lsnrctl
# If ORACLE_HOME is not set then these
# will not be found
#
# these functions work with ksh 93+  and bash 3+
# I do not think they will work with Bourne shell
#######################################

#######################################
# commands may be added to the cmd list
# by extending CMD_LIST and ORACLE_LIST
#######################################

CMD_LIST='awk basename bash cat chmod chown cp cut date dirname file find grep 
 gunzip gzip head id kill ksh ln ls mkdir mknod printf ps pwd rm rmdir scp 
 sed seq sftp ssh stat tar touch tr uname which who xargs'
 
# some additions depending on environment: asmcmd crsctl expdp impdp
ORACLE_LIST='sqlplus rman tnsping srvctl imp exp' # lsnrctl

#######################################
# ECHO_ARGS used in scripts to determine
# if args should be echod on error
#######################################
export ECHO_ARGS='YES'

#######################################
# figure out where this is running
# home computers have different path for pwc.pl
#######################################

[ -x '/bin/uname' ] && UNAME='/bin/uname'
[ -x '/usr/bin/uname' ] && UNAME='/usr/bin/uname'
[ -x '/bin/cut' ] && CUT='/bin/cut'
[ -x '/usr/bin/cut' ] && CUT='/usr/bin/cut'
export UNAME CUT

#######################################
# set the location of the script used
# to set the Oracle environment
# probably /usr/local/bin/oraenv for 
# most installations
#######################################
ORAENV_SH=/usr/local/bin/oraenv
ORAENV_ASK=NO
export ORAENV_SH ORAENV_ASK

#######################################
# set DEBUG to default of 0 if not already set
#######################################
: ${DEBUG:=0}

#######################################
# check to see if FUNCTIONS_FILE set
#######################################
[ -z "$FUNCTIONS_FILE" ] && {

	echo 
	echo error in $0
	echo PLEASE set the FUNCTIONS_FILE variable in $0 
	echo to the full path to orafunctions.sh and try again.
	echo 
	echo eg.

	echo 'FUNCTIONS_FILE=$HOME/scripts/orafunctions.sh; export FUNCTIONS_FILE'
	echo '. $FUNCTIONS_FILE'
	echo 

	exit 5
}

# display variable name and its value
# TESTVAR='this is a test'
# displayVar TESTVAR
# 
# TESTVAR: this is a test
#
function displayVar {
	typeset varname=$1
	typeset varval
	eval varval=\$$varname
	echo $varname: $varval
}

# add underscore to cmd name and display
# displayCmdVar SQLPLUS
#
function displayCmdVar {
	typeset varname='_'${1}
	displayVar $varname
}

function debug {
	typeset LABEL=$1
	shift
	typeset OUT=$*
	if [ "$DEBUG" -gt 0 ]; then
		printf "==== DEBUG $LABEL =====\n"
		printf "VAL: $OUT\n";
		printf "=======================\n"
	fi
}

function hardpath {
	typeset ProgName ProgPath ProgVar
	ProgName=$1
	ProgVar=$2
	ProgVarName=$(echo $2)

	typeset idx=0
	typeset DIRS

	debug ====== $2 ==========================
	
	# setup search paths here
	for path in ${CFG_CUSTOM_PATH-} ${ORACLE_HOME:+$ORACLE_HOME/bin} /etc /bin /sbin /usr/bin /usr/local/bin $HOME~/bin 
	do
		DIRS[$idx]=$path
		debug LOAD_PATHS $path
		(( idx = idx + 1))
	done

	idx=0
	typeset maxidx foundit
	foundit=0
	(( maxidx = ${#DIRS[*]} - 1 ))

	while (( foundit < 1 ))
	do
		debug FOUNDIT $foundit
		debug PATH_INDEX $idx
		debug SEARCH_PATH ${DIRS[$idx]}
		[ -x "${DIRS[$idx]}/$ProgName" ] && {
			ProgPath=${DIRS[$idx]}/$ProgName
			#echo "$ProgVarName - $ProgName: $ProgPath" 
			foundit=1
		}
		(( idx = idx+1 ))

		if [ $idx -gt $maxidx ]; then
			echo max idx reached setting hardpath for $ProgName:$ProgVar
			break
		fi
	done

	# just check to see if file executable
	[ -x "$ProgPath" ] || {
		echo "checking $ProgName"
		echo "ProgName: $ProgName"
		echo "ProgPath: $ProgPath"
		echo "$ProgName - $ProgPath is not executable"
		exit 1
	}

	debug ProgVar $ProgVar
	debug ProgPath $ProgPath
	eval "$ProgVar=$ProgPath"

}

# setup full qualified pathnames for external programs
# the 'continue' command is used to go to next iteration
# of loop to pick up second value in each pair
# variable names are the uppercase equivalent of the command
# name preceded by an underscore
# eg gzip will be _GZIP
# this avoids possible conflicts with variables that have
# meaning to the command - gzip for examples uses the GZIP variable
# returns the passed value in upper case

# need a function varNameConvert to convert to upper case 
# and change '.' to '_' as '.' does not work in var names
# it is required to bootstrap these functions for hardpath
function varNameConvert {
	typeset input=$*

	LOCAL_TR='/usr/bin/tr'

	[ -x "$LOCAL_TR" ] || {
		LOCAL_TR='/bin/tr'
	}

	[ -x "$LOCAL_TR" ] || {
		echo '!!!'
		echo '!!! Cannot locate tr for boostrapping'
		echo '!!!'
		exit 126
	}

	LOCAL_SED='/usr/bin/sed'

	[ -x "$LOCAL_SED" ] || {
		LOCAL_SED='/bin/sed'
	}

	[ -x "$LOCAL_SED" ] || {
		echo '!!!'
		echo '!!! Cannot locate sed for boostrapping'
		echo '!!!'
		exit 127
	}

	input=$(echo $input | $LOCAL_TR '[a-z]' '[A-Z]' | $LOCAL_SED -e 's/\./_/g' )
	echo $input
}


# setup cmd name variables

for x in $CMD_LIST
do
	#echo X: $x
	typeset p=$x
	v=_$(varNameConvert $x)
	#echo V: $v
	hardpath $p $v
	export $v
done

# set hardpath for oracle home binaries if ORACLE_HOME is set

[ -d "$ORACLE_HOME" ] && {
	for x in  $ORACLE_LIST
	do
		#echo X: $x
		typeset p=$x
		v=_$(varNameConvert $x)
		#echo V: $v
		hardpath $p $v
		export $v
	done
}


# get full pathname  to script
# resolve symlinks

function getFilePath {
	typeset SCRIPT=$1
	#echo >&2 debug SCRIPT: $SCRIPT
	STAT_RESULT=$($_STAT --format=%N $SCRIPT | $_SED -e "s/[\`']//g")

	if [ -L "$SCRIPT" ]; then
		STAT_RESULT=$(echo $STAT_RESULT | $_AWK '{ print $3 }')
	fi

	#echo >&2 debug STAT_RESULT: $STAT_RESULT
	#$STAT --format=%N $SCRIPT | $_AWK '{ print $3 }' | $_SED -e "s/[\`']//g"
	echo $STAT_RESULT
}

# getpath
# getfull path name - assuming a FQN script or exe name
function getPath {
	typeset PSCRIPT=$1
	$_DIRNAME $PSCRIPT
}

# getFile
# get just the filename
function getFile {
	typeset PSCRIPT=$1
	$_BASENAME $PSCRIPT
}

# get the relative path
# if one path is rooted ( '/xx/xx/...') then use it
# otherwise concatenate 
# check path
# eg. determine where script was called from, then get
# the path to the location resolving symlinks if needed
# CALLED_SCRIPT=$0
# CALLED_DIRNAME=$(getPath $CALLED_SCRIPT);
# SCRIPT_FQN=$(getFilePath $CALLED_SCRIPT)
# FQN_DIRNAME=$(getPath $SCRIPT_FQN)
# SCRIPT_HOME=$(getRelPath $CALLED_DIRNAME $FQN_DIRNAME)
# SQLDIR=$SCRIPT_HOME/../sql
#
# this is the real location of the script
# even if called via symlink

function getRelPath {
	typeset CALLED_PATH=$1
	typeset QUAL_PATH=$2
	typeset FULLPATH 

	if [ -d '/'"$QUAL_PATH" ]; then
		FULLPATH=$QUAL_PATH
	else
		FULLPATH=$CALLED_PATH/$QUAL_PATH
	fi

	if [ -d $FULLPATH ]; then
		echo $FULLPATH
	else
		echo "Error determining path"
		echo CALLED_PATH: $CALLED_PATH
		echo QUAL_PATH: $QUAL_PATH
		exit 1
	fi
}

# get the password interacticely
# pass the name of the password variable, not the variable itself
# getPasswordInteractive 'MY_PASSWORD'
# if the password already has a value, nothing will be done
# this allows calling the function without first testing 
# to see if the password variable has a value
function getPassword {
	typeset pwName=$1
	typeset noecho=$2
	typeset pwTest
	eval "pwTest=\$${pwName}"
	#echo "pwTest: $pwTest"
	[ -n "$pwTest" ] && return
	if [ "$noecho" != 'Y' ]; then
		echo -n 'Password: '	
	fi
	eval "read $pwName"
}

# returns the passed value in upper case
function uc {
	typeset input=$*
	input=$(echo $input | $_TR '[a-z]' '[A-Z]')
	echo $input
}

# returns the passed value in lower case
function lc {
	typeset input=$*
	input=$(echo $input | $_TR '[A-Z]' '[a-z]')
	echo $input
}

# returns the passed value in upper case
function upperCase {
	uc $*
}

# returns the passed value in lower case
function lowerCase {
	lc $*
}


# determine what the shell is being used to run a script
function currshell {
	typeset myshell
	#echo CURRSHELL: "$_BASENAME | $PS h -p $$ -o args| $CUT -f1 -d' ' "
	# jkstill - 02/15/2011 - added -- as some versions of basename 
	# were interpreting the later commands
	myshell=$($_BASENAME -- $($_PS h -p $$ -o args| $_CUT -f1 -d' ' ))
	#myshell='ASHELL'
	echo $myshell
}

# check for empty argument list
# concat args into a : delimited string
# chkForEmptyArgs 
# check the return value
# returns 0 if args are empty
# returns 1 if args are not empty

function chkForEmptyArgs {
	typeset argsToChk=$1
	#echo argsToChk: $argsToChk
	[ -z "$argsToChk" ] && return 0
	[ $( echo "$argsToChk" | $_GREP -E '^[:]+$' ) ] && return 0
	return 1
}

# validate_args is used to validate combinations of command line arguments
# see scripts validate_args_proto.sh, validate_args.sh and validate_args_unit_test.sh
#
# the method used is to create a bash array of regular expressions
# that describe valid command line expressions
# ( korn apparently cannot be prevented from stripping '{' and '}' from
#   arguments passed to a function.
#   as [[:alnum]]{3,} is a valid regular expression this is a problem )
# if the argument list passed can be grepped by one of the REs then 
# the argument list is valid and 0 is returned
# otherwise 1 is returned
# call the function and then check the return value
# ':' is used as a delimiter for text values
# VALID_ARGS=( ":[[:alnum]]{3,}:[[:alnum:]]{3,}:[[:alnum:]]{3,}" ":[[:alnum]]{3,}::[[:alnum:]]{3,}" )
# validate_args ':SCOTT:ORCL:MYTABLE' 
# RETVAL=$?


function validate_args {
	typeset arglist
	arglist=$1
	
	while shift
	do
		# on tests that do not succeed before running
		# out of regular expressions to test, the last
		# shift will create $1 as an empty variable
		# this line would demonstrate that
		# [ -z "$1" ] && echo $1 | hexdump -C
		# 00000000  0a   |.|
		[ -z "$1" ] && break
		if [ $(echo $arglist | $_GREP -E $1 ) ]; then
			return 0
		fi
		
	done
	return 1

}

function timestamp {
	typeset mydate
	mydate=$($_DATE +%Y%m%d-%H%M%S)
	echo $mydate
}


function timestamp_nano {
	typeset mydate
	mydate=$($_DATE +%Y%m%d-%H%M%S-%N)
	echo $mydate
}

### set a lock so that only 1 copy of a script can run
### usage:
### LOCKFILE=/tmp/script_name.lock
### scriptLock $LOCKFILE
### scriptLock will exit if file cannot be locked
### scriptLock sets a trap - keep in mind if you set traps in your script
###

function scriptLock  {
	typeset MY_LOCKFILE
	MY_LOCKFILE=$1

	# remove stale lockfile
	[ -r "$MY_LOCKFILE" ] && {
		PID=$($_CAT $MY_LOCKFILE)
		ACTIVE=$($_PS --no-headers -p $PID)
		if [ -z "$ACTIVE" ]; then
			rm -f $MY_LOCKFILE
		fi
	}

	# set lock
	if (set -o noclobber; echo "$$" > "$MY_LOCKFILE") 2> /dev/null; then
		trap '$_RM -f "$MY_LOCKFILE"; exit $?' INT TERM EXIT
		return 0
	else
		echo "Failed to acquire $LOCKFILE. Held by $($_CAT $LOCKFILE)"
		exit 1
	fi
}

# remove the lock when script exits
function scriptUnlock {
	$_RM -f "$LOCKFILE"
	trap - INT TERM EXIT
}


function setCustomCmds {
	#echo 'setting custom commands'
	#echo CFG_CUSTOM_CMDS: $CFG_CUSTOM_CMDS
	for x in  $CFG_CUSTOM_CMDS
	do
		typeset p=$x
		v=_$(varNameConvert $x)
		#echo p: $p
		#echo v: $v
		hardpath $p $v
		export $v
	done
}


runSQL () {

	local dbName=$1
	local instName=$2
	local script=$3

	. oraenv <<< $psid > /dev/null
	export ORACLE_SID=$instName

	sqlplus -s -L / as sysdba <<-EOF

		@clear_for_spool
		set term off
		spool ${csvDir}/${dbName}.csv
		prompt timestamp,node_1,node_2,node_3,total
		@$script
		exit
EOF

}



