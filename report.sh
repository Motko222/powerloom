#!/bin/bash

#docker compose safe
if command -v docker-compose &>/dev/null
then docker_compose="docker-compose"
elif docker --help | grep -q "compose"
then docker_compose="docker compose"
fi

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
docker_status=$(docker inspect powerloom-testnet_snapshotter-lite_1 | jq -r .[].State.Status)
foldersize=$(du -hs ~/powerloom-testnet | awk '{print $1}')
id=powerloom-$POWERLOOM_ID
chain=testnet
url=https://snapshotter-dashboard.powerloom.network
version=

if [ "$docker_status" = "running" ]
then 
  status="ok"
else
  status="error"
  message="not running"
fi

cat << EOF
{
  "project":"$folder",
  "id":$id,
  "machine":"$MACHINE",
  "chain":"$chain",
  "type":"lite",
  "status":"$status",
  "message":"$message",
  "docker":"$docker_status",
  "folder_size":"$foldersize",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=node&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary '
    status,node='$id',machine='$MACHINE' status="'$status'",message="'$message'",version="'$version'",url="'$url'",chain="'$chain'" '$(date +%s%N)' 
    '
fi
