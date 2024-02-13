#!/bin/bash

source ~/scripts/powerloom/config/env
cd ~/powerloom

#docker compose safe
if command -v docker-compose &>/dev/null
then docker_compose="docker-compose"
elif docker --help | grep -q "compose"
then docker_compose="docker compose"
fi

docker_status=$(docker inspect powerloom_snapshotter-lite_1 | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom | awk '{print $1}')

if [ "$docker_status" -ne "running" ]
then 
  status="error"
  note="not running"
else
  status="ok"
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
echo "docker_status=$docker_status"
