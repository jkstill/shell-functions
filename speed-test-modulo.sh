#!/usr/bin/env bash


# create a set of random numbers

source math.sh

echo
echo Creating Random Number set
echo

randomFile=$(mktemp -q)
iterations=1000000
divisor=5

echo "randomFile: $randomFile"

for i in $(seq 1 $iterations)
do
	echo $RANDOM >> $randomFile
done

wc -l $randomFile
#cat $randomFile

echo
echo Timing $iterations iterations of computed remainder
echo 

time while read rnd
do
	echo -n "$rnd: "
	modulo_compute $rnd $divisor
done < $randomFile  > /dev/null

echo
echo Timing $iterations iterations of remainder operator
echo 

time while read rnd
do
	echo -n "$rnd: "
	modulo_remainder_op $rnd $divisor
done < $randomFile  > /dev/null


[[ -w $randomFile ]] && { rm -f $randomFile; }
[[ -w $randomFile ]] && { echo "something is wrong -  $randomFile not removed"; }


