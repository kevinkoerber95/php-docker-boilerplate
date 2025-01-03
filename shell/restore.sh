#!/usr/bin/env bash

set -o pipefail # trace ERR through pipes
set -o errtrace # trace ERR through 'time command' and other functions
set -o nounset  # set -u : exit the script if you try to use an uninitialised variable
set -o errexit  # set -e : exit the script if any statement returns a non-true return value

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.config.sh"

if [ "$#" -ne 1 ]; then
  echo "No type defined"
  exit 1
fi

mkdir -p -- "${BACKUP_DIR}"

case "$1" in
###################################
## MySQL
###################################
"mysql")
  if [[ -n "$(dockerContainerId mysql)" ]]; then
    if [ -f "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}" ]; then
      logMsg "Starting MySQL restore..."
      MYSQL_ROOT_PASSWORD=$(dockerExecMySQL printenv MYSQL_ROOT_PASSWORD)
      bzcat "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}" | dockerExecMySQL sh -c "MYSQL_PWD=\"${MYSQL_ROOT_PASSWORD}\" mysql -h mysql -uroot application"
      logMsg "Finished"
    else
      errorMsg "MySQL backup file not found"
      exit 1
    fi
  else
    echo " * skipping mysql restore, no such container"
  fi
  ;;
"postgresql")
  if [[ -n "$(dockerContainerId postgres)" ]]; then
    if [ -f "${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}" ]; then
      logMsg "Starting PostgreSQL restore..."
      POSTGRES_USER=$(dockerExecPostgres printenv POSTGRES_USER)
      POSTGRES_PASSWORD=$(dockerExecPostgres printenv POSTGRES_PASSWORD)
      POSTGRES_DB=$(dockerExecPostgres printenv POSTGRES_DB)

      bzcat "${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}" | dockerExecPostgres sh -c "PGPASSWORD=\"${POSTGRES_PASSWORD}\" psql -h postgres -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
      logMsg "Finished"
    else
      errorMsg "PostgreSQL backup file not found"
      exit 1
    fi
  else
    echo " * skipping postgresql restore, no such container"
  fi
  ;;
###################################
## Default
###################################
*)
  echo "Unsupported database type: $1"
  exit 1
  ;;
esac
