
function getScriptPath {
	typeset SCRIPT=$1
	#echo >&2 debug SCRIPT: $SCRIPT
	STAT_RESULT=$(stat --format=%N $SCRIPT | sed -e "s/[\`']//g")

	if [ -L "$SCRIPT" ]; then
		STAT_RESULT=$(echo $STAT_RESULT | awk '{ print $3 }')
	fi

	##echo >&2 debug STAT_RESULT: $STAT_RESULT
	#$STAT --format=%N $SCRIPT | $AWK '{ print $3 }' | $SED -e "s/[\`']//g"
	echo $STAT_RESULT
}


echo $(getScriptPath $0)

