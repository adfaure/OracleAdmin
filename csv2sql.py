#!/usr/bin/python

from string import Template
import sys

template = Template("INSERT INTO GARES VALUES ('${CODE_LIGNE}', '${NOM}', '${NATURE}', ${LATITUDE}, ${LONGITUDE});")
for line in sys.stdin:
    data = line.rstrip().replace('\'', '\'\'').split(";")
    print template.substitute(CODE_LIGNE=data[0], NOM=data[1], NATURE=data[2], LATITUDE=data[3].replace(',', '.'), LONGITUDE=data[4].replace(',', '.'))
print "commit;"
