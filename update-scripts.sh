#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)

cd $path
git stash push --include-untracked
git pull
chmod +x *.sh
