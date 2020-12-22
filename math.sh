
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

: << 'COMMENT'
 There is very little difference in speed between bitand and xor

 It probably makes no difference which one is used.

 See speed-test-odd-even.sh
COMMENT

# generally this is called via odd_or_even
# as input validation is done there, not repeating it here
odd_or_even_xor () {
	local testInt=$1

   # N xor N-1
	# if 1 then the number is odd
	#(( tmpInt=testInt^(testInt-1) ))

	#if [[ "$tmpInt" -eq 1 ]]; then
	if [[ $((testInt^(testInt-1) )) -eq 1 ]]; then
		echo 'odd'
	else
		echo 'even'
	fi

	return 0
}


# generally this is called via odd_or_even
# as input validation is done there, not repeating it here
odd_or_even_bitand () {
	local testInt=$1

	# in Bash we can use bitwise and
	if [[ $(( 1 & testInt )) -eq 1 ]] ; then
		echo 'odd'
	else
		echo 'even'
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

	odd_or_even_bitand $testInt
	return $?
}

modulo_compute () {
	local dividend=$1
	local divisor=$2
	echo $(( dividend - ((dividend/divisor)*divisor) ))
	return $?
}

# about 5% faster than modulo_compute
# see speed-test-module.sh
modulo_remainder_op () {
	local dividend=$1
	local divisor=$2
	echo $(($dividend%$divisor))
	return $?
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

	#moduloVal=$(modulo_compute $dividend $divisor)
	moduloVal=$(modulo_remainder_op $dividend $divisor)

	echo $moduloVal
	return 0

}

