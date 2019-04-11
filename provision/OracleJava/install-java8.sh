#!/bin/bash

#
# install-java8.sh
# Installs Java8 on linux systems using yum and rpm.
#
# History
#   2017/12/27  mlohn     Created.
#
# Usage
#
#    install-java8.sh
#

export JAVA_HOME=/usr/java/latest

if ! rpm -qa | grep -qw jdk1.8
   then
      if [ -z "$JAVA_VERSION" ]
          then
            echo "Environment variable JAVA_VERSION was not set!"
            exit 1
      fi
      if [ -z "$JAVA_BUILD_VERSION" ]
          then
            echo "Environment variable JAVA_BUILD_VERSION was not set!"
            exit 1
      fi
      if [ -z "$JAVA_MD5" ]
          then
            echo "Environment variable JAVA_MD5 was not set!"
            exit 1
      fi

      echo "Download Oracle Java " $JAVA_VERSION "..."
      wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD_VERSION/$JAVA_MD5/jdk-$JAVA_VERSION-linux-x64.rpm -P /tmp

      echo "Install Oracle Java " $JAVA_VERSION "..."
      sudo yum -y -t localinstall /tmp/jdk-$JAVA_VERSION-linux-x64.rpm

      echo "Delete Oracle Java installation files..."
      rm -f /tmp/jdk-$JAVA_VERSION-linux-x64.rpm

      echo "Configure alternatives"
      sudo alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 20000000
      sudo alternatives --install /usr/bin/java    java    /usr/java/latest/bin/java   20000000
      sudo alternatives --install /usr/bin/javac   javac   /usr/java/latest/bin/javac  20000000
      sudo alternatives --install /usr/bin/javaws  javaws  /usr/java/latest/bin/javaws 20000000
fi

echo "Deinstall OpenJDK 7..."
sudo yum -y -t erase java-1.7.0-openjdk
