#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env
source /root/powerloom-mainnet/$CFG_FILE

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
foldersize=$(du -hs /root/powerloom-mainnet | awk '{print $1}')
height=$(docker container logs $container 2>&1 | grep -a "Current block:" | tail -1 | awk -F "block: " '{print $NF}' | cut -d "|" -f 1 )
version=$(docker container logs $container 2>&1 | grep -a "nodeVersion:" | tail -1 | awk -F "nodeVersion: " '{print $NF}' | sed 's/\"//g' )
last=$(docker container logs $container 2>&1 | grep -a "Successfully submitted snapshot to local collector" | tail -1 | cut -d "|" -f 1 )
last=$(date -d "$(echo $last | tr -d '>')" +%s)
errors=$(docker container logs $container --since 1h 2>&1 | grep -c ERROR)

diff=$(( $(date +%s) - $(date -d "$last" +%s) ))

if [ $diff -lt 3600 ]; then
  last_ago="$(( diff / 60 )) minutes ago"
elif [ $diff -lt 86400 ]; then
  last_ago="$(( diff / 3600 )) hours ago"
else
  last_ago="$(( diff / 86400 )) days ago"
fi

status="ok"
[ $errors -gt 100 ] && status="warning" && message="too many errors ($errors/h)"
[ $diff -gt 86400 ] && status="warning" && message="no submission in 24h"
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
        "chain":"powerloom",
        "network":"mainnet",
        "status":"$status",
        "message":"$message",
        "version":"$version",
        "height":"$height",
        "errors":"$errors",
        "m1":"last=$last_ago",
        "m2":"id=$token_id market=$market",
        "m3":"$m3",
        "url":"https://mint.powerloom.network",
        "url2":"$SOURCE_RPC_URL",
        "url3":"$url3"

  }
}
EOF

cat $json | jq
