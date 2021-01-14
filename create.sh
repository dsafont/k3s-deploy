#!/bin/bash
set -x
source $(dirname $0)/k3s.env
k3d cluster create $CLUSTER_NAME --k3s-server-arg --flannel-backend=none --k3s-server-arg  --disable-network-policy --k3s-server-arg --cluster-cidr=$CLUSTER_CIDR --k3s-server-arg "--disable=servicelb" --k3s-server-arg "--disable=traefik"  --no-lb   -a 1
docker ps | grep $CLUSTER_NAME  | awk '{print $NF}' | while read k;
do
	docker exec -it $k mount --make-rshared /
done

curl -O https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml
yq eval ". | select(.kind == \"DaemonSet\") | select(.metadata.name == \"calico-node\")|.spec.template.spec.containers[0].env += {\"name\": \"CALICO_IPV4POOL_CIDR\", \"value\": \"$CLUSTER_CIDR\"}" calico.yaml | kubectl apply -f -

