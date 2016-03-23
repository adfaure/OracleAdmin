![Oracle Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Oracle_logo.svg/663px-Oracle_logo.svg.png)

[M2PGI_TP_ORACLE] nom_nom.pdf

## 1. Démarrage de l'instance

##### a. Vérifier vos variables d'environnement liées à Oracle, expliquer leurs rôles brièvement.

Pour afficher les variables d'environnement liées à  Oracle, on peut utiliser la command linux :
```
> setenv | grep ORACLE

ORACLE_BASE=/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13
ORACLE_HOME=/oracle/u01/11R2
ORACLE_SID=m2pgi13
```
On remarque trois variables globales:
* ORACLE_BASE : Le répertoire principal qui contient l'installation Oracle.
* ORACLE_HOME : Le répertoire home dans lequel un produit ou une base de données Oracle sont installés.
* ORACLE_SID : Utilisé pour identifier une instance/base oracle. Il doit être unique pour chaques instances.

##### b. Valider les procéduresde démarrage et d'arrêt de votre instance oracle.
##### c. Expliquer les bonnes pratiques à utiliser pour les comptes SYS et SYSTEM.

**connexion en admin :**

    > sqplus /nolog # Permet de lancer sqlplus sans essayer de se connecter
    > connect /as sysdba # Se connecter en admin pour avoir les bons privilèges

**démarrage :**

Une fois connecté à sqlplus avec les bons droits :

    > startup # Démarrage de l'instance

**Arrêt :**

Une fois connecté à sqlplus avec les bon droits :

    > shutdown abort # Arret violent de la base

Une description des différents types d'arrêt est disponible à cette adresse : [https://docs.oracle.com/cd/B28359_01/server.111/b28310/start003.htm](https://docs.oracle.com/cd/B28359_01/server.111/b28310/start003.htm)

## 2. Processus

##### a. Vérifier le fonctionnement de votre base en visualisant les processus de votre instance, commentaires sur ces processus détachés.

Dans le but d'afficher tous les processus vis-à-vis de notre instance Oracle, on utilise la command linux suivante :

    > ps -ef | grep oracle | grep m2pgi13

![Process Oracle](process.png)

Les processus détachés Oracle permettent d'éxecuter des requêtes en tant que service.
Lors du démarrage, Oracle lance ses processus rattaché au processus init (ID : 1) du système d'exploitation. Cela permet de les détacher de la fênetre principal et ainsi les rendre complètement autonome. De plus il est necessaire de disposer de certain privilèges afin de tuer ces processus (voir Section 1).

##### b. Filiation des processus :

* Créer des connexions utilisateurs (par la commande sqlplus) avec l'utilisateur invité.

Une session oracle lancé et attaché au processus sqlplus en tant que Oracle.
Voici l'abre d'affiliation résultants d'une connexion sqlplus.

    .sshd
    └─sqlplus
        └─ oracleim2ag13 (LOCAL=YES [...])

Une fois qu'une commande est lancée dans sqlplus, Oracle prend la main et récupère la session en forkant le process de session puis execute la rêquete associée. La session utilisateur (processus créé suite à la connexion sqlplus) est peut être considérée comme une session tampon qui permet l'échange de données entre l'utilisateur et Oracle.

##### c. Expliquer le rôles des processus principaux liés à votre base.

###### Process monitor process(PMON) - ora_pmon_m2pgi13
 Processus responsable des processus en background. Il se charge de relancer les processus quand ils se sont interonput anormarlement. 

###### System Monitor Process (SMON) - ora_smon_m2pgi13 
Processus chargé de faire une récupération de la base au demarage si necessaire ainsi que d'autre action de récuperation de transaction ou de liberation de segments pas utilisé.

###### Database Writer Process (DBWn) - ora_dbw0_m2pgi13 
Processus d'écriture depuis le buffer oracle sur les disques.

###### Log Writer Process (LGWR) - ora_lgwr_m2pgi13
Processus de management des redo log de l'instance. Necessaire pour l'archivage des données.

## 3. Gestion des utilisateurs

