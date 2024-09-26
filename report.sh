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
docker_status=$(docker inspect powerloom-pre-mainnet_snapshotter-lite-v2_1 | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom-pre-mainnet | awk '{print $1}')
id=$POWERLOOM_ID
network=mainnet
chain="pre-mainnet"
url=https://snapshotter-dashboard.powerloom.network
version=
bucket=node
group=node
owner=$OWNER

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
         "id":"$POWERLOOM_ID",
         "machine":"$MACHINE",
         "grp":"storage",
         "owner":"$OWNER"
  },
  "fields": {
        "chain":"$chain",
        "status":"$status",
        "message":"$message",
        "docker":"$docker_status",
        "folder_size":"$foldersize"
  }
}
EOF
cat $json
