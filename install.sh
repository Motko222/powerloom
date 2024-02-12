#!/bin/bash

cd ~
git clone -b simulation_mode https://github.com/PowerLoom/snapshotter-lite powerloom
cd powerloom
./build.sh