##### a- Création d'utilisateurs
Pour créer les utilisateurs dans la base Oracle :
```
SQL> CREATE USER invite1 IDENTIFIED BY invite1;
SQL> CREATE USER invite2 IDENTIFIED BY invite2;
SQL> CREATE USER invite3 IDENTIFIED BY invite3;
```
On peut vérifier si les utilisateurs ont bien été créés avec :
```
SQL> SELECT * FROM USER;
```
##### b- Allocation des privilèges :

- Donner les droits nécessaires (rôles) aux utilisateurs pour se connecter à la base et créer des objets.

Lorsqu'un utilisateur est créé avec l'instruction CREATE USER, il ne dispose encore d'aucun droit car aucun privilège ne lui a encore été assigné. Il ne peut même pas se connecter à la base !
Pour qu'un utilisateur puisse se connecter à la base et créer des objets, il est nécéssaire de lui attribuer les privilèges nécessaires :
```
SQL> GRANT CONNECT, RESOURCE TO INVITE1, INVITE2, INVITE3;
```
- Expliquer ces rôles en retrouvant les privilèges qui leur sont associés.

Les privilèges système assignés au rôle CONNECT :
```
SQL> SELECT * FROM DBA_SYS_PRIVS WHERE grantee='CONNECT';
```
GRANTEE | PRIVILEGE | ADM
------------ | ------------- | -------------
CONNECT | CREATE SESSION | NO

* CREATE SESSION : Elle permet à un utilisateur de créer une connection à la base de données.

Les privilèges système assignés au rôle RESOURCE :

```
SQL> SELECT * FROM DBA_SYS_PRIVS WHERE grantee='RESOURCE';
```
GRANTEE | PRIVILEGE | ADM
------------ | ------------- | ------------
RESOURCE | CREATE TRIGGER | NO
RESOURCE | CREATE SEQUENCE | NO
RESOURCE | CREATE CLUSTER | NO
RESOURCE | CREATE TYPE | NO
RESOURCE | CREATE PROCEDURE | NO
RESOURCE | CREATE TABLE | NO
RESOURCE | CREATE INDEXTYPE | NO
RESOURCE | CREATE OPERATOR | NO

* CREATE TABLE : Elle permet à un utilisateur de créer une table qui appartiendera à ce dernier.

A noter qu'il possible d'attribuer directement des provilèges à un utilisateur sans passer par les rôles :

```
SQL> GRANT CREATE SESSION, CREATE TABLE TO INVITE1, INVITE2, INVITE3;
```
- Création d'un rôle manager_BDreparti avec les droits create synonym et create database link, attribuer ce rôle à invite3.

Lister les privilèges d'un rôle.
```
SQL> SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE ='MANAGER_BDREPARTI';
```

```
SQL> CREATE ROLE manager_BDreparti;
SQL> GRANT CREATE DATABASE LINK, CREATE SYNONYM TO manager_BDreparti;
SQL> GRANT manager_BDreparti TO INVITE3;
```

##### c- Modifier le mot de passe d'invite2 et lui donner le tablespace users par défaut.
```
SQL> ALTER USER invite2 IDENTIFIED BY invite;
```
```
ALTER USER invite2 IDENTIFIED BY invite2 DEFAULT TABLESPACE users;
```

ROLE ET PRIVILEGE :

http://oracle.developpez.com/guide/administration/adminrole/
https://docs.oracle.com/cd/E21901_01/timesten.1122/e21642/privileges.htm#TTSQL338

DATABASE STATE :

https://docs.oracle.com/cd/B28359_01/server.111/b28310/start002.htm

http://psoug.org/oraerror/ORA-00750.htm
Un fois la base dismounted, il faut la redemarrer.

## 4. Modification état de la base
##### a) Modifier la base pour qu'elle soit en mode maintenance.
Il faut se connecter en mode /nolog, puis :
```
SQL> shutdown abort # Virer toutes les connexions actives
```
Il est possible de démarrer la base en mode restreint. Ce dernier va permettre seulement aux utilisateurs titulaires de privilèges particuliers d'accèder à la base (par exemple, les utilisateur avec le rôle DBA).
```
SQL> startup restrict
```
Pour effectuer des opérations sur la base en tant qu'administrateur :
```
SQL> ALTER DATABASE CLOSE;
SQL> ALTER DATABASE DISMOUNT;
```
http://psoug.org/oraerror/ORA-00750.htm
Un fois la base dismounted, il faut la redemarrer.

