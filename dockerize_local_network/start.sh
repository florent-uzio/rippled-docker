#!/usr/bin/env bash

set -e

docker compose up -d

sleep 3 # The call to "docker exec scylla cqlsh" will be sooner than it's ready if you don't wait a second but it still will start fine
echo "rippled"
echo "*************************"
rippled_container_name="rippled"
rippled_port=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "5005/tcp") 0).HostPort}}' ${rippled_container_name})
curl localhost:${rippled_port} --silent --data '{"method": "server_info"}' | jq -r '.result.info | "Host: \(.hostid)\nVersion: \(.build_version)\nComplete ledgers: \(.complete_ledgers)\nServer state: \(.server_state)\nUptime: \(.uptime)\n"'

echo "Clio"
echo "*************************"
clio_container_name="clio"
clio_port=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "51233/tcp") 0).HostPort}}' ${clio_container_name})
curl localhost:${clio_port} --silent --data '{"method": "server_info"}' | jq -r '.result.info | "Clio version: \(.clio_version)\nlibxrpl: \(.libxrpl_version)\nComplete ledgers: \(.complete_ledgers)\nCache full: \(.cache.is_full)\nUptime: \(.uptime)\n"'

echo "database info"
echo "*************************"
docker exec scylla cqlsh -e 'use clio; select sequence from ledger_range WHERE is_latest = TRUE;'
