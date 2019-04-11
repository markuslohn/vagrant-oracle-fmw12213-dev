#!/usr/bin/python

import os
import re
import sys
import getopt

oracleHome = None
domainName = None
adminUser = None
adminPassword = None
hostName = None
listenPort = None

print 'Prepares a WebLogic domain for development...'
print 'Arguments :', sys.argv[1:]
try:
    opts, args = getopt.getopt(sys.argv[1:], "", ["oracleHome=", "domainName=", "adminUser=", "adminPassword=", "hostName=", "listenPort="])
except getopt.GetoptError, err:
       print str(err)
       sys.exit(1)

for opt, arg in opts:
    if opt == "--oracleHome":
        oracleHome = arg
    elif opt == "--domainName":
        domainName = arg
    elif opt == "--adminUser":
        adminUser = arg
    elif opt == "--adminPassword":
        adminPassword = arg
    elif opt == "--hostName":
        hostName = arg
    elif opt == "--listenPort":
        listenPort = arg
    else:
        assert False, "Unrecognized Argument!"

if oracleHome == None and not os.path.exists(oracleHome):
   print oracleHome + ' does not exists!'
   sys.exit(1)
if listenPort == None:
   listenPort = 7001
if domainName == None:
   domainName = 'soadev_domain'
if adminUser == None:
   adminUser = 'weblogic'
if adminPassword == None:
   adminPassword = 'weblogic1'

domainMode = 'Compact'
domainLocation = oracleHome + '/user_projects/domains/' + domainName
wlsTemplateJar = oracleHome + '/wlserver/common/templates/wls/wls.jar'

print 'Create ' + domainLocation + ' on listen port ' + str(listenPort) + '.'
readTemplate(wlsTemplateJar, domainMode)

print 'Configure AdminServer for ' + domainName + '.'
cd('/Security/base_domain/User/' + adminUser)
cmo.setPassword(adminPassword)
cd('/Server/AdminServer')
cmo.setName('AdminServer')
cmo.setStuckThreadMaxTime(1800)
cmo.setListenPort(int(listenPort))
if hostName != None:
   cmo.setListenAddress(hostName)
writeDomain(domainLocation)
closeTemplate()
dumpStack()

readDomain(domainLocation)
jrfTemplateJar = oracleHome + '/wlserver/common/templates/wls/wls_jrf.jar'
if os.path.exists(jrfTemplateJar):
   print 'Extend domain ' + domainName + ' with template ' + jrfTemplateJar
   addTemplate(jrfTemplateJar)

updateDomain()
closeDomain()
dumpStack()

print 'Domain ' + domainName + ' in ' + domainLocation + ' successfully created.'

exit()
