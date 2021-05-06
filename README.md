### Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью

App: https://github.com/express42/search_engine_ui/

## Preparing infrastructure

Platform: GCP, 2 GKE clusters: an infrastructure and an app cluster.

Enable CloudDNS API:

https://console.cloud.google.com/flows/enableapi?apiid=dns

##### Installing gitlab:

- Initialize gloud:
```
 gcloud init
```
- Change variables and start the script to deploy a gitlab cluster and install a gitlab app:
```
 infra/gke-gitlab-install.sh
```

##### Deploy app cluster:

- Change variables and start the script to deploy an app cluster:
```
 infra/gke-se-install.sh
```

Prometheus and grafana will be installed during script execution.

Change "slack_api_url" and "channel" in infra/values-prometheus.yml to sendings alerts to slack.

Grafana dashboards for app: search-engine-app/monitoring/ 

Prometheus URL: http://monitoring.DOMAIN/

Grafana URL: http://monitoring.DOMAIN/grafana


## Preparing CI/CD
```
echo "$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') gitlab.DOMAIN"
```
- Login to the Gitlab. Login: root. Password (use "use-context" to set the current-context to gitlab cluster):
```
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- Create a Gitlab group, add CI/CD variables:
```
CI_REGISTRY_USER - https://hub.docker.com/ login
CI_REGISTRY_PASSWORD - https://hub.docker.com/ password
```
- Create Gitlab projects:
```
cd search-engine-app/ui/
git init
git remote add origin https://gitlab.DOMAIN/YOUR_GROUP_NAME/search-engine-ui
git add .
git commit -m 'init'
git push origin master
cd ../crawler/
git init
git remote add origin https://gitlab.DOMAIN/YOUR_GROUP_NAME/search-engine-crawler
git add .
git commit -m 'init'
git push origin master
cd ../deploy/
git init
git remote add origin https://gitlab.DOMAIN/YOUR_GROUP_NAME/search-engine-deploy
git add .
git commit -m 'init'
git push origin master
```

- Add Kubernetes cluster to Gitlab: https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html


## 2do:
- Add rabbitmq and mongo exporter
- Add logging
- Automate GKE cluster and Gitlab integration?
- Configure TLS
- Add terraform to deploy infrastructure 
- Update grafana and prometheus charts (they're depricated now)

## DNS
https://my.freenom.com/
