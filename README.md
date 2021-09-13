# Demo-api

This repository contains docker files and documentation to deploy git@github.com:containous/foobar-api.git

The following api need to run on 2 separated K8s cluster load balanced.

Deployment have to get its certificate from a pvc.

Pod should be probed for readiness and liveness.

Clusters and application needs to be monitored.

And finally improve application or deployment with any idea that comes to mind in order to get it more robust or secure.

# Create Clusters



## create cluster on GKE

>> GCP add the possibility to load balance through several region

create a cluster on europe-west1-b

create a cluster on us-central1-a

create global load balancer

create dns entry for global load balancer ip


## build docker image foobar-api

### manually 

create dockerfile 2 layer image

from golang

git clone

build

from scratch 

copy built go binary


### automatically 

>> use skaffold

## install traefik proxy

```
follow https://doc.traefik.io/traefik/getting-started/install-traefik/
```

k create ns traefik

helm repo add traefik https://helm.traefik.io/traefik

helm repo update

helm install traefik traefik/traefik

## 

check if url respond
curl -vik --resolve api.mageekbox.eu:443:35.223.167.83 https://api.mageekbox.eu/api

helm repo add datadog https://helm.datadoghq.com

helm install -n datadog ddmonitoring -f ddvalues.yaml --set datadog.site='datadoghq.eu' --set datadog.apiKey='apikey' datadog/datadog 
