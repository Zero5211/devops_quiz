#!/bin/bash

#This is the most common way to take -/-- parameters.
while [[ $# > 1 ]]
do
key="$1"

case $key in
	-w | --warning)
	WARNING="$2"
	shift
	;;
	-c | --critical)
	CRITICAL="$2"
	shift
	;;
	-u | --user)
	USER="$2"
	;;
	*)
esac
shift
done

#Setting default values if these variables are not set.
if [ -z "$WARNING" ]; then
	WARNING=5
fi
if [ -z "$CRITICAL" ]; then
	CRITICAL=10
fi

#Doesn't make sense to have a WARNING threshold higher than CRITICAL.
if [ $WARNING -ge $CRITICAL ]; then
	echo "The critical value must be lower than warning! Exiting with status UNKNOWN"
	exit 3
fi

#Piping who to wc -l gives us a count of the users,
#since who prints out a line for each user.
#If the user flag is specified, only counts how many
#instances of that specified user are logged in.
if [ -z $USER ]; then
	NUMUSERS="$(who | wc -l)"
else
	NUMUSERS="$(who | grep $USER | wc -l)"
fi

#Nagios plugins written in Bash use exit codes. 
#0 is OK, 1 is WARNING, 2 is CRITICAL, 3 is UNKNOWN
if [ $NUMUSERS -lt $WARNING ]; then
	echo "OK - Users logged in: $NUMUSERS"
	exit 0
elif [ $NUMUSERS -ge $WARNING -a $NUMUSERS -lt $CRITICAL ]; then
	echo "WARNING - Users logged in: $NUMUSERS"
	exit 1
elif [ $NUMUSERS -ge $CRITICAL ]; then
	echo "CRITICAL - Users logged in: $NUMUSERS"
 	exit 2
else
	#Still want to print out the NUMUSERS variable even if 
	#it's unrecognizeable by the previous if statements
	#This will aid in debugging.
	echo "UNKNOWN - Users logged in: $NUMUSERS"
	exit 3
fi
