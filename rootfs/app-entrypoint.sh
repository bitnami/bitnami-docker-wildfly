#!/bin/bash
set -e

if [[ "$1" == "harpoon" && "$2" == "start" ]]; then
  status=`harpoon inspect $BITNAMI_APP_NAME`
  if [[ "$status" == *'"lifecycle": "unpacked"'* ]]; then
    harpoon initialize $BITNAMI_APP_NAME --username ${WILDFLY_USER:-manager} --password ${WILDFLY_PASSWORD:-password}
  fi

fi

# HACKS

if [ ! -d /bitnami/$BITNAMI_APP_NAME/conf ]; then
  cp -a /opt/bitnami/$BITNAMI_APP_NAME/conf /bitnami/$BITNAMI_APP_NAME/conf
fi
rm -rf /opt/bitnami/$BITNAMI_APP_NAME/conf
ln -sf /bitnami/$BITNAMI_APP_NAME/conf /opt/bitnami/$BITNAMI_APP_NAME/conf

if [ ! -d /bitnami/$BITNAMI_APP_NAME/standalone ]; then
  cp -a /opt/bitnami/$BITNAMI_APP_NAME/standalone /bitnami/$BITNAMI_APP_NAME/standalone
fi
rm -rf /opt/bitnami/$BITNAMI_APP_NAME/standalone
ln -sf /bitnami/$BITNAMI_APP_NAME/standalone /opt/bitnami/$BITNAMI_APP_NAME/standalone

## END OF HACKS

chown $BITNAMI_APP_USER: /bitnami/$BITNAMI_APP_NAME || true

exec /entrypoint.sh "$@"
