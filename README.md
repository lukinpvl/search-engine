### Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью

Приложение: https://github.com/express42/search_engine_ui/

##Подготовка инфраструктуры

Платформа: GCP, 2 GKE кластера - инфраструктурный и кластер для приложения.

#####Установка gitlab: 
- Добавить зону se-engine.tk в Cloud DNS (автоматизирую)

- Проиницилизировать gloud: 
```
 gcloud init
```
- Запустить скрипт настройки кластера и установки gitlab:
```
 infra/gke-gitlab-install.sh
```

#####Установка кластера для приложения:

- Запустить скрипт настройки кластера:
```
 infra/gke-se-install.sh
```

##Подготовка CI/CD
- Добавить в hosts:
```
echo "$(gcloud compute addresses list | grep 'gitlab-cluster-external-ip' | awk '{print $2}') gitlab.se-project.tk"
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
git remote add origin https://gitlab.se-project.tk/имя_вашей_группы/search-engine-ui
git add .
git commit -m 'init'
git push origin master
cd ../crawler/ 
git init
git remote add origin https://gitlab.se-project.tk/имя_вашей_группы/search-engine-crawler
git add .
git commit -m 'init'
git push origin master
cd ../deploy/ 
git init
git remote add origin https://gitlab.se-project.tk/имя_вашей_группы/search-engine-deploy
git add .
git commit -m 'init'
git push origin master
```

- Добавить кластер Kubernetes в Gitlab: https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html 

##Планы:
- Добавить мониторинг и логирование
- Добавить тестирование
- Перделать Review (генерация правильных ссылок)
- Добавить деплой search-engine-deploy в staging и production
- Разобраться с DNS (автоматическое создание зоны)
- Автоматизировать интеграцию кластера kubernetes в Gitlab?
- Настроить работу по сертификатам
- Добавить prehooks
- Добатиь ChatOps
- Добавить создание инфраструктуры с помощью terraform
- Причесать скрипт создания инфраструктуры



