#!/bin/sh

set -e

export PROJECT=handy-cell-309908
export REGION=us-central1
export MACHINE_TYPE=n1-standard-2
export NUM_NODES=2
export USE_STATIC_IP=true
export DOMAIN=se-project.tk

echo "enabling service container.googleapis.com"
gcloud services list  --enabled | grep -q container.googleapis.com || gcloud services enable container.googleapis.com

cd infra/gitlab/

echo "gitlab/gke_bootstrap_script.sh up"

./gke_bootstrap_script.sh up
sleep 60

echo "Creating dns (CloudDNS) zone and Gitlab records"

gcloud dns managed-zones list | grep se-project-zone || gcloud dns managed-zones create se-project-zone --description= --dns-name=$DOMAIN.
sleep 60
gcloud dns record-sets transaction start --zone=se-project-zone
gcloud dns record-sets list --zone=se-project-zone | grep gitlab.$DOMAIN || gcloud dns record-sets transaction add $(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') --name=gitlab.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets transaction execute --zone=se-project-zone

echo "Cluster deployed, installing gitlab chart..."


helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo "helm upgrade --install -f gitlab/values-gke-minimum.yaml gitlab gitlab/gitlab   --timeout 5m   --set global.edition=ce   --set global.hosts.domain=example.com   --set global.hosts.externalIP=$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}')   --set certmanager-issuer.email=me@example.com   --set runners.privileged=true"

helm upgrade --install -f values-gke-minimum.yaml gitlab gitlab/gitlab \
  --timeout 5m \
  --set global.edition=ce \
  --set global.hosts.domain=$DOMAIN \
  --set certmanager-issuer.email=me@$DOMAIN \
  --set global.hosts.externalIP=$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') \
  --set gitlab-runner.runners.privileged=true
    # Run all containers with the privileged flag enabled
    # This will allow the docker:stable-dind image to run if you need to run Docker
    # commands. Please read the docs before turning this on:
    # ref: https://docs.gitlab.com/runner/executors/kubernetes.html#using-docker-dind

echo "Gitlab chart installed. Adding external IP to hosts"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "Gitlab root password:"
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"





