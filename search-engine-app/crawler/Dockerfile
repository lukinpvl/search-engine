FROM python:3.6.0-alpine

ENV MONGO mongodb
ENV MONGO_PORT 27017

WORKDIR /app
COPY . /app

RUN apk --no-cache --update add build-base && \
pip install -r /app/requirements.txt && \
apk del build-base

ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE rmq_queue
ENV RMQ_USERNAME guest
ENV RMQ_PASSWORD guest
ENV CHECK_INTERVAL 60 
ENV EXCLUDE_URLS '.*github.com'
ENV URL 'https://vitkhab.github.io/search_engine_test_site/'

#ENTRYPOINT ["python3", "crawler/crawler.py", "$URL"]
ENTRYPOINT python3 crawler/crawler.py $URL
