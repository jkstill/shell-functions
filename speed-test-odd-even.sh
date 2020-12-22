#!/usr/bin/env bash


# create a set of random numbers

source math.sh

echo
echo Creating Random Number set
echo

randomFile=$(mktemp -q)
iterations=1000000

echo "randomFile: $randomFile"

for i in $(seq 1 $iterations)
do
	echo $RANDOM >> $randomFile
done

wc -l $randomFile
#cat $randomFile

echo
echo Timing $iterations iterations of XOR
echo 

time while read rnd
do
	echo -n "$rnd: "
	odd_or_even_xor $rnd
done < $randomFile  > /dev/null

echo
echo Timing $iterations iterations of BITAND
echo 

time while read rnd
do
	echo -n "$rnd: "
	odd_or_even_bitand $rnd
done < $randomFile  > /dev/null


[[ -w $randomFile ]] && { rm -f $randomFile; }
[[ -w $randomFile ]] && { echo "something is wrong -  $randomFile not removed"; }
