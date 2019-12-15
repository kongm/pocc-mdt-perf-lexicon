#!/bin/bash

#bmlist=bmlist.txt
#bmlist=bmlist-test.txt
#bmlist=bmlist-shallow.txt
#bmlist=bmlist-dense.txt
#bmlist=bmlist-sten.txt
bmlist=bmlist-selected.txt

packdir="pldi20-bencmarks"

if [ ! -d $packdir ]; then
  mkdir $packdir
fi

echo "-1" > partitions.txt

while read -r line; do 
  bm=`echo $line |  sed -e 's/ .*$//g'`
  dim=`echo $line | sed -e 's/^.* //g'` 
  echo "Benchmark $bm ==> $dim"
  cp flat/$bm.c .
  tgtdir="$packdir/$bm"
  if [ ! -d $tgtdir ]; then
    mkdir $tgtdir
  fi
  cp flat/$bm.? $tgtdir/
  for arch in SKX KNL; do
    echo "Compiling $bm for {$arch} ..."
    ./run-adap-mdt.sh $bm $dim 1 $arch
    fromfile="$bm.chunked.$arch.c"
    tofile=$bm.NOLT.$arch.c
    echo "Storing $fromfile ==> $tgtdir/$tofile"
    mv $fromfile $tgtdir/$tofile
  done
done < $bmlist
