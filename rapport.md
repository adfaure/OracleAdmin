![Oracle Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Oracle_logo.svg/663px-Oracle_logo.svg.png)

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

**demarrage :**

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
