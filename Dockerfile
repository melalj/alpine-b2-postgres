FROM python:3.9-alpine AS build
RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update \
    && apk add git bash postgresql16-client@edge \
    && pip install --no-cache-dir b2==3.13.1
COPY ./backup.sh /backup.sh
COPY ./restore.sh /restore.sh
COPY ./thin.sh /thin.sh
