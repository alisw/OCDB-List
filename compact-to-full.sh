#!/bin/bash -e
INPUT=${1:-ocdb_list.txt}
PREF=
cat $INPUT | while read LINE; do
  [[ $LINE =~ :$ ]] && { PREF=${LINE%:*}; continue; } || echo $PREF/Run${LINE}.root
done
