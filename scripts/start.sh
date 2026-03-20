#!/bin/bash
set -e 

KC_VERSION=$(cat ./config/KEYCLOAK_VERSION)
KC_BIN="./keycloak-${KC_VERSION}/bin/kc.sh"
DB_ARGS="--db postgres --db-url $PG_JDBC_STRING --db-username $PG_USER --db-password $PG_PASSWORD"

set +e
$KC_BIN bootstrap-admin user --username "$KC_BOOTSTRAP_ADMIN_USERNAME" --password:env KC_BOOTSTRAP_ADMIN_PASSWORD $DB_ARGS
set -e

exec $KC_BIN start \
  --proxy-headers xforwarded \
  --hostname-strict false \
  --http-port 3000 \
  --http-enabled true \
  $DB_ARGS