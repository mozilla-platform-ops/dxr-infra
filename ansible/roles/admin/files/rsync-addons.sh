#!/bin/sh

LOCKFILE="/tmp/rsync-addons-dxr.lock"
AMOADMIN="opsadmin.amo.us-west-2.prod.mozaws.net"
LOGFILE="$HOME/log/rsync-dxr.log"

(
  flock -x -w 10 200 || exit 1
  rsync -avz -e ssh --delete -f '- temp/' --delete-before $AMOADMIN:/data/addons/ /data/dxr_data/addons/addons 2>&1 >> $LOGFILE
) 200>$LOCKFILE
