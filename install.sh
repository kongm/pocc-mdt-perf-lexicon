#!/bin/bash

tar pocc-1.5.0-beta-selfcontained.tar.gz pocc-mdt
cd pocc-mdt
./install.sh
cp ../scripts/*.sh .
./patch-mdt 10




