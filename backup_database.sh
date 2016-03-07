#!/bin/bash

#Fichier de log
LOG_FILE="log_backup"
echo "" > $LOG_FILE
#Tables utiles
VIEW_PARAMETER="V\$PARAMETER"
DBA_DATA_FILES="DBA_DATA_FILES"
VIEW_LOG_FILES="V\$LOGFILE"
#Recurperation du SID
echo "INFO::ORACLE_SID=$ORACLE_SID" |tee -a $LOG_FILE
if [ -z "$ORACLE_SID" ]; then
  echo "WARNING::Auncune base oracle associé à cet environement, no SID" |tee -a $LOG_FILE
  exit 1
fi

echo "INFO::Verification de l'état de la base" |tee -a $LOG_FILE
RUNNING=`ps -ef | grep -v 'grep'| grep "ora_pmon_$ORACLE_SID"`
if [ -z "$RUNNING" ]; then
  echo "WARNING::La base n'est pas démarée" |tee -a $LOG_FILE
  exit 1
fi
echo "INFO::Status base : Démarée"

BACKUP_FOLDER="oracle_backup"
CTL_FOLDER="$BACKUP_FOLDER/clt_files"
TABLESPACE_FOLDER="$BACKUP_FOLDER/tablespace_files"
DB_LOG_FOLDER="$BACKUP_FOLDER/log_files"

if [ -d $BACKUP_FOLDER ]; then
  echo "INFO::Supression de la backup précédente" |tee -a  $LOG_FILE
  rm -r $BACKUP_FOLDER
fi

mkdir $BACKUP_FOLDER
if [ ! $? = 0 ]; then
  echo "WARNING::Impossible de créer le dossier de back up, opération terminé avec erreur"|tee -a $LOG_FILE
  exit 1
fi
echo "INFO::Dossier de backup crée a : $BACKUP_FOLDER"|tee -a $LOG_FILE

mkdir $CTL_FOLDER
if [ ! $? = 0 ]; then
  echo "WARNING::Impossible de créer le dossier pour les fichiers de controles, opération terminé avec erreur : $CTL_FOLDER "|tee -a $LOG_FILE
  exit 1
fi


mkdir $TABLESPACE_FOLDER
if [ ! $? = 0 ]; then
  echo "WARNING::Impossible de créer le dossier pour les fichiers des tablespaces, opération terminé avec erreur : $TABLESPACE_FOLDER"|tee -a $LOG_FILE
  exit 1
fi
mkdir $DB_LOG_FOLDER
if [ ! $? = 0 ]; then
  echo "WARNING::Impossible de créer le dossier pour les fichiers de trace, opération terminé avec erreur : $DB_LOG_FOLDER"|tee -a $LOG_FILE
  exit 1
fi


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

DB_LOG_FILES=`sqlplus -s /nolog << EOF
set pages 0
set head off
set lines 9999
set feed off
connect system/m2pgi13
SELECT MEMBER FROM ${VIEW_LOG_FILES};
EOF`

echo "INFO::Shutdown database" |tee -a  $LOG_FILE
sqlplus -s /nolog << EOF
connect / as sysdba
shutdown abort
exit
EOF
# could be changed for more flexible interuption


CTL_FILES=`echo $RESULTS | sed -e 's/,//g'` #Il y a une virgule dans la reponse ...
#Sauvegarde des fichier de controles.
echo "INFO::Sauvegarde des fichiers de controles dans $CTL_FOLDER" |tee -a $LOG_FILE
for FILE in $CTL_FILES; do
  echo "INFO::Sauvegarde du fichier $FILE" |tee -a $LOG_FILE
  cp $FILE $CTL_FOLDER
  if [ ! $? = 0 ]; then
    echo "WARNING::impossible de copier le fichier $FILE"|tee -a $LOG_FILE
  fi
done

#Sauvegarde des fichiers de tablespaces.
echo "INFO::Sauvegarde des fichiers des tablespace dans $TABLESPACE_FOLDER" |tee -a $LOG_FILE
for FILE in $TABLESPACE_FILES; do
  echo "INFO::Sauvegarde du fichier $FILE" |tee -a $LOG_FILE
  cp $FILE $TABLESPACE_FOLDER
  if [ ! $? = 0 ]; then
    echo "WARNING::impossible de copier le fichier $FILE"|tee -a $LOG_FILE
  fi
done

#Sauvegarde des fichiers de log.
echo "INFO::Sauvegarde des fichiers de log dans $DB_LOG_FOLDER" |tee -a $LOG_FILE
for FILE in $DB_LOG_FILES; do
  echo "INFO::Sauvegarde du fichier  $FILE" |tee -a $LOG_FILE
  cp $FILE $DB_LOG_FOLDER
  if [ ! $? = 0 ]; then
    echo "WARNING::impossible de copier le fichier $FILE"|tee -a $LOG_FILE
  fi
done;

echo "INFO::Startup database" |tee -a  $LOG_FILE
sqlplus -s /nolog << EOF
connect / as sysdba
startup
exit
EOF

echo "INFO::Aucune erreur backup effectue avec succès dans le dossier $BACKUP_FOLDER" |tee -a $LOG_FILE
