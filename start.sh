#!/bin/bash
set -x
source $(dirname $0)/k3s.env
k3d cluster start --wait  $CLUSTER_NAME
docker ps | grep $CLUSTER_NAME  | awk '{print $NF}' | while read k;
do
	docker exec  $k mount --make-rshared /
done
