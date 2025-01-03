#!/usr/bin/env bash

set -o pipefail # trace ERR through pipes
set -o errtrace # trace ERR through 'time command' and other functions
set -o nounset  ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit  ## set -e : exit the script if any statement returns a non-true return value

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.config.sh"

if [ "$#" -ne 1 ]; then
  echo "No type defined"
  exit 1
fi

mkdir -p -- "${BACKUP_DIR}"

case "$1" in
#######################################
## MySQL
#######################################
"mysql")
  if [[ -n "$(dockerContainerId mysql)" ]]; then
    if [ -f "${BACKUP_DIR}/${BACKUP_MYSQL_FILE}" ]; then
      logMsg "Removing old backup file..."
      rm -f -- "$${BACKUP_DIR}/${BACKUP_MYSQL_FILE}"
    fi
    MYSQL_ROOT_PASSWORD=$(dockerExecMySQL printenv MYSQL_ROOT_PASSWORD)
    dockerExecMySQL sh -c "MYSQL_PWD=\"${MYSQL_ROOT_PASSWORD}\" mysqldump -h mysql -uroot --opt --single-transaction --events --routines --comments application" | bzip2 >"${BACKUP_DIR}/${BACKUP_MYSQL_FILE}"
    logMsg "Finished"
    logMsg "You can find your backup file under: ${BACKUP_DIR}/${BACKUP_MYSQL_FILE}"
  else
    echo " * Skipping mysql backup, no such container"
  fi
  ;;
"postgresql")
  if [[ -n "$(dockerContainerId postgres)" ]]; then
    if [ -f "${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}" ]; then
      logMsg "Removing old backup file..."
      rm -f -- "${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}"
    fi
    POSTGRES_USER=$(dockerExecPostgres printenv POSTGRES_USER)
    POSTGRES_PASSWORD=$(dockerExecPostgres printenv POSTGRES_PASSWORD)
    POSTGRES_DB=$(dockerExecPostgres printenv POSTGRES_DB)

    dockerExecPostgres sh -c "PGPASSWORD=\"${POSTGRES_PASSWORD}\" pg_dump -h postgres -U ${POSTGRES_USER} ${POSTGRES_DB}" | bzip2 >"${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}"
    logMsg "Finished"
    logMsg "You can find your backup file under: ${BACKUP_DIR}/${BACKUP_POSTGRES_FILE}"
  else
    echo " * Skipping postgresql backup, no such container"
  fi
  ;;
*)
  echo "Unsupported database type: $1"
  exit 1
  ;;
esac
