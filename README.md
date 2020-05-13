### Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью

Приложение: https://github.com/express42/search_engine_ui/

## Подготовка инфраструктуры

Платформа: GCP, 2 GKE кластера - инфраструктурный и кластер для приложения.

##### Установка gitlab:

- Проиницилизировать gloud:
```
 gcloud init
```
- Изменить переменные при необходимости и запустить скрипт настройки кластера и установки gitlab:
```
 infra/gke-gitlab-install.sh
```

##### Установка кластера для приложения:

- Изменить переменные при необходимости и запустить скрипт настройки кластера:
```
 infra/gke-se-install.sh
```

В процессе выполнения скрипта будет установлен prometheus и grafana.

Для настойки оповещений о alert'ах в slack, необходимо изменить slack_api_url и channel в файле infra/values-prometheus.yml

Для мониторинга приложения подготовлены дашборды для grafana: search-engine-app/monitoring/ 

Prometheus доступен по адресу: http://monitoring.домен/

Grafana доступна по адресу: http://monitoring.домен/grafana


## Подготовка CI/CD
- Добавить в hosts:
```
echo "$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') gitlab.домен"
```
- Зайти в Gitlab. Логин: root. Пароль:
```
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- Создать в Gitlab группу, добавить CI/CD переменные:
```
CI_REGISTRY_USER - логин в https://hub.docker.com/
CI_REGISTRY_PASSWORD - пароль в https://hub.docker.com/
```
- Создать проекты в Gitlab:
```
cd search-engine-app/ui/
git init
git remote add origin https://gitlab.домен/имя_вашей_группы/search-engine-ui
git add .
git commit -m 'init'
git push origin master
cd ../crawler/
git init
git remote add origin https://gitlab.домен/имя_вашей_группы/search-engine-crawler
git add .
git commit -m 'init'
git push origin master
cd ../deploy/
git init
git remote add origin https://gitlab.домен/имя_вашей_группы/search-engine-deploy
git add .
git commit -m 'init'
git push origin master
```
- Сделать проекты публичными

- Добавить кластер Kubernetes в Gitlab: https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html


## Планы:
+ Добавить мониторинг
- Добавить rabbitmq и mongo exporter
- Добавить логирование
+ Добавить тестирование в деплой
+ Переделать Review (генерация правильных ссылок)
+ Добавить деплой search-engine-deploy в staging и production
+ Разобраться с DNS (автоматическое создание зоны)
-? Автоматизировать интеграцию кластера kubernetes в Gitlab?
-? Настроить работу по сертификатам
+ Добавить prehooks
+ Добавить ChatOps (реализованно в alerting)
-? Добавить создание инфраструктуры с помощью terraform
+ Причесать скрипт создания инфраструктуры

