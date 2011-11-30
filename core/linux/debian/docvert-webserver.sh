#!/bin/sh
### BEGIN INIT INFO
# Provides:          docvert
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Required-Start:    $local_fs $network_fs $network $syslog
# Required-Stop:     $local_fs $network_fs $network $syslog
# Short-Description: Docvert web server
# Description:       Start/stop Docvert in server mode
### END INIT INFO

scriptDirectory=$( dirname "$0" )
scriptDirectory=$( cd $scriptDirectory; pwd )

docvertcommand="/opt/docvert/docvert-web.py"
kill="/bin/kill"
pidfile="/tmp/docvert-webserver.pid"
startStopDaemon="/sbin/start-stop-daemon"
rpmDaemon="/usr/bin/daemon"
whoami=$( whoami )

export HOME=/tmp/

if [ -e "$startStopDaemon" ]
then
        if [ -n "$username" ]
        then
                username="-c $username "
        fi
        if [ -n "$groupname" ]
        then
                groupname="-g $groupname "
        fi
elif [ -e "$rpmDaemon" ]
then
        if [ -n "$username" ]
        then
                username="--user=$username"
                if [ -n "$groupname" ]
                then
                        username="$username.$groupname"
                fi
        fi
fi

docvert_start()
{
        if [ -s "$pidfile" ]
        then
                pid=$( cat "$pidfile" )
                echo "Already running? pid file exists at $pidfile that contains process #$pid"
        else
                rm -f "$pidfile"
                if [ -e "$startStopDaemon" ]
                then
                        $startStopDaemon -b -m --pidfile $pidfile --start --exec "$docvertcommand"
                elif [ -e "$rpmDaemon" ]
                then 
                        $rpmDaemon --pidfile=$pidfile $docvertcommand
                else
                        echo "Warning: Unable to find $startStopDaemon or $rpmDaemon so instead I'll daemonize by forking as the current user, $whoami."
                        $docvertcommand &
                fi
                return 0
        fi
}

docvert_stop()
{
        if [ -s "$pidfile" ]
        then
                pid=$( cat "$pidfile" )
                $kill $pid
                sleep 1
                $kill -s 9 "$pid" > /dev/null 2>&1 &
                remainingProcess=$( ps "$pid" | grep $pid )
                if [ -n $remainingProcess ]
                then
                        rm -f "$pidfile"
                        echo "Successfully killed process #$pid"
                        return 0
                else
                        echo "Unable to kill process #$pid. Check permissions? (remaining processes '$remainingProcess')"
                        return 0
                fi
        else
                echo "Stopped. Warning: No pid file found at $pidfile so I'm assuming it was never running."
        fi
}

case "$1" in
        start)
                docvert_start
        ;;
        stop)
                docvert_stop
        ;;
        restart)
                docvert_stop
                sleep 1
                docvert_start
        ;;
        *)
                echo "Usage: docvert-webserver.init.sh {start|stop|restart}"
                exit 1
        ;;
esac

