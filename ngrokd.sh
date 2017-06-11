#!/bin/sh
### BEGIN INIT INFO
# Provides:          ngrok
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the ngrok connection
# Description:       starts ngrok using start-stop-daemon
### END INIT INFO

# Override these variables in /etc/sysconfig/ngrok

NGROK_DOMAIN="YOU-TUNEL-DOMAIN"
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/opt/ngrok/bin/ngrokd
LOGFILE=/var/log/ngrokd.log
DAEMON_ARGS="-tlsKey /opt/ngrok/device.key -tlsCrt /opt/ngrok/device.crt -domain $NGROK_DOMAIN -httpAddr ':80' -httpsAddr ':443' -log '/var/log/ngrokd.log'"
NAME=`/bin/basename $DAEMON`
DESC=ngrok
PIDFILE=/var/run/ngrokd.pid
LOCK=/var/lock/subsys/ngrokd

[ -r /etc/sysconfig/$NAME ] && . /etc/sysconfig/$NAME

. /etc/init.d/functions

do_start()
{
    if [ -s $PIDFILE ]; then
        RETVAL=1
        echo "Already running!"
    else
        echo "Starting $DESC"
        nohup $DAEMON $DAEMON_ARGS 2>&1 &
        RETVAL=$?
        PID=$!
        [ $RETVAL -eq 0 ] && touch $LOCK
        echo $PID > $PIDFILE
    fi

    return $RETVAL
}

do_stop()
{
    killproc -p $PIDFILE $NAME
    RETVAL="$?"
    echo
    [ $RETVAL = 0 ] && rm -rf $LOCK $PIDFILE
    return $RETVAL
}

case "$1" in
  start)
    do_start
    ;;

  stop)
    echo "Stopping $DESC"
    do_stop
    ;;

  status)
    if [ ! -s $PIDFILE ]; then
        echo "Not running"
    else
        PID=`cat $PIDFILE`
        if [[ -n $PID && -n "`ps -p $PID | grep $PID`" ]]; then
            echo "Running (${PID})"
        else
            echo "Not running, yet ${PIDFILE} exists (stop ngrok will fix this)"
        fi
    fi
    ;;

  *)
    echo "Usage: $NAME (start|stop|status)"
    exit 3
    ;;
esac

exit 0