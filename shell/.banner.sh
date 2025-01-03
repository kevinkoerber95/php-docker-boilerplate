#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

cat <<'END_CAT'
  __  __  ______  __    _ ____  ____   _  __  __  _____  ______  _____   ______  ______  _____  ______  ______
 |  |/ / |   ___|\  \  //|    ||    \ | ||  |/ / /     \|   ___||     | |      >|   ___||     ||   _  ||  ____|
 |     \ |   ___| \  \// |    ||     \| ||     \ |     ||   ___||     \ |     < |   ___||     \|____  ||___   \
 |__|\__\|______|  \__/  |____||__/\____||__|\__\\_____/|______||__|\__\|______>|______||__|\__\   |__||______/

END_CAT
