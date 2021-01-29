FROM alpine/git

RUN apk update && apk add bash

COPY . /run

ENTRYPOINT [ "/run/entrypoint.sh" ]