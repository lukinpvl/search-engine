FROM python:3.6.0-alpine

ENV MONGO mongodb
ENV MONGO_PORT 27017

WORKDIR /app
COPY . /app

RUN apk --no-cache --update add build-base && \
pip install -r /app/requirements.txt && \
apk del build-base

WORKDIR /app/ui
ENV FLASK_APP ui.py

EXPOSE 8000

ENTRYPOINT gunicorn ui:app -b 0.0.0.0
