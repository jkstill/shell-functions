#!/bin/bash

# create some date functions for later inclusion in orafunctions.sh

# altweek returns a 0 or 1 based on which week the current date is
# for jobs that run on alternate weeks
# you can pass a date string, or just rely on current date
# a passed date is mostly for testing
# the passed date can be YYYY/MM/DD HH24:MI:SS - other variations possible

DATE=/bin/date

function altweek {

	typeset myDate=$1;
	typeset whichWeek
	typeset weekMod

	if [ -z "$myDate" ] ; then
		whichWeek=$( $DATE +%W )
	else
		whichWeek=$( $DATE -d $myDate +%W )
		DATE_RET=$?
		if [ "$DATE_RET" -gt 0 ]; then
			echo "!! error: Cannot parse date of $myDate !!"
			exit $DATE_RET
		fi
	fi

	(( weekMod = whichWeek % 2))

	echo $weekMod
}


for d in '2011/03/11' '2011/05/15' '2011/06/02' # '234234'
do
	echo '###################################'
	echo Date: $d
	altWeekNum=$(altweek $d)
	#echo mod: $altWeekNum

	case $altWeekNum in
		0) echo "Backup Schedule 0";;
		1) echo "Backup Schedule 1";;
		*) echo "Error in dates!"; exit 127;;
	esac

done

echo '###################################'
$DATE
altWeekNum=$(altweek)
case $altWeekNum in
	0) echo "Backup Schedule 0";;
	1) echo "Backup Schedule 1";;
	*) echo "Error in dates!"; exit 127;;
esac



