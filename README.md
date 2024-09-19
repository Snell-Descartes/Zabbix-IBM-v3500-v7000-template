# Zabbix-IBM-v3500-v5000-v7000-template
Use for monitoring of IBM v3500, v3700, v5000 and v7000 storage systems within Zabbix.

## Important notice
Since I forked from the original project, the following content has been adapted and tested against two V5000 model devices only.
Functional changes highlight:
* Trigger rule changes
* More detailed disk name (+ mdisk)
* SSH key pair authentication, removing the authentication user/pwd parameters.
* Basic ethernet interface check ( WIP: hardcoded at the moment )
* Template file updated for Zabbix V7

## Functionalities
Supports multiple enclosures and monitors power supplies, vdisks, arrays, canisters and disks.

## Credits
Adapted from the original script created by Francisco Tudel 2015

## Usage
* copy the v3700_status.sh file to the proper external files directory on your zabbix server and zabbix proxies.
* Import the template file into your templates section within the Zabbix ui.
* Create a new user with a ssh key auth on your storage system which Zabbix can use.
* Create your host as per nornal but adding the following user macros:
* {$CABIP1} - this is the IP address or the fqdn/hostname of your storage system
* Setup the SSH Key-Based Authentication in the script execution environment.
* The SSH call in the verification script is designed to use a SSH config file
* You will need to change or review the ssh config file path used in the c3700_status.sh file
* review the sh script to match your ssh configuration specifics 
* Execute the 4 discovery rules, which should then populate all the items you need for monitoring.
