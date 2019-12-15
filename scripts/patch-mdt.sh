#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Require installation stage: "
  exit
fi

stage=$1

if [ $stage -eq 10 -o $stage -eq 1 ]; then
cd optimizers
rm -rf ponos
git clone https://github.com/kongm/ponos-performance-lexicon.git ponos
cd ponos
./bootstrap.sh
cd ../..
./bin/pocc-util make ponos
date >> mk.log
echo "Checkout out MDT-ponos" >> mk.log
fi

if [ $stage -eq 10 -o $stage -eq 2 ]; then
cd generators
rm -rf punroller
git clone https://github.com/kongm/mdt-punroller.git punroller
cd punroller
./bootstrap.sh
cd ../..
./bin/pocc-util make punroller
date >> mk.log
echo "Checkout out MDT-punroller" >> mk.log
fi

if [ $stage -eq 10 -o $stage -eq 3 ]; then
cd math
if [ -d piplib-gmp ]; then
  rm -rf piplib-gmp
fi
git clone https://github.com/kongm/piplib-gmp-mdt.git piplib-gmp
#cd piplib-gmp
#./bootstrap.sh
cd ..
./bin/pocc-util make piplib-gmp
date >> mk.log
echo "Checkout out MDT-piplib-gmp" >> mk.log
fi

if [ $stage -eq 10 -o $stage -eq 4 ]; then
cd ir
if [ -d scoplib ]; then
  rm -rf scoplib
fi
git clone https://github.com/kongm/scoplib-mdt.git scoplib
cd ..
./bin/pocc-util make scoplib
date >> mk.log
echo "Checkout out MDT-scoplib" >> mk.log
fi

if [ $stage -eq 10 -o $stage -eq 5 ]; then
  if [ -d nano-space ]; then
    rm -rf nano-space
  fi
  git clone https://github.com/kongm/adaptive-scheduling.git nano-space
  poccroot=`pwd`
  newpr=`echo $poccroot | sed -e 's/\//\\\&/g'`
  cd nano-space
  cat Makefile.template | sed -e "s/#POCCROOT#/$newpr/g" > Makefile
  cat load_my_libs.template | sed -e "s/#POCCROOT#/$newpr/g" > load_my_libs.sh
  chmod +x load_my_libs.sh
  cd ..
fi

if [ $stage -eq 10 -o $stage -eq 6 ]; then
cd driver
repodir=pocc-driver-mdt
git clone https://github.com/kongm/$repodir.git
cp -r $repodir/* .
cd ..
make install
date >> mk.log
echo "Checkout out MDT-driver" >> mk.log
fi

if [ $stage -eq 10 -o $stage -eq 7 ]; then
  ./bin/pocc-util make ponos
  ./bin/pocc-util make punroller
  ./bin/pocc-util make piplib-gmp
  ./bin/pocc-util make scoplib
  make install
fi
