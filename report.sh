#!/bin/bash

source ~/scripts/powerloom/config/env
cd ~/powerloom

#docker compose safe
if command -v docker-compose &>/dev/null
then docker_compose="docker-compose"
elif docker --help | grep -q "compose"
then docker_compose="docker compose"
fi

pid=$(ps aux | grep snapshotter | grep -v grep | awk '{print $2}')
foldersize=$(du -hs ~/powerloom | awk '{print $1}')

if [ -z $pid ]
then 
  status="error"
  note="not running"
fi

echo "updated='$(date +'%y-%m-%d %H:%M')'"
#echo "version='$version'" 
echo "process='$pid'" 
echo "status=$status"
echo "note='$note'" 
echo "network='$network'" 
echo "type=$type"
echo "folder=$foldersize"
echo "id=$ID"
