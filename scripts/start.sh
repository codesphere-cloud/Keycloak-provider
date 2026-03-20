#!/bin/bash
set -e 

KC_VERSION=$(cat ./config/KEYCLOAK_VERSION)
KC_BIN="./keycloak-${KC_VERSION}/bin/kc.sh"
DB_ARGS="--db postgres --db-url $PG_JDBC_STRING --db-username $PG_USER --db-password $PG_PASSWORD"
KC_IMPORT_DIR="./keycloak-${KC_VERSION}/data/import"
IMPORT_FLAG=""

if [ -n "$REALM_CONFIG" ] && [ "$REALM_CONFIG" != "null" ]; then
  REALM_NAME=$(echo "$REALM_CONFIG" | grep -o '"realm"\s*:\s*"[^"]*"' | head -n 1 | cut -d'"' -f4)

  if [ -z "$REALM_NAME" ]; then
    REALM_NAME="imported-realm"
  fi
  
  echo "$REALM_CONFIG" > "$KC_IMPORT_DIR/${REALM_NAME}.json"
  IMPORT_FLAG="--import-realm"
fi

set +e
$KC_BIN bootstrap-admin user --username "$KC_BOOTSTRAP_ADMIN_USERNAME" --password:env KC_BOOTSTRAP_ADMIN_PASSWORD $DB_ARGS
set -e

exec $KC_BIN start \
  --proxy-headers xforwarded \
  --hostname-strict false \
  --http-port 3000 \
  --http-enabled true \
  $IMPORT_FLAG \
  $DB_ARGS