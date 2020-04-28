#!/bin/sh
set -e

#Initialize gcloud using "gcloud init" before start this script
export DOMAIN=se-project.tk
export CLUSTER_NAME=search-engine



gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --enable-autoupgrade \
    --enable-ip-alias \
    --enable-legacy-authorization \
    --enable-autoscaling --min-nodes=2 --max-nodes=10 --num-nodes=2 \
    --addons=HttpLoadBalancing
gcloud container clusters get-credentials $CLUSTER_NAME


helm3 repo add stable https://kubernetes-charts.storage.googleapis.com/
helm3 install nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true

gcloud dns record-sets transaction start --zone=se-project-tk
gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=staging.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=production.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=test.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets transaction execute --zone=se-project-zone

