#!/usr/bin/sh

if [[ -z "$1" ]]
then
  echo "missing pushbullet Access-token";
  exit 1;
fi

if [[ -z "$2" ]]
then
  echo "missing pushbullet device identification... sending to all...";
fi

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH"/httpdocs"

LINECOUNT=`git diff --name-only | wc -l`

if [[ $LINECOUNT -gt 0 ]]
then

  echo "Modified Files : " > $SCRIPTPATH"/tmp_mail_log.txt"

  MODIFIEDFILES=`git diff --name-only`

  echo $MODIFIEDFILES >> $SCRIPTPATH"/tmp_mail_log.txt"

  echo "Untracked files : " >> $SCRIPTPATH"/tmp_mail_log.txt"

  git ls-files --exclude-standard --others >> $SCRIPTPATH"/tmp_mail_log.txt"

  DATE=`date +%Y-%m-%d`

  mail -s "git reset logs from website "$DATE "the_email@domain.noop" < $SCRIPTPATH"/tmp_mail_log.txt"

  curl --header "Access-Token: $1" \
       --header 'Content-Type: application/json' \
       --data-binary "{\"device_iden\":\"$2\",\"body\":\"$MODIFIEDFILES\",\"title\":\"Conso\",\"type\":\"note\"}" \
       --request POST \
       https://api.pushbullet.com/v2/pushes

  git reset --hard HEAD

fi
