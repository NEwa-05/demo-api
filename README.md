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

File described here is: [Dockerfile](https://github.com/NEwa-05/demo-api/blob/master/Dockerfile)

### automatically

Looking to create the OCI image the more efficiently possible, I turn myself to Github Actions since all my work will be on it, tools like argoCD or else could have been used if the request to keep build inside a internal network have been needed)

For this part I used workflow example from internet to create the image, you could see the file here: [create-oci.yml](https://github.com/NEwa-05/demo-api/blob/master/.github/workflows/create-oci.yml)

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

Inside this workflow or others it could be needed to specify secrets, like token or password, to pass this secrets as secure as possible without putting them in the code, the secrets could be created in the settings of the repository.

## Creating Clusters

### Manually

As most of Cloud provider it's simple as a click to create a cluster on the Scaleway WebUI.

When the cluster is ready, a simple download of the kubeconfig from the cluster is possible 
One cluster is in the Paris Region the other in Amsterdam.

Easy as that, the cluster has cloud provider capabilities so if you need a service load balancer or a persistent volume you'll get it when you creat the resource.

### Automatically

For this kind of infrastructure with the deadline I had it was way simpler to use Terraform and not try Pulumi which I've never used at the moment.

Since I need to create 2 resources I won't create conditional resources in the TF files.

Only what I need will be in the TF files, the cluster creation, the node pool creation with the size and count of nodes for the cluster, and finally the "download" of the kubeconfig to access the K8s clsters, the file that create those resources is here: [Terraform Create cluster file](https://github.com/NEwa-05/demo-api/blob/master/terraform/k8s-create.tf)

The only problem I faced for this terraform was to know how to pass the region/AZ to the pool or cluster resources, by checking the doc from hashicorp and made some adjustment it went smoothly on the 3 try.

At the moment the cluster creation is not automated in a github Actions workflow but could be done later on.

## Kubernetes

I've decided to use Traefik Proxy as an ingress controller, in order to use in the future iterration the middleware it brings with it.

For the monitoring, since I was looking at Datadog free demo to discover its services, it was a good opportunity to test it.

Both tools will be installed via helm and will be deployed in both cluster via Github Actions.

Concerning the Github Actions deployment of those 2 tools, I've set manually as repository secret, both kubeconfig (Looking forward to automate the secret creation when the Terraform part will be in Actions)

To deploy the app I use a github Actions workflow which need that kubeconfig is hashed with base64, so like for the clear kubeconfig, I've create repository secret with the base64 content of both clusters kubeconfig, here's the repository which explain the [kubectl workflow](https://github.com/steebchen/kubectl)

### Install traefik proxy via Actions

My first action in order to install Traefik is to create a new namespace to run it.

At first it was made by hand but I quickly decided to create an Actions workflow to deploy it on both cluster.

This workflow like the one that create the OCI image of the foobar-api, will be triggered on demand to lower the number of jobs till I am still moving stuff around on the git repository.

The second part is to define via the github actions made by deliverybot [repo](https://github.com/deliverybot/helm) to manage values, but also version and release of the helm chart I need to deploy.

My first try was unsuccessful cause I didn't verify which version of helm was used by default, so it fails with a "tiller not installed" message. 

This Workflow has 2 ways to define custom values, one where you define the value files from your repository, the other one will create a value file with what you define directly in the workflow:

```yaml
  values: |
    pilot:
      enabled: true
      token: "mytoken"
  value-files: ./traefikvalues.yaml
```

In order to get Traefik metrics in Datadog, we need to modify the values of the deployment, a value file with the needed values has been to the repository and used in the deployment, the [values](https://github.com/NEwa-05/demo-api/blob/document/kube/traefikvalues.yaml)

### Install Datadog via Actions

The process is more or less the same as for Traefik, with some changment to the name of the resources, helm chart and values, but the workflow is the same.

Datadog will need an API key to send metrics to the Remote Service, again, a Repository secret will do the trick, but this time I'll use some values outside of the repository file like this:

```yaml
  values: |
    datadog:
      site: 'datadoghq.eu'
      apiKey: '${{ secrets.DATADOG_APIKEY }}'
      clusterName: 'kube'
   value-files: ./ddvalues.yaml
```

When the pods from datadog are deployed, it will take a few minutes to get metrics or logs in the [Datadog UI](https://app.datadoghq.eu)

### Install the foobar-api via Actions



check if url respond
curl -vik --resolve api.mageekbox.eu:443:35.223.167.83 https://api.mageekbox.eu/api
