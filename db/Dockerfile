FROM postgres:alpine

ARG INIT_DIR=/docker-entrypoint-initdb.d
RUN mkdir -p $INIT_DIR
COPY ./init/ $INIT_DIR
