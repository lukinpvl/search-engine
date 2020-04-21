#!/bin/sh

export PROJECT=search-engine-273811
export REGION=europe-west1
export MACHINE_TYPE=n1-standard-2
export NUM_NODES=2
export USE_STATIC_IP=true

cd gitlab/

echo "gitlab/gke_bootstrap_script.sh up"

./gke_bootstrap_script.sh up
sleep 60

#Добавить создание зоны. Вынести в переменную
gcloud dns record-sets transaction start --zone=se-project-tk
gcloud dns record-sets transaction add $(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') --name=gitlab.se-project.tk. --ttl=300 --type=A --zone=se-project-tk
gcloud dns record-sets transaction execute --zone=se-project-tk

echo "Cluster deployed, installing gitlab chart..."


helm3 repo add gitlab https://charts.gitlab.io/
helm3 repo update

echo "helm3 upgrade --install -f gitlab/values-gke-minimum.yaml gitlab gitlab/gitlab   --timeout 5m   --set global.edition=ce   --set global.hosts.domain=example.com   --set global.hosts.externalIP=$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}')   --set certmanager-issuer.email=me@example.com   --set runners.privileged=true"

helm3 upgrade --install -f values-gke-minimum.yaml gitlab gitlab/gitlab \
  --timeout 5m \
  --set global.edition=ce \
  --set global.hosts.domain=se-project.tk \
  --set certmanager-issuer.email=me@se-project.tk \
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





