#! /bin/bash
# Fantom server init script - Thibaut Colar.

### BEGIN INIT INFO
# Provides:       mycoolserver
# Required-Start: $network
# Required-Stop:  
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description: mycoolserver
### END INIT INFO

USER="root" # User we wil run skyspark as
FANTOM_HOME="/skyspark/skyspark-1.0.40"
FAN_ARGS=""
WORKDIR="/skyspark/skyspark-1.0.40"
CMD="/skyspark/skyspark-1.0.40/bin/skyspark"
NAME="skyspark"

###### Start script ########################################################

recursiveKill() { # Recursively kill a process and all subprocesses
    CPIDS=$(pgrep -P $1);
    for PID in $CPIDS
    do
        recursiveKill $PID
    done
    sleep 3 && kill -9 $1 2>/dev/null & # hard kill after 3 seconds
    kill $1 2>/dev/null # try soft kill first
}

case "$1" in
      start)
        echo "Starting $NAME ..."
        if [ -f "$WORKDIR/$NAME.pid" ] 
        then 
            echo "Already running according to $WORKDIR/$NAME.pid"
            exit 1
        fi
        export FANTOM_HOME=$FANTOM_HOME
        cd "$WORKDIR"
        /bin/su $USER -p -s /bin/sh -c "$CMD $FAN_ARGS" > "$WORKDIR/$NAME.log" 2>&1 &
        PID=$!
        echo $PID > "$WORKDIR/$NAME.pid"
        echo "Started with pid $PID - Logging to $WORKDIR/$NAME.log" && exit 0
        ;;
      stop)
        echo "Stopping $NAME ..."
        if [ ! -f "$WORKDIR/$NAME.pid" ]
        then
            echo "Already stopped!"
            exit 1
        fi
        PID=`cat "$WORKDIR/$NAME.pid"`
        recursiveKill $PID
        rm -f "$WORKDIR/$NAME.pid"
        echo "stopped $NAME" && exit 0
        ;;
      restart)
        $0 stop
        sleep 1
        $0 start
        ;;
      status)
        if [ -f "$WORKDIR/$NAME.pid" ] 
        then 
            PID=`cat "$WORKDIR/$NAME.pid"`
            if [ "$(/bin/ps --no-headers -p $PID)" ]
            then
                echo "$NAME is running (pid : $PID)" && exit 0
            else
                echo "Pid $PID found in $WORKDIR/$NAME.pid, but not running." && exit 1
            fi
        else
            echo "$NAME is NOT running" && exit 1
        fi
    ;;
      *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart|status}" && exit 1
      ;;
esac

exit 0
