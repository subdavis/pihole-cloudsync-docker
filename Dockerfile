FROM docker.io/pihole/pihole:latest

RUN apt-get update && apt-get install ssh gettext-base -qy

ENV GIT_SERVER="github.com"
ENV CLOUDSYNC_TYPE="push"
ENV PULL_INTERVAL="1h"

WORKDIR /usr/local/bin

RUN git clone https://github.com/stevejenkins/pihole-cloudsync
COPY entrypoint.sh /usr/local/bin/cloudsync-entrypoint.sh

RUN mkdir $HOME/.ssh && echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> $HOME/.ssh/config

ENTRYPOINT [ "/usr/local/bin/cloudsync-entrypoint.sh" ]
