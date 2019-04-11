#!/bin/bash

#
# install-flyway.sh
# Installs and configures flyway.
#
# History
#   2017/12/28  mlohn     Created.
#   2018/11/23  mlohn     Updated flyway version
#
# Usage
#
#    install-flyway.sh
#

FLYWAY_VERSION=5.2.1

if ! [ -d "/opt/flyway-$FLYWAY_VERSION" ]
  then
    echo "Download flyway $FLYWAY_VERSION..."
    wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$FLYWAY_VERSION/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz -P /tmp

    echo "Extract flyway to /opt..."
    sudo tar -xzf /tmp/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz -C /opt

    echo "Fixing flyway permissions..."
    sudo chmod -R 0755 /opt/flyway-$FLYWAY_VERSION

    echo "Creating symlink for flyway in /usr/bin ..."
    sudo ln -s /opt/flyway-$FLYWAY_VERSION/flyway /usr/bin

    echo "Delete flyway installation files..."
    rm -f /tmp/flyway-commandline-$FLYWAY_VERSION-linux-x64.tar.gz
fi
