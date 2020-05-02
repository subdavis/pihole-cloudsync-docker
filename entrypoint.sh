#!/bin/bash
set -e

# Verify environment vars
[ -z $GIT_SERVER ] && echo "Environment var GIT_SERVER is required." && exit 1
[ -z $GIT_REPO ] && echo "Environment var GIT_REPO is required." && exit 1
[ -z $GIT_USER ] && echo "Environment var GIT_USER is required." && exit 1
[ -z $GIT_EMAIL ] && echo "Environment var GIT_EMAIL is required." && exit 1
[ -z $CLOUDSYNC_TYPE ] && echo "Environment var CLOUDSYNC_TYPE is required." && exit 1

# Configure git
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# Clone with ssh
git clone "git@${GIT_SERVER}:${GIT_REPO}" "my-pihole-lists"

# Init
/usr/local/bin/pihole-cloudsync/pihole-cloudsync --initpull
/usr/local/bin/pihole-cloudsync/pihole-cloudsync --pull

# command to run on update
cloudsync_command="/usr/local/bin/pihole-cloudsync/pihole-cloudsync --${CLOUDSYNC_TYPE}"

if [ "${CLOUDSYNC_TYPE}" == "push" ]; then
  echo "Trigger PUSH after gravity or lists are updated"
  /usr/local/bin/pihole-cloudsync/pihole-cloudsync --initpush
  gravity_insert_before_line='"${PIHOLE_COMMAND}" status'
  sed -i "/$gravity_insert_before_line/$cloudsync_command\n$gravity_insert_before_line/" /opt/pihole/gravity.sh
  echo "${cloudsync_command}" >> /opt/pihole/list.sh
elif [ "${CLOUDSYNC_TYPE}" == "pull" ]; then
  [ -z $PULL_INTERVAL ] && echo "Environment var PULL_INTERVAL is required." && exit 1
  echo "Trigger PULL on a timer and before updates"
else
  echo "Environment var CLOUDSYNC_TYPE must be one of 'push', 'pull'" && exit 1
fi

exec /s6-init
