#!/usr/bin/python

from string import Template
import sys
import uuid
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
 
