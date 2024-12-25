#!/bin/bash

container=$(docker ps -a | grep "snapshotter-lite-v2" | awk '{print $NF}')

docker container logs -f $container  -n 100
