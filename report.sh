#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env

#docker compose safe
if command -v docker-compose &>/dev/null
 then docker_compose="docker-compose"
 elif docker --help | grep -q "compose"
 then docker_compose="docker compose"
fi

source ~/.bash_profile

container=$(docker ps -a | grep "snapshotter-lite-v2" | awk '{print $NF}')
market=$(echo $container | cut -d "-" -f 6)
token_id=$(echo $container | cut -d "-" -f 4)
docker_status=$(docker inspect $container | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom-pre-mainnet | awk '{print $1}')
height=$(docker container logs $container 2>&1 | grep -a "Current block:" | tail -1 | awk -F "block: " '{print $NF}' | cut -d "|" -f 1 )
version=$(docker container logs $container 2>&1 | grep -a "nodeVersion:" | tail -1 | awk -F "nodeVersion:" '{print $NF}' )
last=$(docker container logs $container 2>&1 | grep -a "Successfully submitted snapshot to local collector" | tail -1 | awk '{print $1 $2}' )
errors=$(docker container logs $container --since 1h 2>&1 | grep -c ERROR)
url=https://snapshotter-dashboard.powerloom.network

m1="last=$last"
m2="id=$token_id market=$market"

status="ok"
[ errors -gt 100 ] && status="warning" && message="too many errors ($errors/h)"
[ "$docker_status" != "running" ] && status="error" && message="docker not running ($docker_status)"

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
         "id":"$folder-$ID",
         "machine":"$MACHINE",
         "grp":"node",
         "owner":"$OWNER"
  },
  "fields": {
        "chain":"mainnet",
        "network":"powerloom",
        "status":"$status",
        "message":"$message",
        "m1":"$m1",
        "m2":"$m2",
        "m3":"$m3",
        "url":"$url",
        "url2":"$url2",
        "url3":"$url3",
        "height":"$height",
        "errors":"$errors"
  }
}
EOF

cat $json | jq
