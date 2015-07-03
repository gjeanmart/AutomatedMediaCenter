#!/bin/bash

##########################################################################
# Script 				: Automated Media Integration
# Description 			: 
# Date de création		: 2015-02-16
# Date de modification	: 2015-06-27
# Version 				: 0.3.0
# Author 				: Grégoire JEANMART [gregoire.jeanmart@gmail.com]
##########################################################################
# Historique
# 2015-02-16 0.1.0 : Création
# 2015-06-22 0.2.0 : Passge à Filebot 4.6 (Java 8)
# 2015-06-27 0.3.0 : Add time to filebot command
##########################################################################
# Parameters
# 	- 1 : filePath 
##########################################################################
# Exceptions
#	- 09 : Unsupported filePath
#	- 10 : Bad number of arguments
#	- 11 : FilePath	doesn't exist
#	- 12 : Filebot exception
##########################################################################
# TODO
#	- Gestion des langues
##########################################################################

LOG_FILE="/data/Private/06-Divers/dev/shell/ami.log"

echo "$(date +'%Y-%m-%d %T') INFO ### Automated Media Integration v.0.3.0 ###" >> $LOG_FILE

nbArgsExpected=1
if [ "$#" -ne "$nbArgsExpected" ]; then
	echo "$(date +'%Y-%m-%d %T') ERROR[10] Bad number of arguments ($#) : $nbArgsExpected expected" >> $LOG_FILE
	
	echo "$(date +'%Y-%m-%d %T') INFO END KO 10" >> $LOG_FILE
	exit 10
fi

##########################################################################
## Initialization parameters
filePath=$(echo "$1" | sed 's/\\//g')
echo "$(date +'%Y-%m-%d %T') INFO filePath = $filePath" >> $LOG_FILE
#fileName=$(echo "$2" | sed 's/\\//g')
#echo "$(date +'%Y-%m-%d %T') INFO fileName = $fileName" >> $LOG_FILE
##########################################################################

##########################################################################
## Initialization variables
java=java
filebot_command="filebot"

## Log level : all, config, info, warning
logLevel=all
## Action : move, copy, keeplink, symlink, hardlink, test
action=move
## Conflict Resolution : override, skip, fail
conflictResolution=override
## Exclude list
excludeList="/data/Private/06-Divers/dev/shell/amc.txt"
## Not found repository
unsortedDir="/data/Media/__A_RANGER/unsorted/"
## DB
dbMovie="TheMovieDB"
dbSerie="TheTVDB"
## Serie Path
seriePath="/data/Media/Video/Serie/"
#seriePath="/data/Media/__A_RANGER/V/Serie/"
## Movie Path
moviePath="/data/Media/Video/Movie/"
#moviePath="/data/Media/__A_RANGER/test/Movie/"
## Serie Format
serieFormat="{n}/Saison {s}/{n} - {s}x{e.pad(2)} - {t}"
## Movie Format
movieFormat="{n} [{y}]/{n} [{y}] ({director} - {genres})"
## XBMC host
xbmc=myraspberry
## Encoding
encoding="UTF-8"
# Limit serie use to differentiate serie and movie
serieLimitMin=50000000
serieLimitMax=700000000

# Clear cache [yes or no]
cleanCache="y"
# Print Version [yes or no]
printVersion="y"
# Clean prefs [yes or no] : reset application settings
cleanPrefs="y"
# Print Sys Info [yes or no]
printSysInfo="y"

##########################################################################

##########################################################################
## Check
if [ -d "$filePath" ]
then
    fileType="D"
	
elif [ -f "$filePath" ]
then
    fileType="F"
	
else
	echo "$(date +'%Y-%m-%d %T') ERROR[11] $filePath doesn't exist" >> $LOG_FILE
	echo "$(date +'%Y-%m-%d %T') INFO END KO 11" >> $LOG_FILE
	exit 11
fi

##########################################################################

##########################################################################
## MAIN

# Print Filebot version
if [ "$printVersion" == "y" ]
then
	echo "$(date +'%Y-%m-%d %T') DEBUG $filebot_command -version" >> $LOG_FILE
	$filebot_command -version  >> $LOG_FILE 2>&1

fi

# Clear Filebot cache
if [ "$cleanCache" == "y" ]
then
	echo "$(date +'%Y-%m-%d %T') DEBUG $filebot_command -clear-cache" >> $LOG_FILE
	$filebot_command -clear-cache  >> $LOG_FILE 2>&1
fi

# Reset application settings
if [ "$cleanPrefs" == "y" ]
then
	echo "$(date +'%Y-%m-%d %T') DEBUG $filebot_command -clear-pref" >> $LOG_FILE
	$filebot_command -clear-prefs  >> $LOG_FILE 2>&1
fi

# Print System Info
if [ "$printSysInfo" == "y" ]
then
	echo "$(date +'%Y-%m-%d %T') DEBUG $filebot_command -script fn:sysinfo" >> $LOG_FILE
	$filebot_command -script fn:sysinfo  >> $LOG_FILE 2>&1
fi

# Search & Rename file with Filebot
echo "$(date +'%Y-%m-%d %T') INFO Search & rename $filePath [type=$fileType] with Filebot" >> $LOG_FILE

echo "$(date +'%Y-%m-%d %T') DEBUG $filebot_command -script fn:amc --action move --conflict $conflictResolution -non-strict --def \"seriesFormat=$seriePath$serieFormat\" --def \"movieFormat=$moviePath$movieFormat\" --def \"clean=y\" --def \"excludeList=$excludeList\" --def \"xbmc=$xbmc\" --def \"minFileSize=$serieLimitMin\" \"ut_kind=multi\" \"ut_dir=$filePath\"  " >> $LOG_FILE
$filebot_command -script fn:amc --action move --conflict $conflictResolution -non-strict --def "seriesFormat=$seriePath$serieFormat" --def "movieFormat=$moviePath$movieFormat" --def "clean=y" --def "excludeList=$excludeList" --def "xbmc=$xbmc" --def "minFileSize=$serieLimitMin" "ut_kind=multi" "ut_dir=$filePath" >> $LOG_FILE 2>&1
filebotExitCode=$?
	
	
# Manage Filebot result
if [ "$filebotExitCode" -ne "0" ]
then
	echo "$(date +'%Y-%m-%d %T') ERROR[12] Filebot exception [code = $filebotExitCode]" >> $LOG_FILE
		
	echo "$(date +'%Y-%m-%d %T') DEBUG Move $filePath in $unsortedDir" >> $LOG_FILE
	mv "$filePath" "$unsortedDir" >> $LOG_FILE 2>&1
		
	echo "$(date +'%Y-%m-%d %T') INFO END KO 12" >> $LOG_FILE
	exit 12
fi
	


##########################################################################

echo "$(date +'%Y-%m-%d %T') INFO END OK" >> $LOG_FILE
exit
