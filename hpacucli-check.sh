#!/bin/bash

###
# FILE:	hpacucli-check.sh (03-Dec-2013)
# LICENSE: GNU/GPL v3.0
# AUTHOR:  Olaf Reitmaier Veracierta <olafrv@gmail.com>
# USAGE:   Check the status of the logical drives on a HP Server
#		  with ssacli (HP Array Configuration Utility Client)
#		  installed, syslog and send an email with errors.
## 
SSACLI=/usr/sbin/ssacli
SSACLI_TMP=/tmp/ssacli.log
ERROR_FOUND=false
MAIL=destination_email_address_here
 
# Debugging?, just pass debug as first parameter.
if [ -z "$1" ]
then
	DEBUG=0
elif [ "$1" == "debug" ]
then
	DEBUG=1
fi
 
###
# SUPPORT COMMUNICATION - CUSTOMER ADVISORY - Document ID: c03676138 - Version: 1
# http://h20566.www2.hp.com/portal/site/hpsc/template.PAGE/public/kb/docDisplay/?sp4ts.oid=3924066&spf_p.tpst=kbDocDisplay&spf_p.prp_kbDocDisplay=wsrp-navigationalState%3DdocId%253Demr_na-c03676138-1%257CdocLocale%253D%257CcalledBy%253D&javax.portlet.begCacheTok=com.vignette.cachetoken&javax.portlet.endCacheTok=com.vignette.cachetoken
# ADVISORY: Linux - HP Array Configuration Utility CLI for Linux (Hpacucli) Version 9.00 (Or Later) Is Delayed in Responding if Storage That Is Not Connected to Local Smart Array Controller Is Configured With Multiple LUNs
# DESCRIPTION: There may be a delay starting the HP Array Configuration Utility CLI for Linux (ssacli) Version 9.00 (or later) on an HP ProLiant server configured to detect multiple LUNs connected via Fibre or iSCSI storage. In addition, there may be times that certain commands will delay in operating. This occurs because functionality was added to the ACU to discover HP branded Solid State Drives (SSD) that are not connected to the HP Smart Array controllers.
# SCOPE: Any HP ProLiant server running the HP Array Configuration Utility CLI for Linux (ssacli) Version 9.00 (or later) configured to detect multiple LUNs connected via Fibre or iSCSI storage.
# RESOLUTION : To prevent the delay from occurring when accessing local storage, type the following command:
# export INFOMGR_BYPASS_NONSA=1
# To re-enable the feature non-smart array device scanning, type the following command.
# export -n INFOMGR_BYPASS_NONSA
# Or use hpssacli version 2.0-23.0 (or later) which is the purpose of this updated script.
###########################################################################################
# HPE Smart Storage Administrator (HPE SSA) CLI for Linux 64-bits
# The HPE Smart Storage Administrator CLI (HPE SSACLI) is a commandline-based disk configuration 
# program that helps you configure, manage, diagnose, and monitor HPE ProLiant Smart Array Controllers 
# and now other storage devices as well, such as host bus adapters (HBAs), HPE Storage controllers, 
# and future devices such as SCSI Express drives, and SAS switch devices. HPE SSACLI replaces 
# the existing HP Array Configuration CLI Utility, or ACUCLI, with an updated design and will deliver 
# new features and functionality for various Smart Storage initiatives as they come online. 
# HPE Smart Array Advanced Pack 1.0 and 2.0 features are now part of the baseline features of HPE SSACLI,
# with the appropriate firmware. HPE SSACLI will allow you to configure and manage your storage as before, 
# but now with additional features, abilities, and supported devices. Existing ACUCLI scripts should only 
# need to make minimal changes such as calling the appropriate binary or executable in order to maintain 
# compatibility. HPE SSASCRIPTING - Scripting can be performed in offline or online environments. 
# The HPE SSA Scripting application has 2 scripting modes – Capture and Input.
############################################################################################
# export INFOMGR_BYPASS_NONSA=1 // not required anymore using ssacli
##
 
# Clean temp files
function deleteTmpFiles
{
	rm -f $FILE_DISK
	rm -f $FILE_DRIVE
	rm -f $FILE_ARRAY
	rm -f $FILE_ARRAY_STATUS
	rm -f $FILE_SLOT
	rm -f $FILE_SLOT_STATUS
	rm -f $FILE_EMAIL
}
 
# Logging
function doLog
{
	# doLog "$slot" "$msg" "level" $DEBUG
	slot=$1
	msg=$2
	level=$3
	debug=$4
	if [ "$level" == "error" ] || [ "$level" == "alert" ] || [ "$debug" == "1" ]
	then
		ERROR_FOUND=true
	fi
	logger -p syslog.$level -t ssacli "$msg"
	echo -e "$msg \
	" >> $FILE_EMAIL
	#if [ "$level" == "error" ] || [ "$level" == "alert" ]
	#then
	#  $SSACLI ctrl slot=$slot show config detail
	#  ERROR=1
	#fi
}

SERVICE="ssacli"
if pgrep -x "$SERVICE" >/dev/null
then
      msg="[ERROR] ssacli is already running, so will not run again"
	echo $msg
       logger -p syslog.info -t ssacli "$msg"
	deleteTmpFiles
	exit 1
fi
 
FILE_DATE=$(date "+%Y-%m-%d-%I_%M")
FILE_SLOT=/tmp/ssacli_${FILE_DATE}_slot.txt
FILE_SLOT_STATUS=/tmp/ssacli_${FILE_DATE}_slot_status.txt
FILE_ARRAY=/tmp/ssacli_${FILE_DATE}_array.txt
FILE_ARRAY_STATUS=/tmp/ssacli_${FILE_DATE}_array_status.txt
FILE_DRIVE=/tmp/ssacli_${FILE_DATE}_drive.txt
FILE_DISK=/tmp/ssacli_${FILE_DATE}_disk.txt
FILE_EMAIL=/tmp/ssacli_${FILE_DATE}_email.txt
 
