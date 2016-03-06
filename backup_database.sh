#!/bin/bash

#Fichier de log
LOG_FILE="log_backup"
echo "" > $LOG_FILE
#Tables utiles
VIEW_PARAMETER="V\$PARAMETER"
DBA_DATA_FILES="DBA_DATA_FILES"

#Dossier de la backup
BACKUP_FOLDER="oracle_backup"
CTL_FOLDER="$BACKUP_FOLDER/clt_files"
TABLESPACE_FOLDER="$BACKUP_FOLDER/tablespace_files"

if [ -d $BACKUP_FOLDER ]; then
  echo "Supression de la backup précédente" |tee  $LOG_FILE
  rm -r $BACKUP_FOLDER
fi

mkdir $BACKUP_FOLDER
mkdir $CTL_FOLDER
mkdir $TABLESPACE_FOLDER


#Requete de recuperation des fichiers de controles ORACLE
RESULTS=`sqlplus -s /nolog << EOF
set pages 0
set head off
set lines 9999
set feed off
connect system/m2pgi13
SELECT VALUE FROM ${VIEW_PARAMETER}
WHERE NAME='control_files';
EOF`

#Requete de recuperation des fichiers des tablespaces
TABLESPACE_FILES=`sqlplus -s /nolog << EOF
set pages 0
set head off
set lines 9999
set feed off
connect system/m2pgi13
SELECT file_name FROM ${DBA_DATA_FILES};
EOF`

echo "Shutdown database" |tee  $LOG_FILE
sqlplus -s /nolog << EOF
connect / as sysdba
shutdown
exit
EOF
# could be changed for mor flexible interuption



CTL_FILES=`echo $RESULTS | sed -e 's/,//g'`
#Sauvegarde des fichier de controles.
for FILE in $CTL_FILES; do
  echo "Sauvegarde du fichier " $FILE |tee  $LOG_FILE
  cp $FILE $CTL_FOLDER
done

#Sauvegarde des fichier de tablespaces.
for FILE in $TABLESPACE_FILES; do
  echo "Sauvegarde du fichier " $FILE |tee  $LOG_FILE
  cp $FILE $TABLESPACE_FOLDER
done

echo "Startup database" |tee  $LOG_FILE

sqlplus -s /nolog << EOF
connect / as sysdba
startup
exit
EOF
