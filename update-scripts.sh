#!/bin/bash

cd ~/scripts/powerloom
git stash push --include-untracked
git pull
chmod +x *.sh
