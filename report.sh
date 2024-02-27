#!/bin/bash

#docker compose safe
if command -v docker-compose &>/dev/null
then docker_compose="docker-compose"
elif docker --help | grep -q "compose"
then docker_compose="docker compose"
fi

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
docker_status=$(docker inspect powerloom_snapshotter-lite_1 | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom-testnet | awk '{print $1}')

if [ "$docker_status" = "running" ]
then 
  status="ok"
else
  status="error"
  note="not running"
fi

cat << EOF
{
  "project":"$folder",
  "id":$POWERLOOM_ID,
  "machine":"$MACHINE",
  "chain":"testnet",
  "type":"snapshotter lite",
  "status":"$status",
  "note":"$note",
  "docker":"$docker_status",
  "folder_size:$folder"
  "updated":"$(date --utc +%FT%TZ)"
}
EOF
