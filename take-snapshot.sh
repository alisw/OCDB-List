#!/bin/bash -e
set -o pipefail
cd "$(dirname "$0")"
type alien-token-init > /dev/null 2>&1 || { echo "AliEn not found" >&2; false; }

OUTPUT=${1:-ocdb_list.txt}

function alien_robust_ls() {
  local I
  local TMPF=$(mktemp)
  for ((I=1; I<=4; I++)); do
    timeout --signal=9 20s alien_ls -a "$1" > $TMPF 2> /dev/null || continue
    grep -q '^\.\.$' $TMPF || continue
    grep -v '^\.\.$' $TMPF | grep -v '^\.$'
    rm -f $TMPF
    return 0
  done
  echo "Failed running alien_ls $1" >&2
  return 1
}

function alien_find_append() {
  local I
  local TMPF=$(mktemp)
  local PREF=$1
  local PAT=$2
  local OLDPREFIX=
  for ((I=1; I<=4; I++)); do
    echo "alien_find $PREF $PAT ($I/4)..." >&2
    timeout --signal=9 30s alien_find $PREF $PAT > $TMPF 2> /dev/null || continue
    grep -q "^$PREF" $TMPF || alien_robust_ls $PREF || continue
    grep "^$PREF" $TMPF | sort -u | while read LINE; do
      NEWPREFIX=${LINE%/*}
      [[ $NEWPREFIX == $OLDPREFIX ]] || { OLDPREFIX=$NEWPREFIX; echo $OLDPREFIX:; }
      echo ${LINE##*/}
    done
    rm -f $TMPF
    return 0
  done
  rm -f $TMPF
  echo "Failed running alien_find $PREF $PAT" >&2
  return 1
}

# Start anew
rm -f $OUTPUT

# Data
PREFIX=/alice/data
YEARS=$(alien_ls $PREFIX | grep -E '^20(09|1[0-9])$')
[[ "$YEARS" ]] || { echo "No valid data year found" >&2; false; }
for YEAR in $YEARS; do
  SUBPREFIX=$PREFIX/$YEAR/OCDB
  DETECTORS=$(alien_robust_ls $SUBPREFIX)
  [[ "$DETECTORS" ]] || { echo "Cannot get detectors for $SUBPREFIX" >&2; false; }
  for DET in $DETECTORS; do
    alien_find_append $SUBPREFIX/$DET Run%.root | sed -e 's/^Run//; s/\.root$//;' >> $OUTPUT
  done
done

# Simulation
PREFIX=/alice/simulation/2008/v4-15-Release
for TYPE in Full Ideal Residual; do
  SUBPREFIX=$PREFIX/$TYPE
  DETECTORS=$(alien_robust_ls $SUBPREFIX)
  [[ "$DETECTORS" ]] || { echo "Cannot get detectors for $SUBPREFIX" >&2; false; }
  for DET in $DETECTORS; do
    alien_find_append $SUBPREFIX/$DET Run%.root | sed -e 's/^Run//; s/\.root$//;' >> $OUTPUT
  done
done
