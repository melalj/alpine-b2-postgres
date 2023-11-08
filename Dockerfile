FROM alpine:latest AS build
RUN apk update \
    && apk add git python3 mongodb-tools \
    && python3 -m ensurepip \
    && python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir b2
