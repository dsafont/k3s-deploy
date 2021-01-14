#!/bin/bash
k3d cluster create k01c1t --k3s-server-arg --flannel-backend=none --k3s-server-arg  --disable-network-policy --k3s-server-arg --cluster-cidr=192.168.0.0/16 --k3s-server-arg "--disable=servicelb" --k3s-server-arg "--disable=traefik"  --no-lb   -a 1
docker exec -it k3d-k01c1t-agent-0 mount --make-rshared /
docker exec -it k3d-k01c1t-server-0 mount --make-rshared /

curl -O https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml
yq eval ". | select(.kind == \"DaemonSet\") | select(.metadata.name == \"calico-node\")|.spec.template.spec.containers[0].env += {\"name\": \"CALICO_IPV4POOL_CIDR\", \"value\": \"$CLUSTER_CIDR\"}" calico_original.yaml | kubectl apply -f -