##### b) Connexion à la base (via sqlplus) avec un des utilisateurs invité, constat ?
Quand on essaie de se connecter à la base avec un utilisateur ne disposant pas de privilèges suffisants (invite1 par exemple) :
```
ORA-01035: ORACLE only available to users with RESTRICTED SESSION privilege
```
##### c) Modifier l'état de la base en fonction pour permettre à l'utilisateur invité de se connecter à nouveau.
Pour enlever le mode restreint de la base :
```
SQL> alter system disable restricted session;
```

## 5. Gestion des ressources
##### a) Pour l'utilisateur invite1 retrouver ses informations (nom, status, tablespace par défaut, date de création).
```
SQL> SELECT * FROM SYS.DBA_USERS WHERE USERNAME = 'INVITE1';
```
##### b) Lancer plusieurs sessions sqplus pour vous connecter à la base sous des noms différents. retrouver à partir du dictionnaire des données les utilisateurs connectés (osuser et username), numéro de process (Processus) et le type de programme.
```
SELECT
  username,
  osuser,
  terminal
FROM
  v$session
WHERE
  username IS NOT null
ORDER BY
  username,
  osuser;
```
##### c) Un des utilisateurs consomme trop de ressources (sx: invite1), lui annuler sa session en récupérant son SID et serial number.
Lister les utilisateurs conncetés https://docs.oracle.com/cd/B19306_01/server.102/b14237/dynviews_2088.htm#REFRN30223
```
SELECT
SID, SERIAL#
FROM
  v$session
WHERE
  username IS NOT null
  and USERNAME='INVITE1'
ORDER BY
  username,
  osuser;
```
Puis pour annuler la session :
```
SQL> ALTER SYSTEM KILL SESSION '<SID,SERIAL#>';
```

##### d) Donner la commande pour verrouiller le compte de l'utilisateur invite1.
```
SQL> ALTER USER INVITE1 ACCOUNT LOCK;
```
Pour déverrouiller le compte de l'utilisateur invite1 :
```
SQL> ALTER USER INVITE1 ACCOUNT UNLOCK;
```

## 6. Administration de la base -- dictionnaire des données
##### a) Dans le dictionnaire des données, retrouver les valeurs des paramètres :
```
SQL> SELECT * FROM V$PARAMETER WHERE NAME = 'processes' OR NAME = 'shared_pool_size' OR NAME ='db_block_size' OR NAME = 'db_name' OR NAME = 'undo_tablespace' OR NAME = 'nls_language';
```
Paramètre | Valeur
--------- | ---------
nombre de processus autorisés | 50
taille maximum de la mémoire partagée | 1117782016
valeur par défaut des blocs | 8192
nom de la base | m2pgi13
tablespace d'annulation | UNDOTBS1
langage utilisé | AMERICAN

##### b) Comparer ces données avec celles du fichier initSID.ora
Le fichier initSID.ora est le fichier de configuration des paramètres d'initialisation de type text (pfile). Lors du lancement de la base, l'instance Oracle cherchera ce dernier dans le but d'appliques les changements. Il est important de noter que les changements ne seront valides que pour l'instance en cours.

On remarque que la plupart des données qu'on a trouvées dans le dictionnaire des données ont été initialisées à partir du fichier init<SID>.ora.

```
processes=50
memory_target=1117782016
db_block_size=8192
db_name=m2pgi13
undo_tablespace=UNDOTBS1
```

##### c) Dans le dictionnaire des données, localiser sur votre base où se trouvent les fichiers de données, fichiers de contrôles et fichiers redo-log, vérifier  ces infos sur le système (im2ag-oracle.e.ujf-grenoble.fr).

Pour trouver les fichiers de données :
```
SQL> SELECT * FROM V$DATAFILE;
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/system01.dbf
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/sysaux01.dbf
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/undotbs01.dbf
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/users01.dbf
```
Pour trouver les fichiers de contrôles :
```
SQL> SELECT * FROM V$PARAMETER WHERE NAME = 'control_files';
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/control01.ctl, /oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/flash_recovery_area/m2pgi13/control02.ctl
```
Pour trouver les fichiers de redo-log :
```
SQL> SELECT * FROM V$LOGFILE;
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/redo03.log
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/redo02.log
/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/redo01.log
```

