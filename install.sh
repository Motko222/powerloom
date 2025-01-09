#!/bin/bash

cd ~
git clone https://github.com/PowerLoom/snapshotter-lite-v2.git powerloom-mainnet
cd powerloom-mainnet
./diagnose.sh
./build.sh
