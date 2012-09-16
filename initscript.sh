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

USER="fantom" # User we wil run fantom as
FANTOM_HOME="/home/fantom/fan"
FAN_ARGS="mycoolserverpod"
WORKDIR="/home/fantom"

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
        echo "Starting $0 ..."
        if [ -f "$WORKDIR/$0.pid" ] 
        then 
            echo "Already running according to $WORKDIR/$0.pid"
            exit 1
        fi
        export FANTOM_HOME=$FANTOM_HOME
        /bin/su $USER -p -s /bin/sh -c "$FANTOM_HOME/bin/fan $FAN_ARGS" > "$WORKDIR/$0.log" 2>&1 &
        PID=$!
        echo $PID > "$WORKDIR/$0.pid"
        echo "Started with pid $PID - Logging to $WORKDIR/$0.log" && exit 0
        ;;
      stop)
        echo "Stopping $0 ..."
        if [ ! -f "$WORKDIR/$0.pid" ]
        then
            echo "Already stopped!"
            exit 1
        fi
        PID=`cat "$WORKDIR/$0.pid"`
        recursiveKill $PID
        rm -f "$WORKDIR/$0.pid"
        echo "stopped $0" && exit 0
        ;;
      restart)
        $0 stop
        sleep 1
        $0 start
        ;;
      status)
        if [ -f "$WORKDIR/$0.pid" ] 
        then 
            PID=`cat "$WORKDIR/$0.pid"`
            if [ "$(/bin/ps --no-headers -p $PID)" ]
            then
                echo "$0 is running (pid : $PID)" && exit 0
            else
                echo "Pid $PID found in $WORKDIR/$0.pid, but not running." && exit 1
            fi
        else
            echo "$0 is NOT running" && exit 1
        fi
    ;;
      *)
      echo "Usage: /etc/init.d/$0 {start|stop|restart|status}" && exit 1
      ;;
esac

exit 0