#!/usr/bin/env /bin/sh
set -e
#set -x

DURATION=60

function clean_exit {
  # Kill off background tshark when we exit
  kill ${CAP_PID}
}
trap clean_exit EXIT

# Start a long-running capture:
rm -f netcap_* full_summary.out collected_summary.out
tshark -z conv,tcp -s 96 -w netcap -b duration:${DURATION} -b files:10 > full_summary.out &
CAP_PID=$!

# Process and gather data:
KEEPLOOKING=1
FN=""
CNT=0
while [ $KEEPLOOKING ] ; do
  if [ -z "$FN" -o "${CNT}" -le 1 ] ; then
    sleep ${DURATION}
    sleep ${DURATION}
  else
    echo "Processing ${FN}"
    tshark -z conv,tcp -r ${FN} | egrep '<->' >> collected_summary.out
    rm -f ${FN}
    FN=""
  fi
  set +e
    FN="$(ls -1 netcap_* | head -1)"
    CNT="$(ls -1 netcap_* | wc -l)"
  set -e
done

kill $CAP_PID

