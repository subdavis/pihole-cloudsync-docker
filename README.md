# Docker Pi Hole Cloudsync

Docker images that contain the excellent [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync) scripts. This project exists because...

* I hate manual configuration.
* I want the reliability and statelessness of Docker.

Currently, only **Primary/Secondary** and **All Secondary** modes are supported.  **Shared Hosts are not supported.**  If you set up DNS correctly, you shouldn't need it anyway.

## Docker Hub Images

**Important**: Because of [pihole/pihole-docker issue #587](https://github.com/pi-hole/docker-pi-hole/issues/587) some of the regular pihole/pihole docker images are broken.  You must use the correct tag for your architecture.

These images are based on the respective arch builds of `pihole/pihole:master-{arch}`.  Others could be supported

* Pi 2 (armv6): `subdavis/pihole-cloudsync:armel`
* Pi 3 (armv7): `subdavis/pihole-cloudsync:armhf`
* Pi 4 (armv8): `subdavis/pihole-cloudsync:arm64`
* Linux 64 bit: `subdavis/pihole-cloudsync:amd64`

[Get subdavis/pihole-cloudsync on Docker Hub](https://hub.docker.com/r/subdavis/pihole-cloudsync).

## Setup

This project forces security best practices.  You will need the following.

1. A brand-new, empty github repo called `pihole-lists`.  Contents of this repo will overwrite pihole defaults, but missing files with be initialized by pihole.
1. An SSH keypair, added to your git account.  **Username/Password auth is not supported**.

```bash
ssh-keygen ~/.ssh/pihole
```

* Put the `~/.ssh/pihole.pub` public key into your git repo account.
* Put the `~/.ssh/pihole` private key into the docker command below.

## Run

This image takes all the same environment vars, volumes, and config as the regular `pihole/pihole` image.  All the configuration listed below is **in addition to** the regular pihole docker options.

### Environment Config

| Variable | Default | Description |
|----------|---------|-------------|
| GIT_SERVER | github.com | where the git repo is hosted |
| GIT_REPO | | repo name, formatted `username/reponame` |
| GIT_USER | | username for git push/pull ops |
| GIT_EMAIL | | email for push/pull ops |
| CLOUDSYNC_TYPE | pull | Primary pi should be "push", all others should be "pull" |

### Volumes

Must use a docker bind mount to put your SSH key in place.

* Syntax is `--volume /path/to/keyname:/root/.ssh/id_rsa`
* Key name inside container must be the default ssh key name, for example `id_rsa`, `id_ecdsa`, `id_dsa`, etc.

### Primary Pi Hole Example

Primary Pi Hole pushes its configuration directly to a git repository any time its gravity or lists change.  This is automated, and happens whenever you click "save" within the UI.

``` bash
# Provide the details of your github repo with this config.
# Running this container will initialize the repo with the
# contents of it's new or existing /etc/pihole config files
docker run --rm -it --name pihole \
  --publish "53:53/udp" \
  --publish "53:53" \
  --publish "67:67/udp" \
  --publish "80:80" \
  --env GIT_SERVER="github.com" \
  --env GIT_REPO="changeme/pihole-lists" \
  --env GIT_USER="changeme" \
  --env GIT_EMAIL="changeme@domain.com" \
  --env CLOUDSYNC_TYPE="push" \
  --volume "/home/changeme/.ssh/pihole:/root/.ssh/id_rsa" \
  subdavis/pihole-cloudsync:changeme
```

> **NOTE:**: if you want to have all secondary servers and no primary, run this once to populate your repository then edit your config files with a normal text exitor.

### Secondary Pi Hole(s) Example

Secondary Pi Holes will pull their configuration from the primary.  They pull on a timer and will update gravity whenever there's a change fromm Git.

cron schedule defaults to "15 minutes past the hour every hour".  Visit [crontab guru](https://crontab.guru/) if you need help making a differnt schedule.

``` bash
# Start your secondary servers after you've initialized
# your repo with the primary.
docker run --rm -it --name pihole \
  --publish "53:53/udp" \
  --publish "53:53" \
  --publish "67:67/udp" \
  --publish "80:80" \
  --env GIT_SERVER="github.com" \
  --env GIT_REPO="changeme/pihole-lists" \
  --env GIT_USER="changeme" \
  --env GIT_EMAIL="changeme@domain.com" \
  --env CLOUDSYNC_TYPE="pull" \
  --env CRON_SCHEDULE="15 * * * *" \
  --volume "/home/changeme/.ssh/pihole:/root/.ssh/id_rsa" \
  subdavis/pihole-cloudsync:changeme
```
