![Oracle Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Oracle_logo.svg/663px-Oracle_logo.svg.png)

## Changement du mot de passe linux
```
passwd
```

# 2 go to home
```
cd
pwd
```
        
# 2 lister home
```
ls -al 
```
.cshrc : redéfinie l'env pour shell
.profile : pour bash

# 3 chouf oracle env
```
setenv | grep ORACLE
```
        HOME=/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13
        PWD=/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13
        ORACLE_BASE=/oracle/TP_ADMIN_ORACLE_M2PGI/m2pgi13
        ORACLE_HOME=/oracle/u01/11R2
        ORACLE_SID=m2pgi13
        
# 4 check if runngin
```
ps -ef | grep m2pgi13
```

# note 
Pour ce connecter as root.
    sqlplus /nolog
    sqlplus / as sysdba 
   
# 5 shut down oracle
    sqlplus /nolog
    sqlplus / as sysdba
    shutdown abort

# 6 lancer l'instance
 
  startup
  



