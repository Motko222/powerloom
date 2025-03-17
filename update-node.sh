#!/bin/bash

cd ~/powerloom-mainnet

# Pull latest changes
git fetch
git checkout main
git stash push --include-untracked
git pull

# Stop existing node and cleanup
./diagnose.sh -y
