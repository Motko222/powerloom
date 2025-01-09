#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

#docker compose safe
if command -v docker-compose &>/dev/null
then docker_compose="docker-compose"
elif docker --help | grep -q "compose"
then docker_compose="docker compose"
fi

source ~/.bash_profile

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
container=$(docker ps -a | grep "snapshotter-lite-v2" | awk '{print $NF}')
market=$(echo $container | cut -d "-" -f 6)
token_id=$(echo $container | cut -d "-" -f 4)
docker_status=$(docker inspect $container | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom-pre-mainnet | awk '{print $1}')
url=https://snapshotter-dashboard.powerloom.network

if [ "$docker_status" = "running" ]
then 
  status="ok"
else
  status="error"
  message="not running"
fi

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
         "id":"$folder",
         "machine":"$MACHINE",
         "grp":"node",
         "owner":"$OWNER"
  },
  "fields": {
        "chain":"mainnet",
        "network":"mainnet",
        "status":"$status",
        "message":"$message",
        "docker":"$docker_status",
        "market":"$marker",
        "token_id":"$token_id",
        "folder_size":"$foldersize"
  }
}
EOF

cat $json | jq