##### d) Pour chaque tablespace de votre base retrouver son nom, son statut, la taille des blocs, l'extent initial et les fichiers associés.

```
SQL> SELECT TABLESPACE_NAME, STATUS, BLOCKS, AUTOEXTENSIBLE, FILE_NAME FROM DBA_DATA_FILES;
```

##### e) Modifier en fonctionnement le nombre de process autorisés (=45), faites en sorte que cette modification soit effective immédiatement et au prochain redémarrage.

```
SQL> ALTER SYSTEM SET processes = 45 scope = both;
```

'scope = both' indique que le changement est fait à la fois en mémoire (memory) et également dans le fichier de paramètres serveur (spfile).

##### f) Expliquer et illustrer le principe de modication statique et dynamique des paramètres.
Il existe deux types d'initialisation de paramètres ([source][1]):
* Des paramètres d'initialisation dynamiques qui peuvent être modifiés pour l'instance de la base de données Oracle en cours. Dans ce cas, ces modifications sont prises en compte immédiatement. Exemple :
```
SQL> ALTER SYSTEM SET processes = 45 scope = memory;
```
* Des paramètres d'initialisation statiques qui ne peuvent pas être modifiés pour l'instance de la base de données Oracle en cours. Ces changements doivent être réalisés dans le spfile et nécessitent un redémarrage de la base de données pour qu'ils prennent effet. Exemple :
```
SQL> ALTER SYSTEM SET processes = 45 scope = spfile;
```

## 7. Tablespaces

##### a) Donner la rêquete visualisant la taille de tous les tablespaces de la base
```
SQL> SELECT tablespace_name, file_name, round(bytes / 1048576) FROM DBA_DATA_FILES;
```
##### b) Modification du tablespace users : ajouter 140 Mo au tablespaces users
```
SQL> ALTER DATABASE
SQL> DATAFILE '/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/users01.dbf'
SQL> RESIZE 200M;
```
##### c) Vérifier si votre base est en gestion automatique avec tablespace ou rollback segment, ajouter un tablespace pour les transactions de 50 Mo et l'activer comme tablespace d'annulation par défaut
```
SQL> SELECT * FROM v$PARAMETER WHERE NAME LIKE 'undo_management';
```
Dans notre cas il est set à auto au debut. You set the UNDO_MANAGEMENT initialization parameter to AUTO to enable automatic undo management. A default undo tablespace is then created at database creation.

[UNDO_MANAGEMENT][2] specifies which undo space management mode the system should use. When set to AUTO, the instance starts in automatic undo management mode. In manual undo  management mode, undo space is allocated externally as rollback segments.

```
SQL> CREATE UNDO TABLESPACE UNDOTS2 DATAFILE '/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/undo_ts.f' SIZE 50M;
SQL> ALTER SYSTEM SET UNDO_TABLESPACE = UNDOTS2;
```
##### d) Ajouter un tablespace USERS2 de 100 Mo géré en mode dictionnaire
```
SQL> CREATE TABLESPACE USERS2 DATAFILE '/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/users02.dbf' SIZE 100M EXTENT MANAGEMENT DICTIONARY;
```
##### e) Ajouter un tablespace USERS3 de 130 Mo, mode de gestion local et avec une taille de bloc de 32 Ko
```
SQL> ALTER SYSTEM SET db_32k_cache_size=32M SCOPE=BOTH;
SQL> CREATE TABLESPACE USERS3 DATAFILE '/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/users03.dbf' SIZE 128M EXTENT MANAGEMENT LOCAL BLOCKSIZE 32K;
```

## 8. Sauvegardes

Cette section est un résumé du script backup_database.sh situé à la racine du projet. Les premières lignes du script vérifient le fonctionnement de la base. Si celle-ci n'est pas démarrée le script s'arrête. Ensuite, trois requêtes d'exécute afin d'identifier les fichiers à sauvegarder.

* Les fichiers de contrôles de Oracle
* Les fichiers de logs pour l'archivage des données
* Les fichiers des tablespaces

