#!/bin/bash

if [ $# -ne 5 ]; then
  echo "Usage: ./run-ponos.sh <arg1> <arg2> <arg3> <arg4>"
  echo "where: "
  echo "arg1 is \"benchmark filename (without .c extension)\""
  echo "arg2 is the schedule dimension in 2d+1 format"
  echo "arg3 is logging (1: ON), (2: OFF)"
  echo "arg4 is the architecture (SKX, KNL, PWR9)"
  exit 1
fi

target=$1
dim=$2
dolog=$3
tarch=$4
mdtdb=$5
capr=0
caps=0

archlist="SKX KNL PWR9 FAKE NONE CNC"
archvalid=0
for aa in $archlist; do 
  if [ $aa == $tarch ]; then
    archvalid=1
  fi
done
if [ $archvalid == 0 ]; then
  echo "Selected architecture is invalid. Aborting compilation ..."
  exit
fi

if [ $dim -lt 1 ]; then
  echo "Schedule dimension given was 0 (zero). Aborting ..."
  exit
fi
 
args=""
#args+=" --candl-dep-isl-simp "
#args+=" --candl-dep-prune "
args+=" --ponos "
#args+=" --ponos-solver cplex "
args+=" --ponos-pip-gmp "

args+=" --ponos-solver-pre "
args+=" --ponos-farkas-max "
args+=" --ponos-farkas-nored "

args+=" --ponos-coef-N "
args+=" --ponos-build-2dp1 "
args+=" --ponos-obj codelet "
args+=" --ponos-sched-sz $dim  "
args+=" --pragmatizer "
args+=" --default-ctxt "
#args+=" --past-super-hoist "
args+=" --ponos-chunked-arch $tarch "
#args+="   --cloog-cloogf 1 "
#args+="   --cloog-cloogl 3 "
#args+=" --ponos-chunked-arch-file bnlmkbox.pmc "

base_args=$args

args+=" --ponos-chunked "
args+=" --ponos-chunked-unroll "
#args+=" --ponos-chunked-auto "
args+=" --ponos-chunked-adaptive "
#args+=" --ponos-mdt-db-file gen-nano-tests/mdt-db.txt"
#args+=" --ponos-mdt-db-file gen-nano-tests/mdt-6obj-db.txt"
#args+=" --ponos-mdt-db-file gen-nano-tests/mdt-12obj-db.txt"
args+=" --ponos-mdt-db-file $mdtdb "
args+=" --ponos-chunked-loop-max-refs $capr "
args+=" --ponos-chunked-loop-max-stmt $caps "
args+=" --ponos-coef 30 "
args+=" --ponos-K 40 "

#args+=" --ponos-quiet "
#args+=" --ponos-pipsolve-lp "
#args+=" --ponos-chunked-loop-max-lat $cap "
#args+=" --cloog-cloogf 4 "
#args+=" --ponos-debug "

echo "Generating chunked variant ..." 
cmd="time ./bin/pocc $args $target.c -o $target.chunked.c "
echo $cmd
x=`date`
echo "Start time: $x"
if [ $dolog -eq 1 ]; then
  timestart=`date`
  { time ./bin/pocc $args $target.c -o $target.chunked.c &> $target.log ; } 2> $target.time
  timeend=`date`
  tempfile=$target.chunked.c

  echo "" >> $tempfile
  echo "/*" >> $tempfile
  cat $target.log >> $tempfile
  echo "" >> $tempfile
  cat $target.time >> $tempfile
  echo "Time start  : $timestart" >> $tempfile
  echo "Time finish : $timeend" >> $tempfile
  echo "*/" >> $tempfile
  mv $tempfile $target.chunked.$tarch.c
else
  time ./bin/pocc $args $target.c -o $target.chunked.c 
fi

#echo "Generating codelet variant ..."
#time ./bin/pocc ${base_args} $target -o $target.codelet.c
