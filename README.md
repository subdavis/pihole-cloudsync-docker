# Docker Pi Hole Cloudsync

Docker images that contain the excellent [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync) scripts. This project exists because...

* I hate manual configuration.  I hate it.
* I want the reliability and statelessness of Docker.

Currently, only **Primary/Secondary** and **All Secondary** modes are supported.  **Shared Hosts are not supported.**  If you set up DNS correctly, you shouldn't need it anyway.

## Setup

This project forces security best practices.  You will need the following.

1. A git repo from the [stevejenkins/my-pihole-lists/generate](https://github.com/stevejenkins/my-pihole-lists/generate) template.
1. An SSH keypair, added to your git account.  **Username/Password auth will never be supported**.

```bash
ssh-keygen ~/.ssh/pihole-cloudsync
```

* Put the `~/.ssh/pihole-cloudsync.pub` public key into your git repo account.
* Put the `~/.ssh/pihole-cloudsync` private key into the docker command below.

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

### Primary Pi Hole

Primary Pi Hole pushes its configuration directly to a git repository any time its gravity or lists change.  This is automated, and happens whenever you click "save" within the UI.

``` bash
docker run --rm -it --name pihole \
  --env GIT_SERVER="github.com" \
  --env GIT_REPO="subdavis/pihole-lists" \
  --env GIT_USER="subdavis" \
  --env GIT_EMAIL="git@subdavis.com" \
  --env CLOUDSYNC_TYPE="push" \
  --volume /home/brandon/.ssh/pihole:/root/.ssh/id_ecdsa \
  subdavis/pihole-cloudsync
```

### Secondary Pi Hole(s)

Secondary Pi Holes will pull their configuration from the primary.  They pull on a timer and will update gravity whenever there's a change fromm Git.

``` bash
docker run --rm -it --name pihole \
  --env GIT_SERVER="github.com" \
  --env GIT_REPO="subdavis/pihole-lists" \
  --env GIT_USER="subdavis" \
  --env GIT_EMAIL="git@subdavis.com" \
  --env CLOUDSYNC_TYPE="push" \
  --volume "/home/brandon/.ssh/pihole:/root/.ssh/id_ecdsa" \
  subdavis/pihole-cloudsync
```

## Building the image

If you don't want to use my pre-built image from Docker Hub, you can build it yourself.

```
docker build -t subdavis/pihole-cloudsync .
```