Une fois les chemins vers les fichiers récupérés, le script les copiera dans des dossiers respectifs et redémarrera la base de données. Un fichier de log est rempli tout au long de la procédure (log_backup situé dans le répertoire depuis lequel on a lancé le script). Les données sauvegardées sont situées dans un dossier dans le répertoire depuis lequel on a lancé le script. 
De plus, le script lèvera un warning si la base n'est pas en mode d'archivage des données (ARCHIVELOG).

## 9. Surveillance espace stockage d'une table : Visualisation fragmentation dans une table
##### a) Créer un tablespace dédié en mode LOCAL/AUTOALLOCATE avec un PCTFREE de 30 et un EXTENT INITIAL de 50 k
```
SQL> CREATE TABLESPACE GARES_TS DATAFILE '/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13/oradata/m2pgi13/garets.dbf' SIZE 100M EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
```
##### b) Création d'une table GARES dans ce tablespace :
```
SQL> CREATE TABLE GARES (CODE_LIGNE NUMBER (20), NOM VARCHAR2 (50), NATURE VARCHAR (70), LATITUDE NUMBER (30), LONGITUDE NUMBER(30)) PCTFREE 30 TABLESPACE GARES_TS STORAGE (INITIAL 50K);
```

Pour vérifier que la table a bien été créée avec les bons paramètres :

```
SQL> SELECT OWNER, TABLE_NAME, TABLESPACE_NAME, PCT_FREE, INITIAL_EXTENT FROM DBA_TABLES WHERE TABLE_NAME = 'GARES';
```

OWNER | TABLE_NAME | TABLESPACE_NAME | PCT_FREE | INITIAL_EXTENT
------|------------|-----------------|----------|---------------
SYSTEM|GARES|GARES_TS|30|57344

## 9.1 Scénario "insertions"
\- **Insertion de 1000 lignes :**
* À l'aide d'un script, ajouter un millier de n-uplets dans votre table.

```
head -1000 gares.csv | ./csv2sql.py > insert1000.sql
```

Ci-dessous le script python "csv2sql.py" qui covertit les données csv en rêquetes SQL:

```python
#!/usr/bin/python

from string import Template
import sys

template = Template("INSERT INTO GARES VALUES ('${CODE_LIGNE}', '${NOM}', '${NATURE}', ${LATITUDE}, ${LONGITUDE});")
for line in sys.stdin:
    data = line.rstrip().replace('\'', '\'\'').split(";")
    print template.substitute(CODE_LIGNE=data[0], NOM=data[1], NATURE=data[2], LATITUDE=data[3].replace(',', '.'), LONGITUDE=data[4].replace(',', '.'))
print "commit;"
```

* À l'aide des outils statistiques d'Oracle, faire une estimation de la taille de la table GARES pour 15 000 enregistrements et 100 000 enregistrements.

Dans Oracle, la taille d'une table peut grandement changer dépendement de ses paramètres de stockage (exemple PCTFREE) et aussi des paramètres du tablespace auquel elle appartient (exemple block size). 

