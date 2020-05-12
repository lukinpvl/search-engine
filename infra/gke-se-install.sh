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


helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true


echo "Creating dns (CloudDNS) zone and records"
gcloud dns managed-zones list | grep se-project-zone || gcloud dns managed-zones create se-project-zone --description= --dns-name=$DOMAIN.
sleep 60
gcloud dns record-sets transaction start --zone=se-project-zone
gcloud dns record-sets list --zone=se-project-zone | grep staging.$DOMAIN || gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=staging.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets list --zone=se-project-zone | grep production.$DOMAIN || gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=production.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets list --zone=se-project-zone | grep test.$DOMAIN || gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=test.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets list --zone=se-project-zone | grep monitoring.$DOMAIN || gcloud dns record-sets transaction add $(kubectl get services | grep 'nginx-ingress-controller' | awk '{print $4}') --name=monitoring.$DOMAIN. --ttl=300 --type=A --zone=se-project-zone
gcloud dns record-sets transaction execute --zone=se-project-zone

sed -i 's/example.com/$DOMAIN/g' values-prometheus.yml
helm upgrade --install prometheus  -f values-prometheus.yml stable/prometheus

sed -i 's/example.com/$DOMAIN/g' values-grafana.yml
helm upgrade --install grafana  -f values-grafana.yml stable/grafana



echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "Grafana admin password:"
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"
echo "##########################################################################################################"

