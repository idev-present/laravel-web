#!/usr/bin/env bash
set -e

# Env variables
ERRORS=0

echo "### STEP: 1/4 -- Check env variables"

if [[ -z ${MYSQL_DATABASE} ]]; then
  echo "ERROR: Missing MYSQL_DATABASE env variable"
  ERRORS=$((ERRORS + 1))
fi

if [[ -z ${MYSQL_USER} ]]; then
  echo "ERROR: Missing MYSQL_USER env variable"
  ERRORS=$((ERRORS + 1))
fi

if [[ -z ${MYSQL_PASSWORD} ]]; then
  echo "ERROR: Missing MYSQL_PASSWORD env variable"
  ERRORS=$((ERRORS + 1))
fi

if [[ -z ${MYSQL_HOST} ]]; then
  echo "ERROR: Missing MYSQL_HOST env variable"
  ERRORS=$((ERRORS + 1))
fi

if [[ -z ${MYSQL_PORT} ]]; then
  echo "ERROR: Missing MYSQL_PORT env variable"
  ERRORS=$((ERRORS + 1))
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "DANGER: There are ${ERRORS} errors. See the console above. Exiting..."
    exit 1
fi
echo "### Ok"

# Check connect to Database
echo "### STEP: 2 -- Check connect to Database"
database_ready(){
TERM=dumb php -- <<'EOPHP'
<?php
$host = getenv("MYSQL_HOST");
$port = getenv("MYSQL_PORT");
$dbName = getenv("MYSQL_DATABASE");
$dbUser = getenv("MYSQL_USER");
$pass = getenv("MYSQL_PASSWORD");

$mysql = new mysqli($host, $dbUser, $pass, $dbName, $port);
if ($mysql->connect_error) {
    $mysql->close();
    exit(1);
}
$mysql->close();
exit(0);
EOPHP
}

until database_ready; do
  >&2 echo 'Waiting for connecting database...'
  sleep 3
done
echo "### Ok"

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "URL: http://${DOMAIN_NAME}"
echo ""
echo "================================================================="
exec "$@"
