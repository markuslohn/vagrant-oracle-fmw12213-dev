#!/bin/bash

#
# delete-wls-domain.sh
# Removes a WebLogic Server domain.
#
# History
#   2017/05/09  mlohn     Created
#
# Parameter
#    domainName = the name of the WebLogic Server domain
#
# Usage
#
#    delete-wls-domain.sh devdomain
#

if [ -z "$ORACLE_HOME" ]
   then
     echo "Environment variable ORACLE_HOME was not set!"
     exit 1
fi

domainName=$1
DOMAIN_HOME=$ORACLE_HOME/user_projects/domains/$domainName

if [ -d "$DOMAIN_HOME" ]
   then
    if [ `ps -ef | grep AdminServer | grep $domainName | wc -l` > 0 ]
       then
         echo "Stopping $domainName..."
         $DOMAIN_HOME/bin/stopWebLogic.sh
    fi

    echo "Deletes $DOMAIN_HOME..."
    rm -rf $ORACLE_HOME/user_projects/domains/$domainName
    rm -rf $ORACLE_HOME/user_projects/applications/$domainName
    sed -i.bak '/$domainName/d' $ORACLE_HOME/domain-registry.xml

    echo "$domainName successfully deleted."
elif
    echo "$DOMAIN_HOME does not exist."
fi
