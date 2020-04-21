#!/bin/sh

#Initialize gcloud using "gcloud init" before start this script

CLUSTER_NAME=search-engine

gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --enable-autoupgrade \
    --enable-ip-alias \
    --enable-legacy-authorization \
    --enable-autoscaling --min-nodes=3 --max-nodes=10 --num-nodes=2 \
    --addons=HttpLoadBalancing
gcloud container clusters get-credentials $CLUSTER_NAME
