
#!/bin/bash

#
# wlsctl.sh
# Start/Stop scirpt for a WebLogic Server development domain.
#
# History
#   2010/07/23  mlohn     Created
#   2017/12/29  mlohn     Waits until AdminServer is started completely
#
# Parameter
#    start
#    stop
#    restart
#    status
#
# Usage
#
#    wlsctl.sh start
#

if [ -z "$ORACLE_HOME" ]
   then
     echo "Environment variable ORACLE_HOME was not set!"
     exit 1
fi
if [ -z "$DOMAIN_NAME" ]
   then
     echo "Environment variable DOMAIN_NAME was not set!"
     exit 1
fi

DOMAIN_HOME=$ORACLE_HOME/user_projects/domains/$DOMAIN_NAME
if ! [ -d "$DOMAIN_HOME" ]
   then
      echo "$DOMAIN_HOME does not exist!"
      exit 1
fi
listenPort="7001"
if [ -z "$ADMIN_PORT" ]
   then
     listenPort=$(sed -n 's:.*<listen-port>\(.*\)<\/listen-port>.*:\1:p' $DOMAIN_HOME/config/config.xml)
     if [ ! -z "$listenPort" -a "$listenPort" != " " ]
        then
          listenPort="7001"
     fi
   else
     listenPort=$ADMIN_PORT
fi
hostname=$(hostname)
echo $hostname ":" $listenPort

state=$1

case $state in

'start')
        if ! [ `ps -ef | grep AdminServer | grep $DOMAIN_NAME | wc -l` -ne 0 ]
          then
            echo "Start WebLogic domain " $DOMAIN_NAME "..."
            mkdir -p $DOMAIN_HOME/servers/AdminServer/logs
            nohup $DOMAIN_HOME/startWebLogic.sh > $DOMAIN_HOME/servers/AdminServer/logs/adminserver.out 2>&1 &

            i="0"
            while [ $i -ne "302" ]
               do
                  sleep 30
                  i="$(curl -s -o /dev/null -silent -w '%{http_code}' http://$hostname:$listenPort/console)"
            done
        fi
        echo "WebLogic domain " $DOMAIN_HOME " successfully started."

;;

'stop')
        echo "Stopping $DOMAIN_NAME..."
        $DOMAIN_HOME/bin/stopWebLogic.sh
        echo "Stopped."
        sleep 10s
        echo "Processes remaining: "
        ps -eaf | grep $DOMAIN_HOME
        echo "Please control the processes after 30 seconds again"
;;

'restart')
        echo "Re-Starting AdminServer for $DOMAIN_NAME..."
        $DOMAIN_HOME/bin/stopWebLogic.sh
        sleep 10s
        nohup $DOMAIN_HOME/startWebLogic.sh > $DOMAIN_HOME/servers/AdminServer/logs/adminserver.out 2>&1 &
        i="0"
        while [ $i -ne "302" ]
           do
              sleep 30
              i="$(curl -s -o /dev/null -silent -w '%{http_code}' http://$hostname:$listenPort/console)"
        done
        echo "WebLogic domain " $DOMAIN_HOME " successfully started."
;;

'status')

        printf "\n\n \033[1mServertyp      | Name                                 | Status      \033[0m\n"
        printf "________________|______________________________________|_____________\n"

        if [ `ps -ef | grep AdminServer | grep $DOMAIN_NAME | wc -l` -ne 0 ]
           then
              procstate='activ'
              proccolor='[32m'
           else
              procstate='inactiv'
              proccolor='[31m'
        fi
        printf "%15s | %30s | \033$proccolor%12s\033[0m\n" "AdminServer ($listenPort)" "$DOMAIN_NAME" "$procstate"
        printf "\n\n"
;;

*)
        echo "Usage: $0 { start | stop | restart | status}"
        exit 1
;;
esac
