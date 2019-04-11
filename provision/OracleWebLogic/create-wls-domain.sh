#!/bin/bash

#
# create-wls-domain.sh
# A wrapper script to create a WebLogic server development domain with WLST.
#
# History
#   2017/05/09  mlohn     Created
#   2017/12/27  mlohn     Re-factored.
#   2018/11/23  mlohn     Configured hostname for Listen Adress in WebLogic Server.
#
# Usage
#
#    create-wls-domain.sh
#

echo "Oracle WebLogic domain configurator started..."

if [ -z "$ORACLE_HOME" ]
   then
     echo "Environment variable ORACLE_HOME was not set!"
     exit 1
fi
if [ -z "$DOMAIN_NAME" ]
   then
     export DOMAIN_NAME=dev_domain
fi

export DOMAIN_HOME=$ORACLE_HOME/user_projects/domains/$DOMAIN_NAME

if [ ! -d "$DOMAIN_HOME" ] && [ -e "$ORACLE_HOME" ]
  then
     echo "Create WebLogic domain " $DOMAIN_NAME " in " $DOMAIN_HOME "..."
     $ORACLE_HOME/oracle_common/common/bin/wlst.sh create-wls-domain.py --oracleHome $ORACLE_HOME --domainName $DOMAIN_NAME --adminUser $ADMIN_USER --adminPassword $ADMIN_PASSWORD --listenPort $ADMIN_PORT --hostName $(hostname)
     echo $DOMAIN_NAME " was successfully created."
fi

echo "Oracle WebLogic Domain configurator completed."