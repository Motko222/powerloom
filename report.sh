#!/bin/bash

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

cat << EOF
{
  "project":"$folder",
  "id":"$id",
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
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,owner=$owner,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\",type=\"$type\" $(date +%s%N)
    "
fi
