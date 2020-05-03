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

# Fetch latest changes from remote
/usr/local/bin/pihole-cloudsync/pihole-cloudsync --initpull
/usr/local/bin/pihole-cloudsync/pihole-cloudsync --pull

# command to run on update
cloudsync_command="/usr/local/bin/pihole-cloudsync/pihole-cloudsync --${CLOUDSYNC_TYPE}"

if [ "${CLOUDSYNC_TYPE}" == "push" ]; then
  echo "Trigger PUSH after gravity or lists are updated"
  /usr/local/bin/pihole-cloudsync/pihole-cloudsync --initpush
  # insert before the second-to-last line in the gravity script
  gravity_linecount=$(wc -l /opt/pihole/gravity.sh | cut -d ' ' -f1)
  insert_line=$(expr ${gravity_linecount} - 2)
  sed -i "${insert_line}i\\${cloudsync_command}" /opt/pihole/gravity.sh
  echo "${cloudsync_command}" >> /opt/pihole/list.sh
elif [ "${CLOUDSYNC_TYPE}" == "pull" ]; then
  [ -z $CRON_SCHEDULE ] && echo "Environment var CRON_SCHEDULE is required." && exit 1
  echo "Trigger PULL on a timer and before updates"
  echo "Pull schedule is crontab: ${CRON_SCHEDULE}"
  # Luckily cron is already run and managed by pihole! Use existing crontab
  echo "# Injected cron update schedule from pihole-cloudsync-docker" >> /etc/cron.d/pihole
  echo "${CRON_SCHEDULE} root ${cloudsync_command}" >> /etc/cron.d/pihole
else
  echo "Environment var CLOUDSYNC_TYPE must be one of 'push', 'pull'" && exit 1
fi

exec /s6-init
