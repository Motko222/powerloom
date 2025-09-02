#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
source $path/env

nano ~/powerloom-mainnet/$CFG_FILE
