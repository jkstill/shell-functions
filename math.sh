
is_a_number () {
	local val2chk=$1

	if [[ -z "$val2chk" ]]; then
		echo 'unknown'
		return 1
	fi

	if [[ ! "$val2chk" =~ ^[[:digit:].,]+$ ]]; then
		#echo 'not a number'
		return 1
	fi
	return 0
}


odd_or_even () {
	local testInt=$1

	if [[ -z "$testInt" ]]; then
		echo 'unknown'
		return 1
	fi

	if ( ! is_a_number $testInt ); then
		echo 'not a number'
		return 1
	fi

	declare tmpInt

	# here is one way to do it
: << 'COMMENT'

	(( tmpInt=testInt^(testInt-1) ))

	if [[ "$tmpInt" -eq 1 ]]; then
		echo 'odd'
	else
		echo 'even'
	fi

COMMENT

	# in Bash we can use bitwise and
	if [[ $(( 1 & testInt )) -eq 1 ]] ; then
		echo 'odd'
	else
		echo 'even'
	fi

	return 0
}

modulo () {
	local dividend=$1
	local divisor=$2

	for testInt in $dividend $divisor
	do
		#echo "modulo testInt: $testInt"
		if [[ -z "$testInt" ]]; then
			echo 'unknown'
			return 1
		fi
	done

	for testInt in $dividend $divisor
	do
		if ( ! is_a_number $testInt ); then
			echo 'not a number'
			return 1
		fi
	done

	declare moduloVal
	# this works due to integer only numbers
	#(( moduloVal = dividend - ((dividend/divisor)*divisor) ))

	# or just use remainder operator
	(( moduloVal = dividend%divisor ))

	echo $moduloVal
	return 0

}

