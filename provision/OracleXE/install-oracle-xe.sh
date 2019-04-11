#!/bin/bash

#
# install-oracle-xe.sh
# Installs and configures Oracle XE 18c. Inspired by https://github.com/oracle/vagrant-boxes/tree/master/OracleDatabase/18.4.0-XE
#
# History
#   2019/04/08  mlohn     Created.
#
# Usage
#
#    install-oracle-xe.sh
#

echo "Install and Configure Oracle XE database..."

ORACLE_USER=oracle
ORACLE_GROUP=oinstall

if [ -z "$ORACLE_PASSWORD" ]
    then
        export ORACLE_PASSWORD=${ORACLE_PASSWORD:-"`openssl rand -base64 8`1"}
fi
if [ -z "$ORACLE_CHARACTERSET" ]
    then
        export ORACLE_CHARACTERSET="AL32UTF8"
fi

if [ ! -d "/opt/oracle/product/18c/dbhomeXE" ]
   then
        echo "Oracle database not installed on this machine."

        if ! [ -f "./oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm" ]
            then
                echo "Prepare OS for Oracle database installation..."
                sudo curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
        fi

        if [ -f "./oracle-database-xe-18c-1.0-1.x86_64.rpm" ]
            then
                echo "Install Oracle database..."
                sudo yum -y localinstall ./oracle-database*18c*
            else
                echo "oracle-database-xe-18c-1.0-1.x86_64.rpm not available for installation. Please download it from Oracle Technology Network."
        fi
fi

if [ ! -d "/home/$ORACLE_USER" ]
    then
        echo "Prepares home folder for user " $ORACLE_USER "..."
        sudo mkdir -p /home/$ORACLE_USER
        sudo chown $ORACLE_USER:$ORACLE_GROUP /home/$ORACLE_USER
        sudo chmod g-rx,o-r-x /home/$ORACLE_USER
fi 
if [ ! -f "/home/$ORACLE_USER/setPassword.sh" ]
    then
        echo "Configure script to change database password."
        sudo cp ./setPassword.sh /home/$ORACLE_USER/ && \
        sudo chown $ORACLE_USER:$ORACLE_GROUP /home/$ORACLE_USER/setPassword.sh && \
        sudo chmod u+x /home/$ORACLE_USER/setPassword.sh
fi
echo "Prepare environment variables..."
if [ ! -f "/home/$ORACLE_USER/.profile" ]
    then
        su $ORACLE_USER -c 'touch ~/.profile'
fi
if [ `grep -En "^export ORACLE_BASE=.*$" /home/$ORACLE_USER/.profile | wc -l` -eq 0 ]
    then
        echo "export ORACLE_BASE=/opt/oracle" | tee -a ~/.profile
fi
if [ `grep -En "^export ORACLE_SID=.*$" /home/$ORACLE_USER/.profile | wc -l` -eq 0 ]
    then
        su -l $ORACLE_USER -c 'echo "export ORACLE_SID=XE" | tee -a ~/.profile'
fi
if [ `grep -En "^export ORACLE_HOME=.*$" /home/$ORACLE_USER/.profile | wc -l` -eq 0 ]
    then
        su -l $ORACLE_USER -c 'echo "export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE" | tee -a ~/.profile'
fi
if [ `grep -En "^export PATH=.*dbhomeXE.*$" /home/$ORACLE_USER/.profile | wc -l` -eq 0 ]
    then
        su -l $ORACLE_USER -c 'echo "export PATH=\$PATH:/opt/oracle/product/18c/dbhomeXE/bin" | tee -a ~/.profile'
fi

if [ -d "/opt/oracle/product/18c/dbhomeXE" ] && [ ! -d "/opt/oracle/oradata/XE" ]
   then
        echo "Create XE database..."
        mv /etc/sysconfig/oracle-xe-18c.conf /etc/sysconfig/oracle-xe-18c.conf.original
        cp ./oracle-xe-18c.conf.tmpl /etc/sysconfig/oracle-xe-18c.conf
        chmod g+w /etc/sysconfig/oracle-xe-18c.conf
        sed -i -e "s|###ORACLE_CHARACTERSET###|$ORACLE_CHARACTERSET|g" /etc/sysconfig/oracle-xe-18c.conf && \
        sed -i -e "s|###ORACLE_PWD###|$ORACLE_PASSWORD|g" /etc/sysconfig/oracle-xe-18c.conf
        su -l -c '/etc/init.d/oracle-xe-18c configure'

        echo "enable global port for EM Express..."
        su -l oracle -c '
             export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
             sqlplus / as sysdba <<EOF
             EXEC DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE);
             EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);
             quit:'

        echo "Configure systemd to start oracle instance on startup..."
        sudo /sbin/chkconfig oracle-xe-18c on
        sudo /sbin/service oracle-xe-18c start    
fi

echo "ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: " $ORACLE_PASSWORD
echo "Oracle Database installer completed."
