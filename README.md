# Demo-api Documentation

## Purpose of this repository

This repository contains a dockerfile, a terraform recipe, K8s yamls, github actions workflow and documentation to deploy git@github.com:containous/foobar-api.git

The following api need to run on 2 separated K8s cluster load balanced.

Deployment have to get its certificate inside a persistent volume.

Container should be probed for readiness and liveness.

Clusters and application needs to be monitored.

And finally improve the application or its deployment with any idea that comes to mind in order to get it more robust, secure or easy to deploy and used by anyone.

## Choice of the Implementation

Following the request and some hints in the words used in it, I choose to deploy the foobar-api inside a Kubernetes cluster.

The Scaleway option concerning the platform underlying infrastructure was a choice of simplicity and costs.

After looking around some documentation to implement google Global load balancing and taking the constraint of time in account, I choose to simply use a round robin DNS to load balance trafic between both clusters/applications.

The use of Github Actions to create automated workflow was an occasion to discover it with a real use case.

Terraform was a choice of experience to lower time consumption when recreating the platform.

## Create OCI image

### Manually

To deploy the foobar-api inside my Kubernetes cluster, I choose to create myself the OCI image (tools like Kaniko or buildpack could have been used).

The creation of the Docker file was pretty symple, looking at the Makefile to get the build command.

The Image file is a multistage build in order to get the simplest image with the lowest attack surface.

First stage from golang image git clone foobar-api repository, build the binary.

Second stage from scrath, get binary from previous build and set the binary to start with the image when running.

Then a simple docker push to get it in my docker hub account.

File described here is: [text](https://github.com/NEwa-05/demo-api/blob/master/Dockerfile)

### automatically

Looking to create the OCI image the more efficiently possible, I turn myself to Github Actions since all my work will be on it, tools like argoCD or else could have been used if the request to keep build inside a internal network have been needed)

For this part I used workflow example from internet to create the image, you could see the file here: [text](https://github.com/NEwa-05/demo-api/blob/master/.github/workflows/create-oci.yml)

The process here is simple, create a build image, then get the Dockerfile from the repository and build the foobar-api image.

At first I did kept the push and pull request at build, but each time I did pushed modification to another file or folder of the repository the image was rebuild.

I didn't want to build and rebuild the image since the code will not move to much at the moment.

replacing the "on" section by this did the trick:

```yaml
on: 
  workflow_dispatch:
    inputs:
      logLevel:
        description: 'Log level'     
        required: true
        default: 'warning'
```

## Creating Clusters


Using terraform through Scaleway

One cluster is in the Paris Region the other in Amsterdam.

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
