#!/bin/bash

#
# install-oracle-weblogic.sh
# Installs and configures Oracle WebLogic Server and Domain.
#
# History
#   2019/04/10  mlohn     Created.
#
# Usage
#
#    install-oracle-weblogic.sh
#

echo "Install and Configure Oracle WebLogic Server..."

ORACLE_USER=$USER
ORACLE_GROUP=$(id -g -n)

if [ -z "$ORACLE" ]
    then
      JAVA_HOME=/usr/java/latest
fi

if ! [ -d "$ORACLE_HOME" ]
   then
      echo "Create " $ORACLE_HOME "..."
      sudo mkdir -p $ORACLE_BASE
      sudo mkdir -p $ORACLE_HOME
      echo "Enable access for " $USER "..."
      sudo chown -R $ORACLE_USER:$ORACLE_GROUP $ORACLE_BASE
      sudo chmod -R o+rx $ORACLE_BASE      
fi

if [ -z "$JAVA_HOME" ]
    then
      JAVA_HOME=/usr/java/latest
fi

if [ ! -d "$ORACLE_HOME" ]
  then
     if [ -f "./fmw_12.2.1.3.0_wls_Disk1_1of1.zip" ]
      then
         $JAVA_HOME/bin/jar -xf ./fmw_12.2.1.3.0_wls_Disk1_1of1.zip
         mv ./fmw_12.2.1.3.0_wls_Disk1_1of1/fmw_12.2.1.3.0_wls.jar ../
     fi
     
     if [ -f "./fmw_12.2.1.3.0_wls.jar" ]
       then
          echo "Installing WebLogic Server 12.2.1.3..."
          cp ./oraInst.loc /tmp
          sed -i -e "s|###ORACLE_GROUP###|$ORACLE_GROUP|g" /tmp/oraInst.loc
          sed -i -e "s|###ORACLE_USER###|$ORACLE_USER|g" /tmp/oraInst.loc
          cp ./wls.rsp /tmp
          sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /tmp/wls.rsp
          $JAVA_HOME/bin/java -jar ./fmw_12.2.1.3.0_wls.jar -silent -invPtrLoc /tmp/oraInst.loc -responseFile /tmp/wls.rsp -ignoreSysPrereqs ORACLE_HOME=$ORACLE_HOME
          rm /tmp/oraInst.loc /tmp/wls.rsp
          echo "Deactivate Derby database..."
          mv $ORACLE_HOME/wlserver/common/derby/lib/derby.jar $ORACLE_HOME/wlserver/common/derby/lib/derby.old
       else
         echo "WebLogic Server 12.2.1.3 have to be downloaded and extracted to OracleWebLogic folder."
     fi
fi

if [ -d "$ORACLE_HOME" ]
   then 
      source ./create-wls-domain.sh
      source ./wlsctl.sh start
fi 
if [ ! -f "~/wlsctl.sh" ]
    then
        echo "Configure wlsctl script..."
        cp ./wlsctl.sh $HOME
        chmod u+x ~/wlsctl.sh
fi
if [ -d "$ORACLE_HOME" ]
  then
    if ! [ -f ~/.bash_aliases ]
        then
           echo "Create file .bash_aliases for " $ORACLE_USER "..."
           touch ~/.bash_aliases
           echo "if [ -f ~/.bash_aliases ]; then" | tee -a  ~/.bashrc
           echo "      . ~/.bash_aliases" | tee -a  ~/.bashrc
           echo "fi" | tee -a ~/.bashrc
    fi
    if [ `grep -En "^alias start=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias start='$HOME/wlsctl.sh start'" | tee -a  ~/.bash_aliases
    fi
    if [ `grep -En "^alias stop=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias stop='$HOME/wlsctl.sh stop'" | tee -a ~/.bash_aliases
    fi
    if [ `grep -En "^alias status=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias status='$HOME/wlsctl.sh status'" | tee -a ~/.bash_aliases
    fi
    if [ `grep -En "^alias dh=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias dh='cd $DOMAIN_HOME'" | tee -a ~/.bash_aliases
    fi
    if [ `grep -En "^alias oh=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias oh='export ORACLE_HOME=$ORACLE_HOME'" | tee -a ~/.bash_aliases
    fi
    if [ `grep -En "^alias dn=.*$" ~/.bash_aliases | wc -l` -eq 0 ]
        then
          echo "alias dn='export DOMAIN_NAME=$DOMAIN_NAME'" | tee -a ~/.bash_aliases
    fi
    if ! [ -f ~/.bash_profile ]
        then
           echo "Create file .bash_profile for " $ORACLE_USER "..."
           touch ~/.bash_profile
           echo ". ~/.profile" | tee -a  ~/.bash_profile
           echo ". ~/.bashrc" | tee -a  ~/.bash_profile
     fi
fi
echo "Oracle WebLogic Server installer completed."
