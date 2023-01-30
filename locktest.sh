:

export FUNCTIONS_FILE=$HOME/scripts/orafunctions.sh
. $FUNCTIONS_FILE

LOCKFILE=/tmp/locktest.lock

echo my PID: $$

scriptLock $LOCKFILE

sleep 10

scriptUnlock

