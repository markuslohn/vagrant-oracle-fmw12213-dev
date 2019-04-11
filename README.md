# vagrant-oracle-fmw12113-dev

This vagrant configuration provides a CentOS 7 system with the following components:

* CentOS 7 without a desktop
* Oracle Java JDK 8
* Flyway
* Oracle XE Database 18c
* Oracle WebLogic Server 12.2.1.3
* A well prepared WebLogic domain: soadev_domain with Java DB

Please use the user vagrant/vagrant to login into the virtual machine. welcome1 is used as
password for all Oracle components, like Fusion Middleware and Database.

Use JDeveloper located on your development machine to access the WebLogic domain inside the VM. Port 7001 (WebLogic), 1521 (Oracle XE) and 5500 (Enterprise Manager) are automatically exposed by the VM.

All bookmarks can be found in file index.html.

## Installation and Configuration Steps

1. Ensure Oracle Virtual Box is installed and configured on your development machine.
   ([http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html))

2. Ensure Vagrant is installed and configured on your development machine.
   ([https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html))

3. Clone the project from git. The target folder is named PROJECT_HOME afterwards.

   ```
   $ git clone 
   ```
4. Download Oracle Database Express Edition 18c to $PROJECT_HOME/provision/OracleXE/oracle-database-xe-18c-1.0-1.x86_64.rpm
   ([http://download.oracle.com/otn/linux/oracle18c/xe/oracle-database-xe-18c-1.0-1.x86_64.rpm](http://download.oracle.com/otn/linux/oracle18c/xe/oracle-database-xe-18c-1.0-1.x86_64.rpm))

5. Download Oracle WebLogic Server 12.2.1.3 to $HOME/Downloads. Now extract the contents of the zip file fmw_12.2.1.3.0_wls_Disk1_1of1.zip to $HOME/Downloads. Copy the file fmw_12.2.1.3.0_wls.jar from $HOME/Downloads/fmw_12.2.1.3.0_wls_Disk1_1of1 to $PROJECT_HOME/provision/OracleWebLogic/fmw_12.2.1.3.0_wls.jar.

6. You can fine tune the configuration by open the vagrant file. The following settings can be modified when the default is not suitable:

   ```
    s.env = {
             ORACLE_PASSWORD: "weblogic1", => Password for Oracle XE database.
             ORACLE_CHARACTERSET: "AL32UTF8",
             ORACLE_BASE: "/opt/oracle", => Base directory where all Oracle software will be installed.
             ORACLE_HOME: "/opt/oracle/middleware/12.2.1.3/soaquickstart",
             DOMAIN_NAME: "soadev_domain", => Name of the WebLogic Domain.
             ADMIN_PORT: "7201", => Port to access WebLogic server.
             ADMIN_NAME: "weblogic", => Name of the admin user for WebLogic server.
             ADMIN_PASSWORD: "weblogic1", => Password of the WebLogic admin user.
             JAVA_VERSION: "8u152",
             JAVA_BUILD_VERSION: "b16",
             JAVA_MD5: "aa0333dd3019491ca4f6ddbe78cdb6d0"}
   ```

9. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev. Startup the VM:

   ```
   $ vagrant up
   ```

10. Add the following line to your local /etc/hosts

    ```
    127.0.0.1       oracledev.esentri.com
    ```

11. Open the file PROJECT_HOME/index.html in a web browser

    This files contains all links and some other important information working with the VM.

## Usage

### Start Virtual Machine

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev

2. Execute start command

   ```
   $vagrant up
   ```

### Stop Virtual Machine

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev

2. Execute stop command

   ```
   $ vagrant halt
   ```

### Login to Virtual machine

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev

2. Execute stop command

   ```
   $ vagrant ssh
   ```

**Note:** You can sudo su - oracle to switch to the oracle user. The oracle user contains the db and weblogic installation.

### Update Virtual Machine

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev

2. Pull the latest changes from the git repository

3. Execute the following command. The virtual machine must be started!

   ```
   $ vagrant rsync
   $ vagrant provision
   ```

### Connecting to Oracle Database

- Hostname: localhost
- Port: 1521
- SID: XE
- PDB: XEPDB1
- EM Express port: 5500
- All passwords are auto-generated and printed on install

### Resetting password
You can reset the password of the Oracle database accounts (SYS, SYSTEM and PDBADMIN only) by switching to the oracle user (sudo su - oracle), then executing /home/oracle/setPassword.sh <Your new password>.

### Start/Stopp Oracle Database

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-db-wls-12c-dev

2. stop command

   ```
   $ vagrant ssh
   $ sudo -s
   $ /etc/init.d/oracle-xe-18c stop
   ```

3. start command
   
   ```
   $ vagrant ssh
   $ sudo -s
   $ /etc/init.d/oracle-xe-18c start
   ```

### Login to WebLogic Console

1. Open a web browser on your local machine

2. Type the following URL http://localhost:7001/console

3. Use the credentials weblogic/weblogic1


### Login to Enterprise Manager

1. Open a web browser on your local machine

2. Type the following URL http://localhost:7001/em

3. Use the credentials weblogic/weblogic1


### Start/Stop WebLogic Server

1. Open a shell on your development machine and navigate to the folder vagrant-oracle-fmw12213-dev

2. stop command

   ```
   $ vagrant ssh
   $ sudo su - oracle
   $ ./wlsctl.sh stop
   ```

3. start command

   ```
   $ vagrant ssh
   $ sudo su - oracle
   $ ./wlsctl.sh start
   ```

   **Note:** The commands are configured as alias. Use the command `alias` to list all available commands.

### Post Installation Steps

### Issues

Obtain and install the following patches from Oracle Support regardings the release 12.2.1.3:

- 27235959: Auf den Server, damit die One-Way Pipelines funktionieren.
- 26851310: Auf JDeveloper, um den DBAdapter verwenden zu können.
