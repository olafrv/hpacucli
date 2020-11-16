WARNING: You must install the new HP MANAGMENT COMPONENT PACK FOR PROLIANT to use this scripts (see details below)

The bellow hpacucli-check.sh is a bash shell script that checks the status of controller, array, logical and physical driver
on a HP Server with the command hpaculi (HP Array Configuration Utility Client) installed, also syslogging and sending an
email with errors, warning and alerts to administrators. 

From 2012 the HP Array Configuration Utility is part of the HP Managment Component Pack for Proliant (MCP) instead of
the HP Support Pack for Proliant (SPP), the former provides agent software for use on community-supported distributions, 
while the last one, provides support for RedHat and SUSE distributions. 

Also the MCP (unlike the SPP, HP Support Pack for Proliant) does not provide drivers and firmware (firmware is provided via HPSUM,
and drivers are provided by the distribution vendors).

You can review the MCP product home page for more information, including support matrices and iso image downloads.

The OLD HP SPP CD for Debian GNU/Linux 5.0 ("lenny") and Ubuntu 9.04 ("jaunty") x86 and AMD64/EM64T" was downloadable from the HP Support Web Site (at least in December, 2012): 
https://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc;=US&swItem;=MTX-799829d8271f455d9367978b5a&prodTypeId;=15351&prodSeriesId;=1121516

The NEW HP MCP from Hewlett-Packard (HP) Software Delivery Repository or directly here https://downloads.linux.hp.com/SDR/project/mcp/

The HP MCP includes:

* hp-health: HP System Health Application and Command line Utilities
* hponcfg: HP RILOE II/iLO online configuration utility
* hp-snmp-agents: Insight Management SNMP Agents for HP ProLiant Systems
* hpsmh: HP System Management Homepage
* hp-smh-templates: HP System Management Homepage Templates
* hpacucli: HP Command Line Array Configuration Utility
* cpqacuxe: HP Array Configuration Utility
* hp-ams: HP Agentless Management Service
