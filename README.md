**NOTE**: You must install the new HP MANAGMENT COMPONENT PACK FOR PROLIANT (MCP) prior to use this script (see details below)

The `hpacucli-check.sh` is a bash shell script that checks the status of controller, array, logical and physical driver on a HP Server with the command hpaculi (HP Array Configuration Utility Client), also provides logging via syslog and sending of an email with errors, warning and alerts to administrators. 

Since 2012 the HP Array Configuration Utility became part of the HP Managment Component Pack for Proliant (MCP) instead of the HP Support Pack for Proliant (SPP), the former provided agent software for use on community-supported distributions, while the latter provided support for RedHat and SUSE distributions. 

Also the MCP (unlike the SPP) did not provide drivers or firmware. Firmware was provided via HPSUM while drivers were provided by the distribution vendors.

The MCP product home page contained for more information, including support matrices and ISO image downloads.

The old HP SPP CD for Debian GNU/Linux 5.0 ("lenny") and Ubuntu 9.04 ("jaunty") x86/AMD64/EM64T" was downloadable from the HP Support Web Site (at least in December of 2012): https://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc;=US&swItem;=MTX-799829d8271f455d9367978b5a&prodTypeId;=15351&prodSeriesId;=1121516

The back then new HP MCP from Hewlett-Packard (HP) Software Delivery Repository or directly here https://downloads.linux.hp.com/SDR/project/mcp/

The HP MCP included:

* hp-health: HP System Health Application and Command line Utilities
* hponcfg: HP RILOE II/iLO online configuration utility
* hp-snmp-agents: Insight Management SNMP Agents for HP ProLiant Systems
* hpsmh: HP System Management Homepage
* hp-smh-templates: HP System Management Homepage Templates
* hpacucli: HP Command Line Array Configuration Utility
* cpqacuxe: HP Array Configuration Utility
* hp-ams: HP Agentless Management Service

This script was tested for 6 months in HP Proliant G4, G5, G6 and G7 Servers with GNU/Linux Debian 6/7, which were migrated from using HP SPP to HP MCP, for more information about this procedure in Debian look at: https://wiki.debian.org/HP/ProLiant

There is docker container implementation: https://github.com/CoRfr/docker-ssacli

