

rpad () {

	local string2pad="$1"
	local endLength="$2"
	local padChar="$3"

	local currLen=${#string2pad}

	while [[ "$currLen" -lt "$endLength" ]]
	do
		string2pad="${string2pad}${padChar}"
		currLen=${#string2pad}
	done

	echo $string2pad
	return 0

}

split_char () {
	local incomingText="$@"

	# accepts STDIN as well
	if [[ -z "$incomingText" ]]; then
		read incomingText
	fi

	echo "$incomingText" | grep --color=never -o '.'
	return 0
}