# Controllers (Slots) Status
ERROR_NOSLOT=1
$SSACLI ctrl all show | grep "Slot " > $FILE_SLOT
while read line1
do
  ERROR_NOSLOT=0
  slot=`expr match "$line1" '.*Slot \([0-9]\).*'`
	# Controller (Slot) Status
	$SSACLI ctrl slot=$slot show status | grep "Status" | grep -v "Not Configured" > $FILE_SLOT_STATUS
	while read line2
	do
		if echo "$line2" | grep "OK" > /dev/null
		then
			msg="[OK] RAID controller slot $slot -> $line2"
			doLog "$slot" "$msg" "info" $DEBUG
		else
			msg="[ERROR] RAID controller slot $slot -> $line2"
			doLog "$slot" "$msg" "error" $DEBUG
		fi
	done < $FILE_SLOT_STATUS
 
	# Arrays Status
  $SSACLI ctrl slot=$slot array all show | grep array > $FILE_ARRAY
  while read line2
  do
		array=`expr match "$line2" '.*array \([a-Z]\).*'`
 
		# Array Status
		ERROR_NOARRAY=1
		$SSACLI ctrl slot=$slot array $array show status | grep array > $FILE_ARRAY_STATUS
		while read line3
		do
		ERROR_NOARRAY=0
			if echo "$line3" | grep "OK" > /dev/null
			then
			 	msg="[OK] RAID controller slot $slot array $array -> $line3"
				doLog "$slot" "$msg" "info" $DEBUG
			else
				msg="[ERROR] RAID controller slot $slot array $array -> $line3"
				doLog "$slot" "$msg" "error" $DEBUG
			fi
		done < $FILE_ARRAY_STATUS
		if [ $ERROR_NOARRAY -eq 1 ]
		then
			msg="[WARN] No array error on RAID controller slot #$slot"
			doLog "$slot" "$msg" "warning" $DEBUG
		fi

		# Physical Drive (Disk) Status
		ERROR_NODISK=1
 	  $SSACLI ctrl slot=$slot physicaldrive all show | grep physicaldrive > $FILE_DISK
	while read line4
 	  do
			ERROR_NODISK=0
	  physicaldrive=`expr match "$line4" '.*physicaldrive \(.*\:.*\:.*\) ('`
   	  if [ `$SSACLI ctrl slot=$slot physicaldrive $physicaldrive show | grep "Status: OK" | wc -l` -eq 0 ]
 		then
		msg="[ERROR] RAID controller slot #$slot physicaldrive $physicaldrive -> $line4"
				doLog "$slot" "$msg" "error" $DEBUG
 		else
		msg="[OK] RAID controller slot #$slot physicaldrive $physicaldrive -> $line4"
				doLog "$slot" "$msg" "info" $DEBUG
 		fi
	done < $FILE_DISK
 
		if [ $ERROR_NODISK -eq 1 ]
		then
			msg="[WARN] No physical drive (disk) error on RAID controller slot #$slot"
			doLog "$slot" "$msg" "warning" $DEBUG
		fi
 
		# Logical Drives Status
		ERROR_NODRIVE=1
		$SSACLI ctrl slot=$slot array $array logicaldrive all show | grep logicaldrive > $FILE_DRIVE
		while read line4
		do
			ERROR_NODRIVE=0
			logicaldrive=`expr match "$line4" '.*logicaldrive \([0-9]\).*'`
			if [ `$SSACLI ctrl slot=$slot array $array logicaldrive $logicaldrive show | grep "Status: OK" | wc -l` -eq 0 ]
			then
				msg="[ERROR] RAID controller slot #$slot array $array drive #$logicaldrive -> $line4"
				doLog "$slot" "$msg" "error" $DEBUG
			else
				msg="[OK] RAID controller slot #$slot array $array drive #$logicaldrive -> $line4"
				doLog "$slot" "$msg" "info" $DEBUG
			fi
	  done < $FILE_DRIVE
 
		if [ $ERROR_NODRIVE -eq 1 ]
		then
			msg="[WARN] No logical drive error on RAID controller slot #$slot"
			doLog "$slot" "$msg" "warning" $DEBUG
		fi
 
		# Array but no physical or logical driver detected is an error
	if [ $ERROR_NOARRAY -eq 0 ]
		then
			if [ $ERROR_NODRIVE -eq 1 ] || [ $ERROR_NODISK -eq 1 ]
			then
				msg="[ERROR] RAID controller (slot) $slot array $array has no logical or physical drives"
				doLog "$slot" "$msg" "alert" $DEBUG
			fi
		fi
 
  done < $FILE_ARRAY
 
done < $FILE_SLOT
 
if [ $ERROR_NOSLOT -eq 1 ]
then
	msg="[ERROR] No RAID controller (slot) detected" | mail -s "RAID Report : No Raid Controller found on `hostname`" maurocali01@gmail.com
	doLog "$slot" "$msg" "alert" $DEBUG
fi

if  $ERROR_FOUND
then
	$SSACLI ctrl all show config detail >> $FILE_EMAIL
	echo "$(cat $FILE_EMAIL)" | mail -s "RAID Report : ERRORS detected on `hostname`" $MAIL
else
	$SSACLI ctrl all show config detail >> $FILE_EMAIL
        echo "$(cat $FILE_EMAIL)" | mail -s "RAID Report : OK on `hostname`" $MAIL
fi
deleteTmpFiles
