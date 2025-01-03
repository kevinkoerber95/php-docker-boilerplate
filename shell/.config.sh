#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

#######################################
## Configuration
#######################################

READLINK='readlink'
unamestr=`uname`
if [ "$unamestr" == 'FreeBSD' -o "$unamestr" == 'Darwin'  ]; then
  READLINK='greadlink'
fi

if [ -z "`which $READLINK`" ]; then
    echo "[ERROR] $READLINK not installed"
    echo "        make sure coreutils are installed"
    echo "        MacOS: brew install coreutils"
    exit 1
fi

SCRIPT_DIR=$(dirname "$($READLINK -f "$0")")
ROOT_DIR=$($READLINK -f "$SCRIPT_DIR/../")

BACKUP_DIR=$($READLINK -f "$ROOT_DIR/backup")
PUBLIC_DIR="$ROOT_DIR/public"
BACKUP_MYSQL_FILE='mysql.sql.bz2'

### ANSI color escape codes
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

#######################################
## Functions
#######################################

errorMsg() {
	echo -e "${RED}[ERROR] $* ${NC}"
}

infoMsg() {
  echo -e "${YELLOW}[INFO] $* ${NC}"
}

successMsg() {
  echo -e "${GREEN}[SUCCESS] $* ${NC}"
}

logMsg() {
	echo " * $*"
}

sectionHeader() {
	echo "*** $* ***"
}

execInDir() {
    echo "[RUN :: $1] $2"

    sh -c "cd \"$1\" && $2"
}

dockerContainerId() {
    if [[ $OSTYPE == "linux-gnu"* ]]; then
	CONTAINER_NAME="${COMPOSE_PROJECT_NAME}_$1_1"
    else
	CONTAINER_NAME="${COMPOSE_PROJECT_NAME}-$1-1"
    fi

    echo "$(docker ps -aqf name=$CONTAINER_NAME)"
}

dockerExec() {
    docker exec -i "$(dockerContainerId app)" "$@"
}

dockerExecProd() {
  docker exec -i -e APP_ENV=prod "$(dockerContainerId app)" "$@"
}

dockerExecUser() {
    docker exec -i -u application "$(dockerContainerId app)" "$@"
}

dockerExecMySQL() {
    docker exec -i "$(dockerContainerId mysql)" "$@"
}

dockerCopyFrom() {
    PATH_DOCKER="$1"
    PATH_HOST="$2"
    docker cp "$(dockerContainerId app):${PATH_DOCKER}" "${PATH_HOST}"
}

dockerCopyTo() {
    PATH_HOST="$1"
    PATH_DOCKER="$2"
    docker cp "${PATH_HOST}" "$(dockerContainerId app):${PATH_DOCKER}"
}
