FROM alpine:latest
RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update \
    && apk add git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev python3 postgresql16-client@edge \
    && python3 -m ensurepip \
    && python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir b2
COPY ./backup.sh /backup.sh
COPY ./restore.sh /restore.sh
COPY ./thin.sh /thin.sh