On va utiliser la procédure CREATE_TABLE_COST pour estimer la taille de la table sachant sa valeur PCTFREE et ses colonnes (pour retourner la liste des champs d'une table on peut utiliser desc. Exemple : desc GARES).

```
DECLARE
 ub NUMBER;
 ab NUMBER;
 cl sys.create_table_cost_columns;
BEGIN
  cl := sys.create_table_cost_columns(
          sys.create_table_cost_colinfo('NUMBER',20),
          sys.create_table_cost_colinfo('VARCHAR2',50),
          sys.create_table_cost_colinfo('VARCHAR',70),
          sys.create_table_cost_colinfo('NUMBER',30),
          sys.create_table_cost_colinfo('NUMBER',30)
        );

  DBMS_SPACE.CREATE_TABLE_COST('GARES_TS',cl,15000,30,ub,ab);

  DBMS_OUTPUT.PUT_LINE('Used Bytes (15K insertions): ' || TO_CHAR(ub/1024/1024) || ' Mb');
  DBMS_OUTPUT.PUT_LINE('Alloc Bytes (15K insertions): ' || TO_CHAR(ab/1024/1024) || ' Mb');

  DBMS_SPACE.CREATE_TABLE_COST('GARES_TS',cl,100000,30,ub,ab);

  DBMS_OUTPUT.PUT_LINE('Used Bytes (100K insertions): ' || TO_CHAR(ub/1024/1024) || ' Mb');
  DBMS_OUTPUT.PUT_LINE('Alloc Bytes (100K insertions): ' || TO_CHAR(ab/1024/1024) || ' Mb');
END;
```

Voici la sortie Console (estimation de la taille de la table après 15k et 100k insertions):

```
Used Bytes (15K insertions): 2,34375 Mb
Alloc Bytes (15K insertions): 3 Mb
Used Bytes (100K insertions): 15,625 Mb
Alloc Bytes (100K insertions): 16 Mb
```

Sachant que :

* *used_bytes* représentent le vrai nombre d'octets utilisés par les données. Cela comprend également les métadonnées des block, pctfree, etc.

* *alloc_bytes* représentent la taille de la table lors de sa création dans le tablespace. Cela prend en considération, la taille des extents dans le tablespace et les propriétés de gestion des extents du tablespace.

\- **Ajouter les lignes correspndantes (15k et 100k), puis vérifier vos estimations de manière opérationnelle.**

Commande Linux qui génère 15k insertions :

```bash
seq 3 | xargs -Inone cat gares.csv | head -15000 | ./csv2sql.py > insert15000.sql
```

Taille de la table après 15k insertions :

```
SELECT bytes/1024/1024 FROM DBA_SEGMENTS WHERE SEGMENT_NAME='GARES';
```

Sortie :
2 Mb

Commande Linux qui génère 100k insertions :

```bash
seq 20 | xargs -Inone cat gares.csv | head -15000 | ./csv2sql.py > insert15000.sql
```

Taille de la table après 100k insertions :

```
SELECT bytes/1024/1024 FROM DBA_SEGMENTS WHERE SEGMENT_NAME='GARES';
```

Sortie :

8 Mb

\- **Visualiser les informations de stockage de la table, comme le taux d'occupation moyen des blocks, en utilisant le package DBMS_SPACE.**

Ci-dessous la [requête][4] pour afficher les informations de stockage de la table :

```
variable unf number;
variable unfb number;
variable fs1 number; -- Number of blocks having at least 0 to 25% free space 
variable fs1b number;
variable fs2 number; -- Number of blocks having at least 25 to 50% free space
variable fs2b number;
variable fs3 number; -- Number of blocks having at least 50 to 75% free space     
variable fs3b number;
variable fs4 number; -- Number of blocks having at least 75 to 100% free space 
variable fs4b number;
variable full number; -- Total number of blocks full in the segment
variable fullb number;

begin
dbms_space.space_usage('SYSTEM','GARES',
                        'TABLE',
                        :unf, :unfb,
                        :fs1, :fs1b,
                        :fs2, :fs2b,
                        :fs3, :fs3b,
                        :fs4, :fs4b,
                        :full, :fullb);
end;
/
print unf ;
print unfb ;
print fs4 ;
print fs4b;
print fs3 ;
print fs3b;
print fs2 ;
print fs2b;
print fs1 ;
print fs1b;
print full;
print fullb;
```

Sortie :

UNF | UNFB | FS4 | FS4B | FS3 | FS3B  | FS2 | FS2B | FS1 | FS1B | FULL | FULLB 
----|------|-----|------|-----|-------|-----|------|-----|------|------|------
0   |0     |52   |425984|894  |7323648|0    |0     |0    |0     |54    |442368

Pour avoir plus de détails, on peut visualiser des informations relatives à la table à partir de la vue 'DBA_TABLES':

```
SQL> SELECT BLOCKS, EMPTY_BLOCKS, AVG_SPACE, AVG_ROW_LEN FROM DBA_TABLES WHERE TABLE_NAME = 'GARES';
```

BLOCKS | EMPTY_BLOCKS | AVG_SPACE | AVG_ROW_LEN
------|-----|------|-----
1000 | 24 | 4815 | 49

On constate que le nombre total des blocks alloués à la table GARES est 1000 dont la plupart ont entre 50% et 75% d'espaces libres (FS3).

\- **Faites un rappel des paramètres de stockage importants utilisés dans cette opération, au niveau du tablespace, segment, extents, blocs.**

PCTFREE est un paramètre de stockage de block utilisé pour spécifier la taille à garder libre dans un block pour des futures mises à jour (updates). Par exemple, avec PCTFREE égale à 30, Oracle rajoutera, au fur et à mesure, des nouvelles lignes à un block jusqu'à ce qu'il sera 70% rempli. En revanche, si l'on dispose d'une table qui ne subit que des insertions, il est important de laisser PCTFREE à 0, vu que l'on ne veut pas réserver de la place pour les updates. 

Avec la valeur de BLOCK_SIZE, PCTFREE peut avoir une grande influence sur la taille finale de la table.

Comme on a pas spécifié une taille de block lors de la création du tablespace GARES\_TS, c'est la valeur par défaut qui y sera attribuée : 
```
SQL> SELECT value FROM v$parameter WHERE name = 'db_block_size';
```
VALUE|
-----|
8192|

Donc la taille de la table après 100k insertions de 8M est en effet la taille de block multipliée par le nombre de blocks :

1000 * 8K = 8M

## 9.1 Scénario "modifications"

Ci-dessous le script python qui permet d'effectuer de nombreuses modifications sur la table GARES :

```python
#!/usr/bin/python

from string import Template
import sys
import random
import string

update = Template("UPDATE GARES SET NOM='${NOM}' WHERE NOM='${F_NOM}';")
delete = Template("DELETE GARES WHERE NOM='${NOM}';")
template = Template("INSERT INTO GARES VALUES ('${CODE_LIGNE}', '${NOM}', '${NATURE}', ${LATITUDE}, ${LONGITUDE});")

for line in sys.stdin:
    data = line.rstrip().replace('\'', '\'\'').split(";")
    randomint = random.randint(0,1)
    if randomint == 0:
        print delete.substitute(NOM=data[1].replace('\'', '\'\''))
    elif randomint == 1:
        pass
    else :
        new_name = ''.join(random.choice(string.lowercase) for x in range(random.randint(10, 50)))
        print update.substitute(NOM=new_name.replace('\'', '\'\''), F_NOM=data[1].replace('\'', '\'\''))
print "commit;"
```

Refaire une analyse de la table après ces opération :

Tout d'abord on affiche le nombre de lignes après les modifications :

```
SQL> SELECT COUNT(*) FROM GARES; 
```
Sortie : 

VALUE|
-----|
51593|

Donc notre script, mis à part les updates, à effectuer environ 50% de deletes.

Sortie de la requête dbms\_space.space\_usage :

UNF | UNFB | FS4 | FS4B | FS3     | FS3B      | FS2   | FS2B      | FS1 | FS1B | FULL  | FULLB 
----|------|-----|------|---------|-----------|-------|-----------|-----|------|-------|------
0   |0     |52   |425984|**574**  |**4702208**|**181**|**1482752**|0    |0     |**193**|**1581056**

Autres informations :

```
SQL> SELECT BLOCKS, EMPTY_BLOCKS, AVG_SPACE, AVG_ROW_LEN FROM DBA_TABLES WHERE TABLE_NAME = 'GARES';
```

BLOCKS | EMPTY_BLOCKS | AVG_SPACE | AVG_ROW_LEN
------|-----|------|-----
1000 | 24 | 4815 | 49

Taille de la table après les modifications :

```
SELECT bytes/1024/1024 FROM DBA_SEGMENTS WHERE SEGMENT_NAME='GARES';
```

Sortie :

8 Mb

On constate que :

* La taille de la table n'a pas diminué même si l'on a supprimé la moitié des lignes.
* Le nombre de block entièrement remplis a augmenté après les updates.



[1]: http://docs.oracle.com/cd/E18283_01/server.112/e17120/create006.htm#i1010047
[2]: https://docs.oracle.com/cd/B28359_01/server.111/b28320/initparams250.htm
[3]: https://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_space.htm#i1003180
[4]: http://www.toadworld.com/platforms/oracle/w/wiki/3281.dbms-space-space-usage
